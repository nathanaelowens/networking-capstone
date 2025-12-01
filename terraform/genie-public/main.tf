resource "digitalocean_droplet" "vpn" {
    image = "ubuntu-24-04-x64"
    name = format("%s.%s", var.hostname, var.domain)
    region = var.region
    size = "s-1vcpu-1gb"

    user_data = templatefile("../cloud-config/${var.cloud_config}/user-data.yaml", {
      hostname = var.hostname
      domain = var.domain
    })

    ssh_keys = [
      data.digitalocean_ssh_key.???????.id
    ]
}

# Attach resource to the project
resource "digitalocean_project_resources" "attach" {
  project = var.project_id

  resources = [
    digitalocean_droplet.vpn.urn
  ]
}
