# NetBox

[NetBox](https://netbox.readthedocs.io/en/stable/) is the leading solution for modeling and documenting modern networks.

## Secrets

There are several secrets necessary to run Netbox in this configuration.

### OIDC Client Secret

This secret is used to authenticate users using Authelia.
Netbox gets the secret from `sealedsecret-oidc-client.yaml`
and the hash of the secret is stored in `authelia/config/configuration.yaml`.
To generate a new, random secret, run the following script:

```sh
OIDC_CLIENT_ID="netbox"
OIDC_CLIENT_SECRET=$(openssl rand -hex 63)
OIDC_CLIENT_HASH=$(authelia crypto hash generate argon2 --password=${OIDC_CLIENT_SECRET} | yq ".Digest" )
kubectl create --namespace=netbox secret generic oidc-client --dry-run=client --output=json \
  --from-literal=SOCIAL_AUTH_OIDC_SECRET=${OIDC_CLIENT_SECRET} \
  | kubeseal --format=yaml > sealedsecret-oidc-client.yaml
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"${OIDC_CLIENT_ID}\").client_secret = \"${OIDC_CLIENT_HASH}\"" \
../authelia/configs/configuration.yaml
```

Redeploy Authelia if you change this secret.

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
  kubeseal --format yaml > sealedsecret-superuser.yaml
```

## Backblaze Bucket Credentials

These credentials are for restoring from and backing up to an S3 bucket on Backblaze.

```sh
ACCESS_KEY_ID=$(\
  bw get item netbox.jdmarble.net |\
  jq '.fields[] | select(.name=="ACCESS_KEY_ID").value' --raw-output\
)
ACCESS_SECRET_KEY=$(\
  bw get item netbox.jdmarble.net |\
  jq '.fields[] | select(.name=="ACCESS_SECRET_KEY").value' --raw-output\
)
kubectl create --namespace=netbox secret generic s3-backup-credentials --dry-run=client --output=json \
  --from-literal=ACCESS_KEY_ID=$ACCESS_KEY_ID \
  --from-literal=ACCESS_SECRET_KEY=$ACCESS_SECRET_KEY \
| kubeseal --format yaml > sealedsecret-s3-backup-credentials.yaml
```

## Installation

The Postgres database is configured to restore from Backblaze on creation.
It is also configured to backup to Backblaze.
Unfortunately, it can't backup to and restore from the same place.
You'll get an error "WAL archive check failed for server... Expected empty archive".
To resolve this issue, you'll have to perform the following procedure:

```sh
backblaze-b2 account authorize $ACCESS_KEY_ID $ACCESS_SECRET_KEY
backblaze-b2 rm --recursive b2://net-jdmarble-netbox/pg-database-restore
backblaze-b2 sync b2://net-jdmarble-netbox/pg-database-backup b2://net-jdmarble-netbox/pg-database-restore
backblaze-b2 rm --recursive b2://net-jdmarble-netbox/pg-database-backup
```

Apply the kustomization:

```sh
kustomize build --enable-helm . \
  | kapp deploy --app=netbox --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/netbox-community/netbox-chart/releases)
Change the version of the chart in `kustomize.yaml`.
