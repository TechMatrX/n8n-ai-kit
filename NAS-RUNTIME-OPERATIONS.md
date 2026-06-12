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

Phase 1 media execution path:

```text
n8n
  -> https://media-worker.techmatrx.com
  -> media-worker-daemon
  -> local ComfyUI
  -> n8n callback webhook
  -> OpenClaw completion endpoint
```

Image and model control is compose-driven:

- `CLOUDFLARED_IMAGE` controls the Cloudflare Tunnel image tag
- `N8N_IMAGE` controls the base image used to build the custom `n8n` container
- `N8N_RUNNERS_IMAGE` controls the external task-runners image tag
- `OLLAMA_IMAGE` controls the Ollama image tag
- `OLLAMA_PULL_MODELS` controls which local Ollama models are pre-pulled

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

Phase 1 media-worker env keys expected in `.env`:

```bash
MEDIA_WORKER_BASE_URL=https://media-worker.techmatrx.com
MEDIA_WORKER_INGRESS_TOKEN=replace-with-worker-ingress-token
MEDIA_WORKER_CALLBACK_TOKEN=replace-with-worker-callback-token
OPENCLAW_MEDIA_COMPLETION_URL=https://openclaw-media.techmatrx.com/internal/media/jobs/complete
OPENCLAW_MEDIA_COMPLETION_TOKEN=replace-with-openclaw-completion-token
```

`OPENCLAW_MEDIA_COMPLETION_*` enables Callback v1 to notify OpenClaw after it
updates the n8n job row. The OpenClaw receiver is the local `media-completion`
plugin exposed through Cloudflare Tunnel at
`openclaw-media.techmatrx.com`.

The completion payload should include artifact pointers so OpenClaw does not
have to search for output media:

- `requestId`
- `jobId`
- `status`
- `assetUrls` for protected/downloadable URLs when available
- `outputPath` for local/admin-only artifacts
- `mimeType`, `duration`, `sizeBytes` when known
- `metadata.profile` and `metadata.traceId`
- `error` for failed jobs

Live workflow source exports are versioned under:

- `n8n/workflows/media/age17-music-generate-acestep-turbo-submit-v2.json`
- `n8n/workflows/media/age17-music-generate-acestep-turbo-callback-v1.json`

When patching these workflows through the live n8n UI or API, re-export them
after validation so the repo remains the recovery/source reference.

Expected services:

- `n8n` exposes the task broker on `0.0.0.0:5679`
- `task-runners` uses `n8nio/runners:2.23.4`
- JavaScript runner health check port: `5681`
- Python runner health check port: `5682`
- Launcher health check port: `5680`
- `minio` provides private S3-compatible media artifact storage on `:9000`

Python support is validated when a Python Code node can execute successfully.

### Phase 1 media artifacts in MinIO

Use MinIO as the S3-compatible artifact system of record. ComfyUI remains an
internal generation service; do not treat protected ComfyUI `/view` URLs as
human-download URLs.

Default bucket:

```bash
MEDIA_ARTIFACT_S3_BUCKET=openclaw-media
MEDIA_ARTIFACT_S3_PREFIX=generated
MEDIA_ARTIFACT_S3_ENDPOINT=http://100.73.253.62:9000
MEDIA_ARTIFACT_S3_FORCE_PATH_STYLE=true
```

`generated` is the recommended base prefix. The worker appends the detected
media type so image and video can be added without redesign:

- `generated/audio/YYYY/MM/DD/<requestId>/<filename>`
- `generated/image/YYYY/MM/DD/<requestId>/<filename>`
- `generated/video/YYYY/MM/DD/<requestId>/<filename>`

The current live audio-only deployment may still use the legacy
`MEDIA_ARTIFACT_S3_PREFIX=generated/audio`; the worker treats an already
media-specific prefix as compatible. Audio keys remain under `generated/audio`,
while future image/video keys map to sibling prefixes.

Recommended policy:

- bucket stays private
- media-worker gets a dedicated access key
- allow object put/get under the generated media prefixes needed by the worker
- generate presigned download URLs for delivery/UI use
- keep MinIO root credentials for administration only

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

After changing `.env`, recreate `n8n` before testing Callback v1 notification;
otherwise the running container will keep the old environment and
`Notify OpenClaw` will remain disabled.

### Refresh only Ollama or Cloudflared safely

Prefer compose-based updates over Synology Container Manager one-click updates so
the running containers stay aligned with the checked-in bundle.

Examples:

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml pull ollama-cpu cloudflared
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --no-deps --force-recreate ollama-cpu cloudflared
```

To refresh `n8n` after changing `N8N_IMAGE`, rebuild and recreate it explicitly:

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml build --pull n8n n8n-import
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --no-deps --force-recreate n8n-import n8n
```

To refresh external runners after changing `N8N_RUNNERS_IMAGE`:

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml pull task-runners
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d --no-deps --force-recreate task-runners
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
- optional entities export
- PostgreSQL dump
- `n8n` volume archive

Formats:

- default: split workflow + credentials exports
- `N8N_EXPORT_FORMAT=entities`: export database entities JSON instead
- `N8N_EXPORT_FORMAT=both`: capture both split exports and entities

Examples:

```bash
sudo ./n8n-backup.sh
N8N_EXPORT_FORMAT=entities sudo ./n8n-backup.sh
N8N_EXPORT_FORMAT=both sudo ./n8n-backup.sh
```

### Restore

```bash
sudo ./n8n-restore.sh YYYYMMDD_HHMMSS
```

What it restores:

- PostgreSQL
- `n8n` volume
- workflow + credentials payload, or entities payload

Restore uses explicit import override mode for `n8n-import`.

Import format selection:

- default: `auto`
- if `./backups/<timestamp>/entities` is populated, restore uses entities import
- otherwise it uses split workflow + credentials import
- you can override with `N8N_IMPORT_FORMAT=split` or `N8N_IMPORT_FORMAT=entities`

Examples:

```bash
sudo ./n8n-restore.sh YYYYMMDD_HHMMSS
N8N_IMPORT_FORMAT=entities sudo ./n8n-restore.sh YYYYMMDD_HHMMSS
N8N_IMPORT_FORMAT=split sudo ./n8n-restore.sh YYYYMMDD_HHMMSS
```

### Import Modes

`n8n-import` now supports two modes:

- `bootstrap` = default; import only when the instance is empty
- `restore` = explicit overwrite/import mode for recovery or cutover

It also supports two import formats:

- `split` = credentials + workflows using `import:credentials` and `import:workflow`
- `entities` = full database-entity import using `import:entities`

Examples:

```bash
sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d n8n-import
```

This uses default bootstrap behavior.

```bash
N8N_IMPORT_FORMAT=entities sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d n8n-import
```

This uses bootstrap behavior with entities import format.

```bash
N8N_IMPORT_MODE=restore sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d n8n-import
```

This forces restore behavior and may overwrite existing workflows/credentials if
payloads are present under `/backup`.

```bash
N8N_IMPORT_MODE=restore N8N_IMPORT_FORMAT=entities sudo /usr/local/bin/docker compose -f docker-compose.yml -f docker-compose.nas.yml up -d n8n-import
```

This forces restore behavior using `import:entities`.

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
