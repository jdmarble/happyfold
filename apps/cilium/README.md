# Cilium

[Cilium](https://cilium.io/) performs a number of functions as deployed in this configuration:

* **Container Network Interface (CNI)**:
  The cluster has been installed with a configuration that disables the
  default CNI (Calico). Before the cluster can be ready, you have to install a
  CNI (Cilium).
* **Gateway API**:
  The applications that need to accept connections from outside of the cluster
  request that capability using Gateway API resources such as `HTTPRoute`.
* **Network Policy Enforcer**:
  Cilium enforces all of the applications' `NetworkPolicy` rules.

## Installation

Apply the kustomization in stages: CRDs then everything else.

```sh
kustomize build --enable-helm apps/cilium \
  | kubectl slice --include-kind CustomResourceDefinition --stdout \
  | kubectl apply -f -
sleep 10  # Wait for the CRDs to apply.
kustomize build --enable-helm apps/cilium \
  | kubectl slice --exclude-kind CustomResourceDefinition --stdout \
  | kubectl apply -f -
```

## Upgrade

[New releases are published on GitHub.](https://github.com/cilium/cilium/releases)
Read the release notes for upgrade procedures.
