# Mealie

Mealie is a self hosted recipe manager and meal planner with a RestAPI backend
and a reactive frontend application built in Vue for a pleasant user experience
for the whole family.

## Installation

Apply the kustomization.

```sh
kubectl apply -k apps/mealie
```

## Secrets

There are several secrets necessary to run Mealie in this configuration.

### OIDC Client Secret

This secret is used to authenticate users using Authelia.
Mealie gets the secret from `sealedsecret-oidc-client.yaml`
and the hash of the secret is stored in `authelia/config/configuration.yaml`.
To generate a new, random secret, run the following script:

```sh
OIDC_CLIENT_SECRET=$(openssl rand -hex 63)
kubectl create --namespace=mealie secret generic oidc-client --dry-run=client --output=json \
  --from-literal=OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET} \
  | kubeseal --format=yaml --merge-into=./apps/mealie/sealedsecret-oidc-client.yaml
OIDC_CLIENT_SECRET_HASH=$(echo -n ${OIDC_CLIENT_SECRET} | argon2 $(openssl rand -hex 16) -id -e -m 16 -t 2 -p 1 )
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"mealie\").client_secret = \"${OIDC_CLIENT_SECRET_HASH}\"" \
  apps/authelia/configs/configuration.yaml
```

The OpenAI secret is to allow Mealie to call out to OpenAI's APIs.

```sh
kubectl create --namespace=mealie secret generic openai --dry-run=client --output=json --from-literal=OPENAI_API_KEY=$(\
  bw get item openai |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie").value' --raw-output\
) |  kubeseal --format yaml > ./apps/mealie/sealedsecret-openai.yaml
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
" | kubectl create --namespace=mealie secret generic rclone-destination-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./apps/mealie/sealedsecret-rclone-destination-config.yaml

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
" | kubectl create --namespace=mealie secret generic rclone-source-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./apps/mealie/sealedsecret-rclone-source-config.yaml
```

## Upgrade

[New releases are published on GitHub.](https://github.com/mealie-recipes/mealie/releases)
Update the container image tag and digest in `deployment-mealie.yaml`.
Review any [update instructions](https://docs.mealie.io/documentation/getting-started/updating/).
