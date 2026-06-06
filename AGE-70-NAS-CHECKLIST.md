# AGE-70 NAS Migration Checklist

This checklist starts from the now-working local `n8n-ai-kit` baseline and turns it into the next migration phase for NAS deployment.

## Goal

Move the verified local Docker-based `n8n-ai-kit` stack onto NAS-backed infrastructure without losing:

- workflows
- credentials
- API connectivity
- file access expectations
- operational restore capability

## Baseline Assumption

Current validated baseline:

- repo: `/Users/andy/Studio/ai/n8n-ai-kit`
- local `n8n` UI works
- workflows imported: `33`
- credentials imported: `13`
- custom image works
- API key + MCP management path work

## Phase 1: NAS target definition

- Confirm Synology runtime surface:
  - DSM `7.3.2-86009 Update 3`
  - `Container Manager` is the deployment UI/runtime
- Decide NAS hostname or ingress domain for `n8n`
- Decide whether NAS will expose:
  - `n8n`
  - `postgres`
  - `qdrant`
  - `open-webui`
  - `flowise`
  directly, or via an ingress layer
- Preferred ingress decision for phase 1:
  - use Cloudflare Tunnel via `cloudflared`
  - do not use Caddy for the public route
  - do not use Synology Proxy Server for this path
- Decide persistent storage root on NAS for:
  - `n8n` data
  - `postgres` data
  - `qdrant` data
  - `open-webui` data
  - `flowise` data
  - backup artifacts
- Recommended DS218+ phase-1 scope:
  - move `n8n` + `postgres` first
  - defer `ollama`, `open-webui`, `flowise`, and likely `qdrant`

## Phase 2: Config adaptation

- Replace local-only `WEBHOOK_URL` with NAS hostname
- Add `CLOUDFLARE_TUNNEL_TOKEN` for the named tunnel path
- Confirm Cloudflare public hostname maps to `http://n8n:5678`
- Retire ngrok after Cloudflare hostname validation
- Review `.env` values and separate:
  - portable values
  - machine-local values
  - secrets that should be rotated before NAS
- Remove deprecated env when convenient:
  - `N8N_RUNNERS_ENABLED`

## Phase 3: Volume and bind strategy

- Map current local bind expectations to NAS storage paths:
  - `/backup`
  - `/data/shared`
  - `/home/node/.n8n-files`
- Decide whether to keep named volumes or switch to explicit NAS bind mounts
- Preserve restore path for:
  - workflow exports
  - credential exports
  - DB dumps
  - volume archives

## Phase 4: Restore rehearsal on NAS

- Build custom `Dockerfile.n8n` on NAS target
- Bring up stack with NAS storage paths
- Import workflow and credential payloads from known-good backup
- Verify:
  - login works
  - workflows present
  - credentials present
  - file-mounted workflows can still read shared content
  - `atlas`, `youtube-transcript`, and Contentful package remain usable

## Phase 5: API and agent integration

- Create or rotate `N8N_API_KEY` on NAS target if needed
- Set agent runtime management base URL to the chosen NAS URL
- Verify:
  - `/healthz`
  - `/api/v1/workflows`
  - MCP health check connected state
- Confirm whether localhost or external hostname should be preferred for codex-home depending on where the agent runs

## Phase 6: Rollback and recovery

- Keep the local backup timestamp and at least one NAS restore snapshot
- Document the revert path:
  - stop NAS stack
  - restore previous data snapshot
  - restart with last known-good env
- Validate `n8n-restore.sh` assumptions still match NAS storage layout

## Acceptance criteria

- NAS-hosted `n8n` reachable and healthy
- workflows and credentials restored
- API key works for MCP/agent management
- shared file paths behave as expected
- documented backup and rollback path exists
- AGE-70 migration checklist can be closed or split into one bounded NAS execution issue
