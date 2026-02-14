#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-./data/workspace}"
TEMPLATE_DIR="./templates/workspace"

mkdir -p "$WORKSPACE_DIR"

for f in AGENTS.md HEARTBEAT.md IDENTITY.md MEMORY.md SOUL.md TOOLS.md USER.md; do
  if [[ -f "${TEMPLATE_DIR}/${f}" ]]; then
    cp "${TEMPLATE_DIR}/${f}" "${WORKSPACE_DIR}/${f}"
  else
    echo "Warning: missing template ${TEMPLATE_DIR}/${f}" >&2
  fi
done

echo "Main workspace files synced at: ${WORKSPACE_DIR}"
