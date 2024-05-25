terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.57.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_base_url
  # the provider does not support the actions we need using the token @todo
  #api_token = var.proxmox_token
  username = var.proxmox_username
  password = var.proxmox_password
  # because self-signed TLS certificate is in use
  insecure = var.proxmox_insecure

  ssh {
    agent = false

    node {
      name    = var.proxmox_node_name
      address = var.proxmox_node_base_address
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}

provider "kubectl" {
  config_path = local_file.kubeconfig.filename
}