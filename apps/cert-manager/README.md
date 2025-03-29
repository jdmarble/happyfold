# cert-manager

This app is needed by Cilium to create and renew mTLS certificates.

This app is used to generate certificates trusted by tools like browsers for HTTPS services.

## `ClusterIssuer`s

There are four cluster issuers.

### `selfsigned`

This creates self-signed certificates.
It's used to bootstrap the `ca` issuer.

### `ca`

This creates certificates signed by the cluster's self-signed certificate.
It's used by Cilium to create certificates for mTLS channels between nodes.

## Installation

Apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=cert-manager --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/cert-manager/cert-manager/releases)
Read the release notes for upgrade procedures.

In `kustomization.yaml`, change the link to the manifests (`cert-manager.yaml`) in the resources section
and update the [tags and digests](https://quay.io/repository/jetstack/cert-manager-controller?tab=tags) in the images section.
