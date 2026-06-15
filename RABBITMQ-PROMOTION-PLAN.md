# RabbitMQ Media Dispatch Promotion Plan

Status: Stage 1 live implementation complete; production remains HTTP.

## Stage 1 Live State

Completed on 2026-06-15 in active workflow `ma2PY9x1YIcNlEBm`:

- Added fail-closed validation for `http`, `rabbitmq-canary`, and `rabbitmq`.
- Added `MEDIA_RABBITMQ_CANARY_REQUEST_IDS` request-ID allowlisting.
- Added selected-worker RabbitMQ readiness and queue checks before publish.
- Added `Dispatch Policy Valid?` so policy failures cannot fall through to HTTP.
- Added dispatch policy metadata to job payload and result records.
- Kept NAS `MEDIA_DISPATCH_MODE=http`.
- Kept worker `RABBITMQ_ENABLED=false`.

Validation evidence:

- live workflow validation: 0 errors
- HTTP submit: `202 Accepted`
- idempotency replay: `200`, same job ID
- completed replacement smoke:
  `req-rabbitmq-promotion-stage1c-20260615-1439`
- completed artifact size: 404,956 bytes
- worker returned ready with zero active/resumable jobs
- ready, retry, and dead-letter queues remained empty

Origin-aware completion routing was added on 2026-06-15 before Stage 2:

- Submit v2 accepts a `delivery` envelope and persists it under job metadata.
- The worker stores that metadata durably and returns `delivery` in its
  completion callback.
- The OpenClaw media-completion plugin routes Telegram completions by
  `accountId`, `target`, `threadId`, and optional `replyTo`.
- Web TUI/webchat completions are injected into the originating `sessionKey`.
- Missing delivery metadata falls back to the configured Andy DM and is logged
  with `deliverySource=fallback`.

Origin-routing validation completed on 2026-06-15:

- Telegram topic callback `req-origin-topic-20260615152320` was delivered by
  account `andytmxbot` to chat `-1003499263851`, topic `2666`; OpenClaw
  reported message ID `3173`.
- Web TUI callback `req-origin-webchat-20260615152337` was injected into
  `agent:andy:main`; session history contains gateway-injected message ID
  `0456c3e2-1a7d-401b-a4c8-d5de333875dc`.
- Missing-envelope callback `req-origin-fallback-20260615152320` used the
  configured Telegram DM fallback with `deliverySource=fallback`; OpenClaw
  reported message ID `1318`.
- These were synthetic failed-status callbacks labeled `VALIDATION_ONLY`; no
  ComfyUI media work was submitted.
- Submit v2 runtime validation remained at zero errors.
- Worker health remained ready with zero active/resumable jobs and
  `RABBITMQ_ENABLED=false`.
- Worker source syntax validation passed.

Direct NAS queue verification was refreshed using the dedicated OpenClaw SSH
identity:

- NAS dispatch mode remained `MEDIA_DISPATCH_MODE=http`.
- `media.jobs.ready`, `media.jobs.retry.1m`, and `media.jobs.dead` each reported
  zero messages, zero ready, zero unacknowledged, and zero consumers.
- RabbitMQ management API access using the worker AMQP credential returned
  HTTP 401, as expected when that user lacks management API access; SSH plus
  `rabbitmqctl` remains the authenticated operations path.

Delivery envelope:

```json
{
  "sessionKey": "agent:andy:telegram:andytmxbot:direct:676871173",
  "agentId": "andy",
  "channel": "telegram",
  "accountId": "andytmxbot",
  "target": "676871173",
  "threadId": null,
  "replyTo": null,
  "requestedBy": "676871173"
}
```

One earlier smoke was accepted but later failed with transient
`COMFY_PROMPT_MISSING`; the worker recovered automatically and the replacement
smoke completed. This was after HTTP dispatch acceptance and did not involve
the dormant RabbitMQ branch.

Source-control follow-up: refresh the checked-in Submit v2 workflow JSON from
the live n8n API. The shell export credential returned HTTP 401, while the n8n
MCP edit/validation path remained authenticated. Do not replace the source file
with a hand-reconstructed graph.

## Objective

Promote the proven RabbitMQ canary path into Submit v2 without a flag-day
cutover. HTTP remains the default and rollback path until RabbitMQ has passed
staged production traffic.

## Target Dispatch Policy

Submit v2 chooses dispatch mode after worker selection:

1. `MEDIA_DISPATCH_MODE=http`
   - Always dispatch through the selected worker HTTP target.
2. `MEDIA_DISPATCH_MODE=rabbitmq-canary`
   - Use RabbitMQ only when the request carries an allowlisted canary marker.
   - All other requests use HTTP.
3. `MEDIA_DISPATCH_MODE=rabbitmq`
   - Use RabbitMQ only when the selected worker heartbeat advertises:
     - `rabbitmqEnabled=true`
     - the expected queue
     - fresh readiness and available capacity
   - Reject before publish when those conditions are not met.

