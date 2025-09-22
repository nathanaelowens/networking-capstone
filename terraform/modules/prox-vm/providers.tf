# main.tf
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  # because self-signed TLS certificate is in use
  insecure = true

  ssh {
    agent    = false
    private_key = file("~/.ssh/id_ed25519")

    node {
      name    = var.proxmox_node
      address = var.proxmox_fqdn
    }
  }
}
