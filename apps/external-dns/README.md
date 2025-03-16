# external-dns

This app configures an external DNS provider (Cloudflare, in this case)
to update DNS entries for services accessible from outside of the cluster.

## Dependencies

This app depends on external-secrets to store the Cloudflare credentials.

DNS entries are created for `Service` resources with the
[appropriate annotations](https://kubernetes-sigs.github.io/external-dns/latest/docs/annotations/annotations/).

DNS entries are also created for [`Gateway` resources](https://kubernetes-sigs.github.io/external-dns/latest/docs/sources/gateway/).

## Secrets

The app needs write access to Cloudflare DNS.
The Cloudflare credentials are stored in Infisical.
The external-secrets app populates `Secret/cloudflare-api-key` for this purpose.

## Installation

First, ensure that all of the dependencies are met.
Finally, apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=external-dns --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/kubernetes-sigs/external-dns/releases)
Read the release notes for upgrade procedures.
