# variables.tf
variable "proxmox_fqdn" {
  type = string
}

variable "proxmox_node" {
  type = string
}
variable "proxmox_snippets_storage" {
  type    = string
  default = "local"
}
variable "proxmox_vm_storage" {
  type    = string
  default = "proxraid3"
}

variable "disk_size" {
  type    = number
  default = 20 # GB
}
variable "dedicated_memory" {
  type    = number
  default = 2048 # MB
}
variable "floating_memory" {
  type    = number
  default = 2048 # MB
}

variable "cpu_cores" {
  type    = number
  default = 1
}
variable "cpu_mask" {
  type    = string
  default = null
}
variable "cpu_flags" {
  type    = list(string)
  default = null
}
variable "cpu_units" {
  description = "Proxmox CPU shares (aka cpuunits). null = let Proxmox default."
  type        = number
  default     = 100 # Should be the default for cgroupv2, but terraform provider is behind the curve and still sets default to 1024
  validation {
    condition     = var.cpu_units == null || (var.cpu_units >= 1 && var.cpu_units <= 262144)
    error_message = "cpu_units must be null or between 1 and 262144."
  }
}
variable "cpu_limit" {
  description = "Hard cap on CPU (0 or null = no cap)."
  type        = number
  default     = null # Proxmox default is fine here
}

variable "auto_poweron" {
  type    = bool
  default = false
}
variable "vm_template" {
  type = string
}
variable "cloud_config" {
  type = string
}
variable "vm_id" {
  type    = number
  default = null
}
variable "vm_name" {
  type = string
  default = null
}
variable "hostname" {
  type = string
}
variable "domain" {
  type    = string
  default = "lanbeforetime.link"
}

variable "description" {
  type    = string
  default = null
}
variable "tags" {
  type    = list(any)
  default = ["terraform"]
}
variable "vlan_id" {
  type    = number
  default = null
}

variable "ip_address" {
  type = string
  default = ""
}
variable "ipv6_address" {
  type = string
  default = ""
}
variable "ipv6_addresses" {
  type    = list(string)
  default = []
  description = "A list of static IPv6 addresses to assign to the main interface."
}
variable "ipv6_token" {
  type = string
  default = null
}
variable "ip_default_gateway" {
  type = string
  default = "192.168.1.1"
}
variable "search_domains" {
  type        = list(string)
  default     = ["lanbeforetime.link"]
}
variable "dns_servers" {
  type        = list(string)
  default     = ["192.168.10.20","192.168.10.21"]
}
variable "autodetect_net_if" {
  type = bool
  default = false
}
variable "net_if0" {
  type = string
  default = "enX0"
}
variable "net_if1" {
  type = string
  default = "enX1"
}
variable "passthrough_disks" {
  type = list(object({
    block_device_path = string  # Path to the /dev block device to be passed through
    interface = string # SCSI device interface name for virtual disk
  }))
  default = []
}
