# Protalos

Small repository to bootstrap an opinionated talos cluster with longhorn storage and a few services on proxmox

blog post: https://blog.stack.rip/diving-into-kubernetes/

## Services

- [Longhorn](https://longhorn.io/)
- [Cilium](https://cilium.io/)
- [Harbor](https://goharbor.io/)
- [Ingrees Nginx](https://kubernetes.github.io/ingress-nginx/)
- [External DNS](https://github.com/kubernetes-sigs/external-dns)
- [Neuvector](https://neuvector.com/)
- [ArgoCD](https://argoproj.github.io/argo-cd/)
- [Cert Manager](https://cert-manager.io/)

Warning: This should not be used as is on the open internet and probably not in "production" environments.

Services like neuvector and harbor are not secure by default.
This project is meant to be a starting point for a talos + proxmox cluster, so fork and adjust to your needs for
things like version pinning, security, etc. Also for cert-manager the recommended way to install the CRDs is manually
and not via helm, so you might want to adjust that as well.

If you purely want to use flux or argocd, you can remove the other services or the helm module and modules.tf.

## Quickstart

1. Clone the repository
2. Install the dependencies via `terraform init`
3. Create a `terraform.tfvars` file with the following content:

There are more variables that can be set, but these are the minimum required to get the cluster up and running.
Check the `variables.tf` file for more information.

```hcl
proxmox_base_url = "https://yourproxmox.url:8006"
proxmox_node_base_address = "your-node-addressor.hostname"
# if you don't use a certificate signed by a CA
proxmox_insecure = true
# bgp/proxmox can't do all the actions using the api key, so a user/password is needed
proxmox_username = "root@pam"
proxmox_password = "yourproxmoxpassword"
proxmox_node_name = "yournode"

# if you want external-dns to update your pihole server otherwise remove or edit helm/external-dns.tf
pihole_server = "https://pihole.yourpihole.url"
pihole_password = "yourpiholepassword"

# amount of worker and control plane nodes
worker_nodes       = 3
controlplane_nodes = 2

acme_email       = "your@email.url"
acme_server      = "https://acme-staging-v02.api.letsencrypt.org/directory"
cloudflare_token = "yourcloudflaretoken-for-dns-01-verification"
```

4. Run `terraform apply` to create the cluster

## Destroying the cluster

Notes for destroying you might receive an error message like:

```
job failed: BackoffLimitExceeded
```

This most likely means that longhorn is preventing the deletion of the resources.
You can confirm that by checking the logs of the longhorn-uninstall pods. They should
print something like:

```
 shared_informer.go:318] Caches are synced for longhorn uninstall
time="2024-05-23T20:15:56Z" level=fatal msg="cannot uninstall Longhorn because deleting-confirmation-flag is set to `false`. Please set it to `true` using Longhorn UI or kubectl -n longhorn-system edit settings.longhorn.io deleting-confirmation-flag " func=main.main.UninstallCmd.func7 file="uninstall.go:48"
```

To fix this, you can set the `deleting-confirmation-flag` to `true` by running:

```
kubectl -n longhorn-system edit settings.longhorn.io deleting-confirmation-flag
```

The uninstaller will sometimes be orchestrated to run on the control plane node and fail because of the taint.
You can fix this by running the following command:

```
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```