# NetBox

[NetBox](https://netbox.readthedocs.io/en/stable/) is the leading solution for modeling and documenting modern networks.

## Secrets

There are several secrets necessary to run Netbox in this configuration.

### OIDC Client Secret

This secret is used to authenticate users using Authelia.
Netbox gets the secret from `externalsecret-oidc-client.yaml`
and the hash of the secret is stored in `authelia/config/configuration.yaml`.
To generate a new, random secret, run the following script to update authelia.
Then, update the secret in Infisical.

```sh
OIDC_CLIENT_ID="netbox"
OIDC_CLIENT_SECRET=$(openssl rand -hex 63)
OIDC_CLIENT_HASH=$(authelia crypto hash generate argon2 --password=${OIDC_CLIENT_SECRET} | yq ".Digest" )
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"${OIDC_CLIENT_ID}\").client_secret = \"${OIDC_CLIENT_HASH}\"" \
../authelia/configs/configuration.yaml
```

Redeploy Authelia if you change this secret.

## Superuser Credentials

The superuser account password and API token are stored in Infisical.

## Backblaze Bucket Credentials

These credentials are for restoring from and backing up to an S3 bucket on Backblaze. They are stored in Infisical.

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

## Manual Backups

You may want to make a backup of the data in a more portable or just a different format.

```sh
kubectl exec --namespace=netbox pg-database-1 --container=postgres -- pg_dump -Fc -d app > netbox-$(date +%F).sql
```

## Upgrade

[New releases are published on GitHub.](https://github.com/netbox-community/netbox-chart/releases)
Change the version of the chart in `kustomize.yaml`.
