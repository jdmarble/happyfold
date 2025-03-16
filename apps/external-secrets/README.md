# External Secrets Operator

[External Secrets Operator](https://external-secrets.io)
is a Kubernetes operator that integrates external secret management systems like
[Infisical](https://infisical.com).

## Installation

Apply the kustomization:

```sh
kustomize build --enable-helm . \
  | kapp deploy --app=external-secrets --file=- --yes
```

Create a secret containing the machine client id and secret from the
[machine identity](https://app.infisical.com/organization/access-management?selectedTab=identities):

```sh
 kubectl create secret generic infisical-machine-client \
  --from-literal=clientId=<machine identity client id> --from-literal=clientSecret=<machine identity client secret>
```

## Upgrade

[New releases are published on GitHub.](https://github.com/external-secrets/external-secrets/releases)
Change the version of the chart in `kustomize.yaml`.
