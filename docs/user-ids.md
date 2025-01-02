# User IDs

Containers should run as a high UID to avoid host conflict.
See
[this justification](https://docs.prismacloud.io/en/enterprise-edition/policy-reference/kubernetes-policies/kubernetes-policy-index/bc-k8s-37#description)
.

Each application is assigned one or more UIDs in the following table.
A '0' indicates that the application requires privileges for all pods and only runs as root.

| Application          | UID   |
|----------------------|-------|
| cilium               | 0     |
| metrics-server       | 10000 |
| sealed-secrets       | 10100 |
| cert-manager         | 10200 |
| external-snapshotter | 10300 |
| longhorn             | 10400 |
| factorio             | 11845 |
