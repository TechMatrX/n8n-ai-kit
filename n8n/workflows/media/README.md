# Media Workflow Notes

## Media Submit Execution Retention Policy

Policy date: 2026-06-27.

During the `/media` rollout stabilization window, the active media submit
workflows intentionally save both successful and failed executions:

```text
saveDataSuccessExecution: all
saveDataErrorExecution: all
```

This keeps n8n execution history useful while validating real Telegram
commands, plugin routing, RabbitMQ dispatch, worker rendering, and artifact
callbacks. The n8n execution log is a debugging surface only; the canonical job
audit trail remains `MediaPhase1Jobs`, the media-worker database, artifact
events, and worker/plugin logs.

Rollout window:

- Start: 2026-06-27 12:30 ICT.
- Review after: 7 days, on or after 2026-07-04.
- Keep failed execution history enabled: `saveDataErrorExecution=all`.
- After the review window, either prune old successful executions or set
  `saveDataSuccessExecution=none` for high-volume submit workflows if n8n DB
  growth becomes material.
- Low-volume/debug workflows may keep successful execution history enabled when
  it remains useful for operator visibility.

Workflows covered by this policy:

| Workflow | ID | Current policy |
| --- | --- | --- |
| AGE17 Dev - Schema Review Submit v1 | `ZpEjbMuAfCZ6WeCt` | success `all`, error `all` |
| AGE17 Dev - Architecture Diagram Submit v1 | `f16UIL4cILvPoAef` | success `all`, error `all` |
| AGE17 Dev - Mermaid Preview Submit v1 | `XyKli7nWYa2JLjPJ` | success `all`, error `all` |
| AGE17 Dev - Markdown Presentation Submit v1 | `Y5aNKgs7P0bJrEJY` | success `all`, error `all` |
| AGE17 Dev - Markdown Mindmap Submit v1 | `R1X0civ6trpBVQbV` | success `all`, error `all` |
| AGE17 Dev - Career JD CV Review Submit v1 | `s1YNvxn73onMsdYY` | success `all`, error `all`; active |
| AGE17 Dev - Music Generate acestep_turbo Submit v2 | `ma2PY9x1YIcNlEBm` | success `all`, error `all` |
| AGE17 Dev - Music Generate acestep_turbo | `CCc3iuVmmLBfCdNu` | success `all`, error `all` |

## AGE17 Dev - Schema Review Submit v1

Live workflow ID: `ZpEjbMuAfCZ6WeCt`

Schema review is a read-only Atlas inspection/review path. Telegram and
OpenClaw plugin requests must pass target aliases only; database credentials
must never be sent from Telegram or persisted in chat text.

Supported target matrix:

| Target alias | Dialect | Status | Notes |
| --- | --- | --- | --- |
| `nas-n8n-postgres` | `postgres` | supported | Read-only Atlas inspect of the NAS n8n Postgres database. |
| MySQL aliases | `mysql` | planned | Add only after worker-side target registry and credential mapping are configured. |
| MariaDB aliases | `mariadb` | planned | Add only after worker-side target registry and credential mapping are configured. |

Operator command:

```text
/media schema_review target=nas-n8n-postgres dialect=postgres title="n8n schema review"
```

The `/media` router rejects unsupported target aliases before submitting to n8n.
The worker remains responsible for resolving approved aliases to credentials and
for enforcing `applyMigrations=false`.

Expected artifacts:

- Markdown report
- Atlas HCL
- redacted SQL descriptor
- JSON schema
- stats TXT
- Mermaid ERD source
- SVG ERD
- PNG ERD

## AGE17 Dev - Career JD CV Review Submit v1

Live workflow ID: `s1YNvxn73onMsdYY`

Export:

```text
n8n/workflows/media/age17-career-jd-cv-review-submit-v1.json
```

This workflow accepts a job description plus an uploaded or pasted CV, validates
that both sources are present, and dispatches the request to the media worker
profile `career_jd_cv_review`.

Dispatch uses the `Cloudflare Access - Media Worker` custom auth credential plus
the worker bearer token header. Controlled smoke
`career-review-n8n-smoke-1783487820` returned HTTP `202`, completed as
`career_jd_cv_review`, uploaded four `generated/presentation` artifacts, and
served the public artifact page:

```text
https://openclaw-media.techmatrx.com/artifacts/career-review-n8n-smoke-1783487820/
```

Accepted source shapes include:

```json
{
  "requestId": "career-review-example",
  "careerReview": {
    "company": "Example Co",
    "role": "AI Platform Architect",
    "jobDescription": {
      "text": "Job description markdown or text",
      "url": "https://example.com/job-description.txt"
    },
    "cv": {
      "text": "CV markdown or text",
      "url": "https://example.com/cv.md"
    },
    "notes": "Optional targeting notes"
  }
}
```

The worker output is analysis-only and source-bound. It can suggest how to
reframe existing CV evidence, but it must not invent employers, projects,
metrics, authorship, credentials, or skills that are not present in the provided
CV/current request context.

Expected artifacts:

- Career review report Markdown
- CV update suggestions JSON
- CV patch guidance Markdown
- JD analysis JSON

## AGE17 Dev - Music Generate acestep_turbo Submit v2

Live workflow ID: `ma2PY9x1YIcNlEBm`

The active n8n workflow now accepts both the original flat request shape and a
structured ACE-Step-inspired shape:

