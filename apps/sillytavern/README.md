# SillyTavern

[SillyTavern](https://docs.sillytavern.app) is a user interface that allows you to interact with text generation LLMs, image generation engines, and TTS voice models.

## Installation

Apply the kustomization:

```sh
kubectl apply -k apps/sillytavern
```

## Secrets

There are secrets necessary to run SillyTavern in this configuration.

### OIDC Client Secret

This secret is used to authenticate users using Authelia.
SillyTavern gets the secret from `sealedsecret-oidc-client.yaml` and the hash of the secret is stored in `authelia/config/configuration.yaml`.
To generate a new, random secret, run the following script:

```sh
OIDC_CLIENT_SECRET=$(openssl rand -hex 63)
echo "\
client_secret = '${OIDC_CLIENT_SECRET}'
cookie_secret = '$(openssl rand -base64 32 | tr -- '+/' '-_')'
" | kubectl create --namespace=sillytavern secret generic oauth2-proxy --dry-run=client --output=json --from-file=oauth2-proxy.conf=/dev/stdin | kubeseal --format yaml > ./apps/sillytavern/sealedsecret-oauth2-proxy.yaml
OIDC_CLIENT_SECRET_HASH=$(echo -n ${OIDC_CLIENT_SECRET} | argon2 $(openssl rand -hex 16) -id -e -m 16 -t 2 -p 1 )
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"sillytavern\").client_secret = \"${OIDC_CLIENT_SECRET_HASH}\"" \
apps/authelia/configs/configuration.yaml
```

## Upgrade

[New releases are published on GitHub.](https://github.com/SillyTavern/SillyTavern/releases)
Get the digest of updated container image [from the packages list](https://github.com/SillyTavern/SillyTavern/pkgs/container/sillytavern).
Then, update the image in `statefulset-sillytavern.yaml`.
