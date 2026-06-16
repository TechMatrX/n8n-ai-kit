# Mermaid Preview Media Render Plan

Status: staged, inactive.

## Purpose

Render Mermaid code blocks from OpenClaw responses into PNG images and attach
the completed image back to the same conversation using the existing
media-completion path.

## Current Live/Staged Assets

- n8n workflow: `AGE17 Dev - Mermaid Preview Submit v1 (Inactive)`
- workflow ID: `XyKli7nWYa2JLjPJ`
- webhook path: `dev/media/mermaid-preview-submit-v1`
- workflow active: `false`
- validation: `0` errors
- worker profile: `mermaid_preview`
- renderer: `@mermaid-js/mermaid-cli`
- output media type: `image/png`

## Target Flow

```text
OpenClaw message_sent hook
-> mermaid-preview plugin
-> n8n Mermaid Preview Submit v1
-> MediaPhase1Jobs
-> RabbitMQ media.jobs / media.generate
-> media-worker-daemon mermaid_preview
-> n8n Callback v1
-> media-completion plugin
-> same-channel image attachment
```

## Activation Gates

Before activating the workflow or plugin:

1. Set `MEDIA_MERMAID_PREVIEW_ENABLED=true` in the n8n runtime.
2. Set `MEDIA_MERMAID_PREVIEW_TOKEN` in the n8n runtime.
3. Create matching OpenClaw token file:
   `/Users/andy/.openclaw/secrets/media-mermaid-preview-token`.
4. Add `mermaid-preview` to OpenClaw plugin load/config with `enabled=true`.
5. Ensure worker advertises:
   - `WORKER_CAPABILITIES=audio,image`
   - `WORKER_PROFILES=acestep_turbo,mermaid_preview`
6. Restart worker and publish fresh heartbeat.
7. Activate n8n workflow only for a controlled DM test first.

## Guardrails

- Mermaid submit workflow is disabled until explicitly activated.
- Plugin defaults to `enabled=false`.
- Maximum Mermaid source size: 20 KB.
- Maximum preview blocks per message: 3.
- Render timeout: 15 seconds.
- Render failures must not block the original assistant response.
- Queue depths must return to zero after each test.

## First Test

Use a Telegram DM response with one small Mermaid block.

Expected evidence:

- n8n submit returns `202`.
- job row profile is `mermaid_preview`.
- RabbitMQ message is consumed once.
- worker produces PNG under `generated/image/...`.
- Callback marks `completed`.
- media-completion attaches the PNG to Andy DM.
- ready/retry/dead queues return to zero.
