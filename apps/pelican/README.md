# Pelican

[Pelican](https://pelican.dev) is a game server control panel.

## Dependencies

This app depends on an implementation of the Gateway API to be installed. For example, Cilium.

This app depends on dragonfly-operator to deploy a Redis alternative.

This app depends on volsync to make backups of the sqlite database.

This app depends on external-secrets to populate secrets for making and restoring backups.

## Secrets

The Backblaze account and key are inserted into the rclone.conf secret for making backups and restoring them on a fresh install.

## Installation

First, ensure that all of the dependencies are met.
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
