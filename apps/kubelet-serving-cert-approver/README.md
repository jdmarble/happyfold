# Kubelet Serving Certificate Approver

This app automatically approves certificate signing requests for kubelets.

## Installation

Apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=kubelet-serving-cert-approver --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/alex1989hu/kubelet-serving-cert-approver/releases)
Read the release notes for upgrade procedures.

In `kustomization.yaml` update the
[image tag and digest](https://github.com/alex1989hu/kubelet-serving-cert-approver/pkgs/container/kubelet-serving-cert-approver).
