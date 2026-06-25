#!/bin/bash
set -eo pipefail

TIMEOUT="${N8N_BUILD_TIMEOUT:-900}"
INLINE_CACHE=true
PULL_BASE=false
COMPOSE_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --timeout)
            TIMEOUT="${2:?missing timeout seconds}"
            shift 2
            ;;
        --no-inline-cache)
            INLINE_CACHE=false
            shift
            ;;
        --pull)
            PULL_BASE=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--timeout <seconds>] [--no-inline-cache] [--pull]" >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

if [ -f "./docker-compose.nas.yml" ] && [ -f "./.env" ]; then
    set -a
    # shellcheck disable=SC1091
    source "./.env"
    set +a

    if [ -n "${NAS_ROOT:-}" ]; then
        COMPOSE_ARGS=(-f docker-compose.yml -f docker-compose.nas.yml)
    fi
fi

DOCKER_BIN="${DOCKER_BIN:-docker}"

docker_compose() {
    "${DOCKER_BIN}" compose "${COMPOSE_ARGS[@]}" "$@"
}

build_args=(--progress=plain build --build-arg BUILDKIT_MAX_PARALLEL_JOBS=4)

if [ "${INLINE_CACHE}" = true ]; then
    build_args+=(--build-arg BUILDKIT_INLINE_CACHE=1)
fi

if [ "${PULL_BASE}" = true ]; then
    build_args+=(--pull)
fi

build_args+=(n8n n8n-import)

echo "Building custom n8n images..."
echo "Build options: timeout=${TIMEOUT}s inline_cache=${INLINE_CACHE} pull_base=${PULL_BASE}"
if command -v timeout >/dev/null 2>&1; then
    timeout "${TIMEOUT}" "${DOCKER_BIN}" compose "${COMPOSE_ARGS[@]}" "${build_args[@]}"
else
    docker_compose "${build_args[@]}"
fi

echo "Removing stale n8n helper containers before verification..."
"${DOCKER_BIN}" rm -f n8n n8n-import 2>/dev/null || true

echo "Verifying compose images..."
docker_compose images

echo "Testing n8n CLI availability..."
project_name="$(basename "${SCRIPT_DIR}")"
"${DOCKER_BIN}" run --rm "${project_name}-n8n-import:latest" n8n --version

echo "Build process completed"
