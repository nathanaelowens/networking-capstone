# main.tf
module "prox-vm" {
    source = "../modules/prox-vm"

    vm_id = 111
    hostname = "orchestra-prox"
    domain   = "lanbeforetime.link"
    ip_address = "192.168.10.16/24"
    ip_default_gateway = "192.168.10.1"
    search_domains = ["lanbeforetime.link"]
    dns_servers = ["192.168.10.20","192.168.10.21"]
    description = "Xen Orchestra Server on Proxtanic"
    tags = ["terraform","backup"]
    auto_poweron = true
    cloud_config = "debian-trixie_0.1"
    vm_template = "debian-trixie-proxtanic3-2025-09-29-10-23-00-am"
    autodetect_net_if = true
    disk_size = 30 #GB
    dedicated_memory = 2048 #MB
    floating_memory = 2048 #MB

    proxmox_node = "proxtanic3"
    proxmox_fqdn = "proxtanic3.lanbeforetime.link"
}
