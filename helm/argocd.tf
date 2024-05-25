resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  version          = "6.7.2"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
}