# n8n Restore Drill - 2026-06-26

Status: dry-run plan only. Do not apply restore unless explicitly approved.

## Known Good Backup

- NAS backup: `/volume1/docker/n8n-ai-kit/n8n-nas-bundle/backups/20260626_174559`
- Local copy: `backups/20260626_174559`
- Size: about 90 MB
- Contents:
  - workflow exports
  - credential exports
  - `entities/entities.zip`
  - `database/n8n_backup.sql`
  - `volume/n8n_storage.tar.gz`

## Runtime Route

Use the NAS SSH route:

```bash
ssh -i ~/.ssh/id_ed25519_openclaw openclaw@100.73.253.62
```

NAS runtime directory:

```bash
cd /volume1/docker/n8n-ai-kit/n8n-nas-bundle
```

Docker on the NAS is available through passwordless sudo:

```bash
sudo -n /usr/local/bin/docker ps
```

The NAS non-interactive shell does not have Docker in `PATH`, so wrappers should
either call `/usr/local/bin/docker` explicitly or use a temporary `docker`
wrapper that delegates to `sudo -n /usr/local/bin/docker`.

## Backup Command

Preferred repeatable backup wrapper from repo root:

```bash
scripts/nas-n8n-backup.sh
```

Dry-run wrapper validation:

```bash
scripts/nas-n8n-backup.sh --dry-run
```

NAS-only backup without local copy:

```bash
scripts/nas-n8n-backup.sh --no-copy
```

Wrapper validation on 2026-06-26:

- `scripts/nas-n8n-backup.sh --dry-run` passed.
- `scripts/nas-n8n-backup.sh --no-copy` completed on NAS.
- Produced NAS backup: `backups/20260626_205651`
- Backup size: about 90 MB
- File count: 69

## Restore Inputs

Before any restore, confirm:

```bash
ls -lah backups/20260626_174559
ls -lah backups/20260626_174559/database/n8n_backup.sql
ls -lah backups/20260626_174559/volume/n8n_storage.tar.gz
```

On NAS:

```bash
ssh -i ~/.ssh/id_ed25519_openclaw openclaw@100.73.253.62 \
  'cd /volume1/docker/n8n-ai-kit/n8n-nas-bundle && find backups/20260626_174559 -maxdepth 2 -type f | sort | wc -l'
```

## Restore Plan

Do not run this section without explicit approval.

The existing restore entrypoint is:

```bash
./n8n-restore.sh 20260626_174559
```

Expected restore actions:

1. Stop `n8n`.
2. Ensure `postgres` is running.
3. Drop and recreate the configured n8n database.
4. Restore `database/n8n_backup.sql`.
5. Restore `/home/node/.n8n` from `volume/n8n_storage.tar.gz`.
6. Fix n8n storage ownership and permissions.
7. Copy workflow/credential/entity export files into the NAS backup mount.
8. Start `n8n-import`.
9. Start `n8n`.

## Pre-Restore Safety Checklist

- Confirm Andy explicitly approved applying restore.
- Take a fresh backup first with `scripts/nas-n8n-backup.sh`.
- Confirm the new backup exists on NAS and local copy if needed.
- Confirm the intended restore timestamp.
- Record current live workflow version checkpoints if the restore targets live n8n.
- Confirm no active media jobs are running.
- Confirm expected downtime window.

## Post-Restore Verification

After an approved restore:

```bash
ssh -i ~/.ssh/id_ed25519_openclaw openclaw@100.73.253.62 \
  'cd /volume1/docker/n8n-ai-kit/n8n-nas-bundle && sudo -n /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml ps'
```

Then verify from local runtime:

```bash
npm run health:media
npm run media:ops-report
```

Expected checks:

- n8n container healthy/running.
- Postgres healthy/running.
- n8n UI/API reachable.
- Media submit workflows still validate.
- Media worker health clean.
- RabbitMQ queues clean.

## NAS Postgres 5433 Note

Schema-review testing currently uses:

```text
NAS host 5433 -> postgres container 5432
```

The compose-managed forwarder is `postgres-public-5433` in
`docker-compose.nas.yml`.

Current mapping:

```yaml
postgres-public-5433:
  command: -dd TCP-LISTEN:5433,fork,reuseaddr TCP:postgres:5432
  ports:
    - 5433:5433
```

To remove this public host port later:

```bash
ssh -i ~/.ssh/id_ed25519_openclaw openclaw@100.73.253.62
cd /volume1/docker/n8n-ai-kit/n8n-nas-bundle
sudo -n /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml stop postgres-public-5433
```

For a durable removal, delete the `postgres-public-5433` service from
`docker-compose.nas.yml`, deploy the updated bundle, then run:

```bash
sudo -n /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --remove-orphans
```
