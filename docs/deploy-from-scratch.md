# Deploy from Scratch

Here's a procedure to deploy this configuration without anything already setup.
Prerequisite is all of the nodes should be running Talos in maintenance mode.

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
| n12d-4wsxmh3 | 192.168.2.35                  |
| teleport     | https://whatismyipaddress.com |

Create DNS `CNAME` records for services in the `jdmarble.net` domain:

| name       | content                       |
|------------|-------------------------------|
| *.teleport | teleport.jdmarble.net         |
| gitea      | teleport.jdmarble.net         |

## Setup Build Environment

You need a temporary directory for files and some environment variables used in subsequent steps.

```
CLUSTER_NAME=jdmarble.net
API_ENDPOINT=https://k8s.jdmarble.net:6443
BUILD_DIR=$(pwd)/build
mkdir -p "${BUILD_DIR}"
```

## Generate Secrets Bundle and Talos Configuration

Run [`talosctl gen secrets --output-file "${BUILD_DIR}/secrets.yaml"`](https://www.talos.dev/v1.5/reference/cli/#talosctl-gen-secrets) then upload the contents of `build/secrets.yaml` to BitWarden as notes in the `talos-secrets.yaml` item.

```
talosctl gen config  \
    --with-secrets "${BUILD_DIR}/secrets.yaml" \
    --output-types talosconfig --output "${BUILD_DIR}/talosconfig" \
    $CLUSTER_NAME $API_ENDPOINT
talosctl config merge "${BUILD_DIR}/talosconfig"
```

## Apply Configuration

Generate the configuration file as described in the `README.md`.
For each node in maintenance mode, run this:

```sh
export NODE=<node name here>
talosctl apply-config --nodes "${NODE}.jdmarble.net" --file "${BUILD_DIR}/${NODE}.yaml" --insecure
```

## Bootstrap k8s

```sh
talosctl bootstrap ...?
```

## Do some stuff from README.md

## Create admin user

```sh
kubectl exec -ti -n teleport-cluster deployment/teleport-cluster-auth -- tctl users add jdmarble-admin --roles=kube-system-master,editor,auditor,access
tsh login --proxy teleport.jdmarble.net:443 --auth=local --user jdmarble-admin
```