Unknown mode values must fail closed with `INVALID_MEDIA_DISPATCH_MODE`.

## Fallback Semantics

Do not automatically retry a RabbitMQ publish through HTTP after the publish
node has run. A publish timeout can be ambiguous and automatic HTTP fallback
could generate the same media job twice.

HTTP fallback is allowed only before RabbitMQ publish:

- dispatch mode is `rabbitmq-canary` and the request is not allowlisted
- selected worker does not advertise RabbitMQ and policy explicitly permits
  pre-publish HTTP fallback
- RabbitMQ credentials or topology fail a preflight check before a job row is
  marked for broker dispatch

After a RabbitMQ publish attempt, return a broker dispatch error and reconcile
by `requestId`/`jobId`; do not send the same job over HTTP.

## Workflow Shape

The production Submit v2 workflow should add these stages after worker
selection and before transport-specific dispatch:

```text
Resolve Dispatch Policy
  -> Dispatch via HTTP
  -> Build RabbitMQ Message
  -> Create/Update Job Row
  -> Publish RabbitMQ Job
  -> Return Accepted
```

The policy node must emit:

- `dispatchMode`
- `dispatchReason`
- `fallbackEligible`
- `selectedWorker`
- `requestId`
- `jobId`
- `brokerMessageId` for RabbitMQ

Both transports must preserve the existing idempotency check and use the same
`requestId` and job-row contract.

## Observability Contract

Record these fields in `MediaPhase1Jobs.payloadJson` and `resultJson`:

- requested and resolved dispatch mode
- dispatch reason
- selected worker ID
- selected HTTP target, when used
- RabbitMQ exchange, routing key, and broker message ID, when used
- publish timestamp
- completion timestamp
- retry/dead-letter outcome

Operational checks:

- queue depth for ready, retry, and dead-letter queues
- oldest ready-message age
- worker heartbeat freshness and `rabbitmqEnabled`
- jobs queued longer than the expected completion window
- duplicate `requestId` or `jobId`

## Rollout Stages

### Stage 0: Current Baseline

- `MEDIA_DISPATCH_MODE=http`
- canary workflow inactive
- worker RabbitMQ consumer disabled
- queues empty

### Stage 1: Production Workflow, Dormant Branch (Complete Live)

- Add and validate the RabbitMQ branch in Submit v2.
- Keep `MEDIA_DISPATCH_MODE=http`.
- Run HTTP smoke and idempotency replay tests.
- Confirm the dormant branch cannot publish.

### Stage 2: Allowlisted Production Canary

- Set worker `RABBITMQ_ENABLED=true`, prefetch `1`.
- Set n8n `MEDIA_DISPATCH_MODE=rabbitmq-canary`.
- Allow exactly one unique request ID.
- Verify completion, artifact delivery, job-row state, and empty queues.
- Return to `MEDIA_DISPATCH_MODE=http` after the test.

### Stage 3: Limited RabbitMQ Traffic

- Use an explicit allowlist or deterministic percentage gate.
- Start with one request at a time.
- Require zero dead letters and no unresolved queued jobs.
- Keep HTTP available for requests not selected before publish.

### Stage 4: RabbitMQ Default

- Set `MEDIA_DISPATCH_MODE=rabbitmq`.
- Keep HTTP code and credentials intact for rollback.
- Remove the standalone canary workflow only after a stable observation period.

## Go/No-Go Gate

Go only when all are true:

- Submit v2 validation has zero errors.
- HTTP smoke and idempotency replay pass.
- At least one fresh worker advertises RabbitMQ enabled and has capacity.
- ready, retry, and dead-letter queues start at zero.
- status/callback delivery is healthy.
- completion routing preserves the originating account, chat/topic, or Web TUI
  session.
- rollback commands and responsible operator are confirmed.

No-go on any validation error, stale worker heartbeat, non-empty dead-letter
queue, unresolved job row, callback failure, or ambiguous duplicate.

## Rollback

1. Set `MEDIA_DISPATCH_MODE=http`.
2. Stop new RabbitMQ canary/percentage traffic.
3. Let already-acknowledged jobs finish; do not replay them through HTTP.
4. Inspect ready, retry, and dead-letter queues by `requestId`/`jobId`.
5. Set worker `RABBITMQ_ENABLED=false`.
6. Restart the worker and verify `/readyz`.
7. Run one HTTP smoke and one idempotency replay.
8. Keep RabbitMQ messages and job rows for reconciliation; do not purge queues
   until their ownership is understood.

## Next Implementation Slice

1. Restore an authenticated workflow export path and refresh the checked-in
   Submit v2 JSON from live n8n.
2. Revalidate the exported source.
3. Prepare the exact Stage 2 runtime commands and observation checklist using
   the dedicated OpenClaw SSH identity.
4. Prepare Stage 2 runtime commands and observation checklist.
5. Do not enable `rabbitmq-canary` or the worker consumer without a separate
   explicit go/no-go.
