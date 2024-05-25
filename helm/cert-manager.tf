resource "helm_release" "cert-manager" {
  chart            = "cert-manager"
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "cert_manager_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-cloudflare
spec:
    acme:
        email: ${var.acme_email}
        server: ${var.acme_server}
        privateKeySecretRef:
          name: letsencrypt-cloudflare-account-key
        solvers:
        - dns01:
            cloudflare:
                apiTokenSecretRef:
                  name: cloudflare-api-token-secret
                  key: api-token
YAML

  depends_on = [
    helm_release.cert-manager
  ]
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = "cert-manager"
  }
  data = {
    "api-token" = var.cloudflare_token
  }

  depends_on = [
    helm_release.cert-manager
  ]
}