Install tool dependencies:

```sh
brew bundle --no-lock --file=Brewfile
```

Allow `direnv` to export some environment variables:

```sh
direnv allow
```

I store my Talos secrets bundle in a Bitwarden attachment.
Login and download it to the temporary directory.

```
bw login
...
export BW_SESSION=...
bw get attachment secrets.yaml --itemid="b4d62c11-9533-4d3c-b54c-b07a0186abd" --output ${BUILD_DIR}/secrets.yaml
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
talosctl --nodes=n07d-72206j2 kubeconfig "${BUILD_DIR}/kubeconfig.yaml"
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
        --config-patch @talos/patches/cilium.yaml \
        --config-patch @talos/patches/discovery.yaml \
        --config-patch @talos/patches/metrics-server.yaml \
        --config-patch @talos/patches/network.yaml \
        --config-patch @talos/patches/version.yaml \
        --with-docs=false --with-examples=false --force \
        $CLUSTER_NAME $API_ENDPOINT
done

WORKER_NODES=(
    a300w
    q330g4
)
for NODE in "${WORKER_NODES[@]}"; do
    talosctl gen config \
        --output "${BUILD_DIR}/${NODE}.yaml" \
        --output-types worker \
        --with-secrets "${BUILD_DIR}/secrets.yaml" \
        --config-patch @talos/nodes/${NODE}.yaml \
        --config-patch @talos/patches/cilium.yaml \
        --config-patch @talos/patches/discovery.yaml \
        --config-patch @talos/patches/longhorn.yaml \
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
