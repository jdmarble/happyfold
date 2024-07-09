---
cwd: ..
---

```sh {"name":"unlock Bitwarden","promptEnv":"yes"}
export BW_SESSION="..."
```

```sh {"name":"update external-dns secret"}
kubectl create --namespace=external-dns secret generic cloudflare-api-key --dry-run=client --output=json --from-literal=apiKey=$(\
  bw get item cloudflare |\
  jq '.fields[] | select(.name=="net-jdmarble-apikey").value' --raw-output\
) | kubeseal --format yaml > ./deployments/external-dns/base/cloudflare-api-key.yaml
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
" | kubectl create --namespace=jellyfin secret generic rclone-destination-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./deployments/jellyfin/base/sealedsecret-rclone-destination-config.yaml

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
" | kubectl create --namespace=jellyfin secret generic rclone-source-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./deployments/jellyfin/base/sealedsecret-rclone-source-config.yaml

```
