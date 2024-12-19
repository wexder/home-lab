terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
  }
}


# module "talos_template" {
#   source = "./modules/template"
#   providers = {
#     proxmox = proxmox
#     talos   = talos
#   }
#
#   ip = "192.168.1.190"
# }

# this is currently little bit broken. You have to apply it two times.
# first with cni enabled
# second with cni set to none
module "talos_nodes" {
  source = "./modules/talos"
  providers = {
    proxmox = proxmox
    talos   = talos
  }

  cluster_endpoint = "https://192.168.1.210:6443"
  # cluster_endpoint = "https://talos-private.lan:6443"
  # current config is not HA enabled
  # will probably need KubeSpan

  nodes = {
    anakin = {
      ip          = "192.168.1.210"
      target_node = "hoth"
      vip         = "192.168.1.68"
      cores       = 4
      # memory       = 16384
      memory       = 4096
      machine_type = "controlplane"
    }

    # luke = {
    #   ip           = "192.168.1.211"
    #   target_node  = "hoth"
    #   vip          = "192.168.1.68"
    #   cores        = 2
    #   memory       = 2048
    #   machine_type = "controlplane"
    # }
    #
    # obiwan = {
    #   ip           = "192.168.1.212"
    #   target_node  = "hoth"
    #   vip          = "192.168.1.68"
    #   cores        = 2
    #   memory       = 2048
    #   machine_type = "controlplane"
    #   # memory = 12288
    # }

    leia = {
      ip           = "192.168.1.213"
      target_node  = "hoth"
      vip          = "192.168.1.68"
      cores        = 2
      # memory       = 4096 * 2
      memory = 12288
      machine_type = "worker"
    }
  }
}
