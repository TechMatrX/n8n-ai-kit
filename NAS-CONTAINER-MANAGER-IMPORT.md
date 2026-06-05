# Synology Container Manager Import Notes

This note is the shortest path for rehearsing the phase-1 NAS stack with
Synology Container Manager.

## Files to use

- `docker-compose.yml`
- `docker-compose.nas.yml`
- `.env` copied from `.env.nas.example` and filled with real values

## Recommended prep

1. Copy the repo to a NAS working directory
2. Copy `.env.nas.example` to `.env`
3. Fill the real hostname and secrets
4. Create bind-mount folders under:

```text
/volume1/docker/n8n-ai-kit/
```

Required subfolders:

- `backup`
- `n8n`
- `n8n-files`
- `postgres`
- `shared`

## Compose merge rule

Use both compose files together so the NAS override disables the heavy services
and swaps named volumes for NAS bind mounts.

Equivalent CLI:

```bash
docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --build
```

If Container Manager only accepts a single compose payload in your workflow,
generate a merged file first from a machine that has Docker Compose:

```bash
set -a; source ./.env; set +a
./n8n-render-nas-compose.sh
```

Then import `docker-compose.nas.merged.yml` plus the `.env` file into the NAS
workflow you prefer.

## First-run verification

After startup, verify in order:

1. `https://your-nas-n8n.example.com/healthz`
2. n8n login page loads
3. workflows are present after import
4. credentials are present after import
5. shared file access works
6. API check works:

```bash
curl -sS -H "X-N8N-API-KEY: <key>" \
  "https://your-nas-n8n.example.com/api/v1/workflows?limit=1"
```

## Keep the Mac fallback

Do not retire the Mac stack until:

- NAS `n8n` is healthy
- workflow import is correct
- credentials import is correct
- API works
- MCP/agent connectivity is re-tested
