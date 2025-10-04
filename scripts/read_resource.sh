#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-http://localhost}"
PORT="${PORT:-8000}"
REQUEST_ID="${REQUEST_ID:-resource-read-1}"
RESOURCE_URI="${1:-https://github.com/DataJourneyHQ/DataJourney/blob/main/README.md}"
TARGET_URL="${HOST}:${PORT}/mcp"

payload=$(printf '{"jsonrpc":"2.0","id":"%s","method":"resources/read","params":{"uri":"%s"}}' "$REQUEST_ID" "$RESOURCE_URI")

printf '→ POST %s\n' "$TARGET_URL" >&2
printf '→ payload: %s\n' "$payload" >&2

response=$(printf '%s' "$payload" |
  curl -sS -X POST "$TARGET_URL" \
    -H 'Content-Type: application/json' \
    --data-binary @-)

printf '→ response: %s\n' "$response"
