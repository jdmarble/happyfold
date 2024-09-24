# Sets environment variables for this project when your working directory is inside.
brew "direnv"
# Some script commands use `kubectl`
brew "kubernetes-cli"
# Secret bundle comes from Bitwarden.
brew "bitwarden-cli"
# Need `talosctl` to configure and manage the nodes.
tap "siderolabs/tap"
brew "siderolabs/tap/talosctl"
# Need to slice json and yaml to regenerate secrets
brew "jq"
brew "yq"
# Create and update sealed-secrets.
brew "kubeseal"
# The Kustomize built in to `kubectl` is missing features like Helm templates used for one of the apps.
brew "kustomize"
# Hash passwords in secrets generation script
brew "argon2"
# Generate RSA for secret
brew "openssl@3"
