#!/bin/bash
set -eo pipefail

SKIP_BUILD=false
BUILD_INLINE_CACHE=true
BUILD_TIMEOUT="${N8N_BUILD_TIMEOUT:-900}"
COMPOSE_ARGS=()
HAS_TASK_RUNNERS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --no-inline-cache)
            BUILD_INLINE_CACHE=false
            shift
            ;;
        --build-timeout)
            BUILD_TIMEOUT="${2:?missing build timeout seconds}"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-build] [--no-inline-cache] [--build-timeout <seconds>]"
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

DOCKER_BIN="${DOCKER_BIN:-docker}"

if [ -f "./docker-compose.nas.yml" ] && [ -f "./.env" ]; then
    set -a
    # shellcheck disable=SC1091
    source "./.env"
    set +a

    if [ -n "${NAS_ROOT:-}" ]; then
        COMPOSE_ARGS=(-f docker-compose.yml -f docker-compose.nas.yml)
    fi
fi

docker_compose() {
    "${DOCKER_BIN}" compose "${COMPOSE_ARGS[@]}" "$@"
}

if docker_compose config --services 2>/dev/null | grep -qx "task-runners"; then
    HAS_TASK_RUNNERS=true
fi

if [ -f "./n8n-backup.sh" ]; then
    echo "Running backup before update..."
    ./n8n-backup.sh
fi

echo "Stopping n8n service..."
docker_compose stop n8n

if [ "${HAS_TASK_RUNNERS}" = true ]; then
    echo "Stopping task-runners service..."
    docker_compose stop task-runners || true
fi

if [ "${SKIP_BUILD}" = true ]; then
    echo "Skipping build as requested"
else
    build_args=(--timeout "${BUILD_TIMEOUT}")
    if [ "${BUILD_INLINE_CACHE}" = false ]; then
        build_args+=(--no-inline-cache)
    fi
    DOCKER_BIN="${DOCKER_BIN}" ./n8n-build.sh "${build_args[@]}"
fi

echo "Starting updated stack..."
docker_compose up -d --force-recreate --no-deps n8n

if [ "${HAS_TASK_RUNNERS}" = true ]; then
    echo "Refreshing task-runners service..."
    docker_compose up -d --force-recreate --no-deps task-runners
fi

echo "Waiting for n8n health check..."
for i in {1..12}; do
    if docker_compose ps n8n | grep -q "healthy"; then
        echo "n8n is healthy"
        break
    fi
    if [ "${i}" -eq 12 ]; then
        echo "Service did not become healthy within 60 seconds"
        exit 1
    fi
    sleep 5
done

docker_compose ps n8n

echo "Runtime version:"
docker_compose exec -T n8n n8n --version || true
