# NAS Runtime Operations

This document captures the final working NAS deployment model for `n8n-ai-kit`
 after cutover, restore, and external task-runner enablement.

## Steady State

Public path:

```text
https://n8n.techmatrx.com
  -> Cloudflare Tunnel
  -> NAS Docker stack
  -> n8n
```

Primary services:

- `n8n`
- `postgres`
- `cloudflared`
- `task-runners` (`n8n-runners`)

## Canonical NAS Data Paths

Use these as the source of truth for live data:

```text
/volume1/docker/n8n-ai-kit/backup
/volume1/docker/n8n-ai-kit/n8n
/volume1/docker/n8n-ai-kit/n8n-files
/volume1/docker/n8n-ai-kit/ollama
/volume1/docker/n8n-ai-kit/postgres
/volume1/docker/n8n-ai-kit/qdrant
/volume1/docker/n8n-ai-kit/shared
```

Bundle path:

```text
/volume1/docker/n8n-ai-kit/n8n-nas-bundle
```

The NAS bundle should contain compose files, scripts, and generated backups.
Do not treat bundle-local `n8n/backup` or `shared` paths as live runtime data.

## External Task Runners

Production mode uses the external sidecar model.

Key files:

```text
docker-compose.nas.yml
n8n-task-runners.json
.env
```

Expected services:

- `n8n` exposes the task broker on `0.0.0.0:5679`
- `task-runners` uses `n8nio/runners:2.23.0`
- JavaScript runner health check port: `5681`
- Python runner health check port: `5682`
- Launcher health check port: `5680`

Python support is validated when a Python Code node can execute successfully.

## Safe NAS Commands

Run from:

```bash
cd /volume1/docker/n8n-ai-kit/n8n-nas-bundle
```

### Status

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml ps
sudo /usr/local/bin/docker logs --tail=120 n8n
sudo /usr/local/bin/docker logs --tail=120 n8n-runners
```

### Start or restart only `n8n`

Use `--no-deps` to avoid retriggering one-shot helpers such as `n8n-import`.

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --no-deps n8n
```

### Recreate external runners

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --force-recreate --no-deps task-runners
```

### Backup

```bash
sudo ./n8n-backup.sh
```

What it captures:

- workflows export
- credentials export
- PostgreSQL dump
- `n8n` volume archive

### Restore

```bash
sudo ./n8n-restore.sh YYYYMMDD_HHMMSS
```

What it restores:

- PostgreSQL
- `n8n` volume
- workflow backup payload
- credentials backup payload

## Critical Operational Notes

### 1. Avoid normal dependency restarts during recovery

The stack includes `n8n-import`, which is a one-shot helper. During recovery or
diagnostics, ordinary `docker compose up -d n8n` may be blocked by this helper
or retrigger it unexpectedly.

Safer pattern:

```bash
docker compose ... up -d --no-deps n8n
```

### 2. `docker compose run` can retrigger helper services

Avoid ad hoc `docker compose run` during restore debugging unless you fully
understand dependency behavior. It can cause `n8n-import` to run again.

### 3. Backup/restore scripts are NAS-aware now

The helper scripts detect NAS mode by checking:

- `docker-compose.nas.yml`
- `.env`
- `NAS_ROOT`

When present, they operate against:

```text
${NAS_ROOT}/backup
```

instead of bundle-local backup paths.

### 4. External runner JSON must preserve default runner definitions

Do not replace `n8n-task-runners.json` with a minimal override-only file.
The config must include:

- `workdir`
- `command`
- `args`
- `allowed-env`
- `health-check-server-port`

The current checked-in file is the known-good baseline.

## Recovery Checklist

If n8n appears empty or asks for new account setup:

1. Check `docker compose ... ps`
2. Check `docker logs n8n`
3. Verify canonical NAS mounts are in use
4. Restore the latest known-good backup
5. If `n8n-import` interferes, bring `n8n` back with `--no-deps`

If external runners fail:

1. Check `docker logs n8n-runners`
2. Verify `N8N_RUNNERS_*` vars in `.env`
3. Verify `n8n-task-runners.json`
4. Recreate only the sidecar:

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --force-recreate --no-deps task-runners
```

## Validated End State

The following are confirmed working in the final NAS state:

- restored workflows and credentials
- public URL through Cloudflare Tunnel
- JS external runner
- Python external runner
- healthy `n8n`, `postgres`, `cloudflared`, and `n8n-runners`
