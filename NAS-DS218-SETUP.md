# DS218+ Phase-1 NAS Setup

This runbook is the practical next step after stabilizing the Mac baseline in
`n8n-ai-kit`.

## Goal

Move only the phase-1 control-plane services onto the Synology DS218+:

- `n8n`
- `postgres`

Do not move the heavier AI services yet:

- `ollama`
- `open-webui`
- `flowise`
- `qdrant` unless you need it immediately

This keeps the first NAS cutover small and reversible.

## Why This Shape Fits DS218+

- DS218+ is better used as a stable workflow/runtime host than as a full AI box
- `n8n` + `postgres` are the critical services for workflow continuity
- the Mac can remain the fallback and keep the heavier AI workloads

## Container Manager Notes

Synology DSM `7.3.2-86009 Update 3` uses **Container Manager** rather than the
older Docker package UI.

That means:

- bind mounts should point at explicit NAS folders
- the safest import path is a compose project plus a verified `.env`
- phase-1 should avoid optional services that add RAM and restart complexity

## Recommended NAS Folder Layout

Use a dedicated root, for example:

```text
/volume1/docker/n8n-ai-kit/
├── backup/
├── n8n/
├── n8n-files/
├── postgres/
└── shared/
```

Purpose:

- `backup/` = imported workflow/credential payloads and restore artifacts
- `n8n/` = runtime app state
- `n8n-files/` = restricted file storage used by workflows
- `postgres/` = database storage
- `shared/` = shared read/write workflow content

## Required Env Values

Set these for the NAS run:

```env
NAS_ROOT=/volume1/docker/n8n-ai-kit
WEBHOOK_URL=https://your-nas-n8n.example.com
N8N_HOST=your-nas-n8n.example.com
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_EDITOR_BASE_URL=https://your-nas-n8n.example.com
N8N_HOST_PORT=5678
```

Keep your existing secrets as-is unless you explicitly want rotation:

- `N8N_ENCRYPTION_KEY`
- `N8N_USER_MANAGEMENT_JWT_SECRET`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_DB`

## Compose Files

Base file:

- `docker-compose.yml`

NAS override:

- `docker-compose.nas.yml`
- `.env.nas.example`
- `NAS-CONTAINER-MANAGER-IMPORT.md`

The NAS override does three things:

1. disables non-phase-1 services
2. swaps named volumes for Synology bind mounts
3. replaces localhost-oriented URL assumptions with NAS host values

## Suggested Rehearsal Flow

1. Copy the repo to the NAS or a NAS-bound working directory
2. Create the NAS folders under `${NAS_ROOT}`
3. Create a NAS-specific `.env`
4. Build and start with both compose files:

```bash
docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --build
```

Or for a Synology Container Manager flow that prefers one merged compose file:

```bash
set -a; source ./.env; set +a
./n8n-render-nas-compose.sh
```

5. Restore/import from the known-good backup payload
6. Verify:
   - `https://your-nas-n8n.example.com/healthz`
   - login works
   - workflows present
   - credentials present
   - shared file access works

## Rollback Rule

Do not retire the Mac runtime yet.

Keep the current Mac stack intact until all of these pass on NAS:

- `n8n` health
- workflow list API
- credential availability
- real workflow test
- MCP/agent management connectivity

## Next Repo Step

After this DS218+ phase-1 rehearsal succeeds, the next repo change should be:

- a small Synology-specific `.env.example` or `.env.nas.example`
- a simple NAS deploy helper for controlled pull + restart

Not yet:

- moving the whole AI stack to NAS
- making NAS the only source of truth
