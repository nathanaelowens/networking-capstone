# main.tf
module "prox-vm" {
    source = "../modules/prox-vm"

    vm_id = 130
    hostname = "snmpserver"
    domain   = "lanbeforetime.link"
    ip_address = "192.168.10.30/24"
    ip_default_gateway = "192.168.10.1"
    search_domains = ["lanbeforetime.link"]
    dns_servers = ["192.168.10.20","192.168.10.21"]
    description = "SNMP Server"
    tags = ["terraform","backup"]
    auto_poweron = true
    cloud_config = "debian-trixie_0.1"
    vm_template = "debian-trixie-proxtanic2-2025-10-27-10-05-56-am"
    autodetect_net_if = true
    disk_size = 50 #GB
    dedicated_memory = 2048 #MB
    floating_memory = 2048 #MB
    proxmox_vm_storage = "proxraid2"

    proxmox_node = "proxtanic2"
    proxmox_fqdn = "proxtanic2.lanbeforetime.link"
}
