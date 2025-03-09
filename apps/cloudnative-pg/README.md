# CloudNativePG

[CloudNativePG](https://cloudnative-pg.io) is an open-source operator designed to manage PostgreSQL workloads on any supported Kubernetes cluster.

## Dependencies

This app depends on Cilium to apply the network policy.

## Installation

Apply the kustomization:

```sh
kustomize build . \
  | kapp deploy --app=cnpg --file=- --yes
```

## Upgrade

[New releases are published on the CloudNativePG site.](https://cloudnative-pg.io/releases/).

Update resources URL and the tag and digest in the images section of `kustomization.yaml`.
