```
nix develop
```

```
CLUSTER_NAME=jdmarble.net
API_ENDPOINT=https://q330g4.jdmarble.net:6443
BUILD_DIR=$(pwd)/build
mkdir -p "${BUILD_DIR}"
```

```
bw login
...
export BW_SESSION=...
bw get notes talos-secrets.yaml > "${BUILD_DIR}/secrets.yaml"
```

```
talosctl gen config  \
    --with-secrets "${BUILD_DIR}/secrets.yaml" \
    --output-types talosconfig --output "${BUILD_DIR}/talosconfig" \
    $CLUSTER_NAME $API_ENDPOINT
talosctl config merge "${BUILD_DIR}/talosconfig"
```

Edit `~/.talos/config` to set the endpoints to:

```yaml
        endpoints:
            - q330g4.jdmarble.net
```


```
NODE=q330g4
talosctl gen config \
    --output "${BUILD_DIR}/${NODE}.yaml" \
    --output-types controlplane \
    --dns-domain local.$CLUSTER_NAME \
    --with-cluster-discovery=false \
    --with-secrets "${BUILD_DIR}/secrets.yaml" \
    --config-patch @talos/nodes/${NODE}.yaml \
    --config-patch @talos/patches/network.yaml \
    --with-docs=false --with-examples=false \
    $CLUSTER_NAME $API_ENDPOINT
talosctl apply-config \
    --nodes ${NODE}.jdmarble.net \
    --file "${BUILD_DIR}/${NODE}.yaml"
```

```
NODE=gigabyte
talosctl gen config \
    --output "${BUILD_DIR}/${NODE}.yaml" \
    --output-types worker \
    --dns-domain local.$CLUSTER_NAME \
    --with-cluster-discovery=false \
    --with-secrets "${BUILD_DIR}/secrets.yaml" \
    --config-patch @talos/nodes/${NODE}.yaml \
    --config-patch @talos/patches/network.yaml \
    --with-docs=false --with-examples=false \
    $CLUSTER_NAME $API_ENDPOINT
talosctl apply-config \
    --nodes ${NODE}.jdmarble.net \
    --file "${BUILD_DIR}/${NODE}.yaml"
```

```
rm -fr ${BUILD_DIR}
```
TODO: Can't I pipe things without temporary files on disk?