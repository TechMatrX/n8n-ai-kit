#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

docker_cmd=("${DOCKER_BIN:-docker}")
if [[ "${DOCKER_SUDO:-false}" == "true" ]]; then
  docker_cmd=(sudo -n "${DOCKER_BIN:-docker}")
fi

model="${1:-}"
if [[ -z "${model}" ]]; then
  echo "Usage: $0 <model>" >&2
  echo "Example: $0 qwen3.5:0.8b" >&2
  exit 64
fi

"${docker_cmd[@]}" compose --env-file .env \
  -f docker-compose.automation.yml -f docker-compose.ai-starter.yml \
  --profile models run --rm --no-deps -e "OLLAMA_MODEL=${model}" ollama-model-pull
