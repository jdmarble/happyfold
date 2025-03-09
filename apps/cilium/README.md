# Cilium

[Cilium](https://cilium.io/) performs a number of functions as deployed in this configuration:

* **Container Network Interface (CNI)**:
  The cluster has been installed with a configuration that disables the
  default CNI (Calico). Before the cluster can be ready, you have to install a
  CNI (Cilium).
* **Gateway API**:
  The applications that need to accept connections from outside of the cluster
  request that capability using Gateway API resources such as `HTTPRoute`.
* **L2 "Load Balancer"**
  Load balancer services are assigned external IP addresses using L2 announcements (VIPs).
* **Network Policy Enforcer**:
  Cilium enforces all of the applications' `NetworkPolicy` rules.

## Installation

Change your current working directory to the app directory.

Install required CRDs from cert-manager if not already present.
Cilium has to be installed before cert-manager,
but these CRDs create a circular dependency that we resolve with this command:

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.crds.yaml
```

Run the following command to install Cilium:

```sh
kustomize build --enable-helm . \
  | kapp deploy --app=cilium --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/cilium/cilium/releases)
Read the release notes for upgrade procedures.
