#!/bin/bash
set -eo pipefail

TIMEOUT=900

echo "Building custom n8n images..."
if command -v timeout >/dev/null 2>&1; then
    timeout "${TIMEOUT}" docker compose --progress=plain build \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --build-arg BUILDKIT_MAX_PARALLEL_JOBS=4 \
        n8n n8n-import
else
    docker compose --progress=plain build \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --build-arg BUILDKIT_MAX_PARALLEL_JOBS=4 \
        n8n n8n-import
fi

echo "Verifying compose images..."
docker compose images

echo "Testing n8n CLI availability..."
project_name="$(basename "${SCRIPT_DIR:-$(pwd)}")"
docker run --rm "${project_name}-n8n-import:latest" n8n --version

echo "Build process completed"
