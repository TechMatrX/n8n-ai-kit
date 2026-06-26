# Media Workflow Live State - 2026-06-26

This file records the post-hardening live n8n state for the AGE17 media
platform. It is a lightweight rollback/export manifest, not a credentials or
database backup.

## Backup Status

The full local `./n8n-backup.sh` path is currently blocked in this runtime:

- Docker daemon is not reachable from the local shell.
- Compose interpolation also requires MinIO env values that are absent from the
  repo-local `.env`, including `MINIO_ROOT_USER`.

Fallback used:

- Confirmed server-side workflow version checkpoints with
  `n8n_workflow_versions`.
- Revalidated all hardened media workflows with `n8n_validate_workflow`.
- Source exports/docs for the edited workflows are committed in this repo where
  applicable.

## Rollback Checkpoints

| Workflow | ID | Active | Latest Version ID | Notes |
| --- | --- | --- | ---: | --- |
| AGE17 Dev - Schema Review Submit v1 | `ZpEjbMuAfCZ6WeCt` | yes | `113` | Atlas/read-only schema review submit contract |
| AGE17 Dev - Architecture Diagram Submit v1 | `f16UIL4cILvPoAef` | yes | `115` | Architecture diagram artifact role submit contract |
| AGE17 Dev - Media Worker Callback v1 | `iW06DQkM5ZqaeEdt` | yes | `117` | Callback role/count preservation |
| AGE17 Dev - Mermaid Preview Submit v1 | `XyKli7nWYa2JLjPJ` | yes | `118` | Mermaid PNG/SVG expected roles |
| AGE17 Dev - Markdown Presentation Submit v1 | `Y5aNKgs7P0bJrEJY` | yes | `119` | Presentation PPTX/PDF/PNG/HTML expected roles |
| AGE17 Dev - Music Generate acestep_turbo Submit v2 | `ma2PY9x1YIcNlEBm` | yes | `120` | Profile-aware music artifact roles/counts |
| AGE17 Dev - Markdown Mindmap Submit v1 | `R1X0civ6trpBVQbV` | yes | `122` | Mindmap HTML + PNG cover expected roles |
| AGE17 Dev - YouTube Publish Package v1 | `K1Sbm9sc6QQJNeTR` | yes | `125` | Active preflight-only package validator |
| AGE17 Dev - YouTube Private Publish v1 | `442Fx3mlY2h8nuAU` | no | `146` | Guarded private publisher, inactive by default |

## Validation Snapshot

All workflows above validated with `errorCount=0`.

Expected warnings remain:

- webhook response/error-handling suggestions
- Code node error-handling suggestions
- dynamic URL expressions that validation cannot statically prove
- disabled staged publish branch warnings in `YouTube Publish Package v1`
- long-chain maintainability suggestions in callback/music workflows

## YouTube Publish State

`YouTube Publish Package v1` remains active as preflight-only. Its publish
branch is disabled/disconnected.

`YouTube Private Publish v1` remains inactive after controlled tests.

Private videos created by the controlled publish path:

- `FHJKJSsnkHw` from
  `happy-birthday-lucy-music-video-20260619120120-ltxv-sheet`
- `3a3Qvuzj-rY` from `music-video-youtube-fit-20260619112642`

Both packages are duplicate-protected. Duplicate proof for
`music-video-youtube-fit-20260619112642` was execution `15131`, which returned
HTTP `409` / `duplicate_blocked` and ran only the gate path.

## Thumbnail Policy

Automated custom-thumbnail setting is parked until the YouTube channel has
custom-thumbnail permission.

Current policy:

- review packages declare
  `metadata.publishing.thumbnailPolicy=manual_until_channel_custom_thumbnail_permission_enabled`
- thumbnail upload is optional/non-fatal
- ledger records immediately after video upload, before thumbnail handling
- thumbnails are a manual/post-upload YouTube Studio step until permission is
  enabled

## Next Safe Steps

- Run full submit-webhook proofs for Mermaid/Presentation when live submit
  tokens are available locally.
- Re-run full `./n8n-backup.sh` only after Docker is running and required
  Compose env values are present.
- If custom-thumbnail permission is enabled, run a dedicated thumbnail-only
  proof before treating automated thumbnail setting as supported.