```json
{
  "requestId": "example",
  "profile": "music_video_loop",
  "music": {
    "tags": ["cinematic", "uplifting"],
    "lyrics": "...",
    "instrumental": false,
    "duration": 120,
    "bpm": 90,
    "key": "C major",
    "timeSignature": "4",
    "language": "en",
    "seed": 123,
    "taskType": "generate",
    "styleTags": ["pop", "orchestral"]
  },
  "youtube": {
    "title": "Video title",
    "description": "Reviewed description",
    "tags": ["ai music", "openclaw"],
    "privacyStatus": "private",
    "categoryId": "10",
    "regionCode": "VN",
    "madeForKids": false
  }
}
```

The workflow normalizes those fields into `metadata.musicRequest`,
`metadata.youtube`, and `metadata.publishing`, then preserves them in durable job
payload/result JSON and the RabbitMQ worker payload. This lets the publishing
package workflow consume reviewed metadata without reparsing the original
submit request.

## AGE17 Dev - YouTube Publish Package v1

Live workflow ID: `K1Sbm9sc6QQJNeTR`

This workflow is active as a preflight endpoint only. It validates a completed
artifact package and falls back to `metadata.youtube` / `metadata.publishing`
for title, description, tags, privacy, category, region, and made-for-kids
values. The YouTube upload branch remains disabled and disconnected from the
active preflight path.

Publishing hardening currently staged:

- package validation can now derive `finalVideoUrl` and `thumbnailUrl` from
  callback-style `assets` / `artifactMetadata` using artifact roles before
  falling back to legacy top-level URLs
- role-aware plans preserve `finalVideoRole`, `thumbnailRole`,
  `artifactCount`, and `artifactRoles` so the reviewed upload plan is traceable
- duplicate-publish detection reads `youtubePublishLedger` from workflow static
  data and blocks known duplicate keys before upload
- the ledger-write node is placed after upload and thumbnail update, but remains
  disabled so preflight tests cannot mark a video as published
- thumbnail handling is staged as `Download Thumbnail (disabled)` followed by
  `Set YouTube Thumbnail (disabled)` against YouTube's thumbnail upload
  endpoint; thumbnail upload is optional until the channel has custom-thumbnail
  permission
- response payload includes `gateBlocks`, `thumbnailPlan`, and `rollbackPlan`
- dry-run execution `7272` returned `preflight_only` with no external upload
- live preflight execution `14929` used a real `music_video_loop` package and
  returned `preflight_only` with `finalVideoRole=primary_video`,
  `thumbnailRole=cover`, `artifactCount=5`, and only three nodes executed:
  webhook, validator, and response

Real publishing now belongs to the separate guarded private workflow below.
This workflow stays preflight-only.

## AGE17 Dev - YouTube Private Publish v1

Live workflow ID: `442Fx3mlY2h8nuAU`

This workflow is staged as the separate private-upload path, but remains
inactive. It must only be activated for a deliberate approval test against a
reviewed package.

Safety gates:

- workflow inactive by default
- validates the same artifact package shape as the preflight endpoint
- requires `confirm=publish-to-youtube`
- requires `YOUTUBE_PUBLISH_APPROVAL_TOKEN`
- requires `privacyStatus=private`
- blocks duplicate publish keys
- writes the publish ledger immediately after upload, before optional thumbnail
  handling

Validation status:

- n8n validation: 0 errors, 8 expected warnings from dynamic URLs, error
  handling suggestions, and the guarded IF branch
- inactive trigger test correctly refused execution
- first controlled private upload created YouTube video `FHJKJSsnkHw`, then
  failed at custom thumbnail upload with YouTube `403` because the authenticated
  channel does not have custom thumbnail permission
- the workflow now records the ledger before thumbnail handling and includes a
  duplicate guard for the reviewed package key
  `happy-birthday-lucy-music-video-20260619120120-ltxv-sheet`
- duplicate guard proof execution `15036` returned HTTP `409` /
  `duplicate_blocked` and ran only the four gate nodes; no download, upload,
  thumbnail, or ledger branch executed
- fresh package `music-video-youtube-fit-20260619112642` uploaded successfully
  as private YouTube video `3a3Qvuzj-rY`; ledger recorded immediately after
  upload; duplicate proof execution `15131` returned HTTP `409` /
  `duplicate_blocked` and ran only the four gate nodes

Thumbnail policy:

- custom thumbnail upload currently fails with YouTube `403` because the
  authenticated channel does not have custom-thumbnail permission
- the workflow treats thumbnail upload as non-fatal and records the publish
  ledger before attempting thumbnail upload
- generated review packages should declare
  `metadata.publishing.thumbnailPolicy=manual_until_channel_custom_thumbnail_permission_enabled`
- until the channel permission is enabled, thumbnails are a manual/post-upload
  YouTube Studio step

Follow-up before another private publish:

- keep the workflow inactive until the next controlled test
- make a fresh reviewed package for the next publish test, or intentionally
  clear the duplicate guard only after confirming rollback/deletion
- enable YouTube custom-thumbnail permission for the channel when ready, then
  run a dedicated thumbnail-only proof before treating automated thumbnail
  setting as supported

Reviewed package fixture:

```text
n8n/workflows/media/fixtures/youtube-publish-package-reviewed.example.json
```

Local dry-run gate:

```bash
node scripts/youtube-publish-package-dry-run.mjs --json
node scripts/youtube-publish-package-regression.mjs
```

The dry-run gate performs no n8n or YouTube API calls. It validates required
package fields, URL shape, reviewed title/description/tags, privacy,
language, made-for-kids, duplicate key, thumbnail plan, and rollback plan. A
passing unapproved package returns `preflight_only` with `approval_required` and
`upload_branch_disabled`.

Use the fixture as the callback-to-publishing handoff shape for the first real
preflight. Replace placeholder URLs and review fields with the selected artifact
package before submitting it to the workflow.
