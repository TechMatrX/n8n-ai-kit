# Release Notes - 2026-06-06

## Summary

This release stabilizes the Synology NAS deployment for `n8n-ai-kit` and adds
production-safe external task-runner support for both JavaScript and Python.

## What Changed

### NAS runtime stabilization

- standardized NAS runtime paths around `${NAS_ROOT}`
- removed dependence on bundle-local backup paths for backup/restore helpers
- cleaned up duplicate bundle-local runtime folders in the live NAS environment
- preserved the working NAS operational model in `NAS-RUNTIME-OPERATIONS.md`

### Backup and restore hardening

- `n8n-backup.sh` now detects NAS mode and exports to `${NAS_ROOT}/backup`
- `n8n-restore.sh` now restores from and stages import payloads into the
  canonical NAS backup location
- `n8n-prepare-nas-bundle.sh` now includes:
  - `n8n-backup.sh`
  - `n8n-task-runners.json`

### n8n runtime cleanup

- removed deprecated `N8N_RUNNERS_ENABLED` from `docker-compose.yml`
- moved Code-node external module allowlisting to the external runner config
- cleared prior proxy and allowlist warnings in the NAS runtime

### External task runners

- added `task-runners` sidecar service using `n8nio/runners:2.23.0`
- enabled external runner mode for `n8n`
- added final known-good `n8n-task-runners.json`
- validated both launchers:
  - JavaScript
  - Python

### Update workflow safety

- `n8n-update.sh` now:
  - detects NAS mode
  - uses NAS-aware compose arguments
  - restarts `n8n` with `--force-recreate --no-deps`
  - refreshes `task-runners` separately when present

## Validated Outcomes

- `n8n` healthy
- `postgres` healthy
- `cloudflared` healthy
- `n8n-runners` healthy
- restored data confirmed present in browser
- public URL working:

```text
https://n8n.techmatrx.com
```

- Python runner validated end-to-end with a real Python Code node execution

## Known Non-Blocking Notes

- optional Python internal-runner warning is no longer relevant because the
  stack now uses the external sidecar model
- future operator actions should prefer the NAS runbook and `--no-deps` patterns
  documented in `NAS-RUNTIME-OPERATIONS.md`

