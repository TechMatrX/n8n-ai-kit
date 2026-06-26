# Media Workflow Notes

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
  `Set YouTube Thumbnail (disabled)` against YouTube's thumbnail upload endpoint
- response payload includes `gateBlocks`, `thumbnailPlan`, and `rollbackPlan`
- dry-run execution `7272` returned `preflight_only` with no external upload
- live preflight execution `14929` used a real `music_video_loop` package and
  returned `preflight_only` with `finalVideoRole=primary_video`,
  `thumbnailRole=cover`, `artifactCount=5`, and only three nodes executed:
  webhook, validator, and response

Real publishing still requires enabling the upload/thumbnail/ledger branch,
confirming the `YOUTUBE_PUBLISH_APPROVAL_TOKEN` positive path, and running the
first reviewed package as a private YouTube upload.

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
- writes the publish ledger only after upload and thumbnail handling complete

Validation status:

- n8n validation: 0 errors, 9 expected warnings from dynamic URLs, error
  handling suggestions, and the guarded IF branch
- inactive trigger test correctly refused execution
- first controlled private upload created YouTube video `FHJKJSsnkHw`, then
  failed at custom thumbnail upload with YouTube `403` because the authenticated
  channel does not have custom thumbnail permission
- because the thumbnail failure happened before the ledger node, the workflow
  now includes a duplicate guard for the reviewed package key
  `happy-birthday-lucy-music-video-20260619120120-ltxv-sheet`

Follow-up before another private publish:

- keep the workflow inactive until the next controlled test
- move ledger recording immediately after the video upload, before thumbnail
  handling
- make thumbnail upload non-fatal or skip it until the YouTube channel has
  custom thumbnail permission

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
