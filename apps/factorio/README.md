# Factorio

This deploys a server for the game Factorio.

## Installation

Apply the kustomization.

```sh
kubectl apply -k apps/factorio
```

## Upgrade

[New releases are published on GitHub.](https://github.com/goofball222/factorio/pkgs/container/factorio)
Update the container image tag and digest in `statefulset-factorio.yaml`.
