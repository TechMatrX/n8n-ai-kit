#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import { validateYouTubePublishPackage } from "./youtube-publish-package-dry-run.mjs";

const fixturePath = "n8n/workflows/media/fixtures/youtube-publish-package-reviewed.example.json";
const fixture = JSON.parse(fs.readFileSync(fixturePath, "utf8"));

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

const preflight = validateYouTubePublishPackage(fixture);
assert.equal(preflight.ok, true);
assert.equal(preflight.status, "preflight_only");
assert.equal(preflight.readyForUpload, false);
assert.equal(preflight.uploadEnabled, false);
assert.equal(preflight.publishApproved, false);
assert.deepEqual(preflight.gateBlocks, ["approval_required", "upload_branch_disabled"]);
assert.equal(preflight.uploadPlan.privacyStatus, "private");
assert.equal(preflight.uploadPlan.madeForKids, false);
assert.equal(preflight.uploadPlan.language, "en");
assert.equal(preflight.uploadPlan.description.includes(fixture.artifactPageUrl), false);
assert.equal(preflight.uploadPlan.description.includes("Source artifact package"), false);
assert.equal(preflight.rollbackPlan.keepSourceArtifact, fixture.artifactPageUrl);
assert.equal(preflight.uploadPlan.finalVideoRole, null);
assert.equal(preflight.uploadPlan.thumbnailRole, null);
assert.equal(
  fixture.metadata.publishing.thumbnailPolicy,
  "set_during_private_publish_with_retry",
);

const approved = validateYouTubePublishPackage(fixture, {
  approve: true,
  approvalToken: "token",
  expectedApprovalToken: "token",
});
assert.equal(approved.ok, true);
assert.equal(approved.status, "approved_preflight_only");
assert.equal(approved.publishApproved, true);
assert.deepEqual(approved.gateBlocks, ["upload_branch_disabled"]);
assert.equal(approved.readyForUpload, false);

const missingTags = clone(fixture);
missingTags.metadata.youtube.tags = [];
const missingTagsResult = validateYouTubePublishPackage(missingTags);
assert.equal(missingTagsResult.ok, false);
assert.equal(missingTagsResult.status, "invalid_package");
assert.ok(missingTagsResult.missing.includes("metadata.youtube.tags"));
assert.ok(missingTagsResult.gateBlocks.some((block) => block.startsWith("missing:")));

const karaokePublicTerm = clone(fixture);
karaokePublicTerm.metadata.youtube.title = "Happy Birthday Lucy - Karaoke Song";
karaokePublicTerm.metadata.youtube.description = "A warm karaoke birthday song.";
karaokePublicTerm.metadata.youtube.tags = ["happy birthday", "karaoke"];
const karaokePublicTermResult = validateYouTubePublishPackage(karaokePublicTerm);
assert.equal(karaokePublicTermResult.ok, false);
assert.equal(karaokePublicTermResult.status, "invalid_package");
assert.ok(karaokePublicTermResult.validationErrors.some((error) => error.includes("blocked public term: karaoke")));

const publicPackage = clone(fixture);
publicPackage.metadata.youtube.privacyStatus = "public";
const publicBlocked = validateYouTubePublishPackage(publicPackage);
assert.equal(publicBlocked.ok, false);
assert.ok(publicBlocked.validationErrors.includes("public privacy requires --allow-public"));

const publicAllowed = validateYouTubePublishPackage(publicPackage, { allowPublic: true });
assert.equal(publicAllowed.ok, true);
assert.equal(publicAllowed.uploadPlan.privacyStatus, "public");

const missingMadeForKids = clone(fixture);
delete missingMadeForKids.metadata.youtube.madeForKids;
const missingMadeForKidsResult = validateYouTubePublishPackage(missingMadeForKids);
assert.equal(missingMadeForKidsResult.ok, false);
assert.ok(missingMadeForKidsResult.missing.includes("metadata.youtube.madeForKids"));

const callbackShape = clone(fixture);
delete callbackShape.finalVideoUrl;
delete callbackShape.thumbnailUrl;
callbackShape.assets = [
  {
    role: "cover",
    mediaType: "image",
    downloadUrl: "https://media.example.com/artifacts/music-video-loop-reviewed-YYYYMMDD-HHMM/cover.png",
  },
  {
    role: "primary_video",
    mediaType: "video",
    downloadUrl: "https://media.example.com/artifacts/music-video-loop-reviewed-YYYYMMDD-HHMM/final.mp4",
  },
];
const callbackShapeResult = validateYouTubePublishPackage(callbackShape);
assert.equal(callbackShapeResult.ok, true);
assert.equal(callbackShapeResult.uploadPlan.finalVideoRole, "primary_video");
assert.equal(callbackShapeResult.uploadPlan.thumbnailRole, "cover");
assert.equal(callbackShapeResult.uploadPlan.artifactCount, 2);
assert.deepEqual(callbackShapeResult.uploadPlan.artifactRoles, ["cover", "primary_video"]);

console.log("youtube publish package regression: ok");
