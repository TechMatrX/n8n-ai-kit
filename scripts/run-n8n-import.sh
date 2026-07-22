#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

docker_cmd=("${DOCKER_BIN:-docker}")
if [[ "${DOCKER_SUDO:-false}" == "true" ]]; then
  docker_cmd=(sudo -n "${DOCKER_BIN:-docker}")
fi

mode="${1:-bootstrap}"
format="${2:-auto}"

case "${mode}" in
  bootstrap) confirm_restore="" ;;
  restore) confirm_restore="RESTORE" ;;
  *) echo "Usage: $0 [bootstrap|restore] [auto|entities|split]" >&2; exit 64 ;;
esac
case "${format}" in
  auto|entities|split) ;;
  *) echo "Usage: $0 [bootstrap|restore] [auto|entities|split]" >&2; exit 64 ;;
esac

"${docker_cmd[@]}" compose --env-file .env -f docker-compose.automation.yml \
  --profile maintenance run --rm --no-deps \
  -e "N8N_IMPORT_MODE=${mode}" \
  -e "N8N_IMPORT_FORMAT=${format}" \
  -e "N8N_IMPORT_CONFIRM_RESTORE=${confirm_restore}" \
  n8n-import
