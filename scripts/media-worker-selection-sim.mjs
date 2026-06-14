const now = Date.now();
const maxAgeMs = 180000;
const requiredMediaType = "audio";
const requiredProfile = "acestep_turbo";
const defaultTargetPreference = ["cloudflare", "tailscale", "direct"];

function list(value) {
  return String(value || "")
    .split(",")
    .map((entry) => entry.trim())
    .filter(Boolean);
}

function isFresh(worker) {
  const updatedAt = Date.parse(worker.updatedAtIso || worker.updatedAt || worker.createdAt || "");
  return Number.isFinite(updatedAt) && now - updatedAt <= maxAgeMs;
}

function normalizeTarget(target) {
  if (!target || !target.kind) return null;
  return {
    kind: target.kind,
    baseUrl: target.baseUrl || null,
    jobsUrl: target.jobsUrl || null,
    auth: target.auth || null,
    reachable: target.reachable ?? null,
    status: target.status ?? null,
    latencyMs: target.latencyMs ?? null,
    error: target.error || null
  };
}

function parseHeartbeat(worker) {
  try {
    return worker.heartbeatJson ? JSON.parse(worker.heartbeatJson) : {};
  } catch {
    return {};
  }
}

function targetMetadata(worker) {
  const heartbeat = parseHeartbeat(worker);
  const dispatch = heartbeat.dispatch || {};
  const network = heartbeat.network || {};
  const targets = Array.isArray(dispatch.targets)
    ? dispatch.targets.map(normalizeTarget).filter(Boolean)
    : [];
  return {
    dispatchBaseUrl: dispatch.baseUrl || null,
    dispatchJobsUrl: dispatch.jobsUrl || null,
    publicBaseUrl: dispatch.publicBaseUrl || null,
    preferredTarget: dispatch.preferredTarget || null,
    targetPreference: Array.isArray(dispatch.targetPreference) ? dispatch.targetPreference : [],
    targets,
    networkMode: network.mode || null,
    tailscaleName: network.tailscaleName || worker.tailscaleName || null,
    tailscaleIp: network.tailscaleIp || worker.tailscaleIp || null
  };
}

function readyWorkers(workers) {
  return workers
    .filter((worker) => worker.workerId)
    .filter((worker) => worker.status === "ok")
    .filter((worker) => !worker.drain)
    .filter((worker) => Boolean(worker.capacityAvailable))
    .filter((worker) => Number(worker.activeJobs || 0) < Number(worker.maxConcurrentJobs || 0))
    .filter((worker) => Boolean(worker.comfyReachable))
    .filter((worker) => list(worker.supportedMediaTypes).includes(requiredMediaType))
    .filter((worker) => list(worker.supportedProfiles).includes(requiredProfile))
    .filter(isFresh)
    .sort((a, b) => Number(a.activeJobs || 0) - Number(b.activeJobs || 0));
}

function chooseWorker(workers) {
  const selectedWorker = readyWorkers(workers)[0];
  if (!selectedWorker) return null;
  return {
    workerId: selectedWorker.workerId,
    status: selectedWorker.status,
    activeJobs: selectedWorker.activeJobs,
    maxConcurrentJobs: selectedWorker.maxConcurrentJobs,
    updatedAtIso: selectedWorker.updatedAtIso,
    rabbitmqEnabled: selectedWorker.rabbitmqEnabled,
    rabbitmqQueue: selectedWorker.rabbitmqQueue,
    target: targetMetadata(selectedWorker)
  };
}

function legacyTarget(selectedTarget) {
  const selectedJobsUrl = String(selectedTarget.dispatchJobsUrl || "").trim();
  const selectedBaseUrl = String(selectedTarget.dispatchBaseUrl || "").trim().replace(/\/+$/, "");
  if (!selectedJobsUrl && !selectedBaseUrl) return null;
  return {
    kind: selectedTarget.preferredTarget || selectedTarget.networkMode || "legacy",
    baseUrl: selectedBaseUrl || null,
    jobsUrl: selectedJobsUrl || (selectedBaseUrl ? `${selectedBaseUrl}/jobs` : ""),
    reachable: null,
    auth: null
  };
}

function chooseTarget(selectedWorker, envPreference = "") {
  const selectedTarget = selectedWorker?.target || {};
  const targetPreference = String(envPreference || selectedTarget.targetPreference?.join?.(",") || defaultTargetPreference.join(","))
    .split(",")
    .map((entry) => entry.trim())
    .filter(Boolean);
  const candidateTargets = Array.isArray(selectedTarget.targets) ? selectedTarget.targets : [];
  for (const kind of targetPreference) {
    const target = candidateTargets.find((candidate) => candidate.kind === kind && candidate.reachable !== false && candidate.jobsUrl);
    if (target) return target;
  }
  return candidateTargets.find((candidate) => candidate.reachable !== false && candidate.jobsUrl)
    || legacyTarget(selectedTarget);
}

