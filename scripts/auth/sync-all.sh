#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

CONTAINER_NAME="${1:-openclaw}"
ENV_FILE="${2:-.env}"
CLIPPY_SOURCE_DIR="${3:-}"
CLIPPY_DEST_DIR="${4:-./data/clippy}"
WHOOP_DEST_DIR="${5:-./data/whoop}"
STRICT_CLIPPY="${STRICT_CLIPPY:-0}"

echo "[1/2] Syncing WHOOP auth from ${ENV_FILE}..."
"${ROOT_DIR}/scripts/auth/sync-whoop.sh" "$ENV_FILE" "$WHOOP_DEST_DIR" "$CONTAINER_NAME"

echo "[2/2] Syncing Clippy auth..."
if "${ROOT_DIR}/scripts/auth/sync-clippy.sh" "$CONTAINER_NAME" "$CLIPPY_SOURCE_DIR" "$CLIPPY_DEST_DIR"; then
  :
else
  if [[ "$STRICT_CLIPPY" == "1" ]]; then
    echo "Error: Clippy sync failed and STRICT_CLIPPY=1." >&2
    exit 1
  fi
  echo "Warning: Clippy sync failed (likely missing local session files)." >&2
  echo "WHOOP sync completed; you can still use WHOOP-backed automations." >&2
fi

echo "Auth sync complete."

