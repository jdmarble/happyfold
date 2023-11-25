You can make all of the development tools available using nix if you have flakes enabled:

```
nix develop
```

Setup some environment variables and create the temporary build directory:

```
CLUSTER_NAME=jdmarble.net
API_ENDPOINT=https://k8s.jdmarble.net:6443
BUILD_DIR=$(pwd)/build
mkdir -p "${BUILD_DIR}"
```

I store my Talos secrets bundle in a Bitwarden note.
Login and download it to the temporary directory.

```
bw login
...
export BW_SESSION=...
bw get notes talos-secrets.yaml > "${BUILD_DIR}/secrets.yaml"
```

With the secrets bundle, you can create a `talosconfig` file for authentication with the Talos API.

```
talosctl gen config  \
    --with-secrets "${BUILD_DIR}/secrets.yaml" \
    --output-types talosconfig --output "${BUILD_DIR}/talosconfig" \
    $CLUSTER_NAME $API_ENDPOINT
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

You can generate a `kubectl` configuation file from the secrets bundle:

```yaml
talosctl kubeconfig --nodes n07d-72206j2
```

## Change Node Configuration

```
CONTROL_PLANE_NODES=(
    n07d-4pdc5j2
    n07d-72206j2
    n07d-9wvtpk2
)
for NODE in "${CONTROL_PLANE_NODES[@]}"; do
    talosctl gen config \
        --output "${BUILD_DIR}/${NODE}.yaml" \
        --output-types controlplane\
        --with-secrets "${BUILD_DIR}/secrets.yaml" \
        --config-patch @talos/nodes/${NODE}.yaml \
        --config-patch @talos/patches/discovery.yaml \
        --config-patch @talos/patches/metrics-server.yaml \
        --config-patch @talos/patches/network.yaml \
        --config-patch @talos/patches/version.yaml \
        --with-docs=false --with-examples=false --force \
        $CLUSTER_NAME $API_ENDPOINT
done

WORKER_NODES=(
    sock-quota
    a300w
    gigabyte
    q330g4
)
for NODE in "${WORKER_NODES[@]}"; do
    talosctl gen config \
        --output "${BUILD_DIR}/${NODE}.yaml" \
        --output-types worker \
        --with-secrets "${BUILD_DIR}/secrets.yaml" \
        --config-patch @talos/nodes/${NODE}.yaml \
        --config-patch @talos/patches/discovery.yaml \
        --config-patch @talos/patches/iscsi.yaml \
        --config-patch @talos/patches/metrics-server.yaml \
        --config-patch @talos/patches/network.yaml \
        --config-patch @talos/patches/version.yaml \
        --with-docs=false --with-examples=false --force \
        $CLUSTER_NAME $API_ENDPOINT
done

ALL_NODES=( "$CONTROL_PLANE_NODES[@]" "$WORKER_NODES[@]" )
for NODE in "${ALL_NODES[@]}"; do
    talosctl apply-config \
        --nodes ${NODE}.jdmarble.net \
        --file "${BUILD_DIR}/${NODE}.yaml"
done
```

```
rm -fr ${BUILD_DIR}
```

## Bootstrap Argo CD

```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
kubectl config set-context --current --namespace=argocd
argocd login --core
argocd app create cluster --file cluster-app.yaml
argocd app sync cluster --resource '!metallb.io:*:*'
argocd app sync metallb
argocd app sync cluster
```

## Configure Secrets

To allow the Infisical secrets operator to populate secrets in this environment, use the web UI to create a service-token and apply it manually:

```sh
kubectl create secret generic service-token --namespace=infisical --from-literal=infisicalToken=<your-service-token-here>
```

To allow the Teleport Kubernetes agent running in this cluster to join the Teleport Cluster running in this cluster, we have to manually link them up.

```sh
tsh login teleport.jdmarble.net
kubectl --namespace teleport-kube-agent create secret generic teleport-kube-agent-join-token --from-literal=auth-token=$(tctl tokens add --type=app --ttl=1h --format=text)
```
