# RabbitMQ Media Dispatch Promotion Plan

Status: Stage 3 limited-traffic run completed; production remains HTTP.

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

## Stage 2 Canary Result

Completed on 2026-06-15 with one allowlisted production request:

- request ID: `req-rabbitmq-stage2-20260615-153525`
- job ID: `job_1781512649769_qfgsgv`
- broker message ID: `msg_1781512649769_zkb7ka`
- profile/duration: `acestep_turbo`, 15 seconds
- Submit v2 response: `202 Accepted`
- dispatch policy: `rabbitmq-canary` resolved to `rabbitmq` because the request
  ID was allowlisted
- selected worker: `mac-studio-a`, RabbitMQ enabled, prefetch `1`
- completed artifact: 417,354-byte MP3
- storage key:
  `generated/audio/2026/06/15/req-rabbitmq-stage2-20260615-153525/acestep-turbo_00033_.mp3`
- terminal job row: `completed`
- idempotent replay: `200`, same job ID, no second execution
- post-canary ready, retry, and dead-letter queues: zero messages and zero
  unacknowledged messages
- rollback completed: NAS returned to `MEDIA_DISPATCH_MODE=http`, canary
  allowlist cleared, worker returned to `RABBITMQ_ENABLED=false`, and RabbitMQ
  consumers returned to zero

The canary also exposed a callback workflow defect: Callback v1 dropped the
top-level `delivery` envelope before notifying OpenClaw, so the completed media
used the configured DM fallback. Callback v1 was patched live to preserve
`delivery` through normalization, job result storage, and the OpenClaw
notification payload. Both Callback v1 and Submit v2 validate with zero errors.
A synthetic terminal callback then proved exact routing with:

- `deliverySource=callback`
- `accountId=andytmxbot`
- `target=676871173`
- `replyTo=24424`
- Telegram message ID `24463`

No second RabbitMQ media job was run after the callback fix.

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

### Stage 2: Allowlisted Production Canary (Complete)

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

### Stage 3 Prepared Scope

Prepared on 2026-06-15. Stage 3 must remain allowlist-only; do not use a
percentage gate yet.

Scope:

- three unique 15-second `acestep_turbo` requests
- one active RabbitMQ job at a time
- explicit `MEDIA_RABBITMQ_CANARY_REQUEST_IDS` containing only the prepared
  request IDs
- observation window: 30 minutes after the third completion
- origin coverage:
  - one Telegram DM request
  - one Telegram topic request
  - one Web TUI/webchat request or synthetic terminal callback if no active
    Web TUI submit path is available

Stage 3 preflight gates:

- Submit v2 validation: zero errors
- Callback v1 validation: zero errors
- NAS `MEDIA_DISPATCH_MODE=http`
- worker `RABBITMQ_ENABLED=false`
- `media.jobs.ready`, `media.jobs.retry.1m`, and `media.jobs.dead` all have
  zero messages and zero unacknowledged messages
- worker health reports zero active/resumable jobs and capacity available
- callback delivery test after the Stage 2 fix has `deliverySource=callback`

Stage 3 runtime sequence:

1. Generate three request IDs and write them into the Stage 3 log.
2. Enable worker RabbitMQ consumer with `RABBITMQ_ENABLED=true`, prefetch `1`,
   then restart the worker.
3. Set NAS `MEDIA_DISPATCH_MODE=rabbitmq-canary`.
4. Set `MEDIA_RABBITMQ_CANARY_REQUEST_IDS` to the three generated request IDs.
5. Recreate only the n8n service.
6. Submit request 1 and wait for terminal completion.
7. Verify job row, artifact delivery, and zero ready/retry/dead queues.
8. Submit request 2 only after request 1 is terminal and queues are zero.
9. Submit request 3 only after request 2 is terminal and queues are zero.
10. Restore NAS `MEDIA_DISPATCH_MODE=http` and clear the allowlist.
11. Disable worker RabbitMQ with `RABBITMQ_ENABLED=false`, restart the worker.
12. Run an idempotent replay for each Stage 3 request and one non-allowlisted
    HTTP smoke.
13. Observe for 30 minutes: worker health, job rows, queue depth, and delivery
    logs.

Stage 3 success criteria:

- all three allowlisted requests complete exactly once
- no duplicate `requestId` or `jobId`
- all completions deliver via `deliverySource=callback`
- no messages in ready, retry, or dead-letter queues after each job
- worker returns to RabbitMQ disabled after rollback
- n8n returns to `MEDIA_DISPATCH_MODE=http`

Stage 3 no-go / abort:

- any validation error
- stale worker heartbeat
- any queue message in `media.jobs.dead`
- any retry message after the first retry interval
- callback delivery fallback for a request that supplied a delivery envelope
- ComfyUI terminal failure unrelated to RabbitMQ can be recorded, but do not
  submit the next Stage 3 request until the failed job is reconciled

