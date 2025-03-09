---
# All relative paths are relative to the base directory of the project.
cwd: ..
---

# Deploy from Scratch

Here's a procedure to deploy this configuration without anything already setup.

## Prerequisites

All of the nodes should be running Talos Linux 1.9 in maintenance mode.
One way to do that is to boot them all from the Talos ISO image.

## DNS Records and DHCP

Configure DHCP to give these nodes fixed IP addresses.
Configure DNS `A` records for nodes and services in the `jdmarble.net` domain:

| name         | content      |
|--------------|--------------|
| k8s          | 192.168.2.8  |
| n07d-72206j2 | 192.168.2.17 |
| n07d-4pdc5j2 | 192.168.2.18 |
| n07d-9wvtpk2 | 192.168.2.19 |
| q330g4       | 192.168.2.34 |
| d08s-4wd2t52 | 192.168.2.35 |

## Generate Talos Configuration

Create a new secrets file and upload it to Bitwarden:

```sh
talhelper gensecret > talsecret.yaml
```

Generate the Talos configuration for all of the nodes described in `talconfig.yaml`.

```sh
talhelper genconfig
```

## Apply Configuration

```sh
NODES=(
    n07d-72206j2.jdmarble.net
    n07d-4pdc5j2.jdmarble.net
    n07d-9wvtpk2.jdmarble.net
    a300w.jdmarble.net
    q330g4.jdmarble.net
    d08s-4wd2t52.jdmarble.net
)
for NODE in "${NODES[@]}"; do
  talosctl apply-config --nodes "${NODE}" --file "${BUILD_DIR}/${CLUSTER_NAME}-${NODE}.yaml" --insecure
done
```

Wait for the nodes to reboot into the new installation.
Each node should show `STAGE: Booting` and `KUBELET: Healthy` on the dashboard.

## Bootstrap etcd

```sh
talosctl bootstrap --nodes=${NODES[@]:0:1}
```

## Get Administrator Credentials

```sh
talosctl --nodes=${NODES[@]:0:1} kubeconfig "${BUILD_DIR}/kubeconfig.yaml"
```

## Manually Approve Initial CSRs

The cluster is configured to rotate server certificates to be compatible with the metrics server.
This will prevent all of the kubelets from working until their certificate signing requests have been approved.
Later, you'll install Kubelet Serving Cert Approver, but you have to manually approve the CSRs until then.

```sh
kubectl get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' \
  | xargs kubectl certificate approve
```

See [Talos Linux documents for Deploying Metrics Server](https://www.talos.dev/v1.9/kubernetes-guides/configuration/deploy-metrics-server/) for more information.

The cluster is now ready to [install "apps"](install-apps.md).
