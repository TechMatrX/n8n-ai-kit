# n8n Migration Plan

This repo is the clean migration target for Andy's local Docker-based `n8n` stack and the stepping stone for the NAS move tracked under `AGE-70`.

## Scope

Move the repo-managed runtime customizations from:

- `/Users/andy/Studio/ai-agents-masterclass/local-ai-packaged`

into:

- `/Users/andy/Studio/ai/n8n-ai-kit`

without dragging along machine-local secrets, backup payloads, or transient runtime state.

## What Is In Git

- `docker-compose.yml`
- `Dockerfile.n8n`
- build/update/backup/restore helper scripts
- shared helper code
- empty import/file directories needed by the runtime
- documentation for the migration path

## What Stays Out Of Git

- `.env`
- exported credentials
- exported workflows used only for cutover
- SQL dumps
- tarred volumes
- large ad hoc backups under `backups/`

## Current Local Runtime Facts

- Live `n8n` runtime is reachable at `http://localhost:5678`
- The running container is `n8n`
- The live stack is currently sourced from the old `local-ai-packaged` repo
- The target repo should become the new source of truth before NAS cutover

## Migration Phases

1. Repo migration
   - merge Docker/runtime customizations into `n8n-ai-kit`
   - keep the newer upstream starter-kit improvements already present in `n8n-ai-kit`

2. Local cutover dry run
   - create a fresh `.env` in `n8n-ai-kit`
   - back up the current live stack with `./backup_n8n.sh`
   - copy only the needed backup payloads into `n8n/backup/`
   - bring up the stack from `n8n-ai-kit`
   - verify `n8n`, `postgres`, `qdrant`, `open-webui`, and `flowise`

3. NAS preparation
   - replace localhost-only assumptions
   - move webhook/base URLs to NAS-reachable hostnames
   - map persistent data paths to NAS storage
   - test restore and restart behavior from backup material

## Suggested Cutover Sequence

1. `cp .env.example .env`
2. fill in real secrets and local values
3. run `./build_n8n.sh`
4. run `./backup_n8n.sh` in the old stack
5. place importable backup payloads in `n8n/backup/{credentials,workflows}`
6. start the new stack with `docker compose up -d`
7. validate the UI and workflow execution at `http://localhost:5678`
8. only then retire the old repo-backed stack

## AGE-70 Tie-In

The missing AGE-70 deliverable is the migration checklist for the real Mac runtime state. This repo is now intended to become that checklist's concrete implementation base:

- clean repo source of truth
- reproducible Docker build
- explicit backup/restore path
- clearer separation between repo content and runtime data

## Post-Cutover Reality Notes

The first real local cutover surfaced two operator-facing facts that should be treated as normal checklist items:

- the UI login/account state may require creating a fresh local `n8n` account after the new stack comes up
- the previous `N8N_API_KEY` may not remain valid across the cutover, so downstream agent/tool config should be updated with a newly created key
