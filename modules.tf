module "helm" {
  source = "./helm"

  pihole_server            = var.pihole_server
  pihole_password          = var.pihole_password
  cilium_pool_ip_addresses = local.worker_ip_addresses
  harbor_hostname          = var.harbor_hostname
  neuvector_hostname       = var.neuvector_hostname
  acme_email               = var.acme_email
  acme_server              = var.acme_server
  cloudflare_token         = var.cloudflare_token
  kubeconfig               = local_file.kubeconfig.filename
  harbor_admin_password    = var.harbor_admin_password

  depends_on = [
    data.http.kubernetes
  ]
}