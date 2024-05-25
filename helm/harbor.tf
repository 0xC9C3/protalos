resource "helm_release" "harbor" {
  chart            = "harbor"
  name             = "harbor"
  namespace        = "harbor"
  create_namespace = true

  repository = "https://charts.bitnami.com/bitnami"

  set {
    name  = "adminPassword"
    value = var.harbor_admin_password
  }

  set {
    name  = "exposureType"
    value = "ingress"
  }

  set {
    name  = "ingress.core.hostname"
    value = var.harbor_hostname
  }

  set {
    name  = "ingress.core.tls"
    value = "true"
  }

  set {
    name  = "ingress.core.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-cloudflare"
  }

  set {
    name  = "ingress.core.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "${var.harbor_hostname}."
  }

  set {
    name  = "ingress.core.ingressClassName"
    value = "nginx"
  }

  # this always takes a long time to install
  timeout = 600

  depends_on = [
    helm_release.longhorn,
    helm_release.ingress-nginx
  ]
}
