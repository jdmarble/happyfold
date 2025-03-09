# Longhorn

Longhorn is a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes.

## Dependencies

This app depends on external-snapshotter to make volume snapshots work.

This app depends on sealed-secrets for protecting the OIDC client secret.

This app depends on Cilium to implement the Gateway API for access to the user interface front end.

## Secrets

The Longhorn UI frontend is protected by OAuth2-Proxy.
OAuth2-Proxy requires a secret, client key stored.
A hash of the secret is needed by Authelia for validation.
The following commands will generate a new secret, store it in a sealed-secret, and insert the hash into the Authelia configuration file.

```sh
OIDC_CLIENT_ID="longhorn"
OIDC_CLIENT_SECRET=$(openssl rand -hex 63)
OIDC_CLIENT_HASH=$(authelia crypto hash generate argon2 --password=${OIDC_CLIENT_SECRET} | yq ".Digest" )
COOKIE_SECRET=$(openssl rand -base64 32 | tr -- '+/' '-_')
echo "\
client_secret = '${OIDC_CLIENT_SECRET}'
cookie_secret = '${COOKIE_SECRET}'
" | kubectl create --namespace=longhorn-system secret generic oauth2-proxy --dry-run=client --output=json --from-file=oauth2-proxy.conf=/dev/stdin \
| kubeseal --format yaml > ./sealedsecret-oauth2-proxy.yaml
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"${OIDC_CLIENT_ID}\").client_secret = \"${OIDC_CLIENT_HASH}\"" \
../authelia/configs/configuration.yaml
```

Redeploy authelia after updating this secret.

## Installation

First, ensure that all of the dependencies are met.
Then, regenerate the secrets as described in the [Secrets](#secrets) section, if necessary.
Secrets must be regenerated when Sealed Secrets is deployed.
For example, when the cluster is newly deployed.

Finally, apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=longhorn --file=- --yes
```

## Upgrade

### Longhorn

[New releases are published on GitHub.](https://github.com/longhorn/longhorn/releases)
Read the "Upgrade" page from the documentation site of the new release for upgrade procedures.
For example: https://longhorn.io/docs/1.8.0/deploy/upgrade/ .

Check the version of ["Enable CSI Snapshot Support on a Cluster](https://longhorn.io/docs/1.8.0/snapshots-and-backups/csi-snapshot-support/enable-csi-snapshot-support/#if-your-kubernetes-distribution-does-not-bundle-the-snapshot-controller)
that matches the version you are upgrading to. Upgrade the external-snapshotter app if required.

### OAuth2-Proxy

[New releases are published on GitHub.](https://github.com/oauth2-proxy/oauth2-proxy/releases)
Read the release notes for upgrade procedures.

Update the image [tag and digest](https://quay.io/repository/oauth2-proxy/oauth2-proxy?tab=tags) in `deployment-oauth2-proxy.yaml`.
