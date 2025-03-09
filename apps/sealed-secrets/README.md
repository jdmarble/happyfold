# Sealed Secrets

This app is needed by various other apps to encrypt secrets into files that are safe to commit.
The sealed secrets are decrypted only in the cluster.

## Installation

Apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=sealed-secrets --file=- --yes
```

## Upgrade

[New releases are published by Bitnami on GitHub.](https://github.com/bitnami-labs/sealed-secrets/releases)
Read the release notes for upgrade procedures.

In `kustomization.yaml`, change the link to the manifests (`controller.yaml`) in the resources section
and update the tag/digest in the images section.

Update the client version. For example, in the `devbox.json` file.
