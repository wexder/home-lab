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

provider "proxmox" {
  pm_api_url          = "http://192.168.1.240:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform_test"
  pm_api_token_secret = "d638ac3f-fb12-4979-92b2-5fadf0f5f585"
  pm_tls_insecure     = true
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
  # current config is not HA enabled
  # will probably need KubeSpan
  node_ips = [
    "192.168.1.210",
    "192.168.1.211",
    # "192.168.1.212",
  ]

  nodes = {
    anakin = {
      ip     = "192.168.1.210"
      vip    = "192.168.1.68"
      cores  = 2
      memory = 8192
      # memory = 12288
    }
    # current config is not HA enabled
    # will probably need KubeSpan
    #
    # luke = {
    #   ip     = "192.168.1.211"
    #   vip    = "192.168.1.68"
    #   cores  = 2
    #   memory = 4096
    #   # memory = 12288
    # }
    #
    # obiwan = {
    #   ip     = "192.168.1.212"
    #   vip    = "192.168.1.68"
    #   cores  = 2
    #   memory = 4096
    #   # memory = 12288
    # }
  }
}
