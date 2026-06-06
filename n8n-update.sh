#!/bin/bash
set -eo pipefail

SKIP_BUILD=false
COMPOSE_ARGS=()
HAS_TASK_RUNNERS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-build]"
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

docker_compose() {
    docker compose "${COMPOSE_ARGS[@]}" "$@"
}

if docker compose "${COMPOSE_ARGS[@]}" config --services 2>/dev/null | grep -qx "task-runners"; then
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
    ./n8n-build.sh
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
