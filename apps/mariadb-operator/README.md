# mariadb-operator

[mariadb-operator](https://github.com/mariadb-operator/mariadb-operator)
allows for declarative management of MariaDB using Kubernetes CRDs rather than imperative commands.

## Installation

Apply the kustomization:

```sh
kustomize build --enable-helm . \
  | kapp deploy --app=mariadb-operator --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/mariadb-operator/mariadb-operator/releases)
Change the version of the chart in `kustomize.yaml`.
