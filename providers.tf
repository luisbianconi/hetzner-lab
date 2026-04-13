terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.60.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}