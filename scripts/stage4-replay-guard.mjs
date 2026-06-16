#!/usr/bin/env node
/**
 * Stage 4 replay/evidence guard.
 *
 * This helper prevents the operator mistake from the 2026-06-15 Stage 4 run:
 * replaying a payload whose original request failed before a job row existed,
 * which can create a new RabbitMQ job after worker readiness is restored.
 *
 * Usage:
 *   node scripts/stage4-replay-guard.mjs --manifest stage4-run.json
 *   node scripts/stage4-replay-guard.mjs --manifest stage4-run.json --execute
 *
 * Manifest schema:
 * {
 *   "submitUrl": "https://.../webhook/dev/media/generate-acestep-turbo-v2",
 *   "requests": [
 *     {
 *       "name": "dm",
 *       "requestId": "req-rabbitmq-stage4-dm-...",
 *       "jobId": "job_...",
 *       "terminalStatus": "completed",
 *       "payload": { "requestId": "req-rabbitmq-stage4-dm-...", ... }
 *     }
 *   ]
 * }
 *
 * Guard rules:
 * - requestId is required and must equal payload.requestId.
 * - jobId is required before a replay is allowed.
 * - terminalStatus must be completed before a replay is allowed.
 * - failed pre-publish / NO_READY_WORKER payloads must not be replayed.
 * - --execute requires STAGE4_REPLAY_GUARD_CONFIRM=completed-only.
 */

import { readFile } from 'node:fs/promises';
import process from 'node:process';

const TERMINAL_REPLAYABLE = new Set(['completed']);
const NON_REPLAYABLE_ERRORS = new Set([
  'NO_READY_WORKER',
  'WORKER_NOT_RABBITMQ_READY',
  'RABBITMQ_PREFLIGHT_FAILED',
  'WORKER_DISPATCH_FAILED',
  'MEDIA_WORKER_BASE_URL_NOT_CONFIGURED',
  'MEDIA_WORKER_INGRESS_TOKEN_NOT_CONFIGURED'
]);

function usage(exitCode = 0) {
  const out = exitCode === 0 ? console.log : console.error;
  out(`Usage: node scripts/stage4-replay-guard.mjs --manifest <file> [--execute]\n\n` +
    `Dry-run validates replay eligibility. --execute performs POST replays only for completed rows.\n` +
    `Set STAGE4_REPLAY_GUARD_CONFIRM=completed-only when using --execute.`);
  process.exit(exitCode);
}

function parseArgs(argv) {
  const args = { execute: false, manifest: '' };
  for (let i = 2; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--help' || arg === '-h') usage(0);
    if (arg === '--execute') {
      args.execute = true;
      continue;
    }
    if (arg === '--manifest') {
      args.manifest = argv[++i] || '';
      continue;
    }
    console.error(`Unknown argument: ${arg}`);
    usage(2);
  }
  if (!args.manifest) usage(2);
  return args;
}

function normalizeStatus(value) {
  return String(value || '').trim().toLowerCase();
}

function validateRequest(entry, index) {
  const label = entry?.name || `request[${index}]`;
  const errors = [];
  const warnings = [];
  const requestId = String(entry?.requestId || '').trim();
  const payloadRequestId = String(entry?.payload?.requestId || '').trim();
  const jobId = String(entry?.jobId || '').trim();
  const terminalStatus = normalizeStatus(entry?.terminalStatus || entry?.status);
  const errorCode = String(entry?.errorCode || entry?.submitErrorCode || '').trim();

  if (!requestId) errors.push('missing requestId');
  if (!entry?.payload || typeof entry.payload !== 'object') errors.push('missing payload object');
  if (requestId && payloadRequestId && requestId !== payloadRequestId) {
    errors.push(`payload.requestId mismatch (${payloadRequestId})`);
  }
  if (requestId && !payloadRequestId) errors.push('payload.requestId missing');
  if (!jobId) errors.push('missing jobId; original request may not have created a job row');
  if (!TERMINAL_REPLAYABLE.has(terminalStatus)) {
    errors.push(`terminalStatus must be completed before replay; got ${terminalStatus || '<empty>'}`);
  }
  if (NON_REPLAYABLE_ERRORS.has(errorCode)) {
    errors.push(`non-replayable pre-publish errorCode ${errorCode}`);
  }
  if (entry?.allowReplay === false) errors.push('allowReplay=false');
  if (entry?.notes) warnings.push(String(entry.notes));

  return {
    label,
    requestId,
    jobId,
    terminalStatus,
    payload: entry?.payload,
    ok: errors.length === 0,
    errors,
    warnings
  };
}

async function postReplay(submitUrl, item) {
  const res = await fetch(submitUrl, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(item.payload)
  });
  const text = await res.text();
  let body;
  try { body = JSON.parse(text); } catch { body = { raw: text }; }
  const replayOk = res.status === 200 && body?.idempotentReplay === true && body?.jobId === item.jobId;
  return { httpStatus: res.status, replayOk, body };
}

async function main() {
  const args = parseArgs(process.argv);
  const manifest = JSON.parse(await readFile(args.manifest, 'utf8'));
  const submitUrl = String(manifest.submitUrl || process.env.STAGE4_SUBMIT_URL || '').trim();
  const requests = Array.isArray(manifest.requests) ? manifest.requests : [];
  if (requests.length === 0) {
    console.error('Manifest must contain a non-empty requests array.');
    process.exit(2);
  }

  const results = requests.map(validateRequest);
  const blocked = results.filter((r) => !r.ok);
  for (const result of results) {
    const prefix = result.ok ? 'ALLOW' : 'BLOCK';
    console.log(`${prefix} ${result.label} requestId=${result.requestId || '<missing>'} jobId=${result.jobId || '<missing>'} status=${result.terminalStatus || '<missing>'}`);
    for (const warning of result.warnings) console.log(`  note: ${warning}`);
    for (const error of result.errors) console.log(`  reason: ${error}`);
  }

  if (blocked.length > 0) {
    console.error(`Replay blocked: ${blocked.length} request(s) are not safe to replay.`);
    process.exit(1);
  }

  if (!args.execute) {
    console.log('Dry-run only: all listed requests are eligible for idempotency replay.');
    return;
  }

  if (!submitUrl) {
    console.error('submitUrl is required in manifest or STAGE4_SUBMIT_URL for --execute.');
    process.exit(2);
  }
  if (process.env.STAGE4_REPLAY_GUARD_CONFIRM !== 'completed-only') {
    console.error('Set STAGE4_REPLAY_GUARD_CONFIRM=completed-only to execute guarded replays.');
    process.exit(2);
  }

  for (const item of results) {
    const replay = await postReplay(submitUrl, item);
    console.log(`REPLAY ${item.label} http=${replay.httpStatus} replayOk=${replay.replayOk}`);
    console.log(JSON.stringify(replay.body));
    if (!replay.replayOk) {
      console.error(`Replay failed guard verification for ${item.label}. Stop Stage 4 evidence collection.`);
      process.exit(1);
    }
  }
}

main().catch((error) => {
  console.error(error?.stack || error?.message || String(error));
  process.exit(1);
});
