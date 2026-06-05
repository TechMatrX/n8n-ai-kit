#!/usr/bin/env bash
set -euo pipefail

SKIP_PULL=false
SKIP_HEALTHCHECK=false
OUTPUT_FILE="docker-compose.nas.merged.yml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-pull)
      SKIP_PULL=true
      shift
      ;;
    --skip-healthcheck)
      SKIP_HEALTHCHECK=true
      shift
      ;;
    --output)
      OUTPUT_FILE="${2:?missing output path}"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--skip-pull] [--skip-healthcheck] [--output <merged-compose-path>]" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

if [ ! -f "./.env" ]; then
  echo "Missing .env in ${SCRIPT_DIR}" >&2
  echo "Create it from .env.nas.example before deploying." >&2
  exit 1
fi

set -a
source "./.env"
set +a

if [ "${SKIP_PULL}" = false ]; then
  echo "Pulling latest repo state..."
  git pull --ff-only
fi

echo "Rendering merged NAS compose file..."
./n8n-render-nas-compose.sh "${OUTPUT_FILE}"

echo "Starting NAS phase-1 stack..."
docker compose -f "${OUTPUT_FILE}" up -d --build

if [ "${SKIP_HEALTHCHECK}" = true ]; then
  echo "Skipping health checks as requested"
  exit 0
fi

echo "Waiting for n8n health check..."
for i in {1..24}; do
  if curl -fsS "${WEBHOOK_URL%/}/healthz" >/tmp/n8n-nas-healthz.json 2>/dev/null; then
    echo "n8n /healthz is reachable"
    break
  fi
  if [ "${i}" -eq 24 ]; then
    echo "n8n /healthz did not become reachable within 120 seconds" >&2
    exit 1
  fi
  sleep 5
done

if [ -n "${N8N_API_KEY:-}" ]; then
  echo "Checking n8n API workflow list..."
  http_code="$(
    curl -sS -o /tmp/n8n-nas-workflows.json -w '%{http_code}' \
      -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
      "${WEBHOOK_URL%/}/api/v1/workflows?limit=1"
  )"
  if [ "${http_code}" != "200" ]; then
    echo "n8n API check failed with HTTP ${http_code}" >&2
    exit 1
  fi
  echo "n8n API workflow list returned HTTP 200"
else
  echo "N8N_API_KEY is not set; skipping API workflow check"
fi

echo "NAS deploy completed successfully"