function worker({
  workerId,
  activeJobs = 0,
  maxConcurrentJobs = 1,
  status = "ok",
  drain = false,
  capacityAvailable = activeJobs < maxConcurrentJobs,
  comfyReachable = true,
  ageMs = 10000,
  targets = [],
  targetPreference = defaultTargetPreference
}) {
  const dispatch = {
    baseUrl: targets[0]?.baseUrl || null,
    jobsUrl: targets[0]?.jobsUrl || null,
    publicBaseUrl: targets[0]?.baseUrl || null,
    preferredTarget: targets[0]?.kind || null,
    targetPreference,
    targets
  };
  return {
    workerId,
    status,
    drain,
    activeJobs,
    maxConcurrentJobs,
    capacityAvailable,
    supportedMediaTypes: "audio",
    supportedProfiles: "acestep_turbo",
    comfyReachable,
    artifactStorageEnabled: true,
    rabbitmqEnabled: false,
    rabbitmqQueue: "media.jobs.ready",
    heartbeatJson: JSON.stringify({ dispatch, network: { mode: targets[0]?.kind || null } }),
    updatedAtIso: new Date(now - ageMs).toISOString()
  };
}

function target(kind, reachable, status = 200) {
  return {
    kind,
    baseUrl: `https://${kind}.worker.example.com`,
    jobsUrl: `https://${kind}.worker.example.com/jobs`,
    auth: kind === "cloudflare" ? "cloudflare_access" : "bearer",
    reachable,
    status,
    latencyMs: kind === "cloudflare" ? 70 : 8,
    error: reachable ? null : "simulated_unreachable"
  };
}

const scenarios = [
  {
    name: "skips unreachable preferred target and falls back to tailscale",
    workers: [
      worker({
        workerId: "worker-a",
        targets: [target("cloudflare", false, 522), target("tailscale", true, 200), target("direct", true, 200)]
      })
    ],
    expectWorker: "worker-a",
    expectTarget: "tailscale"
  },
  {
    name: "skips drained worker and selects healthy fallback worker",
    workers: [
      worker({ workerId: "worker-drained", drain: true, targets: [target("cloudflare", true, 403)] }),
      worker({ workerId: "worker-ready", targets: [target("cloudflare", true, 403)] })
    ],
    expectWorker: "worker-ready",
    expectTarget: "cloudflare"
  },
  {
    name: "skips capacity-full worker and selects available worker",
    workers: [
      worker({ workerId: "worker-full", activeJobs: 1, maxConcurrentJobs: 1, capacityAvailable: false, targets: [target("cloudflare", true, 403)] }),
      worker({ workerId: "worker-available", targets: [target("direct", true, 200)], targetPreference: ["direct"] })
    ],
    expectWorker: "worker-available",
    expectTarget: "direct"
  },
  {
    name: "returns no worker when all candidates are stale or unhealthy",
    workers: [
      worker({ workerId: "worker-stale", ageMs: maxAgeMs + 1000, targets: [target("cloudflare", true, 403)] }),
      worker({ workerId: "worker-unhealthy", comfyReachable: false, targets: [target("cloudflare", true, 403)] })
    ],
    expectWorker: null,
    expectTarget: null
  }
];

const results = scenarios.map((scenario) => {
  const selectedWorker = chooseWorker(scenario.workers);
  const selectedTarget = chooseTarget(selectedWorker);
  const passed = (selectedWorker?.workerId || null) === scenario.expectWorker
    && (selectedTarget?.kind || null) === scenario.expectTarget;
  return {
    name: scenario.name,
    passed,
    selectedWorker: selectedWorker?.workerId || null,
    selectedTarget: selectedTarget?.kind || null,
    expectedWorker: scenario.expectWorker,
    expectedTarget: scenario.expectTarget
  };
});

for (const result of results) {
  const marker = result.passed ? "PASS" : "FAIL";
  console.log(`${marker} ${result.name}`);
  console.log(`  selected=${result.selectedWorker || "none"} target=${result.selectedTarget || "none"}`);
}

const failed = results.filter((result) => !result.passed);
if (failed.length) {
  console.error(JSON.stringify({ failed }, null, 2));
  process.exit(1);
}

console.log(JSON.stringify({ ok: true, scenarios: results.length }, null, 2));
