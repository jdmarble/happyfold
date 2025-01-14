# Project Zomboid

Project Zomboid is an open-world, isometric video game
set in the post-apocalyptic, zombie-infested exclusion zone of the fictional Knox Country (formerly Knox County), Kentucky, United States,
where the player is challenged to survive for as long as possible before inevitably dying.

## Installation

Apply the kustomization.

```sh
kubectl apply -k apps/zomboid
```

## Secrets

There are some secrets necessary to run Project Zomboid in this configuration.

### Backblaze

The Backblaze secrets are for making backups and restoring them on a fresh install.

```sh
echo "[net-jdmarble-zomboid-RO]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-zomboid-RO_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-zomboid-RO_key").value' --raw-output\
)
" | kubectl create --namespace=zomboid secret generic rclone-destination --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./apps/zomboid/sealedsecret-rclone-destination.yaml

echo "[net-jdmarble-zomboid-RW]
type = b2
account = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-zomboid-RW_account").value' --raw-output\
)
key = $(\
  bw get item backblaze |\
  jq '.fields[] | select(.name=="net-jdmarble-zomboid-RW_key").value' --raw-output\
)
hard_delete = true
" | kubectl create --namespace=zomboid secret generic rclone-source --dry-run=client --output=json --from-file=rclone.conf=/dev/stdin | kubeseal --format yaml > ./apps/zomboid/sealedsecret-rclone-source.yaml
```

## Upgrade

????
