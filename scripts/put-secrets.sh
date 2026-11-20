#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY' > /tmp/lab.json
import json, base64, subprocess
def sec(n):
    return json.loads(subprocess.check_output(
        ["kubectl", "-n", "open5gs", "get", "secret", n, "-o", "json"]))["data"]
ue = sec("ue-auth")
print(json.dumps({
    "k":   base64.b64decode(ue["k"]).decode(),
    "opc": base64.b64decode(ue["opc"]).decode(),
    "hnet": sec("open5gs-udm-hnet"),
}))
PY
aws secretsmanager create-secret --region us-east-1 --name sixg-evolution/lab \
  --secret-string file:///tmp/lab.json >/dev/null 2>&1 \
|| aws secretsmanager put-secret-value --region us-east-1 --secret-id sixg-evolution/lab \
  --secret-string file:///tmp/lab.json >/dev/null
rm -f /tmp/lab.json
echo "saved to Secrets Manager: sixg-evolution/lab"
