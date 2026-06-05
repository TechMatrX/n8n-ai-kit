#!/bin/bash
set -e

echo "1. Building n8n image without cache..."
DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker compose build --no-cache n8n

echo "2. Checking compose images..."
docker compose images

echo "3. Testing directory structure..."
docker run --rm n8n-ai-kit-n8n:latest ls -la /home/node/.n8n /home/node/.n8n-files /backup /data/shared

echo "4. Verifying permissions..."
docker run --rm n8n-ai-kit-n8n:latest sh -lc 'stat -c "%U:%G" /home/node/.n8n /home/node/.n8n-files /backup /data/shared'
