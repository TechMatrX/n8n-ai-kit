# RabbitMQ Media Dispatch Promotion Plan

Status: design approved for implementation sequencing; production remains HTTP.

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

### Stage 1: Production Workflow, Dormant Branch

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

Add the dormant feature-flagged RabbitMQ branch to the source-controlled Submit
v2 workflow, with `MEDIA_DISPATCH_MODE=http` as the default. Validate locally
and in n8n, but do not activate RabbitMQ traffic or modify NAS runtime values.
