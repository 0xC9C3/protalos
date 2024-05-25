# get the ip from the target interface using .network_interface_names and .ipv4_addresses
locals {
  talos_endpoint_ip = proxmox_virtual_environment_vm.talos_control_plane_nodes[0].ipv4_addresses[
  index(proxmox_virtual_environment_vm.talos_control_plane_nodes[0].network_interface_names, var.node_network_interface)
  ][
  0
  ]
  worker_ip_addresses = [
    for node in proxmox_virtual_environment_vm.talos_worker_nodes :
    node.ipv4_addresses[
    index(node.network_interface_names, var.node_network_interface)
    ][
    0
    ]
  ]
  control_plane_ip_addresses = [
    for node in proxmox_virtual_environment_vm.talos_control_plane_nodes :
    node.ipv4_addresses[
    index(node.network_interface_names, var.node_network_interface)
    ][
    0
    ]
  ]
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "this_control_plane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${local.talos_endpoint_ip}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = talos_machine_secrets.this.talos_version

  depends_on = [
    proxmox_virtual_environment_vm.talos_control_plane_nodes,
  ]
}

data "talos_machine_configuration" "this_worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = "https://${local.talos_endpoint_ip}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = talos_machine_secrets.this.talos_version

  depends_on = [
    proxmox_virtual_environment_vm.talos_worker_nodes
  ]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration

  endpoints = [
    for node in proxmox_virtual_environment_vm.talos_control_plane_nodes :
    node.ipv4_addresses[
    index(node.network_interface_names, var.node_network_interface)
    ][
    0
    ]
  ]
  nodes = concat(
    [
      for node in proxmox_virtual_environment_vm.talos_control_plane_nodes :
      node.ipv4_addresses[
      index(node.network_interface_names, var.node_network_interface)
      ][
      0
      ]
    ],
    [
      for node in proxmox_virtual_environment_vm.talos_worker_nodes :
      node.ipv4_addresses[
      index(node.network_interface_names, var.node_network_interface)
      ][
      0
      ]
    ]
  )
}

resource "talos_machine_configuration_apply" "control_plane" {
  count = var.control_plane_nodes

  node = proxmox_virtual_environment_vm.talos_control_plane_nodes[count.index].ipv4_addresses[
  index(
    proxmox_virtual_environment_vm.talos_control_plane_nodes[count.index].network_interface_names,
    var.node_network_interface
  )
  ][
  0
  ]

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this_control_plane.machine_configuration

  config_patches = [
    yamlencode({
      # when using cilium as cni, the network name must be set to none
      cluster = {
        network = {
          cni = {
            name = "none"
          }
        }
      }
      machine = {
        install = {
          image = "${var.talos_factory_installer_base_url}${var.talos_factory_hash}:${var.talos_version}"
          disk  = "/dev/vda"
          wipe  = true
        }
        kubelet = {
          extraMounts = [
            {
              destination = "/var/lib/longhorn"
              source      = "/var/lib/longhorn"
              type        = "bind"
              options     = [
                "bind",
                "rshared",
                "rw"
              ]
            }
          ]
        }
        network = {
          hostname = "${var.cluster_name}-controlplane-${count.index}"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  count = var.worker_nodes

  node = proxmox_virtual_environment_vm.talos_worker_nodes[count.index].ipv4_addresses[
  index(
    proxmox_virtual_environment_vm.talos_worker_nodes[count.index].network_interface_names,
    var.node_network_interface
  )
  ][
  0
  ]


  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this_worker.machine_configuration

  config_patches = [
    yamlencode({
      # when using cilium as cni, the network name must be set to none
      cluster = {
        network = {
          cni = {
            name = "none"
          }
        }
      }
      machine = {
        install = {
          image = "${var.talos_factory_installer_base_url}${var.talos_factory_hash}:${var.talos_version}"
          disk  = "/dev/vda"
          wipe  = true
        }
        kubelet = {
          extraMounts = [
            {
              destination = "/var/lib/longhorn"
              source      = "/var/lib/longhorn"
              type        = "bind"
              options     = [
                "bind",
                "rshared",
                "rw"
              ]
            }
          ]
        }
        network = {
          hostname = "${var.cluster_name}-worker-${count.index}"
        }
        disks = [
          {
            device     = "/dev/vdb"
            partitions = [
              {
                mountpoint = "/var/lib/longhorn"
              }
            ]
          }
        ]
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.control_plane
  ]
  node                 = local.talos_endpoint_ip
  client_configuration = talos_machine_secrets.this.client_configuration
}

# Wait for the endpoint to be up before checking the cluster health
# since there is a rare chance that the endpoint is not up yet which will
# cause the health check to fail immediately
data "http" "kubernetes" {
  url      = "https://${local.talos_endpoint_ip}:6443/version"
  insecure = true
  retry {
    attempts     = 120
    min_delay_ms = 5000
    max_delay_ms = 5000
  }
  depends_on = [
    talos_machine_bootstrap.this
  ]
}

data "talos_cluster_health" "this" {
  depends_on = [
    data.http.kubernetes
  ]

  client_configuration = talos_machine_secrets.this.client_configuration

  endpoints = [
    local.talos_endpoint_ip
  ]

  control_plane_nodes = local.control_plane_ip_addresses

  worker_nodes = local.worker_ip_addresses
}

# write config to file
resource "local_file" "talos_config" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "${path.module}/talosconfig"
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.talos_endpoint_ip
}

resource "local_file" "kubeconfig" {
  content  = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename = "${path.module}/kubeconfig"
}