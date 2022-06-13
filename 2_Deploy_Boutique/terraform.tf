terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    intersight = {
      source  = "ciscodevnet/intersight"
    }
    local = {
      source  = "hashicorp/local"
    }
  }
}

provider "kubernetes" {
  config_path    = "./kubeconfig.yaml"
}

provider "intersight" {
  apikey    = var.intersight_api_key
  secretkey = base64decode(var.intersight_secretkey_b64)
  endpoint  = "https://intersight.com"
}


