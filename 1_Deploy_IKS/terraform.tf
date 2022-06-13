terraform {
  required_providers {
    intersight = {
      source  = "ciscodevnet/intersight"
    }
  }
}

########### Providers ###########
provider "intersight" {
  apikey    = local.creds.intersight_api_key
  secretkey = base64decode(local.creds.intersight_secretkey_b64)
  endpoint  = "https://intersight.com"
}

########### Locals ###########
locals {
  model = yamldecode(file("variables.yml"))
  creds = yamldecode(file("creds.yml"))
}
