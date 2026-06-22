#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const DEFAULT_FIXTURE =
  "n8n/workflows/media/fixtures/youtube-publish-package-reviewed.example.json";

function parseArgs(argv) {
  const args = {
    fixture: DEFAULT_FIXTURE,
    json: false,
    approve: false,
    approvalToken: "",
    expectedApprovalToken: "",
    allowPublic: false,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--fixture") args.fixture = argv[++i];
    else if (arg === "--json") args.json = true;
    else if (arg === "--approve") args.approve = true;
    else if (arg === "--approval-token") args.approvalToken = argv[++i] || "";
    else if (arg === "--expected-approval-token") args.expectedApprovalToken = argv[++i] || "";
    else if (arg === "--allow-public") args.allowPublic = true;
    else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

function printHelp() {
  console.log(`Usage: node scripts/youtube-publish-package-dry-run.mjs [options]

Options:
  --fixture <path>                 Package JSON to validate
  --approve                        Simulate approval payload
  --approval-token <token>         Provided approval token for simulation
  --expected-approval-token <tok>  Expected approval token for simulation
  --allow-public                   Allow privacyStatus=public
  --json                           Print machine-readable JSON only
`);
}

function text(value) {
  return typeof value === "string" ? value.trim() : "";
}

function firstText(...values) {
  for (const value of values) {
    const result = text(value);
    if (result) return result;
  }
  return "";
}

function clamp(value, max) {
  const result = text(value);
  return result.length > max ? result.slice(0, max).trim() : result;
}

function arrayFrom(value) {
  if (Array.isArray(value)) return value;
  return String(value || "").split(",");
}

function isPlainObject(value) {
  return Boolean(value && typeof value === "object" && !Array.isArray(value));
}

function isHttpUrl(value) {
  try {
    const url = new URL(value);
    return url.protocol === "http:" || url.protocol === "https:";
  } catch {
    return false;
  }
}

function explicitBoolean(...values) {
  for (const value of values) {
    if (typeof value === "boolean") return value;
    if (value === "true") return true;
    if (value === "false") return false;
  }
  return undefined;
}

export function validateYouTubePublishPackage(input, options = {}) {
  const body = input.body ?? input;
  const expectedToken = text(options.expectedApprovalToken);
  const providedToken = text(options.approvalToken || body.approvalToken || body.publishApprovalToken);
  const confirm = options.approve ? "publish-to-youtube" : body.confirm;
  const publishApproved = Boolean(
    expectedToken && providedToken && providedToken === expectedToken && confirm === "publish-to-youtube",
  );
  const uploadEnabled = false;

  const artifacts = isPlainObject(body.artifacts) ? body.artifacts : {};
  const metadata = isPlainObject(body.metadata) ? body.metadata : {};
  const youtubeMetadata = isPlainObject(metadata.youtube) ? metadata.youtube : {};
  const publishingMetadata = isPlainObject(metadata.publishing) ? metadata.publishing : {};
  const musicMetadata = isPlainObject(metadata.musicRequest) ? metadata.musicRequest : {};

  const requestId = firstText(body.requestId, metadata.requestId);
  const artifactPageUrl = firstText(body.artifactPageUrl, artifacts.pageUrl, artifacts.artifactPageUrl);
  const finalVideoUrl = firstText(body.finalVideoUrl, artifacts.finalVideoUrl, artifacts.mp4Url, artifacts.videoUrl);
  const thumbnailUrl = firstText(body.thumbnailUrl, artifacts.thumbnailUrl);
  const title = clamp(firstText(body.title, youtubeMetadata.title, publishingMetadata.title, metadata.title), 100);
  const descriptionBase = firstText(
    body.description,
    youtubeMetadata.description,
    publishingMetadata.description,
    metadata.description,
  );
  const description = clamp(descriptionBase, 5000);
  const tagsRaw = Array.isArray(body.tags)
    ? body.tags
    : (Array.isArray(youtubeMetadata.tags)
        ? youtubeMetadata.tags
        : (Array.isArray(publishingMetadata.tags)
            ? publishingMetadata.tags
            : arrayFrom(youtubeMetadata.tags || publishingMetadata.tags || metadata.tags)));
  const tags = [...new Set(tagsRaw.map((tag) => text(tag)).filter(Boolean))].slice(0, 25);
  const privacyStatus = firstText(body.privacyStatus, youtubeMetadata.privacyStatus) || "private";
  const categoryId = firstText(body.categoryId, youtubeMetadata.categoryId) || "10";
  const regionCode = firstText(body.regionCode, youtubeMetadata.regionCode) || "VN";
  const language = firstText(
    body.language,
    body.defaultLanguage,
    youtubeMetadata.language,
    youtubeMetadata.defaultLanguage,
    musicMetadata.language,
  );
  const madeForKids = explicitBoolean(body.madeForKids, youtubeMetadata.madeForKids);
  const duplicateKey = firstText(body.duplicateKey, publishingMetadata.duplicateKey, requestId);

  const missing = [];
  if (!requestId) missing.push("requestId");
  if (!artifactPageUrl) missing.push("artifactPageUrl");
  if (!finalVideoUrl) missing.push("finalVideoUrl");
  if (!thumbnailUrl) missing.push("thumbnailUrl");
  if (!title) missing.push("metadata.youtube.title");
  if (!descriptionBase) missing.push("metadata.youtube.description");
  if (!tags.length) missing.push("metadata.youtube.tags");
  if (!duplicateKey) missing.push("metadata.publishing.duplicateKey");
  if (!language) missing.push("metadata.youtube.language");
  if (madeForKids === undefined) missing.push("metadata.youtube.madeForKids");

  const validationErrors = [];
  if (artifactPageUrl && !isHttpUrl(artifactPageUrl)) validationErrors.push("artifactPageUrl must be http(s)");
  if (finalVideoUrl && !isHttpUrl(finalVideoUrl)) validationErrors.push("finalVideoUrl must be http(s)");
  if (thumbnailUrl && !isHttpUrl(thumbnailUrl)) validationErrors.push("thumbnailUrl must be http(s)");
  if (privacyStatus && !["private", "unlisted", "public"].includes(privacyStatus)) {
    validationErrors.push("metadata.youtube.privacyStatus must be private, unlisted, or public");
  }
  if (privacyStatus === "public" && !options.allowPublic) {
    validationErrors.push("public privacy requires --allow-public");
  }
  if (title.length > 100) validationErrors.push("metadata.youtube.title exceeds 100 characters");
  if (description.length > 5000) validationErrors.push("metadata.youtube.description exceeds 5000 characters");

  const gateBlocks = [];
  if (missing.length) gateBlocks.push(`missing:${missing.join(",")}`);
  if (validationErrors.length) gateBlocks.push(`invalid:${validationErrors.join(",")}`);
  if (!publishApproved) gateBlocks.push("approval_required");
  if (!uploadEnabled) gateBlocks.push("upload_branch_disabled");

  const ok = missing.length === 0 && validationErrors.length === 0;
  const readyForUpload = ok && publishApproved && uploadEnabled;
  const status = !ok ? "invalid_package" : publishApproved ? "approved_preflight_only" : "preflight_only";
  const responseCode = ok ? 200 : 400;

  return {
    ok,
    responseCode,
    status,
    requestId,
    publishApproved,
    uploadEnabled,
    readyForUpload,
    gateBlocks,
    missing,
    validationErrors,
    message: ok
      ? (publishApproved
          ? "Package passed validation and explicit approval. Upload remains disabled until the final publish switch is enabled."
          : "Package passed validation. Upload requires confirm=publish-to-youtube and approvalToken.")
      : `Package validation failed: ${[...missing, ...validationErrors].join(", ")}`,
    uploadPlan: {
      requestId,
      duplicateKey,
      finalVideoUrl,
      thumbnailUrl,
      artifactPageUrl,
      title,
      description,
      tags,
      tagsCsv: tags.join(","),
      privacyStatus,
      categoryId,
      regionCode,
      language,
      madeForKids,
      notifySubscribers: false,
    },
    thumbnailPlan: {
      sourceUrl: thumbnailUrl,
      requiresVideoId: true,
      endpoint: "https://www.googleapis.com/upload/youtube/v3/thumbnails/set",
      stagedNode: "Set YouTube Thumbnail (disabled)",
    },
    rollbackPlan: {
      deleteUploadedVideo: "Use YouTube video delete by videoId if an accidental upload occurs.",
      clearLedgerKey: duplicateKey
        ? `Remove youtubePublishLedger[${duplicateKey}] from workflow static data only after confirming YouTube rollback.`
        : "",
      keepSourceArtifact: artifactPageUrl,
    },
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const fixturePath = path.resolve(args.fixture);
  const input = JSON.parse(fs.readFileSync(fixturePath, "utf8"));
  const result = validateYouTubePublishPackage(input, args);
  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(`${result.ok ? "OK" : "FAIL"} ${result.status}`);
    console.log(result.message);
    console.log(`gateBlocks=${result.gateBlocks.join(",") || "none"}`);
    if (result.missing.length) console.log(`missing=${result.missing.join(",")}`);
    if (result.validationErrors.length) console.log(`validationErrors=${result.validationErrors.join(",")}`);
    console.log(`requestId=${result.requestId || ""}`);
    console.log(`privacyStatus=${result.uploadPlan.privacyStatus}`);
    console.log(`madeForKids=${result.uploadPlan.madeForKids}`);
  }
  process.exitCode = result.ok ? 0 : 1;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
