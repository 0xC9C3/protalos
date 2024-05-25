resource "helm_release" "ingress-nginx" {
  chart            = "ingress-nginx"
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"

  depends_on = [
    kubectl_manifest.cilium_ip_pool
  ]
}