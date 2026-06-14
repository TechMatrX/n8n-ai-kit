# RabbitMQ Media Dispatch Canary Plan

Status: staged plan only. Do not enable until Andy explicitly approves.

## Current Safe State

- Submit v2 workflow: `ma2PY9x1YIcNlEBm`
- Disabled canary workflow: `CmgTVKYeHMPpVyNH`
- Default runtime path: HTTP dispatch to selected worker
- Required guardrail: `MEDIA_DISPATCH_MODE=http`
- RabbitMQ queues must remain empty before and after every pre-canary check:
  - `media.jobs.ready`
  - `media.jobs.retry.1m`
  - `media.jobs.dead`

## Preconditions

Before any canary attempt:

1. Submit v2 validates with zero errors.
2. `MediaWorkers` has at least one ready real worker.
3. Selected worker heartbeat is fresh and advertises:
   - `status=ok`
   - `drain=false`
   - `capacityAvailable=true`
   - `activeJobs < maxConcurrentJobs`
   - `comfyReachable=true`
   - target candidates for `cloudflare`, `tailscale`, or both
4. `media-worker-daemon` is running with:
   - `RABBITMQ_ENABLED=false` for pre-canary checks
   - HTTP ingress still healthy
5. NAS n8n stays on:
   - `MEDIA_DISPATCH_MODE=http`
6. RabbitMQ topology exists and queues are empty.
7. The controlled synthetic worker row remains non-dispatching:
   - `workerId=phase3-sim-drained-a`
   - `drain=true`
   - `capacityAvailable=false`

## Pre-Canary Validation

Run these without changing runtime mode:

```bash
node --check scripts/media-worker-selection-sim.mjs
node scripts/media-worker-selection-sim.mjs
```

Validate the live workflow:

```text
n8n_validate_workflow:
  id: ma2PY9x1YIcNlEBm
  profile: runtime
  expected: 0 errors
```

Check NAS dispatch mode and RabbitMQ queues:

```bash
ssh openclaw@100.73.253.62 \
  'cd /volume1/docker/n8n-ai-kit/n8n-nas-bundle &&
   grep -E "^MEDIA_DISPATCH_MODE=" .env &&
   sudo -n /usr/local/bin/docker compose --env-file .env \
     -f docker-compose.yml -f docker-compose.nas.yml \
     exec -T rabbitmq rabbitmqctl list_queues \
       name messages messages_ready messages_unacknowledged --formatter json'
```

Expected:

- `MEDIA_DISPATCH_MODE=http`
- all queue counts are `0`

## Canary Scope

The first canary must be a single low-cost audio job:

- profile: `acestep_turbo`
- duration: `15`
- count: `1`
- unique `requestId`
- no concurrent canary jobs

The canary is not a full cutover. It is one controlled RabbitMQ dispatch test.

## Disabled Canary Workflow

An inactive guarded workflow is staged for future approval:

- n8n workflow: `CmgTVKYeHMPpVyNH`
- source file: `n8n/workflows/media/media-rabbitmq-canary-submit-v1-disabled.json`
- active state: `false`
- webhook path: `dev/media/rabbitmq-canary-submit-v1`
- current behavior: inactive guarded canary path with a staged RabbitMQ publish node
- publish target: exchange `media.jobs`, routing key `media.generate`
- canary message: one `acestep_turbo` job with a 15-second Comfy workflow payload

The guard returns blocked unless all are true:

- `MEDIA_RABBITMQ_CANARY_ENABLED=true`
- request `canaryToken` matches `MEDIA_RABBITMQ_CANARY_TOKEN`
- request `confirm` equals `rabbitmq-canary-approved`

The workflow remains inactive. The RabbitMQ publish node can only run after the
workflow is explicitly activated and a request passes all guards above.

## Canary Enablement Sequence

Only execute after explicit approval.

1. Pause routine media submissions if needed.
2. Confirm RabbitMQ queues are empty.
3. Enable worker RabbitMQ consumer for exactly one worker:
   - set `RABBITMQ_ENABLED=true`
   - keep `RABBITMQ_PREFETCH=1`
   - restart `media-worker-daemon`
   - confirm `/readyz` remains healthy
4. Confirm the disabled canary workflow still contains only the guarded canary
   publish path, leaving Submit v2 untouched.
5. Switch only the canary runtime path to:
   - `MEDIA_DISPATCH_MODE=rabbitmq`
6. Submit one canary request.
7. Watch these checkpoints:
   - Submit v2 returns `202`
   - `media.jobs.ready` depth increases briefly
   - worker consumes the message
   - job row updates to `completed`
   - callback writes final result
   - `media.jobs.ready`, `media.jobs.retry.1m`, and `media.jobs.dead` return to `0`

## Abort Conditions

Abort immediately if any occur:

- Submit v2 returns non-2xx.
- `media.jobs.dead` receives any message.
- `media.jobs.retry.1m` receives any message that does not clear on first retry.
- `media.jobs.ready` stays nonzero for more than 60 seconds.
- worker `/readyz` remains unavailable after the canary.
- job row is not updated within the expected worker completion window.
- callback fails or result storage is missing.

## Rollback

Rollback order:

1. Set n8n back to `MEDIA_DISPATCH_MODE=http`.
2. Set worker back to `RABBITMQ_ENABLED=false`.
3. Restart `media-worker-daemon`.
4. Confirm HTTP Submit v2 smoke succeeds.
5. Confirm RabbitMQ queues are empty.
6. Leave the controlled synthetic worker row drained.

## Success Criteria

The canary is successful only when all are true:

- exactly one RabbitMQ canary job completes
- no dead-letter messages
- retry queue is empty
- ready queue is empty
- job row status is `completed`
- result artifact exists
- HTTP rollback smoke also succeeds

## Current Decision

Do not run the canary yet. The system is staged for a future explicit approval,
with runtime still on HTTP dispatch.
