#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT_DIR"

CONTAINER_NAME="openclaw"

echo "=== OpenClaw Provision ==="

# Validate .env exists
if [[ ! -f .env ]]; then
  echo "ERROR: .env file not found. Copy .env_example to .env and configure."
  exit 1
fi

# Load env
set -a
source .env
set +a

# Check required vars
REQUIRED_VARS="COMPASS_API_KEY TELEGRAM_BOT_TOKEN OPENCLAW_GATEWAY_AUTH_TOKEN"
for var in $REQUIRED_VARS; do
  if [[ -z "${!var:-}" ]]; then
    echo "ERROR: $var is not set in .env"
    exit 1
  fi
done

# Ensure directories
mkdir -p data/.openclaw data/workspace data/clippy data/whoop

# Initialize config if not exists
if [[ ! -f data/.openclaw/openclaw.json ]]; then
  cp config/openclaw.json_example data/.openclaw/openclaw.json
  chmod 600 data/.openclaw/openclaw.json
fi

# Update config with gateway token
python3 - <<PY
import json

cfg_path = "data/.openclaw/openclaw.json"
token = "${OPENCLAW_GATEWAY_AUTH_TOKEN}"

with open(cfg_path, "r") as f:
    obj = json.load(f)

obj.setdefault("gateway", {})
obj["gateway"]["mode"] = "local"
obj["gateway"]["bind"] = "loopback"
obj["gateway"].setdefault("auth", {})["mode"] = "token"
obj["gateway"]["auth"]["token"] = token

with open(cfg_path, "w") as f:
    json.dump(obj, f, indent=2)

print("Config updated.")
PY

chmod 600 data/.openclaw/openclaw.json

# Sync workspace from templates
echo "Syncing workspace..."
for f in templates/workspace/*.md; do
  [[ -f "$f" ]] && cp "$f" data/workspace/
done

# Restart container
echo "Restarting container..."
docker compose up -d --force-recreate

# Wait for healthy
echo "Waiting for container..."
for i in {1..45}; do
  status=$(docker inspect -f '{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "none")
  if [[ "$status" == "healthy" ]]; then
    echo "Container is healthy."
    exit 0
  fi
  sleep 2
done

echo "WARNING: Container did not become healthy within 90s"
docker logs --tail 20 "$CONTAINER_NAME" || true
exit 1
