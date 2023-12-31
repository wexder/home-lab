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
  # iso         = "local:iso/talos-1.6.iso"

  # The destination resource pool for the new VM
  # pool = "pool0"

  cores   = each.value.cores
  sockets = 1
  memory  = each.value.memory

  disk {
    storage = "hdd"
    size    = "20G"
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

  os_type   = "cloud-init"
  ipconfig0 = "ip=${each.value.ip}/24,gw=192.168.1.1"
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  cluster_name       = "private-cluster"
  machine_type       = "controlplane"
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = "1.28.3"
  talos_version      = "v1.6"
}

data "talos_client_configuration" "this" {
  for_each             = var.nodes
  cluster_name         = "private-cluster"
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = var.node_ips
}

resource "talos_machine_configuration_apply" "this" {
  for_each = var.nodes
  depends_on = [
    proxmox_vm_qemu.cloudinit-test
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = each.value.ip
  config_patches = [
    yamlencode({
      machine = {
        kubelet = {
          extraMounts = [
            {
              destination = "/var/local/etc/iscsi",
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
            "192.168.1.52",
            "8.8.8.8",
          ],
          interfaces = [
                # {
                #     interface= "eth0",
                #     dhcp = true,
                #     vip = {
                #         ip = each.value.vip
                #     },
                # },
          ]
        },
        features = {
          kubePrism = {
            enabled = true,
            port    = 7445,
          }
        },
        install = {
          disk = "/dev/vda"
          extensions = [
            {
              image = "ghcr.io/siderolabs/iscsi-tools:v0.1.1"
            },
            ]
        },
      },
      cluster = {
        discovery = {
          enabled = true,
          registries = {
            kubernetes = {
              disabled = true,
            },
            service = {},
          },
        },
        # network = {
        #   cni = {
        #     name = "none",
        #   }
        # },
        allowSchedulingOnControlPlanes = true,
      },
    })
  ]
}


resource "talos_machine_bootstrap" "this" {
  for_each = var.nodes
  depends_on = [
    talos_machine_configuration_apply.this,
    proxmox_vm_qemu.cloudinit-test
  ]
  node                 = each.value.ip
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_cluster_kubeconfig" "this" {
  for_each = var.nodes
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = each.value.ip
}

