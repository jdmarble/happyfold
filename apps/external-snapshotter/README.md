# CSI Snapshotter

The [CSI snapshotter](https://github.com/kubernetes-csi/external-snapshotter)
is part of Kubernetes implementation of Container Storage Interface (CSI)
and implements both the volume snapshot and the volume group snapshot feature.

This app is what allows the longhorn app to make volume snapshots.

## Installation

Apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=external-snapshotter --file=- --yes
```

## Upgrade

[New releases are published on GitHub,](https://github.com/kubernetes-csi/external-snapshotter/releases)
but don't upgrade to a version that Longhorn doesn't support.
