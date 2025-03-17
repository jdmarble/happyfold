# authelia

This app provides OIDC authentication for other apps.

## Dependencies

This app depends on Gateway API CRDs deployed by the Cilium app.

This app depends on sealed-secrets.

## Secrets

There are a number of keys that authelia needs to keep secret.
If they are regenerated, you will have to reset any current sessions.
Use the following command to regenerate them, then update the secrets in Infisical:

```sh
AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET_FILE="$(authelia crypto rand --length 64 --charset alphanumeric)"
AUTHELIA_SESSION_SECRET_FILE="$(authelia crypto rand --length 64 --charset alphanumeric)"
AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE="$(authelia crypto rand --length 64 --charset alphanumeric)"
jwks.rsa.2048.key="$(openssl genrsa 2048)"
```

Users and their hashed passwords are stored in `configs/users.yaml`.
To create a password hash, use the following command:

```sh
authelia crypto hash generate argon2
```

## Installation

First, ensure that all of the dependencies are met.
Then, regenerate the secrets as described in the [Secrets](#secrets) section, if necessary.
Secrets must be regenerated when Sealed Secrets is deployed.
For example, when the cluster is newly deployed.

Finally, apply the kustomization.

```sh
kustomize build . \
  | kapp deploy --app=authelia --file=- --yes
```

## Upgrade

[New releases are published on GitHub.](https://github.com/authelia/authelia/releases)
Read the release notes for upgrade procedures.

In `statefulset-authelia.yaml` update the
[image tag and digest](https://github.com/authelia/authelia/pkgs/container/authelia/versions?filters%5Bversion_type%5D=tagged).
