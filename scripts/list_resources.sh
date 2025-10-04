#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-http://localhost}"
PORT="${PORT:-8000}"
REQUEST_ID="${REQUEST_ID:-resources-list-1}"
CURSOR="${CURSOR:-}"
TARGET_URL="${HOST}:${PORT}/mcp"

if [ -n "$CURSOR" ]; then
  payload=$(printf '{"jsonrpc":"2.0","id":"%s","method":"resources/list","params":{"cursor":"%s"}}' "$REQUEST_ID" "$CURSOR")
else
  payload=$(printf '{"jsonrpc":"2.0","id":"%s","method":"resources/list"}' "$REQUEST_ID")
fi

printf '→ POST %s\n' "$TARGET_URL" >&2
printf '→ payload: %s\n' "$payload" >&2

response=$(printf '%s' "$payload" |
  curl -sS -X POST "$TARGET_URL" \
    -H 'Content-Type: application/json' \
    --data-binary @-)

printf '→ response: %s\n' "$response"
