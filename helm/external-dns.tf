resource "helm_release" "external-dns" {
  chart            = "external-dns"
  name             = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  repository = "https://charts.bitnami.com/bitnami"

  set {
    name  = "provider"
    value = "pihole"
  }

  set {
    name  = "pihole.server"
    value = var.pihole_server
  }

  set {
    name  = "pihole.secretName"
    value = "pihole-secret"
  }

  depends_on = [
    kubernetes_secret.pihole
  ]
}

resource "kubernetes_secret" "pihole" {
  metadata {
    name      = "pihole-secret"
    namespace = "external-dns"
  }
  data = {
    "pihole_password" = var.pihole_password
  }
}