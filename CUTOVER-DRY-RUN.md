# Cutover Dry Run

This is the first safe dry run to move from the current live Docker stack in:

- `/Users/andy/Studio/ai-agents-masterclass/local-ai-packaged`

to the repo-clean target:

- `/Users/andy/Studio/ai/n8n-ai-kit`

This is the concrete Mac runtime checklist that AGE-70 was missing.

## Current Live Runtime Facts

### Source of truth today

- Live UI: `http://localhost:5678`
- Current live repo: `/Users/andy/Studio/ai-agents-masterclass/local-ai-packaged`
- Current live container name: `n8n`

### Live Docker mounts

- `/Users/andy/Studio/ai-agents-masterclass/local-ai-packaged/n8n/backup` -> `/backup`
- `/Users/andy/Studio/ai-agents-masterclass/local-ai-packaged/shared` -> `/data/shared`
- Docker volume `local-ai-packaged_n8n_storage` -> `/home/node/.n8n`
- `/Users/andy/Studio/ai-agents-masterclass/local-ai-packaged/n8n/files` -> `/home/node/.n8n-files`

### Live named volumes

- `local-ai-packaged_n8n_storage`
- `local-ai-packaged_postgres_storage`
- `local-ai-packaged_qdrant_storage`
- `local-ai-packaged_open-webui`

### Live env keys confirmed set

- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_DB`
- `N8N_ENCRYPTION_KEY`
- `N8N_USER_MANAGEMENT_JWT_SECRET`
- `CONTENTFUL_MANAGEMENT_TOKEN`
- `CONTENTFUL_SPACE_ID`
- `CONTENTFUL_ENV_ID`
- `NODE_FUNCTION_ALLOW_EXTERNAL`
- `N8N_RELEASE_DATE`
- `N8N_RESTRICT_FILE_ACCESS_TO`
- `WEBHOOK_URL`

### Prepared snapshot for first dry run

- Backup timestamp: `20260603_191621`
- Exported workflows: `33`
- Exported credentials: `13`
- SQL dump: `backups/20260603_191621/database/n8n_backup.sql`
- Volume archive: `backups/20260603_191621/volume/n8n_storage.tar.gz`
- Import payloads copied into target repo:
  - `n8n/backup/workflows/`
  - `n8n/backup/credentials/`

## Important Constraint

The current live stack already owns these ports:

- `5678` for `n8n`
- `5432` for `postgres`
- `6333` for `qdrant`
- `8080` for `open-webui`
- `3001` for `flowise`

So a dry run cannot bind the default ports at the same time unless the old stack is stopped or the new stack is temporarily remapped.

## Recommended Dry-Run Strategy

Use a staged cutover:

1. Build and validate images first without starting the target stack.
2. Export backup material from the live source stack.
3. Prepare target `.env`.
4. Stop the old stack only when ready to test the target stack on the real ports.
5. Bring up the target stack and verify behavior.

## Step 1: Validate target images

From `/Users/andy/Studio/ai/n8n-ai-kit`:

```bash
cp .env.example .env
# fill in the real values from the current local-ai-packaged .env
./n8n-build.sh
```

Expected result:

- custom `n8n-ai-kit-n8n` image builds
- custom `n8n-ai-kit-n8n-import` image builds
- `n8n --version` runs inside the built import image

## Step 2: Export the live stack state

From `/Users/andy/Studio/ai-agents-masterclass/local-ai-packaged`:

```bash
./n8n-backup.sh
```

Expected result:

- timestamped backup under `./backups/YYYYMMDD_HHMMSS/`
- workflow exports
- credential exports
- SQL dump
- `n8n_storage.tar.gz`

## Step 3: Prepare import payloads for target repo

From the chosen backup timestamp, copy only what is needed into:

- `n8n/backup/workflows/`
- `n8n/backup/credentials/`

Do not copy:

- `database/n8n_backup.sql` into git
- `volume/n8n_storage.tar.gz` into git
- `.env` into git

## Step 4: Create the target runtime env

In `/Users/andy/Studio/ai/n8n-ai-kit/.env`:

- copy the actual values from the current source `.env`
- keep the target paths and repo layout from `n8n-ai-kit`

Minimum required values:

```env
POSTGRES_USER=...
POSTGRES_PASSWORD=...
POSTGRES_DB=...
N8N_ENCRYPTION_KEY=...
N8N_USER_MANAGEMENT_JWT_SECRET=...
CONTENTFUL_MANAGEMENT_TOKEN=...
CONTENTFUL_SPACE_ID=...
CONTENTFUL_ENV_ID=...
NODE_FUNCTION_ALLOW_EXTERNAL=...
N8N_RELEASE_DATE=...
N8N_RESTRICT_FILE_ACCESS_TO=/home/node/.n8n-files,/backup,/data/shared
WEBHOOK_URL=...
```

## Step 5: Real-port cutover test

When ready to test the target stack on the real ports:

From the old source repo:

```bash
docker compose down
```

Then from `/Users/andy/Studio/ai/n8n-ai-kit`:

```bash
docker compose up -d
docker compose ps
docker compose logs --tail=100 n8n
```

Expected checks:

- `http://localhost:5678` loads
- `n8n-import` completes successfully
- `postgres` is healthy
- `qdrant` is reachable
- `open-webui` and `flowise` come up cleanly

## Step 6: Functional verification

Verify all of these:

1. Can log into the existing local `n8n` account.
2. If login state did not migrate cleanly, create a fresh local account and confirm access to the imported instance.
3. If the previous `N8N_API_KEY` is no longer valid after cutover, create a new API key and update downstream agent/tool config that talks to this instance.
4. Expected workflows are present.
5. Expected credentials are present.
6. Shared files under `/data/shared` are visible to workflows.
7. Custom external packages work:
   - `youtube-transcript`
   - `@contentful/rich-text-from-markdown`
8. `atlas` is installed in the custom image.
9. Webhook flows still match the configured `WEBHOOK_URL`.

## Step 7: Rollback if needed

If target stack fails validation:

1. Stop the target stack:

```bash
cd /Users/andy/Studio/ai/n8n-ai-kit
docker compose down
```

2. Restart the original stack:

```bash
cd /Users/andy/Studio/ai-agents-masterclass/local-ai-packaged
docker compose up -d
```

3. If the data state was changed and must be restored, use the chosen backup timestamp with:

```bash
./n8n-restore.sh YYYYMMDD_HHMMSS
```

## NAS Follow-On

Once the local cutover succeeds, the NAS step becomes mostly infrastructure adaptation:

- replace localhost-only assumptions
- bind persistent storage to NAS-managed locations
- update `WEBHOOK_URL` for the NAS hostname
- re-test backup/restore on NAS-backed storage
- decide whether to keep the same service split or simplify the stack
