terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "~> 5"
    }
  }

  cloud {
    organization = "hashiathome"
    workspaces {
      name  = "consul-ca"
    }
  }
}
