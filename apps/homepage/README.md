# homepage

This app provides a convenient dashboard and link page for all of the services available on the cluster.

## Dependencies

This app depends on an implementation of the Gateway API to be installed. For example, Cilium.

This app depends on metrics-server to display CPU and memory usage of nodes.

This app depends on external-secrets to store API keys to show service status.

## Secrets

The app needs an API key for [Octoprint](https://octopi.jdmarble.net).

These secrets are stored in Infisical.
The external-secrets app populates `Secret/api-keys` for this purpose.

## Installation

First, ensure that all of the dependencies are met.
Finally, apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=homepage --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/gethomepage/homepage/releases)
Read the release notes for upgrade procedures.

Find the [new container image with the tag that matches the release](https://github.com/gethomepage/homepage/pkgs/container/homepage/versions)
and plug the new tag and digest into `deployment-homepage.yaml`.
