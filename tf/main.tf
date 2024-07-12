terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }

    truenas = {
      source  = "dariusbakunas/truenas"
      version = "0.11.1"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
  }
}

provider "talos" {}

provider "proxmox" {
  pm_api_url          = "http://192.168.1.240:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform_test"
  pm_api_token_secret = "d638ac3f-fb12-4979-92b2-5fadf0f5f585"
  pm_tls_insecure     = true
}

provider "truenas" {
  api_key  = "1-rsGI3oqBN7pYchW0Bcjf66Y9h1P95O2AafT6d98vLoFuerPFnjwyh7KsWgIvGQRG"
  base_url = "http://192.168.1.112/api/v2.0"
}

module "nas" {
  source = "./modules/nas"
  providers = {
    truenas = truenas
  }
}

module "talos" {
  source = "./modules/talos"
  providers = {
    proxmox = proxmox
    talos   = talos
  }
}
