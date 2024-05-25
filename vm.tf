locals {
  talos_iso_url = "${var.talos_factory_base_url}${var.talos_factory_hash}/${var.talos_version}/${var.talos_image_name}"
}

resource "proxmox_virtual_environment_vm" "talos_control_plane_nodes" {
  count     = var.control_plane_nodes
  name      = "${var.cluster_name}-controlplane-${count.index}"
  node_name = var.proxmox_node_name

  cpu {
    type  = "x86-64-v2-AES"
    cores = var.controlplane_cpus
  }

  memory {
    dedicated = var.controlplane_memory
  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.controlplane_install_disk_size
  }

  boot_order = [
    "virtio0"
  ]
}

resource "proxmox_virtual_environment_vm" "talos_worker_nodes" {
  count     = var.worker_nodes
  name      = "${var.cluster_name}-worker-${count.index}"
  node_name = var.proxmox_node_name

  cpu {
    type  = "x86-64-v2-AES"
    cores = var.worker_cpus
  }

  memory {
    dedicated = var.worker_memory
  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.worker_install_disk_size
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio1"
    iothread     = true
    discard      = "on"
    size         = var.worker_extra_disk_size
    file_format  = "raw"

  }

  boot_order = [
    "virtio0",
    "virtio1"
  ]
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  url          = local.talos_iso_url
  file_name    = "talos-${var.talos_version}-${var.talos_image_name}"
  lifecycle {
    prevent_destroy = true
  }
}