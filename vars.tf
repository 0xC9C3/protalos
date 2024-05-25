# the provider does not support the actions we need using the token @todo
#variable "proxmox_token" {
#    description = "Proxmox token"
#    sensitive = true
#}

variable "proxmox_username" {
  description = "Proxmox username"
}

variable "proxmox_password" {
  description = "Proxmox password"
  sensitive   = true
}

variable "proxmox_base_url" {
  description = "Proxmox base url"
  default     = "https://proxmox.example.com:8006/api2/json"
}

variable "proxmox_insecure" {
  description = "Proxmox insecure"
  default     = false
}

variable "proxmox_node_name" {
  description = "Proxmox node name"
  default     = "pve"
}

variable "talos_factory_base_url" {
  description = "talos factory base url"
  default     = "https://factory.talos.dev/image/"
}

variable "talos_factory_installer_base_url" {
  description = "talos factory image base url"
  default     = "factory.talos.dev/installer/"
}

variable "talos_factory_hash" {
  description = "talos factory hash"
  default     = "88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b"
}

variable "talos_image_name" {
  description = "talos image name"
  default     = "nocloud-amd64.iso"
}

variable "talos_version" {
  description = "talos version to use"
  default     = "v1.7.2"
}

variable "cluster_name" {
  description = "cluster name"
  default     = "talos-cluster"
}

variable "proxmox_node_base_address" {
  description = "proxmox node base address"
  default     = "proxmox.example.com"
}

variable "node_network_interface" {
  description = "node network interface"
  default     = "eth0"
}

variable "control_plane_nodes" {
  description = "controlplane nodes"
  default     = 1
}

variable "controlplane_cpus" {
  description = "controlplane cpus"
  default     = 2
}

variable "controlplane_memory" {
  description = "controlplane memory"
  default     = 2048
}

variable "controlplane_install_disk_size" {
  description = "controlplane ephemeral disk size"
  default     = 10
  validation {
    condition     = var.controlplane_install_disk_size >= 10
    error_message = "The controlplane ephemeral disk size must be at least 10GB"
  }
}

variable "worker_nodes" {
  description = "worker nodes"
  default     = 3
}

variable "worker_cpus" {
  description = "worker cpus"
  default     = 4
}

variable "worker_memory" {
  description = "worker memory"
  default     = 4096
}

variable "worker_install_disk_size" {
  description = "worker ephemeral disk size"
  default     = 30
  validation {
    condition     = var.worker_install_disk_size >= 10
    error_message = "The worker ephemeral disk size must be at least 10GB"
  }
}

variable "worker_extra_disk_size" {
  description = "worker extra disk size"
  default     = 50
}

variable "pihole_server" {
  description = "pihole server"
  default     = ""
}

variable "pihole_password" {
  description = "pihole password"
  default     = ""
}

variable "harbor_hostname" {
  description = "Harbor hostname"
  default     = ""
}

variable "neuvector_hostname" {
  description = "Neuvector hostname"
  default     = ""
}

variable "acme_email" {
  description = "Email address for ACME account"
  default     = ""
}

variable "acme_server" {
  description = "ACME server URL"
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "cloudflare_token" {
  description = "Cloudflare API token"
  default     = ""
}

variable "harbor_admin_password" {
  description = "Harbor admin password"
  default     = "Password12345!"
}