Stage 3 commands use the dedicated NAS identity:

```bash
ssh -i ~/.ssh/id_ed25519_openclaw openclaw@100.73.253.62
```

Do not start Stage 3 execution without a fresh explicit `GO Stage 3`.

### Stage 3 Result

Executed on 2026-06-15 after explicit `GO Stage 3`.

Preflight:

- Submit v2 validation: zero errors
- Callback v1 validation: zero errors
- NAS started in `MEDIA_DISPATCH_MODE=http`
- worker started with `RABBITMQ_ENABLED=false`
- `media.jobs.ready`, `media.jobs.retry.1m`, and `media.jobs.dead` all started
  with zero messages and zero unacknowledged messages
- worker health reported zero active/resumable jobs and capacity available

Runtime setup:

- Stage 3 allowlist:
  - `req-rabbitmq-stage3-dm-20260615-165113`
  - `req-rabbitmq-stage3-topic-20260615-165113`
  - `req-rabbitmq-stage3-webchat-20260615-165113`
- worker RabbitMQ consumer enabled with prefetch `1`
- NAS set to `MEDIA_DISPATCH_MODE=rabbitmq-canary`
- non-allowlisted traffic remained on HTTP

Initial guardrail event:

- first DM submit failed closed before publish because Submit v2 saw a stale
  worker RabbitMQ heartbeat
- no job row was created and no RabbitMQ message was published
- refreshed the worker heartbeat with `npm run heartbeat:publish`
- continued only after the worker advertised fresh RabbitMQ readiness

Limited RabbitMQ jobs:

- DM request `req-rabbitmq-stage3-dm-20260615-165113`
  - job `job_1781517230380_mq9zlh`
  - broker message `msg_1781517230380_g563je`
  - artifact: 412,545-byte MP3
  - storage:
    `generated/audio/2026/06/15/req-rabbitmq-stage3-dm-20260615-165113/acestep-turbo_00034_.mp3`
  - delivery: `deliverySource=callback`, account `andytmxbot`, target
    `676871173`, reply-to `24491`, Telegram message `24513`
  - queues zero after completion
- Topic request `req-rabbitmq-stage3-topic-20260615-165113`
  - job `job_1781517530368_agvj97`
  - broker message `msg_1781517530368_fx1xhr`
  - artifact: 433,102-byte MP3
  - storage:
    `generated/audio/2026/06/15/req-rabbitmq-stage3-topic-20260615-165113/acestep-turbo_00035_.mp3`
  - delivery: `deliverySource=callback`, account `andytmxbot`, target
    `-1003499263851`, thread `2666`, Telegram message `3174`
  - queues zero after completion
- Webchat request `req-rabbitmq-stage3-webchat-20260615-165113`
  - job `job_1781517817172_1uy0lt`
  - artifact: 399,887-byte MP3
  - storage:
    `generated/audio/2026/06/15/req-rabbitmq-stage3-webchat-20260615-165113/acestep-turbo_00036_.mp3`
  - delivery: `deliverySource=callback`, session `agent:andy:main`, agent
    `andy`, injected message `38a7db37-41da-4086-b953-81bbdf554dfc`

Rollback and regression:

- NAS restored to `MEDIA_DISPATCH_MODE=http`
- `MEDIA_RABBITMQ_CANARY_REQUEST_IDS` cleared
- worker restored to `RABBITMQ_ENABLED=false`
- RabbitMQ consumers returned to zero
- idempotent replays for all three Stage 3 requests returned `200`, same job
  IDs, and `idempotentReplay=true`
- non-allowlisted HTTP regression request
  `req-rabbitmq-stage3-http-regression-20260615-1710` completed after rollback
  as job `job_1781518199496_gxsk9t`
  - artifact: 397,664-byte MP3
  - delivery: `deliverySource=callback`, account `andytmxbot`, target
    `676871173`, reply-to `24491`, Telegram message `24546`

Observation:

- 30-minute observation window:
  - start: `2026-06-15T10:14:18Z`
  - end: `2026-06-15T10:44:18Z`
- final worker health: `status=ok`, zero active/resumable jobs,
  `rabbitmq.enabled=false`
- final NAS mode: `MEDIA_DISPATCH_MODE=http`
- final allowlist: empty
- final `media.jobs.ready`, `media.jobs.retry.1m`, and `media.jobs.dead`
  counts: zero messages, zero ready, zero unacknowledged, zero consumers

Stage 3 result: pass. Stage 4 remains gated by a separate explicit go/no-go.

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
   Submit v2 and Callback v1 JSON from live n8n.
2. Revalidate the exported sources.
3. Prepare Stage 4 default RabbitMQ runbook and go/no-go criteria.
4. Keep production on HTTP until explicit `GO Stage 4`.
