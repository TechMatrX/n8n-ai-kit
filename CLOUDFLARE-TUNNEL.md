# Cloudflare Tunnel Notes

This note captures the recommended external-access path for the current
`n8n-ai-kit` deployment and the minimum work needed to finish a durable
Cloudflare cutover.

## Decision

Use Cloudflare Tunnel as the preferred external-access layer for `n8n` instead
of exposing port `5678` directly.

Why:

- edge TLS is handled by Cloudflare
- inbound access works without router/NAT changes
- the final hostname can be stable for webhooks and editor links
- the current compose/env layout already supports a host-based external URL

## Current Validation State

Validated on 2026-06-06 against the live local `n8n` process on
`http://localhost:5678`:

- local `/healthz` returned `200`
- a Cloudflare Quick Tunnel successfully proxied the live instance
- remote `/healthz` through the Quick Tunnel returned `200`
- the n8n editor root loaded successfully through the Quick Tunnel

This proves the current deployment can sit behind Cloudflare Tunnel without
application code changes.

## Important Limitation

The validated Quick Tunnel is only a temporary test path.

Do not treat Quick Tunnel as the final production configuration because:

- the hostname is random and changes between runs
- there is no local named-tunnel credential material on this host
- there is no Cloudflare Access policy attached by default
- `WEBHOOK_URL` and editor-base settings should not be pinned to an ephemeral URL

## Named-Tunnel Prerequisites

To complete the durable cutover from this host, the operator needs:

1. Cloudflare account access for the target zone
2. a named tunnel created or permission to create one
3. local tunnel credentials under `~/.cloudflared/`
4. a chosen hostname such as `n8n.example.com`

At the time of this validation:

- `~/.cloudflared/` was absent on the host
- no named tunnel config was present locally

## Final Host Settings

Before restarting `n8n` behind the final named tunnel, set the external URL
values to the stable Cloudflare hostname:

```env
WEBHOOK_URL=https://n8n.example.com
N8N_HOST=n8n.example.com
N8N_PROTOCOL=https
N8N_EDITOR_BASE_URL=https://n8n.example.com
```

If the final runtime is the NAS phase-1 deployment, apply those values in the
NAS `.env` file before `docker compose` startup.

## Recommended Security Posture

Minimum:

- keep n8n login enabled
- keep `N8N_SECURE_COOKIE=true`
- keep API access behind `X-N8N-API-KEY`

Preferred:

- front the tunnel hostname with Cloudflare Access
- restrict UI access to approved identities
- reserve API use for explicit machine-to-machine paths

## Validation Checklist

After the named tunnel is configured, verify:

1. `https://<hostname>/healthz`
2. `https://<hostname>/`
3. `https://<hostname>/api/v1/workflows?limit=1` with `X-N8N-API-KEY`
4. n8n editor-generated webhook URLs match the Cloudflare hostname
5. MCP health check succeeds against the same hostname
