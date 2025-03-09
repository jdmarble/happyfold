# Jellyfin

This deploys a software for streaming media to the various client apps.

## Secrets

This app requires several secrets to function.

### Backup Credentials

The configuration data (not media) are backed up to a Backblaze bucket.
There are seperate credentials for read-only (for restoration) and write (for backups).
These secrets are stored in Bitwarden, but deployed to Kuberetes using sealed secrets.
To regenerate the sealed secrets, run these commands:

```sh
echo "[net-jdmarble-jellyfin-RO]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-jellyfin-RO_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-jellyfin-RO_key").value' --raw-output\
)
" | kubectl create --namespace=jellyfin secret generic rclone-destination-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin \
  | kubeseal --format yaml > sealedsecret-rclone-destination-config.yaml

echo "[net-jdmarble-jellyfin-RW]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-jellyfin-RW_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-jellyfin-RW_key").value' --raw-output\
)
hard_delete = true
" | kubectl create --namespace=jellyfin secret generic rclone-source-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin \
  | kubeseal --format yaml > sealedsecret-rclone-source-config.yaml
```

## Installation

Apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=jellyfin --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/jellyfin/jellyfin/releases)
Update the container image tag and digest in `deployment.yaml`.
