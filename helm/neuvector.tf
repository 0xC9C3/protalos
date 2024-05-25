resource "helm_release" "neuvector" {
  chart            = "core"
  name             = "neuvector"
  namespace        = "neuvector"
  create_namespace = false

  repository = "https://neuvector.github.io/neuvector-helm/"

  set {
    name  = "manager.svc.type"
    value = "ClusterIP"
  }

  set {
    name  = "manager.ingress.enabled"
    value = "true"
  }

  set {
    name  = "manager.ingress.host"
    value = var.neuvector_hostname
  }

  set {
    name  = "manager.ingress.tls"
    value = "true"
  }

  set {
    name  = "manager.ingress.secretName"
    value = "neuvector-tls"
  }

  set {
    name  = "manager.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-cloudflare"
  }

  set {
    name  = "manager.ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "${var.neuvector_hostname}."
  }

  set {
    name  = "manager.ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "controller.replicas"
    value = "1"
  }

  set {
    name  = "cve.scanner.replicas"
    value = "1"
  }

  depends_on = [
    kubernetes_namespace.neuvector
  ]
}


resource "kubernetes_namespace" "neuvector" {
  metadata {
    name = "neuvector"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}