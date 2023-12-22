terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0-alpha.0"
    }
  }
}

resource "proxmox_vm_qemu" "cloudinit-test" {
  for_each    = var.nodes
  name        = "talos-tf-${each.key}"
  desc        = "Talos created by terraform"
  target_node = "hoth"
  clone       = "talos-cloud"
  qemu_os     = "other"
  iso         = "local:iso/talos-1.6.iso"

  cores   = 1
  sockets = 1
  memory  = 1

  disk {
    storage = "hdd"
    size    = "15G"
    type    = "virtio"
    backup  = false
  }

  tags = "talos;private"


  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  vga {
    type   = "std"
    memory = 16
  }
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  cluster_name       = "private-cluster"
  machine_type       = "controlplane"
  cluster_endpoint   = var.ip
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = "1.28.3"
  talos_version      = "v1.6"
}

data "talos_client_configuration" "this" {
  cluster_name         = "private-cluster"
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = var.ip
}

resource "talos_machine_configuration_apply" "this" {
  depends_on = [
    proxmox_vm_qemu.cloudinit-test
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  nodE                        = var.ip
  config_patches = [
    yamlencode({
      machine = {
        kubelet = {
          extraMounts = [
            {
              destination = "/usr/local/etc/iscsi",
              type        = "bind",
              source      = "/var/local/etc/iscsi",
              options = [
                "bind",
                "rshared",
                "rw",
              ]
            },
          ]
        },
        network = {
          nameservers = [
            "8.8.8.8",
          ],
        },
        install = {
          disk = "/dev/vda"
          extensions = [
            {
              image = "ghcr.io/siderolabs/iscsi-tools:v0.1.1"
            },
            {
                image = "ghcr.io/siderolabs/qemu-guest-agent:8.1.3"
            },
            ]
        },
      },
    })
  ]
}


resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this,
    proxmox_vm_qemu.cloudinit-test
  ]
  node                 = var.ip
  client_configuration = talos_machine_secrets.this.client_configuration
}
