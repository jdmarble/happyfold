# NetBox

[NetBox](https://netbox.readthedocs.io/en/stable/) is the leading solution for modeling and documenting modern networks.

## Installation

The Postgres database is configured to restore from Backblaze on creation.
It is also configured to backup to Backblaze.
Unfortunately, it can't backup to and restore from the same place.
You'll get an error "WAL archive check failed for server... Expected empty archive".
To resolve this issue, you'll have to perform the following procedure:

1. Login to Backblaze and click "Make Full Bucket Snapshot" on the "net-jdmarble-netbox" bucket because you're going to fuck it up.
   Wait for the snapshot to "prepare" then download it.
1. Determine which path, `postgres-db-A` or `postgres-db-B` is the latest backup directory.
   It'll be the one with the latest uploaded date.
1. Delete the _older_ directory.
   It needs to be empty or the [safety checks](https://cloudnative-pg.io/documentation/1.20/recovery/#restoring-into-a-cluster-with-a-backup-section)
   will stop the restoration.
1. Edit `cluster-pg-database.yaml` and swap the backup and restore directory names.
   The `externalClusters[...].barmanObjectStore.serverName` should be the latest backup directory.
   The `backup.barmanObjectStore.serverName` should be the directory you just deleted.

Apply the kustomization:

```sh
kustomize build --enable-helm . \
  | kapp deploy --app=netbox --file=- --yes
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

## Backblaze Bucket Credentials

These credentials are for restoring from and backing up to an S3 bucket on Backblaze.

```sh
kubectl create --namespace=netbox secret generic s3-backup-credentials --dry-run=client --output=json \
  --from-literal=ACCESS_KEY_ID=$(\
      bw get item netbox.jdmarble.net |\
      jq '.fields[] | select(.name=="ACCESS_KEY_ID").value' --raw-output\
    ) \
  --from-literal=ACCESS_SECRET_KEY=$(\
      bw get item netbox.jdmarble.net |\
      jq '.fields[] | select(.name=="ACCESS_SECRET_KEY").value' --raw-output\
    ) \
| kubeseal --format yaml > sealedsecret-s3-backup-credentials.yaml
```

## Upgrade

[New releases are published on GitHub.](https://github.com/netbox-community/netbox-chart/releases)
Change the version of the chart in `kustomize.yaml`.
