# Release Notes - 2026-06-17

## Shared Media Callback Workflow Cleanup

This release aligns the n8n source-of-truth workflow exports with the generic
media worker callback flow now used by Mermaid, presentation, image, and music
jobs.

### Workflow Identity

- Renamed live workflow `iW06DQkM5ZqaeEdt` from the old music-specific name to:
  `AGE17 Dev - Media Worker Callback v1`.
- Renamed the source export file from:
  `n8n/workflows/media/age17-music-generate-acestep-turbo-callback-v1.json`
  to:
  `n8n/workflows/media/age17-media-worker-callback-v1.json`.
- Updated export metadata so the repo matches the live workflow name.

### Callback URL

- Updated the shared callback webhook path to:
  `dev/media/media-worker-callback-v1`.
- Updated webhook ID to:
  `dev-media-media-worker-callback-v1`.
- Updated `NAS-RUNTIME-OPERATIONS.md` to point at the generic callback export
  and cleaned webhook path.

### Validation

- n8n runtime validation reports the shared callback workflow as active and
  valid with `0` errors.
- Fresh Mermaid and `/deck` Telegram smokes completed through the shared
  callback after the path change.
- `Notify OpenClaw` returned OK for both smoke paths.
- Source workflow JSON parses cleanly with `jq`.
