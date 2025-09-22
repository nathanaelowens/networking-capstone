data "proxmox_virtual_environment_vms" "vm_template" {
  filter {
    name   = "name"
    values = [var.vm_template]
  }
}

locals {
  template_id = one(data.proxmox_virtual_environment_vms.vm_template.vms[*].vm_id)
  vm_name = var.vm_name != null ? var.vm_name : var.hostname
}

resource "proxmox_virtual_environment_file" "cloud_config_user_data" {
  content_type = "snippets"
  datastore_id = var.proxmox_snippets_storage
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("../cloud-config/${var.cloud_config}/user-data.yaml", {
      hostname = var.hostname
      domain   = var.domain
    })

    file_name = "${var.hostname}_user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_config_network_data" {
  content_type = "snippets"
  datastore_id = var.proxmox_snippets_storage
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("../cloud-config/${var.cloud_config}/network-config.yaml", {
      hostname     = var.hostname
      domain       = var.domain
      ip_address   = var.ip_address == "" ? null : var.ip_address
      ipv6_address = var.ipv6_address == "" ? null : var.ipv6_address
      ipv6_addresses = length(var.ipv6_addresses) > 0 ? var.ipv6_addresses : null
      ipv6_token = var.ipv6_token != null ? var.ipv6_token : null
      ip_default_gateway = var.ip_default_gateway
      search_domains = var.search_domains
      dns_servers = var.dns_servers
      autodetect_net_if = var.autodetect_net_if
      net_if       = var.net_if0
      net_if0      = var.net_if0
      net_if1      = var.net_if1
    })

    file_name = "${var.hostname}_network-data.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  vm_id = var.vm_id != null ? var.vm_id : null

  name      = local.vm_name
  description = var.description != null ? var.description : null
  tags = var.tags # Note: Proxmox always sorts the VM tags. If the list in template is not sorted, then Proxmox will always report a difference on the resource.

  on_boot = var.auto_poweron ? true : false

  node_name = var.proxmox_node

  cpu {
    cores = var.cpu_cores

    # Passing null omits the argument, so Proxmox uses its own default.
    type  = var.cpu_mask
    flags = var.cpu_flags
    units = var.cpu_units
    limit = var.cpu_limit
  }

  memory {
    dedicated = var.dedicated_memory
    floating = var.floating_memory
  }

  network_device {
    bridge = "vmbr0"
    vlan_id = var.vlan_id != null ? var.vlan_id : null
  }

  disk {
    datastore_id = var.proxmox_vm_storage
    file_format  = "raw"
    interface    = "scsi0"
    size         = var.disk_size
  }

  # Dynamic block to pass through physical disks
  dynamic "disk" {
    for_each = var.passthrough_disks
    content {
      datastore_id = "" # Datastore is irrelevant for passed-through disks
      path_in_datastore = disk.value.block_device_path
      file_format = "raw" # Needed for block device passthrough
      interface = disk.value.interface
    }
  }

  clone {
    vm_id = local.template_id
  }

  initialization {
    datastore_id = var.proxmox_vm_storage
    interface = "scsi10"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config_user_data.id
    network_data_file_id = proxmox_virtual_environment_file.cloud_config_network_data.id
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true
}
