---
# All relative paths are relative to the base directory of the project.
cwd: ..
---

# Deploy from Scratch

Here's a procedure to deploy this configuration without anything already setup.

## Prerequisites

You need `talosctl` version 1.7 installed and on your path.
All of the nodes should be running Talos Linux 1.7 in maintenance mode.
One way to do that is to boot them all from the Talos ISO image.

## DNS Records and DHCP

Configure DHCP to give these nodes fixed IP addresses.
Configure DNS `A` records for nodes and services in the `jdmarble.net` domain:

| name         | content                       |
|--------------|-------------------------------|
| k8s          | 192.168.2.8                   |
| n07d-72206j2 | 192.168.2.17                  |
| n07d-4pdc5j2 | 192.168.2.18                  |
| n07d-9wvtpk2 | 192.168.2.19                  |
| gigabyte     | 192.168.2.32                  |
| a300w        | 192.168.2.33                  |
| q330g4       | 192.168.2.34                  |


## Setup Build Environment

You need a temporary directory for files and some environment variables used in subsequent steps.

```
export CLUSTER_NAME=jdmarble.net
export API_ENDPOINT=https://k8s.jdmarble.net:6443
export BUILD_DIR=$(pwd)/build
mkdir -p "${BUILD_DIR}"
```

## Generate Secrets Bundle

Run [`talosctl gen secrets`](https://www.talos.dev/v1.7/reference/cli/#talosctl-gen-secrets).

```sh
talosctl gen secrets --output-file "${BUILD_DIR}/secrets.yaml"
```

Now upload the contents of `build/secrets.yaml` to BitWarden as an attachment to the `jdmarble.net` item for future reference.

## Generate Talos Configuration

Generate the Talos configuration by combining the default configuration and the secrets you just generated.

```sh
talosctl gen config \
    "${CLUSTER_NAME}" "${API_ENDPOINT}" \
    --with-secrets="${BUILD_DIR}/secrets.yaml" \
    --output-types=talosconfig --output="${BUILD_DIR}/talosconfig"
talosctl config merge "${BUILD_DIR}/talosconfig"
```

For some reason, the endpoint needs to be manually configured.
Edit `~/.talos/config` to set the endpoints to:

```yaml
        endpoints:
            - n07d-72206j2.jdmarble.net
            - n07d-4pdc5j2.jdmarble.net
            - n07d-9wvtpk2.jdmarble.net
```

## Apply Configuration

Generate the configuration file as described in the `README.md`.
For each node in maintenance mode, run this:

```sh
export NODE=<node name here>
talosctl apply-config --nodes "${NODE}.jdmarble.net" --file "${BUILD_DIR}/${NODE}.yaml" --insecure
```

## Bootstrap etcd

```sh
talosctl bootstrap --nodes n07d-4pdc5j2
```

## Get Administrator Credentials

```sh
talosctl --nodes=${NODE} kubeconfig
```

## Manually Approve Initial CSRs

The cluster is configured to rotate server certificates to be compatible with the metrics server.
This will prevent all of the kubelets from working until their certificate signing requests have been approved.
Later, you'll install Kubelet Serving Cert Approver, but you have to manually approve the CSRs until then.

```sh
kubectl get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs kubectl certificate approve
```

See [Talos Linux documents for Deploying Metrics Server](https://www.talos.dev/v1.7/kubernetes-guides/configuration/deploy-metrics-server/) for more information.

## Bootstrap Applications

This will install ArgoCD and configure it to install the other software by pulling deployments from the git repository.

```sh
kubectl apply --kustomize='deployments/argocd/base'
```
