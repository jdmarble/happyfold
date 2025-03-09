# cert-manager

This app is needed by Cilium to create and renew mTLS certificates.

This app is used to generate certificates trusted by tools like browsers for HTTPS services.

## Dependencies

This app depends on Sealed Secrets being installed on the cluster.

## `ClusterIssuer`s

There are four cluster issuers.

### `selfsigned`

This creates self-signed certificates.
It's used to bootstrap the `ca` issuer.

### `ca`

This creates certificates signed by the cluster's self-signed certificate.
It's used by Cilium to create certificates for mTLS channels between nodes.

### `staging-letsencrypt-cloudflare`

This creates certificates signed by Let's Encrypt's staging service.
It uses a DNS challenge against a domain registered on Cloudflare.
These certificates are for testing only before rolling out to the next issuer.

### `letsencrypt-cloudflare`

Same as `staging-letsencrypt-cloudflare`, but for production Let's Encrypt.
This is used for certificates that need to be trusted by tools running outside of the cluster like browsers.

## Secrets

The app needs write access to Cloudflare DNS to prove we own that domain to generate trusted certificates.
You can generate a new, encrypted secret containing the necessary Cloudflare API key with these commands:

```sh
kubectl create --namespace=cert-manager secret generic cloudflare-api-key --dry-run=client --output=json --from-literal=apiKey=$(\
  bw get item cloudflare |\
  jq '.fields[] | select(.name=="net-jdmarble-apikey").value' --raw-output\
) | kubeseal --format yaml > sealedsecret-cloudflare-api-key.yaml
```

## Installation

First, ensure that all of the dependencies are met.
Then, regenerate the secrets as described in the [Secrets](#secrets) section, if necessary.
Secrets must be regenerated when Sealed Secrets is deployed.
For example, when the cluster is newly deployed.

Finally, apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=cert-manager --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/cert-manager/cert-manager/releases)
Read the release notes for upgrade procedures.

In `kustomization.yaml`, change the link to the manifests (`cert-manager.yaml`) in the resources section
and update the [tags and digests](https://quay.io/repository/jetstack/cert-manager-controller?tab=tags) in the images section.
