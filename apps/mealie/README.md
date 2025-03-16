# Mealie

Mealie is a self hosted recipe manager and meal planner with a RestAPI backend
and a reactive frontend application built in Vue for a pleasant user experience
for the whole family.

## Secrets

There are several secrets necessary to run Mealie in this configuration.

### OIDC Client Secret

This secret is used to authenticate users using Authelia.
Mealie gets the secret from `sealedsecret-oidc-client.yaml`
and the hash of the secret is stored in `authelia/config/configuration.yaml`.
To generate a new, random secret, run the following script:

```sh
OIDC_CLIENT_ID="mealie"
OIDC_CLIENT_SECRET=$(openssl rand -hex 63)
OIDC_CLIENT_HASH=$(authelia crypto hash generate argon2 --password=${OIDC_CLIENT_SECRET} | yq ".Digest" )
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"${OIDC_CLIENT_ID}\").client_secret = \"${OIDC_CLIENT_HASH}\"" \
  ../authelia/configs/configuration.yaml
```

Edit the secret in Infisical and redeploy the Authelia app whenever the client secret changes.

### OpenAI API Key

The OpenAI secret is to allow Mealie to call out to OpenAI's APIs.

### B2 Key

The Backblaze account and key are inserted into the rclone.conf secret for making backups and restoring them on a fresh install.

## Installation

First, ensure all dependencies are installed.
Finally, apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=mealie --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/mealie-recipes/mealie/releases)
Update the container image tag and digest in `deployment-mealie.yaml`.
Review any [update instructions](https://docs.mealie.io/documentation/getting-started/updating/).
