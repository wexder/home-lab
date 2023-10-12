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

module "talos_nodes" {
  source = "./modules/talos"
  providers = {
    proxmox = proxmox
    talos   = talos
  }

  cluster_endpoint = "https://192.168.1.190:6443"

  nodes = {
    anakin = {
      ip     = "192.168.1.190"
      cores  = 4
      memory = 8168
      # memory = 12288
    }
  }
}
