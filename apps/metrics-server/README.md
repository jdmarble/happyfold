# metrics-server

This app provides metrics on cluster nodes such as CPU and memory usage.

## Installation

Apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=metrics-server --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/kubernetes-sigs/metrics-server/releases)
Read the release notes for upgrade procedures.
