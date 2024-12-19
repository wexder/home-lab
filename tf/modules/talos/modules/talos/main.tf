terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0"
    }
  }
}

resource "proxmox_vm_qemu" "cloudinit" {
  for_each    = var.nodes
  name        = "talos-tf-${each.key}"
  desc        = "Talos created by terraform"
  target_node = each.value.target_node
  clone       = "talos-1.6-cloud"
  qemu_os     = "other"
  boot        = "order=scsi0;ide2"
  # agent       = 0
  # iso         = "local:iso/talos-1.6.iso"
  # The destination resource pool for the new VM
  # pool = "pool0"

  cores   = each.value.cores
  sockets = 1
  memory  = each.value.memory

  disks {
    virtio {
      virtio0 {
        disk {
          storage = "hdd"
          size    = 50
          backup  = false
        }
      }
    }

    scsi {
      scsi0 {
        disk {
          backup  = true
          format  = "qcow2"
          storage = "local"
          size    = 2
        }
      }
    }
  }

  network {
    bridge    = "vmbr0"
    firewall  = false
    link_down = false
    model     = "virtio"
  }

  tags = "private;talos"


  vga {
    type   = "std"
    memory = 16
  }

  os_type                 = "cloud-init"
  cloudinit_cdrom_storage = "local"
  ipconfig0               = "ip=${each.value.ip}/24,gw=192.168.1.1"
}

resource "talos_machine_secrets" "this" {
  talos_version = "v1.6.7"
}

data "talos_machine_configuration" "this" {
  for_each           = var.nodes
  cluster_name       = "private-cluster"
  machine_type       = each.value.machine_type
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = "1.29.2"
  talos_version      = "v1.6.7"
}

data "talos_client_configuration" "this" {
  for_each             = var.nodes
  cluster_name         = "private-cluster"
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for n in var.nodes : n.ip]
}

resource "talos_machine_configuration_apply" "this" {
  for_each = var.nodes
  depends_on = [
    proxmox_vm_qemu.cloudinit
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.value.ip
  config_patches = [
    yamlencode({
      machine = {
        kubelet = {
          extraArgs = {
            # rotate-server-certificates = true
          },
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
            "192.168.1.53",
            # "8.8.8.8",
          ],
          interfaces = [
            # {
            #   interface = "eth0",
            #   # dhcp      = true,
            #   addresses = [
            #     each.value.ip,
            #   ],
            #   vip = {
            #     ip = each.value.vip
            #   },
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
            # {
            #   image = "ghcr.io/siderolabs/qemu-guest-agent:8.2.2"
            # },
            {
              image = "ghcr.io/siderolabs/iscsi-tools:v0.1.4"
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
        proxy = {
          disabled = true,
        },
        network = {
          cni = {
            name = "none",
          },
        },
        # allowSchedulingOnControlPlanes = true,
        extraManifests = [
          # "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
          # "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml",
        ],
      },
    })
  ]
}


resource "talos_machine_bootstrap" "this" {
  count = length(var.nodes) >= 1 ? 1 : 0
  depends_on = [
    talos_machine_configuration_apply.this,
    proxmox_vm_qemu.cloudinit
  ]
  endpoint             = length(var.nodes) >= 1 ? [for n in var.nodes : n.ip][0] : ""
  node                 = length(var.nodes) >= 1 ? [for n in var.nodes : n.ip][0] : ""
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_cluster_kubeconfig" "this" {
  count = length(var.nodes) >= 1 ? 1 : 0
  depends_on = [
    talos_machine_configuration_apply.this,
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = length(var.nodes) >= 1 ? [for n in var.nodes : n.ip][0] : ""
}

