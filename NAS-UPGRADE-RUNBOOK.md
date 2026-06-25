# NAS Upgrade Runbook

This runbook captures the safe upgrade path for the live NAS `n8n-ai-kit`
bundle after the 2.27.4 runtime upgrade.

## Target Selection

Use the stable n8n app tag, not beta/next tags.

Current validated target:

```bash
N8N_IMAGE=n8nio/n8n:2.27.4
N8N_RUNNERS_IMAGE=n8nio/runners:2.27.4
```

Check tags before future upgrades:

```bash
npm view n8n dist-tags --json
```

## Live NAS Path

```bash
cd /volume1/docker/n8n-ai-kit/n8n-nas-bundle
```

The live data paths are controlled by `NAS_ROOT` in `.env`. Do not treat
bundle-local `n8n/backup` or `shared` as live runtime data on NAS.

## Preflight

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml config --quiet
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml ps
curl -fsS http://127.0.0.1:5678/healthz
```

Confirm pins:

```bash
grep -E '^N8N_IMAGE=|^N8N_RUNNERS_IMAGE=' .env
```

## Backup

Run the helper before stopping services:

```bash
sudo ./n8n-backup.sh
```

Expected backup contents:

- workflows export
- credentials export
- PostgreSQL dump
- n8n volume archive

For manual file rollback before changing bundle files:

```bash
backup_dir="./backups/pre-n8n-$(date +%Y%m%d-%H%M%S)"
mkdir -p "${backup_dir}"
for f in .env .env.example Dockerfile.n8n docker-compose.yml docker-compose.nas.yml README.md NAS-RUNTIME-OPERATIONS.md; do
  [ -f "$f" ] && cp -p "$f" "${backup_dir}/$f"
done
```

## Preferred Upgrade

Use this when Docker behaves normally:

```bash
sudo ./n8n-update.sh
```

This runs backup, stops `n8n` and `task-runners`, builds the custom n8n image,
recreates `n8n`, recreates `task-runners`, and checks health.

## Synology-Safe Upgrade

Synology Container Manager can stall while exporting inline build cache. If that
happens, disable inline cache:

```bash
sudo ./n8n-update.sh --no-inline-cache --build-timeout 1800
```

If sudo is restricted to Docker only, run explicit Docker commands instead of
shelling through a function:

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml build --progress=plain n8n n8n-import
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --force-recreate --no-deps n8n
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml pull task-runners
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --force-recreate --no-deps task-runners
```

## Recovery During Upgrade

If build or helper behavior blocks service recovery, restore service first:

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --no-build n8n
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --force-recreate --no-deps task-runners
```

Avoid plain `up -d n8n` during recovery unless you intend to run dependencies;
it can retrigger or wait on the one-shot `n8n-import` helper.

## Post-Upgrade Validation

```bash
sudo /usr/local/bin/docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' | grep -E 'n8n|runners|postgres'
sudo /usr/local/bin/docker exec n8n n8n --version
sudo /usr/local/bin/docker inspect n8n-runners --format 'runner_image={{.Config.Image}}'
curl -fsS http://127.0.0.1:5678/healthz
```

Expected for the 2.27.4 upgrade:

```text
n8n --version -> 2.27.4
runner_image=n8nio/runners:2.27.4
/healthz -> {"status":"ok"}
```

Then validate through MCP:

- `n8n_health_check`
- `n8n_list_workflows`
- `n8n_validate_workflow` for touched workflows

For the AI Media Platform lane, also run from `media-worker-daemon`:

```bash
npm run health:media
```

Expected healthy state:

- worker live and ready
- heartbeat fresh
- RabbitMQ ready/retry/dead queues at `0/0/0`
- no warning or critical issues

## 2.27.4 Upgrade Notes

Observed on Synology:

- `n8n-update.sh` backup succeeded.
- Docker build verified `n8n --version` as `2.27.4` inside the image.
- Build stalled while preparing inline-cache layers.
- Service was recovered with `up -d --no-build n8n`, then runners were
  recreated from `n8nio/runners:2.27.4`.
- Final runtime validation showed healthy `n8n` on `2.27.4` and healthy
  `n8n-runners` on `2.27.4`.
