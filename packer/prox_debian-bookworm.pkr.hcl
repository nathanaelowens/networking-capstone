packer {
  required_plugins {
   proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_url" {
  type        = string
  description = "This will be pulled from the env var 'PROXMOX_URL'"
  default     = null
}

variable "proxmox_node" {
  type        = string
  description = "This will be pulled from the env var 'PKR_VAR_proxmox_node'"
  default     = null
}

variable "proxmox_username" {
  type        = string
  description = "This will be pulled from the env var 'PROXMOX_USERNAME'"
  sensitive   = true
  default     = null
}

variable "proxmox_token" {
  type        = string
  description = "This will be pulled from the env var 'PROXMOX_TOKEN'"
  sensitive   = true
  default     = null
}

variable "storage_pool" {
  type        = string
  description = "The name of the storage pool packer will use"
  default     = "local-zfs"
}

variable "raw_timestamp" {
  type    = string
  default = null
}

variable "timezone" {
  type    = string
  default = null
}

locals {
  template_name_timestamp = formatdate("YYYY-MM-DD-HH-mm-ss-aa", var.raw_timestamp)
  template_description_date = formatdate("EEEE D MMMM YYYY", var.raw_timestamp)
  template_description_time = formatdate("HH:mm:ss aa", var.raw_timestamp)
  template_name        = "debian-bookworm-${var.proxmox_node}-${local.template_name_timestamp}"
}

source "proxmox-iso" "debian-bookworm" {
  boot_iso {
    iso_url = "https://cdimage.debian.org/debian-cd/12.11.0/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso"
    iso_checksum = "sha512:0921d8b297c63ac458d8a06f87cd4c353f751eb5fe30fd0d839ca09c0833d1d9934b02ee14bbd0c0ec4f8917dde793957801ae1af3c8122cdf28dde8f3c3e0da"
    type = "ide"
    iso_storage_pool = "iso-storage"
    unmount = true
  }

  http_directory    = "debian-bookworm/http"

  proxmox_url = var.proxmox_url
  insecure_skip_tls_verify = true
  node     = var.proxmox_node
  username = var.proxmox_username
  token = var.proxmox_token

  boot_command =  [
    "<wait><wait><wait>c<wait><wait><wait>",
    "linux /install.amd/vmlinuz ",
    "auto=true ",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "hostname=debian ",
    "domain= ",
    "interface=auto ",
    "vga=788 noprompt quiet --<enter>",
    "initrd /install.amd/initrd.gz<enter>",
    "boot<enter>"
  ]

  template_name        = local.template_name
  template_description = "Debian Bookworm Template, generated on ${local.template_description_date} at ${local.template_description_time} ${var.timezone}."
  tags = "debian-bookworm;packer;template"
  os = "l26" #+
  bios = "ovmf"
  scsi_controller = "virtio-scsi-single"
  cores = 1
  memory      = 1024 #MB
  ballooning_minimum = 1024 #MB
  qemu_agent = true

  efi_config {
    efi_storage_pool = var.storage_pool
    pre_enrolled_keys = false
    efi_type = "4m"
  }

  disks {
      disk_size = "10G"
      type = "scsi"
      storage_pool = var.storage_pool
  }

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  
  ssh_username            = "root"
  ssh_password            = "debian"
  ssh_timeout             = "60000s"
}

build {
  sources = ["proxmox-iso.debian-bookworm"]

  provisioner "shell" {
    inline = [
    "echo 'manage_etc_hosts: true' >> /etc/cloud/cloud.cfg",
    "dd if=/dev/urandom of=/swapfile bs=1M count=4096",
    "echo 'swap /swapfile /dev/urandom swap,cipher=aes-xts-plain64,size=512' >> /etc/crypttab",
    "echo '/dev/mapper/swap none swap sw 0 0' >> /etc/fstab",
    "mkdir -p /etc/systemd/system/systemd-cryptsetup@.service.d",
    "cat >/etc/systemd/system/systemd-cryptsetup@.service.d/override.conf <<EOL",
    "[Unit]",
    "Before=dev-mapper-%i.swap",
    "Requires=systemd-random-seed.service",
    "After=systemd-random-seed.service",
    "[Service]",
    "ExecStartPost=/usr/bin/udevadm trigger /dev/mapper/%i",
    "EOL",
    "usermod -p '!' root", # Make root account unable to be logged into
    "sed -i 's/PermitRootLogin yes/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config",
    "DEBIAN_FRONTEND=noninteractive apt remove -y ifupdown", # Remove old ifupdown networking
    "DEBIAN_FRONTEND=noninteractive apt install -y systemd-resolved", # Install systemd-resolved
    "DEBIAN_FRONTEND=noninteractive apt clean -y", # Clean apt cache
    "cloud-init clean", # Have cloud-init do its cleanup work
    "rm /etc/ssh/ssh_host_*", # Remove ssh host keys, cloud-init will regenerate
    "truncate -s 0 /etc/machine-id /var/lib/dbus/machine-id", # Reset machine-id - DON'T DELETE THE FILE!
    "truncate -s 0 /root/.bash_history", # Clear bash history for a fresh start!
    ]
  }
}
