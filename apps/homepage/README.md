# homepage

This app provides a convenient dashboard and link page for all of the services available on the cluster.

## Dependencies

This app depends on an implementation of the Gateway API to be installed. For example, Cilium.

This app depends on metrics-server to display CPU and memory usage of nodes.

## Secrets

```sh
OCTOPRINT_API_KEY=$(bw get item octoprint | jq '.fields[] | select(.name=="homepage-api-key").value' --raw-output)
kubectl create --namespace=homepage secret generic api-keys --dry-run=client --output=json \
  --from-literal=octoprint_api_key=$OCTOPRINT_API_KEY \
  | kubeseal --format=yaml > sealedsecret-api-keys.yaml
```


## Installation

First, ensure that all of the dependencies are met.
Then, regenerate the secrets if necessary.

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
