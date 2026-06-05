#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="${1:-docker-compose.nas.merged.yml}"

required_vars=(
  NAS_ROOT
  WEBHOOK_URL
  N8N_HOST
  N8N_PROTOCOL
)

missing=()
for var_name in "${required_vars[@]}"; do
  if [ -z "${!var_name:-}" ]; then
    missing+=("$var_name")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Missing required environment variables:" >&2
  printf ' - %s\n' "${missing[@]}" >&2
  echo >&2
  echo "Load a NAS-ready .env first, for example:" >&2
  echo "  cp .env.nas.example .env" >&2
  echo "  set -a; source ./.env; set +a" >&2
  exit 1
fi

docker compose \
  -f docker-compose.yml \
  -f docker-compose.nas.yml \
  config > "${OUTPUT_FILE}"

echo "Rendered NAS compose file: ${OUTPUT_FILE}"
