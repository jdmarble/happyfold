---
cwd: ..
---

```sh {"name":"unlock Bitwarden","promptEnv":"yes"}
export BW_SESSION="..."
```

```sh {"name":"update Authelia secrets"}
kubectl create --namespace=authelia secret generic authelia --dry-run=client --output=json \
  --from-literal=jwks.rsa.2048.key="$(openssl genrsa -out - 2048)" \
  | kubeseal --format=yaml --merge-into=./apps/authelia/sealedsecret-authelia.yaml

# ArgoCD OIDC client secret
ARGOCD_CLIENT_SECRET=$(openssl rand -hex 63)
kubectl create --namespace=argocd secret generic oidc-client --dry-run=client --output=json \
  --from-literal=oidc.authelia.clientSecret=${ARGOCD_CLIENT_SECRET} \
  | kubeseal --format=yaml --merge-into=./apps/argocd/sealedsecret-oidc-client.yaml
ARGOCD_CLIENT_SECRET_HASH=$(echo -n ${ARGOCD_CLIENT_SECRET} | argon2 $(openssl rand -hex 16) -id -e -m 16 -t 2 -p 1 )
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"argocd\").client_secret = \"${ARGOCD_CLIENT_SECRET_HASH}\"" \
  apps/authelia/configs/configuration.yaml

# Longhorn OIDC client secret
LONGHORN_CLIENT_SECRET=$(openssl rand -hex 63)
echo "\
client_secret = '${LONGHORN_CLIENT_SECRET}'
cookie_secret = '$(openssl rand -base64 32 | tr -- '+/' '-_')'
" | kubectl create --namespace=longhorn-system secret generic oauth2-proxy --dry-run=client --output=json --from-file=oauth2-proxy.conf=/dev/stdin | kubeseal --format yaml > ./apps/longhorn/sealedsecret-oauth2-proxy.yaml
LONGHORN_CLIENT_SECRET_HASH=$(echo -n ${LONGHORN_CLIENT_SECRET} | argon2 $(openssl rand -hex 16) -id -e -m 16 -t 2 -p 1 )
yq -i ".identity_providers.oidc.clients[] |= select(.client_id == \"longhorn\").client_secret = \"${LONGHORN_CLIENT_SECRET_HASH}\"" \
apps/authelia/configs/configuration.yaml
```

```sh {"name":"update cert-manager secret"}
kubectl create --namespace=cert-manager secret generic cloudflare-api-key --dry-run=client --output=json --from-literal=apiKey=$(\
  bw get item cloudflare |\
  jq '.fields[] | select(.name=="net-jdmarble-apikey").value' --raw-output\
) | kubeseal --format yaml > ./apps/cert-manager/sealedsecret-cloudflare-api-key.yaml
```

```sh {"name":"update external-dns secret"}
kubectl create --namespace=external-dns secret generic cloudflare-api-key --dry-run=client --output=json --from-literal=apiKey=$(\
  bw get item cloudflare |\
  jq '.fields[] | select(.name=="net-jdmarble-apikey").value' --raw-output\
) | kubeseal --format yaml > ./apps/external-dns/cloudflare-api-key.yaml
```

```sh {"name":"update Homepage secrets"}
OCTOPRINT_API_KEY=???
kubectl create --namespace=homepage secret generic api-keys --dry-run=client --output=json \
  --from-literal=octoprint_api_key=$OCTOPRINT_API_KEY \
  | kubeseal --format=yaml > ./apps/homepage/sealedsecret-api-keys.yaml
```

```sh {"name":"update Jellyfin secrets"}
echo "[net-jdmarble-jellyfin-RO]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-jellyfin-RO_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-jellyfin-RO_key").value' --raw-output\
)
" | kubectl create --namespace=jellyfin secret generic rclone-destination-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./apps/jellyfin/sealedsecret-rclone-destination-config.yaml

echo "[net-jdmarble-jellyfin-RW]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-jellyfin-RW_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-jellyfin-RW_key").value' --raw-output\
)
hard_delete = true
" | kubectl create --namespace=jellyfin secret generic rclone-source-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./apps/jellyfin/sealedsecret-rclone-source-config.yaml
```

```sh {"name":"update Mealie secrets"}
kubectl create --namespace=mealie secret generic openai --dry-run=client --output=json --from-literal=OPENAI_API_KEY=$(\
  bw get item openai |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie").value' --raw-output\
) |  kubeseal --format yaml > ./apps/mealie/sealedsecret-openai.yaml

echo "[net-jdmarble-mealie-RO]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie-RO_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie-RO_key").value' --raw-output\
)
" | kubectl create --namespace=mealie secret generic rclone-destination-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./apps/mealie/sealedsecret-rclone-destination-config.yaml

echo "[net-jdmarble-mealie-RW]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie-RW_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-mealie-RW_key").value' --raw-output\
)
hard_delete = true
" | kubectl create --namespace=mealie secret generic rclone-source-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./apps/mealie/sealedsecret-rclone-source-config.yaml
```
