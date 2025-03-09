# VolSync

[VolSync](https://github.com/backube/volsync)
asynchronously replicates Kubernetes persistent volumes between clusters using either rsync or rclone.
This cluster uses to make backups of PVs to B2.

## Installation

Apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=volsync --file=- --yes
```

## Upgrade

[New releases are published on GitHub](https://github.com/backube/volsync/releases).
Update the manifest URL and container image in the `kustomization.yaml` file.
