Choose a new release version:

```sh
export TALOS_VERSION="v1.9.3"
export K8S_VERSION="1.32.1"
```

Upgrade `talosctl` version in `devbox.json`.

Request a schematic ID from [Image Factory] with your customizations:

```sh
export SCHEMATIC_ID=`
  curl --silent --request POST \
    --data-binary @talos/customization.yaml \
    https://factory.talos.dev/schematics | \
  jq '.id' --raw-output
`
```

* Edit `talos/patches/version.yaml` with the `SCHEMATIC_ID` and installer version.
```sh
export INSTALLER_IMAGE="factory.talos.dev/installer/${SCHEMATIC_ID}:${TALOS_VERSION}"
echo "image: \"${INSTALLER_IMAGE}\""
```

* Change the other image versions in `version.yaml` to match those from the release notes.

* Perform an upgrade with the new installer image tag on each node _one at a time_.
```sh
NODES=(
    a300w
    q330g4
    d08s-4wd2t52
    n07d-4pdc5j2
    n07d-72206j2
    n07d-9wvtpk2
)
for NODE in "${NODES[@]}"; do
  talosctl upgrade --image=${INSTALLER_IMAGE} --nodes=${NODE}
done
```

* Perform a Kubernetes upgrade.
```sh
talosctl --nodes n07d-9wvtpk2 upgrade-k8s --to ${K8S_VERSION}
```

* Use `talosctl apply-config --dry-run ...` to check that the deployed state matches the configuration in the `talos` directory.
