# Pelican

[Pelican](https://pelican.dev) is a game server control panel.

## Dependencies

This app depends on an implementation of the Gateway API to be installed. For example, Cilium.

This app depends on dragonfly-operator to deploy a Redis alternative.

This app depends on sealed-secrets to encrypt secrets.

This app depends on cert-manager to issue TLS certificates.

This app depends on volsync to make backups of the sqlite database.

## Secrets

This app requires several secrets to function.

### Backup Credentials

The configuration data (not media) are backed up to a Backblaze bucket.
There are seperate credentials for read-only (for restoration) and write (for backups).
These secrets are stored in Bitwarden, but deployed to Kuberetes using sealed secrets.
To regenerate the sealed secrets, run these commands:

```sh
echo "[net-jdmarble-pelican-sqlite-RO]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-pelican-sqlite-RO_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-pelican-sqlite-RO_key").value' --raw-output\
)
" | kubectl create --namespace=pelican secret generic rclone-destination-sqlite --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin \
  | kubeseal --format yaml > sealedsecret-rclone-destination-sqlite.yaml

echo "[net-jdmarble-pelican-sqlite-RW]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-pelican-sqlite-RW_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-pelican-sqlite-RW_key").value' --raw-output\
)
hard_delete = true
" | kubectl create --namespace=pelican secret generic rclone-source-sqlite --dry-run=client --output=json \
      --from-file=rclone.conf=/dev/stdin \
  | kubeseal --format yaml > sealedsecret-rclone-source-sqlite.yaml
```

## Installation

First, ensure that all of the dependencies are met.
Then, regenerate the secrets if necessary.

Finally, apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=pelican --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/pelican-dev/panel/releases)
Read the release notes for upgrade procedures.

Find the [new container image with the tag that matches the release](https://github.com/pelican-dev/panel/pkgs/container/panel)
and plug the new tag and digest into `deployment-pelican.yaml`.
