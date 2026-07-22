#!/usr/bin/env bash
set -euo pipefail

DOCKER_BIN="${DOCKER_BIN:-/usr/local/bin/docker}"
BASE_COMPOSE_FILE="${BASE_COMPOSE_FILE:-docker-compose.automation.yml}"
AI_COMPOSE_FILE="${AI_COMPOSE_FILE:-docker-compose.ai-starter.yml}"
LEGACY_CONTAINERS=(ollama qdrant)
TARGET_CONTAINERS=(media-automation-ollama-nas-1 media-automation-qdrant-1)

docker_cmd() {
  sudo "$DOCKER_BIN" "$@"
}

rollback() {
  docker_cmd compose --env-file .env -f "$BASE_COMPOSE_FILE" -f "$AI_COMPOSE_FILE" \
    stop ollama-nas qdrant >/dev/null 2>&1 || true
  docker_cmd start "${LEGACY_CONTAINERS[@]}" >/dev/null 2>&1 || true
  echo "ai_starter_cutover_rollback=true" >&2
}

trap rollback ERR

for container in "${LEGACY_CONTAINERS[@]}"; do
  docker_cmd inspect "$container" >/dev/null
done

docker_cmd stop "${LEGACY_CONTAINERS[@]}" >/dev/null
docker_cmd compose --env-file .env -f "$BASE_COMPOSE_FILE" -f "$AI_COMPOSE_FILE" \
  up -d ollama-nas qdrant

for container in "${TARGET_CONTAINERS[@]}"; do
  retries=36
  until [[ "$(docker_cmd inspect "$container" --format '{{.State.Health.Status}}' 2>/dev/null || true)" == "healthy" ]]; do
    retries=$((retries - 1))
    [[ "$retries" -gt 0 ]]
    sleep 5
  done
done

docker_cmd exec media-automation-ollama-nas-1 ollama list >/dev/null
docker_cmd exec media-automation-qdrant-1 bash -lc \
  'exec 3<>/dev/tcp/127.0.0.1/6333; printf "GET /collections HTTP/1.0\r\nHost: localhost\r\n\r\n" >&3; grep -q "200 OK" <&3'

trap - ERR
echo "ai_starter_cutover_ok=true"

