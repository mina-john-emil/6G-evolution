#!/usr/bin/env bash
set -euo pipefail
kubectl -n open5gs get pods
kubectl -n open5gs exec deploy/ueransim -c ue -- ip -br addr | grep uesimtun
for i in 0 1 2; do
  echo "== uesimtun$i"
  kubectl -n open5gs exec deploy/ueransim -c ue -- ping -c 2 -I uesimtun$i 8.8.8.8 | tail -2
done
