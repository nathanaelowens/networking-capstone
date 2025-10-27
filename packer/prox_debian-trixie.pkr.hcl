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
  default     = "truenas_templates"
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
  template_name        = "debian-trixie-${var.proxmox_node}-${local.template_name_timestamp}"
}

source "proxmox-iso" "debian-trixie" {
  boot_iso {
    iso_url = "https://cdimage.debian.org/debian-cd/13.1.0/amd64/iso-cd/debian-13.1.0-amd64-netinst.iso"
    iso_checksum = "sha512:873e9aa09a913660b4780e29c02419f8fb91012c8092e49dcfe90ea802e60c82dcd6d7d2beeb92ebca0570c49244eee57a37170f178a27fe1f64a334ee357332"
    type = "ide"
    iso_storage_pool = "truenas_isos"
    unmount = true
  }

  # Give Packer more time to wait on long PVE tasks (downloads, etc.)
  task_timeout = "20m"

  http_directory    = "debian-trixie/http"

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
  template_description = "Debian Trixie Template, generated on ${local.template_description_date} at ${local.template_description_time} ${var.timezone}."
  tags = "debian-trixie;packer;template"
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
  sources = ["proxmox-iso.debian-trixie"]

  provisioner "shell" {
    inline = [
    "echo 'manage_etc_hosts: true' >> /etc/cloud/cloud.cfg",
    "dd if=/dev/urandom of=/swapfile bs=1M count=4096",
    "echo '/swapfile none swap defaults 0 0' >> /etc/fstab",
    "mkdir -p /etc/systemd/system/systemd-cryptsetup@.service.d",
    "cat >/etc/systemd/system/systemd-cryptsetup@.service.d/override.conf <<EOL",
    "[Unit]",
    "Before=dev-mapper-%i.swap",
    "Requires=systemd-random-seed.service",
    "After=systemd-random-seed.service",
    "[Service]",
    "ExecStartPost=/usr/bin/udevadm trigger /dev/mapper/%i",
    "EOL",
    "sudo rm -f /etc/netplan/00-installer-config.yaml", # Remove installer-generated netplan file
    "usermod -p '!' root", # Make root account unable to be logged into
    "sed -i 's/PermitRootLogin yes/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config",
    "DEBIAN_FRONTEND=noninteractive apt-get remove -y ifupdown", # Remove old ifupdown networking
    "DEBIAN_FRONTEND=noninteractive apt-get install -y systemd-resolved", # Install systemd-resolved
    "DEBIAN_FRONTEND=noninteractive apt-get clean -y", # Clean apt cache
    "cloud-init clean", # Have cloud-init do its cleanup work
    "rm /etc/ssh/ssh_host_*", # Remove ssh host keys, cloud-init will regenerate
    "truncate -s 0 /etc/machine-id /var/lib/dbus/machine-id", # Reset machine-id - DON'T DELETE THE FILE!
    "truncate -s 0 /root/.bash_history", # Clear bash history for a fresh start!
    ]
  }
}
