variable "pihole_server" {
  description = "pihole server"
  default     = ""
}

variable "pihole_password" {
  description = "pihole password"
  default     = ""
}

variable "cilium_pool_ip_addresses" {
  description = "List of IP addresses to be used for cilium ip pool"
  type        = list(string)
  default     = []
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

variable "kubeconfig" {
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "harbor_admin_password" {
  description = "Harbor admin password"
  default     = "Password12345!"
}