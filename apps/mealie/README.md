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
kubectl create --namespace=mealie secret generic oidc-client --dry-run=client --output=json \
  --from-literal=OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET} \
  | kubeseal --format=yaml > sealedsecret-oidc-client.yaml
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"${OIDC_CLIENT_ID}\").client_secret = \"${OIDC_CLIENT_HASH}\"" \
  ../authelia/configs/configuration.yaml
```

The OpenAI secret is to allow Mealie to call out to OpenAI's APIs.

```sh
kubectl create --namespace=mealie secret generic openai --dry-run=client --output=json --from-literal=OPENAI_API_KEY=$(\
  bw get item openai |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie").value' --raw-output\
) |  kubeseal --format yaml > sealedsecret-openai.yaml
```

The Backblaze secrets are for making backups and restoring them on a fresh install.

```sh
echo "[net-jdmarble-mealie-RO]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie-RO_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie-RO_key").value' --raw-output\
)
" | kubectl create --namespace=mealie secret generic rclone-destination-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin \
  | kubeseal --format yaml > sealedsecret-rclone-destination-config.yaml

echo "[net-jdmarble-mealie-RW]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie-RW_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie-RW_key").value' --raw-output\
)
hard_delete = true
" | kubectl create --namespace=mealie secret generic rclone-source-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin \
  | kubeseal --format yaml > sealedsecret-rclone-source-config.yaml
```

## Installation

First, ensure all dependencies are installed.
Next, regenerate the secrets if necessary.

Finally, apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=mealie --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/mealie-recipes/mealie/releases)
Update the container image tag and digest in `deployment-mealie.yaml`.
Review any [update instructions](https://docs.mealie.io/documentation/getting-started/updating/).
