#!/bin/bash
set -eo pipefail

SKIP_BUILD=false

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

if [ -f "./backup_n8n.sh" ]; then
    echo "Running backup before update..."
    ./backup_n8n.sh
fi

echo "Stopping n8n service..."
docker compose stop n8n

if [ "${SKIP_BUILD}" = true ]; then
    echo "Skipping build as requested"
else
    ./build_n8n.sh
fi

echo "Starting updated stack..."
docker compose up -d n8n

echo "Waiting for n8n health check..."
for i in {1..12}; do
    if docker compose ps n8n | grep -q "healthy"; then
        echo "n8n is healthy"
        break
    fi
    if [ "${i}" -eq 12 ]; then
        echo "Service did not become healthy within 60 seconds"
        exit 1
    fi
    sleep 5
done

docker compose ps n8n
