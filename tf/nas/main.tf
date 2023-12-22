terraform {
  required_providers {
    truenas = {
      source  = "dariusbakunas/truenas"
      version = "0.11.1"
    }
  }
}

provider "truenas" {
  api_key = "1-rsGI3oqBN7pYchW0Bcjf66Y9h1P95O2AafT6d98vLoFuerPFnjwyh7KsWgIvGQRG"
  # base_url = "http://nas.tailcceac.ts.net/api/v2.0"
  base_url = "http://192.168.1.112/api/v2.0"
}

