# Gateway

This "app" is not an actual piece of software, but a collection of resources that configure the gateway API.

## Dependencies

This app depends on cilium to implement the Gateway API class.

This app depends on cert-manager to generate TLS certificates for the HTTPS gateway.
The following issuers are configured for this purpose:

### `staging-letsencrypt-cloudflare`

This creates certificates signed by Let's Encrypt's staging service.
It uses a DNS challenge against a domain registered on Cloudflare.
These certificates are for testing only before rolling out to the next issuer.

### `letsencrypt-cloudflare`

Same as `staging-letsencrypt-cloudflare`, but for production Let's Encrypt.
This is used for certificates that need to be trusted by tools running outside of the cluster like browsers.

This app depends on external-secrets to store the Cloudflare credentials necessary to perform the DNS challenge.

## Secrets

The app needs write access to Cloudflare DNS to prove we own that domain to generate trusted certificates.
The Cloudflare credentials are stored in Infisical.
The external-secrets app populates `Secret/cloudflare-api-key` for this purpose.

## Installation

Apply the kustomization:

```sh
kustomize build . \
  | kapp deploy --app=gateway --file=- --yes
```
