# NetBox

[NetBox](https://netbox.readthedocs.io/en/stable/) is the leading solution for modeling and documenting modern networks.

## Installation

Apply the kustomization:

```sh
kustomize build --enable-helm apps/netbox \
  | kubectl apply -f -
```

## Secrets

There are several secrets necessary to run Netbox in this configuration.

### OIDC Client Secret

This secret is used to authenticate users using Authelia.
Netbox gets the secret from `sealedsecret-oidc-client.yaml`
and the hash of the secret is stored in `authelia/config/configuration.yaml`.
To generate a new, random secret, run the following script:

```sh
OIDC_CLIENT_SECRET=$(openssl rand -hex 63)
kubectl create --namespace=netbox secret generic oidc-client --dry-run=client --output=json \
  --from-literal=SOCIAL_AUTH_OIDC_SECRET=${OIDC_CLIENT_SECRET} \
  | kubeseal --format=yaml --merge-into=./apps/netbox/sealedsecret-oidc-client.yaml
OIDC_CLIENT_SECRET_HASH=$(echo -n ${OIDC_CLIENT_SECRET} | argon2 $(openssl rand -hex 16) -id -e -m 16 -t 2 -p 1 )
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"netbox\").client_secret = \"${OIDC_CLIENT_SECRET_HASH}\"" \
  apps/authelia/configs/configuration.yaml
```

## Superuser Credentials

This command will get the superuser account credentials.

```sh
kubectl create --namespace=netbox secret generic superuser --dry-run=client --output=json \
  --from-literal=username=jdmarble_admin \
  --from-literal=password=$(bw get password netbox.jdmarble.net)\
  --from-literal=email=jdmarble_admin@jdmarble.com \
  --from-literal=api_token=$(\
      bw get item netbox.jdmarble.net |\
      jq '.fields[] | select(.name=="api_token").value' --raw-output\
    ) |\
  kubeseal --format yaml > ./apps/netbox/sealedsecret-superuser.yaml
```

## Upgrade

[New releases are published on GitHub.](https://github.com/netbox-community/netbox-chart/releases)
Change the version of the chart in `kustomize.yaml`.
