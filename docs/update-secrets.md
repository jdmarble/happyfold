---
cwd: ..
---

```sh {"name":"unlock Bitwarden","promptEnv":"yes"}
export BW_SESSION="..."
```

```sh {"name":"update external-dns secrets"}
kubectl create --namespace=external-dns secret generic cloudflare-api-key --dry-run=client --output=json --from-literal=apiKey=$(\
  bw get item cloudflare |\
  jq '.fields[] | select(.name=="net-jdmarble-apikey").value' --raw-output\
) | kubeseal --format yaml > ./deployments/external-dns/base/cloudflare-api-key.yaml
```

```sh {"name":"update Jellyfin secret"}
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
hard_delete = true
" | kubectl create --namespace=jellyfin secret generic rclone-destination-config --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./deployments/jellyfin/base/secret_rclone-destination-config.yaml
```
