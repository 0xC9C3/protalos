resource "helm_release" "longhorn" {
  name             = "longhorn"
  namespace        = "longhorn-system"
  create_namespace = false
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  version          = "1.6.2"

  depends_on = [
    kubernetes_namespace.longhorn,
    helm_release.cilium
  ]
}

resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"

    // https://longhorn.io/docs/1.6.2/deploy/important-notes/#pod-security-policies-disabled--pod-security-admission-introduction
    labels = {
      "pod-security.kubernetes.io/enforce"         = "privileged"
      "pod-security.kubernetes.io/enforce-version" = "latest"
      "pod-security.kubernetes.io/audit"           = "privileged"
      "pod-security.kubernetes.io/audit-version"   = "latest"
      "pod-security.kubernetes.io/warn"            = "privileged"
      "pod-security.kubernetes.io/warn-version"    = "latest"
    }
  }
}