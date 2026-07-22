#!/usr/bin/env bash
set -euo pipefail

DOCKER_BIN="${DOCKER_BIN:-/usr/local/bin/docker}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.automation.yml}"
LEGACY_CONTAINERS=(
  n8n
  n8n-runners
  n8n-nas-bundle-postgres-1
  postgres-public-5433
  cloudflared
)
TARGET_CONTAINERS=(
  media-automation-postgres-1
  media-automation-n8n-1
  media-automation-task-runners-1
  media-automation-cloudflared-1
  media-automation-postgres-public-5433-1
)

docker_cmd() {
  sudo "$DOCKER_BIN" "$@"
}

rollback() {
  docker_cmd compose --env-file .env -f "$COMPOSE_FILE" stop >/dev/null 2>&1 || true
  docker_cmd start "${LEGACY_CONTAINERS[@]}" >/dev/null 2>&1 || true
  echo "automation_cutover_rollback=true" >&2
}

trap rollback ERR

docker_cmd stop "${LEGACY_CONTAINERS[@]}" >/dev/null
docker_cmd compose --env-file .env -f "$COMPOSE_FILE" up -d

retries=36
until [[ "$(docker_cmd inspect media-automation-n8n-1 --format '{{.State.Health.Status}}' 2>/dev/null || true)" == "healthy" ]]; do
  retries=$((retries - 1))
  [[ "$retries" -gt 0 ]]
  sleep 5
done

for container in "${TARGET_CONTAINERS[@]}"; do
  [[ "$(docker_cmd inspect "$container" --format '{{.State.Running}}')" == "true" ]]
done

trap - ERR
echo "automation_cutover_ok=true"
