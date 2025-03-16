# Jellyfin

This deploys a software for streaming media to the various client apps.

## Secrets

This app requires several secrets to function.

### Backup Credentials

The configuration data (not media) are backed up to a Backblaze bucket.
The Backblaze account and key are inserted into the rclone.conf secret for making backups and restoring them on a fresh install.

## Installation

Apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=jellyfin --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/jellyfin/jellyfin/releases)
Update the container image tag and digest in `deployment.yaml`.
