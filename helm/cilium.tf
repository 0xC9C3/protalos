locals {
  cilium_pool_ip_addresses = [for ip in var.cilium_pool_ip_addresses : " - cidr: ${ip}/32"]
}

resource "helm_release" "cilium" {
  chart     = "cilium"
  name      = "cilium"
  namespace = "kube-system"

  repository = "https://helm.cilium.io/"

  #https://www.talos.dev/v1.6/kubernetes-guides/network/deploying-cilium/#method-1-helm-install
  set {
    name  = "operator.replicas"
    value = "1"
  }

  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }

  set {
    name  = "kubeProxyReplacement"
    value = "disabled"
  }

  set {
    name  = "securityContext.capabilities.ciliumAgent"
    value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
  }

  set {
    name  = "securityContext.capabilities.cleanCiliumState"
    value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
  }

  set {
    name  = "cgroup.autoMount.enabled"
    value = "false"
  }

  set {
    name  = "cgroup.hostRoot"
    value = "/sys/fs/cgroup"
  }

  # disabling hubble since we are using neuvector
  set {
    name  = "hubble.enabled"
    value = "false"
  }

  #set {
  #  name  = "hubble.relay.enabled"
  #  value = "true"
  #}

  #set {
  #  name  = "hubble.ui.enabled"
  #  value = "true"
  #}
}

resource "kubectl_manifest" "cilium_ip_pool" {
  yaml_body = <<YAML
apiVersion: cilium.io/v2alpha1
kind: CiliumLoadBalancerIPPool
metadata:
  name: cilium-pool
spec:
    blocks:
    ${join("\n    ", local.cilium_pool_ip_addresses)}
YAML

  depends_on = [
    helm_release.cilium
  ]
}