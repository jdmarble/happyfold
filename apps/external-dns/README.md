# external-dns

This app configures an external DNS provider (Cloudflare, in this case)
to update DNS entries for services accessible from outside of the cluster.

## Dependencies

This app depends on Sealed Secrets being installed on the cluster.

DNS entries are created for `Service` resources with the
[appropriate annotations](https://kubernetes-sigs.github.io/external-dns/latest/docs/annotations/annotations/).

DNS entries are also created for [`Gateway` resources](https://kubernetes-sigs.github.io/external-dns/latest/docs/sources/gateway/).

## Secrets

The `cloudflare-api-key` secret allows external-dns to make changes to the domain.
The secret is encrypted with Sealed Secrets.
You can regenerate a new secret and encrypt it with the following command:

```sh
kubectl create --namespace=external-dns secret generic cloudflare-api-key --dry-run=client --output=json --from-literal=apiKey=$(\
  bw get item cloudflare |\
  jq '.fields[] | select(.name=="net-jdmarble-apikey").value' --raw-output\
) | kubeseal --format yaml > sealedsecret-cloudflare-api-key.yaml
```

## Installation

First, ensure that all of the dependencies are met.
Then, regenerate the secrets as described in the [Secrets](#secrets) section, if necessary.
Secrets must be regenerated when Sealed Secrets is deployed.
For example, when the cluster is newly deployed.

Finally, apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=external-dns --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/kubernetes-sigs/external-dns/releases)
Read the release notes for upgrade procedures.
