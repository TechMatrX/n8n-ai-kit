-- Create "agent_chat_subscriptions" table
CREATE TABLE "agent_chat_subscriptions" (
  "agentId" character varying(36) NOT NULL,
  "integrationType" character varying(64) NOT NULL,
  "credentialId" character varying(255) NOT NULL,
  "threadId" character varying(255) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_76598cf91038bee1f3ac94c94bc" PRIMARY KEY ("agentId", "integrationType", "credentialId", "threadId"),
  CONSTRAINT "CHK_agent_chat_subscriptions_integrationType" CHECK (("integrationType")::text = ANY ((ARRAY['telegram'::character varying, 'slack'::character varying, 'linear'::character varying])::text[]))
);
-- Set comment to column: "agentId" on table: "agent_chat_subscriptions"
COMMENT ON COLUMN "agent_chat_subscriptions"."agentId" IS 'Agent that owns this subscription';
-- Set comment to column: "integrationType" on table: "agent_chat_subscriptions"
COMMENT ON COLUMN "agent_chat_subscriptions"."integrationType" IS 'Chat integration platform for this subscription';
-- Set comment to column: "credentialId" on table: "agent_chat_subscriptions"
COMMENT ON COLUMN "agent_chat_subscriptions"."credentialId" IS 'Credential connection that owns this subscription';
-- Set comment to column: "threadId" on table: "agent_chat_subscriptions"
COMMENT ON COLUMN "agent_chat_subscriptions"."threadId" IS 'Platform thread ID the agent is subscribed to';
-- Create "agent_checkpoints" table
CREATE TABLE "agent_checkpoints" (
  "runId" character varying(255) NOT NULL,
  "agentId" character varying(255) NULL,
  "state" text NULL,
  "expired" boolean NOT NULL DEFAULT false,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_50a27cbafa6806c9b162304b5fd" PRIMARY KEY ("runId")
);
-- Create index "IDX_5e31c210f896d539964bf99fe3" to table: "agent_checkpoints"
CREATE INDEX "IDX_5e31c210f896d539964bf99fe3" ON "agent_checkpoints" ("agentId");
-- Create "agent_execution" table
CREATE TABLE "agent_execution" (
  "id" character varying(36) NOT NULL,
  "threadId" character varying(128) NOT NULL,
  "status" character varying(16) NOT NULL,
  "startedAt" timestamptz(3) NULL,
  "stoppedAt" timestamptz(3) NULL,
  "duration" integer NOT NULL DEFAULT 0,
  "userMessage" text NOT NULL,
  "assistantResponse" text NOT NULL,
  "model" character varying(255) NULL,
  "promptTokens" integer NULL,
  "completionTokens" integer NULL,
  "totalTokens" integer NULL,
  "cost" double precision NULL,
  "toolCalls" json NULL,
  "timeline" json NULL,
  "error" text NULL,
  "hitlStatus" character varying(16) NULL,
  "source" character varying(32) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_ba438acc8532addc12d1ef17049" PRIMARY KEY ("id"),
  CONSTRAINT "CHK_agent_execution_hitlStatus" CHECK (("hitlStatus")::text = ANY (ARRAY[('suspended'::character varying)::text, ('resumed'::character varying)::text])),
  CONSTRAINT "CHK_agent_execution_status" CHECK ((status)::text = ANY (ARRAY[('success'::character varying)::text, ('error'::character varying)::text]))
);
-- Create index "IDX_63d3c3a68b9cebf05f967f0b1c" to table: "agent_execution"
CREATE INDEX "IDX_63d3c3a68b9cebf05f967f0b1c" ON "agent_execution" ("threadId", "createdAt");
-- Create "agent_execution_threads" table
CREATE TABLE "agent_execution_threads" (
  "id" character varying(128) NOT NULL,
  "agentId" character varying(36) NOT NULL,
  "agentName" character varying(255) NOT NULL,
  "projectId" character varying(255) NOT NULL,
  "sessionNumber" integer NOT NULL DEFAULT 0,
  "totalPromptTokens" integer NOT NULL DEFAULT 0,
  "totalCompletionTokens" integer NOT NULL DEFAULT 0,
  "totalCost" double precision NOT NULL DEFAULT 0,
  "totalDuration" integer NOT NULL DEFAULT 0,
  "title" character varying(255) NULL,
  "emoji" character varying(8) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "taskId" character varying(32) NULL,
  "taskVersionId" character varying(36) NULL,
  "parentThreadId" character varying(128) NULL,
  "parentAgentId" character varying(36) NULL,
  CONSTRAINT "PK_22373dbf6ba6929d8ac50093309" PRIMARY KEY ("id")
);
-- Create index "IDX_0468a9dc35597314e641d4722a" to table: "agent_execution_threads"
CREATE INDEX "IDX_0468a9dc35597314e641d4722a" ON "agent_execution_threads" ("agentId");
-- Create index "IDX_0e2f8bf92a7a9c88b89670f701" to table: "agent_execution_threads"
CREATE INDEX "IDX_0e2f8bf92a7a9c88b89670f701" ON "agent_execution_threads" ("projectId");
-- Create index "IDX_agent_execution_threads_taskVersionId" to table: "agent_execution_threads"
CREATE INDEX "IDX_agent_execution_threads_taskVersionId" ON "agent_execution_threads" ("taskVersionId");
-- Set comment to column: "taskId" on table: "agent_execution_threads"
COMMENT ON COLUMN "agent_execution_threads"."taskId" IS 'Published task ID that triggered this session; not an FK because published runs can outlive draft task definition rows';
-- Set comment to column: "taskVersionId" on table: "agent_execution_threads"
COMMENT ON COLUMN "agent_execution_threads"."taskVersionId" IS 'Published agent_history version that supplied the task snapshot';
-- Set comment to column: "parentThreadId" on table: "agent_execution_threads"
COMMENT ON COLUMN "agent_execution_threads"."parentThreadId" IS 'Parent session thread id that delegated this subagent run.';
-- Set comment to column: "parentAgentId" on table: "agent_execution_threads"
COMMENT ON COLUMN "agent_execution_threads"."parentAgentId" IS 'Saved agent id of the parent that delegated this subagent run.';
-- Create "agent_files" table
CREATE TABLE "agent_files" (
  "id" character varying(16) NOT NULL,
  "agentId" character varying(36) NOT NULL,
  "binaryDataId" text NOT NULL,
  "fileName" character varying(255) NOT NULL,
  "mimeType" character varying(255) NOT NULL,
  "fileSizeBytes" integer NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_692920e59217af7d124cd95106f" PRIMARY KEY ("id")
);
-- Create index "IDX_45dafc48fe2ce95eac30fc8ffd" to table: "agent_files"
CREATE INDEX "IDX_45dafc48fe2ce95eac30fc8ffd" ON "agent_files" ("agentId", "createdAt");
-- Set comment to column: "id" on table: "agent_files"
COMMENT ON COLUMN "agent_files"."id" IS 'Application-generated n8n nano ID';
-- Set comment to column: "agentId" on table: "agent_files"
COMMENT ON COLUMN "agent_files"."agentId" IS 'Agent that owns this uploaded file';
-- Set comment to column: "binaryDataId" on table: "agent_files"
COMMENT ON COLUMN "agent_files"."binaryDataId" IS 'Opaque BinaryDataService reference (mode-prefixed, e.g. "filesystem-v2:<uuid>"); not an FK to binary_data, which only has rows in DB storage mode';
-- Set comment to column: "fileSizeBytes" on table: "agent_files"
COMMENT ON COLUMN "agent_files"."fileSizeBytes" IS 'Uploaded file size in bytes';
-- Create "agent_history" table
CREATE TABLE "agent_history" (
  "versionId" character varying(36) NOT NULL,
  "agentId" character varying(36) NOT NULL,
  "schema" json NULL,
  "tools" json NULL,
  "skills" json NULL,
  "publishedById" uuid NULL,
  "author" character varying(255) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_65ffcfe7a8e112fb826311fb092" PRIMARY KEY ("versionId")
);
-- Create index "IDX_87cd5a8da20304b089ea2f83fe" to table: "agent_history"
CREATE INDEX "IDX_87cd5a8da20304b089ea2f83fe" ON "agent_history" ("agentId");
-- Set comment to column: "schema" on table: "agent_history"
COMMENT ON COLUMN "agent_history"."schema" IS 'Frozen snapshot of the published AgentJsonConfig';
-- Set comment to column: "tools" on table: "agent_history"
COMMENT ON COLUMN "agent_history"."tools" IS 'Frozen map of `toolId → { code, descriptor }` at publish time';
-- Set comment to column: "skills" on table: "agent_history"
COMMENT ON COLUMN "agent_history"."skills" IS 'Frozen map of `skillId → AgentSkill` at publish time';
-- Create "agent_task_definition" table
CREATE TABLE "agent_task_definition" (
  "id" character varying(32) NOT NULL,
  "agentId" character varying(36) NOT NULL,
  "name" character varying(128) NOT NULL,
  "objective" text NOT NULL,
  "cronExpression" character varying(128) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_1756c11c637903e97629a7a784a" PRIMARY KEY ("id")
);
-- Create index "IDX_f45d0535a2ed59b6c2dd6da98a" to table: "agent_task_definition"
CREATE INDEX "IDX_f45d0535a2ed59b6c2dd6da98a" ON "agent_task_definition" ("agentId");
-- Set comment to column: "id" on table: "agent_task_definition"
COMMENT ON COLUMN "agent_task_definition"."id" IS 'Application-generated task ID referenced from agent JSON config';
-- Set comment to column: "agentId" on table: "agent_task_definition"
COMMENT ON COLUMN "agent_task_definition"."agentId" IS 'Owning agent; task definitions are deleted when the agent is deleted';
-- Set comment to column: "objective" on table: "agent_task_definition"
COMMENT ON COLUMN "agent_task_definition"."objective" IS 'User-authored instruction sent to the agent when this task runs';
-- Set comment to column: "cronExpression" on table: "agent_task_definition"
COMMENT ON COLUMN "agent_task_definition"."cronExpression" IS 'Cron schedule evaluated using the instance timezone';
-- Create "agent_task_run_lock" table
CREATE TABLE "agent_task_run_lock" (
  "agentId" character varying(36) NOT NULL,
  "taskId" character varying(32) NOT NULL,
  "holderId" uuid NOT NULL,
  "heldUntil" timestamptz(3) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_f593adaf7230e964d3c25deda64" PRIMARY KEY ("agentId", "taskId")
);
-- Set comment to column: "agentId" on table: "agent_task_run_lock"
COMMENT ON COLUMN "agent_task_run_lock"."agentId" IS 'Published agent whose scheduled task run is locked';
-- Set comment to column: "taskId" on table: "agent_task_run_lock"
COMMENT ON COLUMN "agent_task_run_lock"."taskId" IS 'Published task ID whose scheduled run is locked';
-- Set comment to column: "holderId" on table: "agent_task_run_lock"
COMMENT ON COLUMN "agent_task_run_lock"."holderId" IS 'Ephemeral lock owner token generated by the running main';
-- Set comment to column: "heldUntil" on table: "agent_task_run_lock"
COMMENT ON COLUMN "agent_task_run_lock"."heldUntil" IS 'Time after which another main can claim this task run lock';
-- Create "agent_task_snapshot" table
CREATE TABLE "agent_task_snapshot" (
  "versionId" character varying(36) NOT NULL,
  "taskId" character varying(32) NOT NULL,
  "enabled" boolean NOT NULL,
  "name" character varying(128) NOT NULL,
  "objective" text NOT NULL,
  "cronExpression" character varying(128) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_2142a8bcda2360c3c5e34f82640" PRIMARY KEY ("versionId", "taskId")
);
-- Set comment to column: "versionId" on table: "agent_task_snapshot"
COMMENT ON COLUMN "agent_task_snapshot"."versionId" IS 'Published agent_history version this task snapshot belongs to';
-- Set comment to column: "taskId" on table: "agent_task_snapshot"
COMMENT ON COLUMN "agent_task_snapshot"."taskId" IS 'Stable task ID referenced from the published agent JSON config';
-- Set comment to column: "enabled" on table: "agent_task_snapshot"
COMMENT ON COLUMN "agent_task_snapshot"."enabled" IS 'Published enabled state for this task at publish time';
-- Set comment to column: "objective" on table: "agent_task_snapshot"
COMMENT ON COLUMN "agent_task_snapshot"."objective" IS 'User-authored instruction sent to the agent when this task runs';
-- Set comment to column: "cronExpression" on table: "agent_task_snapshot"
COMMENT ON COLUMN "agent_task_snapshot"."cronExpression" IS 'Cron schedule evaluated using the instance timezone';
-- Create "agents" table
CREATE TABLE "agents" (
  "id" character varying(36) NOT NULL,
  "name" character varying(128) NOT NULL,
  "description" character varying(512) NULL,
  "projectId" character varying(255) NOT NULL,
  "integrations" json NOT NULL DEFAULT '[]',
  "schema" json NULL,
  "tools" json NOT NULL DEFAULT '{}',
  "skills" json NOT NULL DEFAULT '{}',
  "versionId" character varying(36) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "activeVersionId" character varying(36) NULL,
  CONSTRAINT "PK_9c653f28ae19c5884d5baf6a1d9" PRIMARY KEY ("id")
);
-- Create index "IDX_a30d560207c4071d98aa03c179" to table: "agents"
CREATE INDEX "IDX_a30d560207c4071d98aa03c179" ON "agents" ("projectId");
-- Create index "IDX_agents_projectId" to table: "agents"
CREATE INDEX "IDX_agents_projectId" ON "agents" ("projectId");
-- Create "agents_memory_entries" table
CREATE TABLE "agents_memory_entries" (
  "id" character varying(36) NOT NULL,
  "agentId" character varying(36) NOT NULL,
  "resourceId" character varying(255) NOT NULL,
  "content" text NOT NULL,
  "contentHash" character varying(64) NOT NULL,
  "status" character varying(16) NOT NULL,
  "supersededBy" character varying(36) NULL,
  "embeddingModel" character varying(128) NULL,
  "embedding" json NULL,
  "metadata" json NULL,
  "lastSeenAt" timestamptz(3) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_bfbc45dc88f66fae4e4b4a15fec" PRIMARY KEY ("id"),
  CONSTRAINT "FK_0edf1226b77ddc525eae4938079" FOREIGN KEY ("supersededBy") REFERENCES "agents_memory_entries" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "CHK_agents_memory_entries_status" CHECK ((status)::text = ANY (ARRAY[('active'::character varying)::text, ('superseded'::character varying)::text, ('dropped'::character varying)::text]))
);
-- Create index "IDX_0edf1226b77ddc525eae493807" to table: "agents_memory_entries"
CREATE INDEX "IDX_0edf1226b77ddc525eae493807" ON "agents_memory_entries" ("supersededBy");
-- Create index "IDX_1443a75e59adbfb796071d6639" to table: "agents_memory_entries"
CREATE INDEX "IDX_1443a75e59adbfb796071d6639" ON "agents_memory_entries" ("resourceId");
-- Create index "IDX_a03e04e94bea8439dd166d4b52" to table: "agents_memory_entries"
CREATE UNIQUE INDEX "IDX_a03e04e94bea8439dd166d4b52" ON "agents_memory_entries" ("agentId", "resourceId", "contentHash");
-- Create index "IDX_aff2807b31eccbafe59d0474f0" to table: "agents_memory_entries"
CREATE INDEX "IDX_aff2807b31eccbafe59d0474f0" ON "agents_memory_entries" ("agentId", "resourceId", "status", "createdAt", "id");
-- Set comment to column: "agentId" on table: "agents_memory_entries"
COMMENT ON COLUMN "agents_memory_entries"."agentId" IS 'Agent that owns this episodic memory entry';
-- Set comment to column: "resourceId" on table: "agents_memory_entries"
COMMENT ON COLUMN "agents_memory_entries"."resourceId" IS 'agents_resources.id partition used for episodic recall scope';
-- Set comment to column: "supersededBy" on table: "agents_memory_entries"
COMMENT ON COLUMN "agents_memory_entries"."supersededBy" IS 'Self-reference to replacement memory entry';
-- Set comment to column: "embeddingModel" on table: "agents_memory_entries"
COMMENT ON COLUMN "agents_memory_entries"."embeddingModel" IS 'Embedding model used to produce embedding';
-- Set comment to column: "embedding" on table: "agents_memory_entries"
COMMENT ON COLUMN "agents_memory_entries"."embedding" IS 'Embedding vector for episodic recall';
-- Set comment to column: "metadata" on table: "agents_memory_entries"
COMMENT ON COLUMN "agents_memory_entries"."metadata" IS 'Optional system metadata for ranking and debugging';
-- Set comment to column: "lastSeenAt" on table: "agents_memory_entries"
COMMENT ON COLUMN "agents_memory_entries"."lastSeenAt" IS 'Last time equivalent content was observed; updatedAt tracks row mutation time';
-- Create "agents_memory_entry_cursors" table
CREATE TABLE "agents_memory_entry_cursors" (
  "agentId" character varying(36) NOT NULL,
  "observationScopeId" character varying(255) NOT NULL,
  "lastIndexedObservationId" character varying(36) NOT NULL,
  "lastIndexedObservationCreatedAt" timestamptz(3) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_b31a1d5c009a27f4cc5ef8f102a" PRIMARY KEY ("agentId", "observationScopeId")
);
-- Create index "IDX_069e791e428391a5569e7a96b2" to table: "agents_memory_entry_cursors"
CREATE INDEX "IDX_069e791e428391a5569e7a96b2" ON "agents_memory_entry_cursors" ("observationScopeId");
-- Set comment to column: "agentId" on table: "agents_memory_entry_cursors"
COMMENT ON COLUMN "agents_memory_entry_cursors"."agentId" IS 'Agent that owns this cursor';
-- Set comment to column: "observationScopeId" on table: "agents_memory_entry_cursors"
COMMENT ON COLUMN "agents_memory_entry_cursors"."observationScopeId" IS 'agents_threads.id source stream indexed into episodic memory';
-- Set comment to column: "lastIndexedObservationId" on table: "agents_memory_entry_cursors"
COMMENT ON COLUMN "agents_memory_entry_cursors"."lastIndexedObservationId" IS 'Last observation-log row indexed into episodic memory';
-- Set comment to column: "lastIndexedObservationCreatedAt" on table: "agents_memory_entry_cursors"
COMMENT ON COLUMN "agents_memory_entry_cursors"."lastIndexedObservationCreatedAt" IS 'Creation timestamp for the last indexed observation-log row';
-- Create "agents_memory_entry_locks" table
CREATE TABLE "agents_memory_entry_locks" (
  "agentId" character varying(36) NOT NULL,
  "resourceId" character varying(255) NOT NULL,
  "holderId" character varying(64) NOT NULL,
  "heldUntil" timestamptz(3) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_a8e0f570d04a174292bea104ae6" PRIMARY KEY ("agentId", "resourceId")
);
-- Create index "IDX_9594c0983cfee1c8ff49b05848" to table: "agents_memory_entry_locks"
CREATE INDEX "IDX_9594c0983cfee1c8ff49b05848" ON "agents_memory_entry_locks" ("resourceId");
-- Set comment to column: "agentId" on table: "agents_memory_entry_locks"
COMMENT ON COLUMN "agents_memory_entry_locks"."agentId" IS 'Agent that owns this lock';
-- Set comment to column: "resourceId" on table: "agents_memory_entry_locks"
COMMENT ON COLUMN "agents_memory_entry_locks"."resourceId" IS 'agents_resources.id partition locked for episodic indexing';
-- Set comment to column: "holderId" on table: "agents_memory_entry_locks"
COMMENT ON COLUMN "agents_memory_entry_locks"."holderId" IS 'Ephemeral background-task lock owner token';
-- Create "agents_memory_entry_sources" table
CREATE TABLE "agents_memory_entry_sources" (
  "id" character varying(36) NOT NULL,
  "agentId" character varying(36) NOT NULL,
  "memoryEntryId" character varying(36) NOT NULL,
  "observationId" character varying(36) NOT NULL,
  "threadId" character varying(255) NOT NULL,
  "evidenceHash" character varying(64) NOT NULL,
  "evidenceText" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_278f05e98e74baaaa93f52b4bab" PRIMARY KEY ("id")
);
-- Create index "IDX_451d387a182fa8dd8002dfc3a7" to table: "agents_memory_entry_sources"
CREATE INDEX "IDX_451d387a182fa8dd8002dfc3a7" ON "agents_memory_entry_sources" ("threadId");
-- Create index "IDX_a353ac251315ef0af6ad3c9f0a" to table: "agents_memory_entry_sources"
CREATE UNIQUE INDEX "IDX_a353ac251315ef0af6ad3c9f0a" ON "agents_memory_entry_sources" ("memoryEntryId", "observationId", "evidenceHash");
-- Create index "IDX_cb7c15d22fd068a0806aa57fc0" to table: "agents_memory_entry_sources"
CREATE INDEX "IDX_cb7c15d22fd068a0806aa57fc0" ON "agents_memory_entry_sources" ("observationId");
-- Create index "IDX_f9573af4ed653f13b0ba1f7b12" to table: "agents_memory_entry_sources"
CREATE INDEX "IDX_f9573af4ed653f13b0ba1f7b12" ON "agents_memory_entry_sources" ("agentId", "threadId");
-- Set comment to column: "agentId" on table: "agents_memory_entry_sources"
COMMENT ON COLUMN "agents_memory_entry_sources"."agentId" IS 'Agent that owns the linked episodic memory entry source';
-- Set comment to column: "memoryEntryId" on table: "agents_memory_entry_sources"
COMMENT ON COLUMN "agents_memory_entry_sources"."memoryEntryId" IS 'Episodic memory entry linked to this source evidence';
-- Set comment to column: "observationId" on table: "agents_memory_entry_sources"
COMMENT ON COLUMN "agents_memory_entry_sources"."observationId" IS 'Observation-log row used as source evidence';
-- Set comment to column: "threadId" on table: "agents_memory_entry_sources"
COMMENT ON COLUMN "agents_memory_entry_sources"."threadId" IS 'Source conversation thread that produced the linked observation';
-- Set comment to column: "evidenceHash" on table: "agents_memory_entry_sources"
COMMENT ON COLUMN "agents_memory_entry_sources"."evidenceHash" IS 'Bounded hash used to deduplicate exact evidence links';
-- Set comment to column: "evidenceText" on table: "agents_memory_entry_sources"
COMMENT ON COLUMN "agents_memory_entry_sources"."evidenceText" IS 'Exact source evidence text from the observation, not recall scope';
-- Create "agents_messages" table
CREATE TABLE "agents_messages" (
  "id" character varying(36) NOT NULL,
  "threadId" character varying(255) NOT NULL,
  "resourceId" character varying(255) NOT NULL,
  "role" character varying(36) NOT NULL,
  "type" character varying(36) NULL,
  "content" json NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_81020dc608dfb0af1ede386d907" PRIMARY KEY ("id")
);
-- Create index "IDX_agents_messages_threadId_createdAt" to table: "agents_messages"
CREATE INDEX "IDX_agents_messages_threadId_createdAt" ON "agents_messages" ("threadId", "createdAt");
-- Create index "IDX_fc7bf858660bfafd19181e8e35" to table: "agents_messages"
CREATE INDEX "IDX_fc7bf858660bfafd19181e8e35" ON "agents_messages" ("threadId", "createdAt");
-- Create "agents_observation_cursors" table
CREATE TABLE "agents_observation_cursors" (
  "agentId" character varying(36) NOT NULL,
  "observationScopeId" character varying(255) NOT NULL,
  "lastObservedMessageId" character varying(36) NOT NULL,
  "lastObservedAt" timestamptz(3) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_eb777ac57ab872d38f8ebd19317" PRIMARY KEY ("agentId", "observationScopeId")
);
-- Create index "IDX_87aa187d27ea67eafd16490515" to table: "agents_observation_cursors"
CREATE INDEX "IDX_87aa187d27ea67eafd16490515" ON "agents_observation_cursors" ("observationScopeId");
-- Set comment to column: "agentId" on table: "agents_observation_cursors"
COMMENT ON COLUMN "agents_observation_cursors"."agentId" IS 'Agent that owns this cursor';
-- Set comment to column: "observationScopeId" on table: "agents_observation_cursors"
COMMENT ON COLUMN "agents_observation_cursors"."observationScopeId" IS 'agents_threads.id source stream checkpointed by this cursor';
-- Create "agents_observation_locks" table
CREATE TABLE "agents_observation_locks" (
  "agentId" character varying(36) NOT NULL,
  "observationScopeId" character varying(255) NOT NULL,
  "taskKind" character varying(20) NOT NULL,
  "holderId" character varying(64) NOT NULL,
  "heldUntil" timestamptz(3) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_7e2e315162ac3d80587e15ac2c3" PRIMARY KEY ("agentId", "observationScopeId", "taskKind"),
  CONSTRAINT "CHK_agents_observation_locks_taskKind" CHECK (("taskKind")::text = ANY (ARRAY[('observer'::character varying)::text, ('reflector'::character varying)::text]))
);
-- Create index "IDX_6b55089892e447c2f82e5ec60e" to table: "agents_observation_locks"
CREATE INDEX "IDX_6b55089892e447c2f82e5ec60e" ON "agents_observation_locks" ("observationScopeId");
-- Set comment to column: "agentId" on table: "agents_observation_locks"
COMMENT ON COLUMN "agents_observation_locks"."agentId" IS 'Agent that owns this lock';
-- Set comment to column: "observationScopeId" on table: "agents_observation_locks"
COMMENT ON COLUMN "agents_observation_locks"."observationScopeId" IS 'agents_threads.id source stream locked for observation tasks';
-- Set comment to column: "holderId" on table: "agents_observation_locks"
COMMENT ON COLUMN "agents_observation_locks"."holderId" IS 'Ephemeral background-task lock owner token, not a user ID';
-- Create "agents_observations" table
CREATE TABLE "agents_observations" (
  "id" character varying(36) NOT NULL,
  "agentId" character varying(36) NOT NULL,
  "observationScopeId" character varying(255) NOT NULL,
  "marker" character varying(16) NOT NULL,
  "text" text NOT NULL,
  "parentId" character varying(36) NULL,
  "tokenCount" integer NOT NULL DEFAULT 0,
  "status" character varying(16) NOT NULL,
  "supersededBy" character varying(36) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_9ad319654d12c2649f7caf27135" PRIMARY KEY ("id"),
  CONSTRAINT "FK_127ee1078ffa952bb37b511efad" FOREIGN KEY ("supersededBy") REFERENCES "agents_observations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_501e2d1701a10e24fb69ab5fc5f" FOREIGN KEY ("parentId") REFERENCES "agents_observations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "CHK_agents_observations_marker" CHECK ((marker)::text = ANY (ARRAY[('critical'::character varying)::text, ('important'::character varying)::text, ('info'::character varying)::text, ('completion'::character varying)::text])),
  CONSTRAINT "CHK_agents_observations_status" CHECK ((status)::text = ANY (ARRAY[('active'::character varying)::text, ('superseded'::character varying)::text, ('dropped'::character varying)::text]))
);
-- Create index "IDX_07cb1e4a302629c5fa5d74d2bb" to table: "agents_observations"
CREATE INDEX "IDX_07cb1e4a302629c5fa5d74d2bb" ON "agents_observations" ("agentId", "observationScopeId", "status");
-- Create index "IDX_127ee1078ffa952bb37b511efa" to table: "agents_observations"
CREATE INDEX "IDX_127ee1078ffa952bb37b511efa" ON "agents_observations" ("supersededBy");
-- Create index "IDX_4cfd8a70ebb0a5b0cf047dca3c" to table: "agents_observations"
CREATE INDEX "IDX_4cfd8a70ebb0a5b0cf047dca3c" ON "agents_observations" ("observationScopeId");
-- Create index "IDX_501e2d1701a10e24fb69ab5fc5" to table: "agents_observations"
CREATE INDEX "IDX_501e2d1701a10e24fb69ab5fc5" ON "agents_observations" ("parentId");
-- Set comment to column: "id" on table: "agents_observations"
COMMENT ON COLUMN "agents_observations"."id" IS 'Application-generated n8n string ID, not a database UUID';
-- Set comment to column: "agentId" on table: "agents_observations"
COMMENT ON COLUMN "agents_observations"."agentId" IS 'Agent that owns this observation row';
-- Set comment to column: "observationScopeId" on table: "agents_observations"
COMMENT ON COLUMN "agents_observations"."observationScopeId" IS 'agents_threads.id source stream for this observation log';
-- Create "agents_resources" table
CREATE TABLE "agents_resources" (
  "id" character varying(255) NOT NULL,
  "metadata" text NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_fa6b20b2d31a9991529dbf8ef7d" PRIMARY KEY ("id")
);
-- Create "agents_threads" table
CREATE TABLE "agents_threads" (
  "id" character varying(128) NOT NULL,
  "resourceId" character varying(255) NOT NULL,
  "title" character varying(255) NULL,
  "metadata" text NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_4a3feb0a13ffe315c009cce64e5" PRIMARY KEY ("id")
);
-- Create index "IDX_54fa1b94f34a409beafae567a4" to table: "agents_threads"
CREATE INDEX "IDX_54fa1b94f34a409beafae567a4" ON "agents_threads" ("resourceId");
-- Create "ai_builder_temporary_workflow" table
CREATE TABLE "ai_builder_temporary_workflow" (
  "workflowId" character varying(36) NOT NULL,
  "threadId" uuid NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_85a87a1ba0f61999fe11dc56325" PRIMARY KEY ("workflowId")
);
-- Create index "IDX_39b07732e819fb561d74c38763" to table: "ai_builder_temporary_workflow"
CREATE INDEX "IDX_39b07732e819fb561d74c38763" ON "ai_builder_temporary_workflow" ("threadId");
-- Create "annotation_tag_entity" table
CREATE TABLE "annotation_tag_entity" (
  "id" character varying(16) NOT NULL,
  "name" character varying(24) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_69dfa041592c30bbc0d4b84aa00" PRIMARY KEY ("id")
);
-- Create index "IDX_ae51b54c4bb430cf92f48b623f" to table: "annotation_tag_entity"
CREATE UNIQUE INDEX "IDX_ae51b54c4bb430cf92f48b623f" ON "annotation_tag_entity" ("name");
-- Create "auth_identity" table
CREATE TABLE "auth_identity" (
  "userId" uuid NULL,
  "providerId" character varying(255) NOT NULL,
  "providerType" character varying(32) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY ("providerId", "providerType")
);
-- Create "auth_provider_sync_history" table
CREATE TABLE "auth_provider_sync_history" (
  "id" serial NOT NULL,
  "providerType" character varying(32) NOT NULL,
  "runMode" text NOT NULL,
  "status" text NOT NULL,
  "startedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "endedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "scanned" integer NOT NULL,
  "created" integer NOT NULL,
  "updated" integer NOT NULL,
  "disabled" integer NOT NULL,
  "error" text NULL,
  PRIMARY KEY ("id")
);
-- Create "binary_data" table
CREATE TABLE "binary_data" (
  "fileId" uuid NOT NULL,
  "sourceType" character varying(50) NOT NULL,
  "sourceId" character varying(255) NOT NULL,
  "data" bytea NOT NULL,
  "mimeType" character varying(255) NULL,
  "fileName" character varying(255) NULL,
  "fileSize" integer NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_fc3691585b39408bb0551122af6" PRIMARY KEY ("fileId"),
  CONSTRAINT "CHK_binary_data_sourceType" CHECK (("sourceType")::text = ANY ((ARRAY['execution'::character varying, 'chat_message_attachment'::character varying, 'agent_file'::character varying])::text[]))
);
-- Create index "IDX_56900edc3cfd16612e2ef2c6a8" to table: "binary_data"
CREATE INDEX "IDX_56900edc3cfd16612e2ef2c6a8" ON "binary_data" ("sourceType", "sourceId");
-- Set comment to column: "sourceType" on table: "binary_data"
COMMENT ON COLUMN "binary_data"."sourceType" IS 'Source the file belongs to, e.g. ''execution''';
-- Set comment to column: "sourceId" on table: "binary_data"
COMMENT ON COLUMN "binary_data"."sourceId" IS 'ID of the source, e.g. execution ID';
-- Set comment to column: "data" on table: "binary_data"
COMMENT ON COLUMN "binary_data"."data" IS 'Raw, not base64 encoded';
-- Set comment to column: "fileSize" on table: "binary_data"
COMMENT ON COLUMN "binary_data"."fileSize" IS 'In bytes';
-- Create "chat_hub_agent_tools" table
CREATE TABLE "chat_hub_agent_tools" (
  "agentId" uuid NOT NULL,
  "toolId" uuid NOT NULL,
  CONSTRAINT "PK_cc8806fdea48297a7d497035d72" PRIMARY KEY ("agentId", "toolId")
);
-- Create "chat_hub_agents" table
CREATE TABLE "chat_hub_agents" (
  "id" uuid NOT NULL,
  "name" character varying(256) NOT NULL,
  "description" character varying(512) NULL,
  "systemPrompt" text NOT NULL,
  "ownerId" uuid NOT NULL,
  "credentialId" character varying(36) NULL,
  "provider" character varying(16) NOT NULL,
  "model" character varying(64) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "icon" json NULL,
  "files" json NOT NULL DEFAULT '[]',
  "suggestedPrompts" json NOT NULL DEFAULT '[]',
  CONSTRAINT "PK_f39a3b36bbdf0e2979ddb21cf78" PRIMARY KEY ("id")
);
-- Set comment to column: "provider" on table: "chat_hub_agents"
COMMENT ON COLUMN "chat_hub_agents"."provider" IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';
-- Set comment to column: "model" on table: "chat_hub_agents"
COMMENT ON COLUMN "chat_hub_agents"."model" IS 'Model name used at the respective Model node, ie. "gpt-4"';
-- Create "chat_hub_messages" table
CREATE TABLE "chat_hub_messages" (
  "id" uuid NOT NULL,
  "sessionId" uuid NOT NULL,
  "previousMessageId" uuid NULL,
  "revisionOfMessageId" uuid NULL,
  "retryOfMessageId" uuid NULL,
  "type" character varying(16) NOT NULL,
  "name" character varying(128) NOT NULL,
  "content" text NOT NULL,
  "provider" character varying(16) NULL,
  "model" character varying(256) NULL,
  "workflowId" character varying(36) NULL,
  "executionId" integer NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "agentId" uuid NULL,
  "status" character varying(16) NOT NULL DEFAULT 'success',
  "attachments" json NULL,
  CONSTRAINT "PK_7704a5add6baed43eef835f0bfb" PRIMARY KEY ("id"),
  CONSTRAINT "FK_1f4998c8a7dec9e00a9ab15550e" FOREIGN KEY ("revisionOfMessageId") REFERENCES "chat_hub_messages" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "FK_25c9736e7f769f3a005eef4b372" FOREIGN KEY ("retryOfMessageId") REFERENCES "chat_hub_messages" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "FK_e5d1fa722c5a8d38ac204746662" FOREIGN KEY ("previousMessageId") REFERENCES "chat_hub_messages" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create index "IDX_chat_hub_messages_sessionId" to table: "chat_hub_messages"
CREATE INDEX "IDX_chat_hub_messages_sessionId" ON "chat_hub_messages" ("sessionId");
-- Set comment to column: "type" on table: "chat_hub_messages"
COMMENT ON COLUMN "chat_hub_messages"."type" IS 'ChatHubMessageType enum: "human", "ai", "system", "tool", "generic"';
-- Set comment to column: "provider" on table: "chat_hub_messages"
COMMENT ON COLUMN "chat_hub_messages"."provider" IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';
-- Set comment to column: "model" on table: "chat_hub_messages"
COMMENT ON COLUMN "chat_hub_messages"."model" IS 'Model name used at the respective Model node, ie. "gpt-4"';
-- Set comment to column: "agentId" on table: "chat_hub_messages"
COMMENT ON COLUMN "chat_hub_messages"."agentId" IS 'ID of the custom agent (if provider is "custom-agent")';
-- Set comment to column: "status" on table: "chat_hub_messages"
COMMENT ON COLUMN "chat_hub_messages"."status" IS 'ChatHubMessageStatus enum, eg. "success", "error", "running", "cancelled"';
-- Set comment to column: "attachments" on table: "chat_hub_messages"
COMMENT ON COLUMN "chat_hub_messages"."attachments" IS 'File attachments for the message (if any), stored as JSON. Files are stored as base64-encoded data URLs.';
-- Create "chat_hub_session_tools" table
CREATE TABLE "chat_hub_session_tools" (
  "sessionId" uuid NOT NULL,
  "toolId" uuid NOT NULL,
  CONSTRAINT "PK_87aea76ff4c274c4a5ac838ebe3" PRIMARY KEY ("sessionId", "toolId")
);
-- Create "chat_hub_sessions" table
CREATE TABLE "chat_hub_sessions" (
  "id" uuid NOT NULL,
  "title" character varying(256) NOT NULL,
  "ownerId" uuid NOT NULL,
  "lastMessageAt" timestamptz(3) NOT NULL,
  "credentialId" character varying(36) NULL,
  "provider" character varying(16) NULL,
  "model" character varying(256) NULL,
  "workflowId" character varying(36) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "agentId" uuid NULL,
  "agentName" character varying(128) NULL,
  "type" character varying(16) NOT NULL DEFAULT 'production',
  CONSTRAINT "PK_1eafef1273c70e4464fec703412" PRIMARY KEY ("id"),
  CONSTRAINT "CHK_chat_hub_sessions_type" CHECK ((type)::text = ANY (ARRAY[('production'::character varying)::text, ('manual'::character varying)::text]))
);
-- Create index "IDX_chat_hub_sessions_owner_lastmsg_id" to table: "chat_hub_sessions"
CREATE INDEX "IDX_chat_hub_sessions_owner_lastmsg_id" ON "chat_hub_sessions" ("ownerId", "lastMessageAt" DESC, "id");
-- Set comment to column: "provider" on table: "chat_hub_sessions"
COMMENT ON COLUMN "chat_hub_sessions"."provider" IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';
-- Set comment to column: "model" on table: "chat_hub_sessions"
COMMENT ON COLUMN "chat_hub_sessions"."model" IS 'Model name used at the respective Model node, ie. "gpt-4"';
-- Set comment to column: "agentId" on table: "chat_hub_sessions"
COMMENT ON COLUMN "chat_hub_sessions"."agentId" IS 'ID of the custom agent (if provider is "custom-agent")';
-- Set comment to column: "agentName" on table: "chat_hub_sessions"
COMMENT ON COLUMN "chat_hub_sessions"."agentName" IS 'Cached name of the custom agent (if provider is "custom-agent")';
-- Create "chat_hub_tools" table
CREATE TABLE "chat_hub_tools" (
  "id" uuid NOT NULL,
  "name" character varying(255) NOT NULL,
  "type" character varying(255) NOT NULL,
  "typeVersion" double precision NOT NULL,
  "ownerId" uuid NOT NULL,
  "definition" json NOT NULL,
  "enabled" boolean NOT NULL DEFAULT true,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_696d26426c704fba79b2c195ef5" PRIMARY KEY ("id")
);
-- Create index "IDX_4c72ebdb265d1775bf61147af0" to table: "chat_hub_tools"
CREATE UNIQUE INDEX "IDX_4c72ebdb265d1775bf61147af0" ON "chat_hub_tools" ("ownerId", "name");
-- Create "credential_dependency" table
CREATE TABLE "credential_dependency" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "credentialId" character varying(36) NOT NULL,
  "dependencyType" character varying(64) NOT NULL,
  "dependencyId" character varying(255) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_80212729ed0ffa0709417ab28f4" PRIMARY KEY ("id")
);
-- Create index "IDX_5ec8e8c8d3539f3696cf73b43b" to table: "credential_dependency"
CREATE INDEX "IDX_5ec8e8c8d3539f3696cf73b43b" ON "credential_dependency" ("credentialId");
-- Create index "IDX_91ee85fa9619dd6776725e117b" to table: "credential_dependency"
CREATE INDEX "IDX_91ee85fa9619dd6776725e117b" ON "credential_dependency" ("dependencyType", "dependencyId");
-- Create index "IDX_credential_dependency_credentialId_dependencyType_dependenc" to table: "credential_dependency"
CREATE UNIQUE INDEX "IDX_credential_dependency_credentialId_dependencyType_dependenc" ON "credential_dependency" ("credentialId", "dependencyType", "dependencyId");
-- Create "credentials_entity" table
CREATE TABLE "credentials_entity" (
  "name" character varying(128) NOT NULL,
  "data" text NOT NULL,
  "type" character varying(128) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "id" character varying(36) NOT NULL,
  "isManaged" boolean NOT NULL DEFAULT false,
  "isGlobal" boolean NOT NULL DEFAULT false,
  "isResolvable" boolean NOT NULL DEFAULT false,
  "resolvableAllowFallback" boolean NOT NULL DEFAULT false,
  "resolverId" character varying(16) NULL,
  PRIMARY KEY ("id")
);
-- Create index "idx_07fde106c0b471d8cc80a64fc8" to table: "credentials_entity"
CREATE INDEX "idx_07fde106c0b471d8cc80a64fc8" ON "credentials_entity" ("type");
-- Create index "pk_credentials_entity_id" to table: "credentials_entity"
CREATE UNIQUE INDEX "pk_credentials_entity_id" ON "credentials_entity" ("id");
-- Create "data_table" table
CREATE TABLE "data_table" (
  "id" character varying(36) NOT NULL,
  "name" character varying(128) NOT NULL,
  "projectId" character varying(36) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_e226d0001b9e6097cbfe70617cb" PRIMARY KEY ("id"),
  CONSTRAINT "UQ_b23096ef747281ac944d28e8b0d" UNIQUE ("projectId", "name")
);
-- Create "data_table_column" table
CREATE TABLE "data_table_column" (
  "id" character varying(36) NOT NULL,
  "name" character varying(128) NOT NULL,
  "type" character varying(32) NOT NULL,
  "index" integer NOT NULL,
  "dataTableId" character varying(36) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_673cb121ee4a8a5e27850c72c51" PRIMARY KEY ("id"),
  CONSTRAINT "UQ_8082ec4890f892f0bc77473a123" UNIQUE ("dataTableId", "name")
);
-- Set comment to column: "type" on table: "data_table_column"
COMMENT ON COLUMN "data_table_column"."type" IS 'Expected: string, number, boolean, or date (not enforced as a constraint)';
-- Set comment to column: "index" on table: "data_table_column"
COMMENT ON COLUMN "data_table_column"."index" IS 'Column order, starting from 0 (0 = first column)';
-- Create "data_table_user_SPGOyAFf0KBfcgp4" table
CREATE TABLE "data_table_user_SPGOyAFf0KBfcgp4" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "requestId" text NULL,
  "jobId" text NULL,
  "status" text NULL,
  "payloadJson" text NULL,
  "resultJson" text NULL,
  "updatedAtIso" text NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_9960a93a33db14782944ee8a19d" PRIMARY KEY ("id")
);
-- Create "data_table_user_V1zRtKHvsME9BgkO" table
CREATE TABLE "data_table_user_V1zRtKHvsME9BgkO" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "workerId" text NULL,
  "status" text NULL,
  "drain" boolean NULL,
  "activeJobs" double precision NULL,
  "maxConcurrentJobs" double precision NULL,
  "capacityAvailable" boolean NULL,
  "supportedMediaTypes" text NULL,
  "supportedProfiles" text NULL,
  "comfyReachable" boolean NULL,
  "artifactStorageEnabled" boolean NULL,
  "rabbitmqEnabled" boolean NULL,
  "rabbitmqQueue" text NULL,
  "heartbeatJson" text NULL,
  "updatedAtIso" timestamptz(3) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_1fae78f527bce05f567894db2b3" PRIMARY KEY ("id")
);
-- Create "deployment_key" table
CREATE TABLE "deployment_key" (
  "id" character varying(36) NOT NULL,
  "type" character varying(64) NOT NULL,
  "value" text NOT NULL,
  "algorithm" character varying(20) NULL,
  "status" character varying(20) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_94bb7aeb5def5a0284a5fe9f9a0" PRIMARY KEY ("id")
);
-- Create index "IDX_deployment_key_data_encryption_active" to table: "deployment_key"
CREATE UNIQUE INDEX "IDX_deployment_key_data_encryption_active" ON "deployment_key" ("type") WHERE (((status)::text = 'active'::text) AND ((type)::text = 'data_encryption'::text));
-- Create index "IDX_deployment_key_instance_id_active" to table: "deployment_key"
CREATE UNIQUE INDEX "IDX_deployment_key_instance_id_active" ON "deployment_key" ("type") WHERE (((status)::text = 'active'::text) AND ((type)::text = 'instance.id'::text));
-- Create index "IDX_deployment_key_jwe_private_key_active" to table: "deployment_key"
CREATE UNIQUE INDEX "IDX_deployment_key_jwe_private_key_active" ON "deployment_key" ("type", "algorithm") WHERE (((status)::text = 'active'::text) AND ((type)::text = 'jwe.private-key'::text));
-- Create index "IDX_deployment_key_signing_binary_data_active" to table: "deployment_key"
CREATE UNIQUE INDEX "IDX_deployment_key_signing_binary_data_active" ON "deployment_key" ("type") WHERE (((status)::text = 'active'::text) AND ((type)::text = 'signing.binary_data'::text));
-- Create index "IDX_deployment_key_signing_hmac_active" to table: "deployment_key"
CREATE UNIQUE INDEX "IDX_deployment_key_signing_hmac_active" ON "deployment_key" ("type") WHERE (((status)::text = 'active'::text) AND ((type)::text = 'signing.hmac'::text));
-- Create index "IDX_deployment_key_signing_jwt_active" to table: "deployment_key"
CREATE UNIQUE INDEX "IDX_deployment_key_signing_jwt_active" ON "deployment_key" ("type") WHERE (((status)::text = 'active'::text) AND ((type)::text = 'signing.jwt'::text));
-- Create "dynamic_credential_entry" table
CREATE TABLE "dynamic_credential_entry" (
  "credential_id" character varying(16) NOT NULL,
  "subject_id" character varying(2048) NOT NULL,
  "resolver_id" character varying(16) NOT NULL,
  "data" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_5135ffcabecad4727ff6b9b803d" PRIMARY KEY ("credential_id", "subject_id", "resolver_id")
);
-- Create index "IDX_62476b94b56d9dc7ed9ed75d3d" to table: "dynamic_credential_entry"
CREATE INDEX "IDX_62476b94b56d9dc7ed9ed75d3d" ON "dynamic_credential_entry" ("subject_id");
-- Create index "IDX_d61a12235d268a49af6a3c09c1" to table: "dynamic_credential_entry"
CREATE INDEX "IDX_d61a12235d268a49af6a3c09c1" ON "dynamic_credential_entry" ("resolver_id");
-- Create "dynamic_credential_resolver" table
CREATE TABLE "dynamic_credential_resolver" (
  "id" character varying(16) NOT NULL,
  "name" character varying(128) NOT NULL,
  "type" character varying(128) NOT NULL,
  "config" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_b76cfb088dcdaf5275e9980bb64" PRIMARY KEY ("id")
);
-- Create index "IDX_9c9ee9df586e60bb723234e499" to table: "dynamic_credential_resolver"
CREATE INDEX "IDX_9c9ee9df586e60bb723234e499" ON "dynamic_credential_resolver" ("type");
-- Set comment to column: "config" on table: "dynamic_credential_resolver"
COMMENT ON COLUMN "dynamic_credential_resolver"."config" IS 'Encrypted resolver configuration (JSON encrypted as string)';
-- Create "dynamic_credential_user_entry" table
CREATE TABLE "dynamic_credential_user_entry" (
  "credentialId" character varying(16) NOT NULL,
  "userId" uuid NOT NULL,
  "resolverId" character varying(16) NOT NULL,
  "data" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_74f548e633abc66dc27c8f0ca77" PRIMARY KEY ("credentialId", "userId", "resolverId")
);
-- Create index "IDX_6edec973a6450990977bb854c3" to table: "dynamic_credential_user_entry"
CREATE INDEX "IDX_6edec973a6450990977bb854c3" ON "dynamic_credential_user_entry" ("resolverId");
-- Create index "IDX_a36dc616fabc3f736bb82410a2" to table: "dynamic_credential_user_entry"
CREATE INDEX "IDX_a36dc616fabc3f736bb82410a2" ON "dynamic_credential_user_entry" ("userId");
-- Create "evaluation_collection" table
CREATE TABLE "evaluation_collection" (
  "id" character varying(36) NOT NULL,
  "name" character varying(128) NOT NULL,
  "description" text NULL,
  "workflowId" character varying(36) NOT NULL,
  "evaluationConfigId" character varying(36) NOT NULL,
  "createdById" uuid NULL,
  "insightsCache" json NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_e720b6efc1e45b878ebb0b2ca30" PRIMARY KEY ("id")
);
-- Create index "IDX_a48ce930c3bc7604894b8f0eaa" to table: "evaluation_collection"
CREATE INDEX "IDX_a48ce930c3bc7604894b8f0eaa" ON "evaluation_collection" ("workflowId");
-- Create index "IDX_d634a0c93fd7de68a87eab951b" to table: "evaluation_collection"
CREATE INDEX "IDX_d634a0c93fd7de68a87eab951b" ON "evaluation_collection" ("evaluationConfigId");
-- Create "evaluation_config" table
CREATE TABLE "evaluation_config" (
  "id" character varying(36) NOT NULL,
  "workflowId" character varying(36) NOT NULL,
  "name" character varying(128) NOT NULL,
  "status" character varying(16) NOT NULL DEFAULT 'valid',
  "invalidReason" character varying(64) NULL,
  "datasetSource" character varying(32) NOT NULL,
  "datasetRef" json NOT NULL,
  "startNodeName" character varying(255) NOT NULL,
  "endNodeName" character varying(255) NOT NULL,
  "metrics" json NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_59c14dccf8989df94070c2dcfda" PRIMARY KEY ("id"),
  CONSTRAINT "UQ_3c3c99a712e971835c52292e44c" UNIQUE ("workflowId", "name")
);
-- Create index "IDX_fd7542bb123074760285dc1bbf" to table: "evaluation_config"
CREATE INDEX "IDX_fd7542bb123074760285dc1bbf" ON "evaluation_config" ("workflowId");
-- Create "event_destinations" table
CREATE TABLE "event_destinations" (
  "id" uuid NOT NULL,
  "destination" jsonb NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY ("id")
);
-- Create "execution_annotation_tags" table
CREATE TABLE "execution_annotation_tags" (
  "annotationId" integer NOT NULL,
  "tagId" character varying(24) NOT NULL,
  CONSTRAINT "PK_979ec03d31294cca484be65d11f" PRIMARY KEY ("annotationId", "tagId")
);
-- Create index "IDX_a3697779b366e131b2bbdae297" to table: "execution_annotation_tags"
CREATE INDEX "IDX_a3697779b366e131b2bbdae297" ON "execution_annotation_tags" ("tagId");
-- Create index "IDX_c1519757391996eb06064f0e7c" to table: "execution_annotation_tags"
CREATE INDEX "IDX_c1519757391996eb06064f0e7c" ON "execution_annotation_tags" ("annotationId");
-- Create "execution_annotations" table
CREATE TABLE "execution_annotations" (
  "id" serial NOT NULL,
  "executionId" integer NOT NULL,
  "vote" character varying(6) NULL,
  "note" text NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_7afcf93ffa20c4252869a7c6a23" PRIMARY KEY ("id")
);
-- Create index "IDX_97f863fa83c4786f1956508496" to table: "execution_annotations"
CREATE UNIQUE INDEX "IDX_97f863fa83c4786f1956508496" ON "execution_annotations" ("executionId");
-- Create "execution_data" table
CREATE TABLE "execution_data" (
  "executionId" integer NOT NULL,
  "workflowData" json NOT NULL,
  "data" text NOT NULL,
  "workflowVersionId" character varying(36) NULL,
  PRIMARY KEY ("executionId")
);
-- Create "execution_entity" table
CREATE TABLE "execution_entity" (
  "id" serial NOT NULL,
  "finished" boolean NOT NULL,
  "mode" character varying NOT NULL,
  "retryOf" character varying NULL,
  "retrySuccessId" character varying NULL,
  "startedAt" timestamptz(3) NULL,
  "stoppedAt" timestamptz(3) NULL,
  "waitTill" timestamptz(3) NULL,
  "status" character varying NOT NULL,
  "workflowId" character varying(36) NOT NULL,
  "deletedAt" timestamptz(3) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "storedAt" character varying(2) NOT NULL DEFAULT 'db',
  "tracingContext" json NULL,
  "deduplicationKey" character varying(255) NULL,
  "jsonSizeBytes" bigint NOT NULL DEFAULT 0,
  "workflowVersionId" character varying(36) NULL DEFAULT NULL::character varying,
  CONSTRAINT "pk_e3e63bbf986767844bbe1166d4e" PRIMARY KEY ("id"),
  CONSTRAINT "execution_entity_storedAt_check" CHECK (("storedAt")::text = ANY (ARRAY[('db'::character varying)::text, ('fs'::character varying)::text, ('s3'::character varying)::text]))
);
-- Create index "IDX_execution_entity_deduplicationKey" to table: "execution_entity"
CREATE UNIQUE INDEX "IDX_execution_entity_deduplicationKey" ON "execution_entity" ("deduplicationKey") WHERE ("deduplicationKey" IS NOT NULL);
-- Create index "IDX_execution_entity_deletedAt" to table: "execution_entity"
CREATE INDEX "IDX_execution_entity_deletedAt" ON "execution_entity" ("deletedAt");
-- Create index "IDX_execution_entity_workflowId_status_id" to table: "execution_entity"
CREATE INDEX "IDX_execution_entity_workflowId_status_id" ON "execution_entity" ("workflowId", "status", "id") WHERE ("deletedAt" IS NULL);
-- Create index "idx_execution_entity_stopped_at_status_deleted_at" to table: "execution_entity"
CREATE INDEX "idx_execution_entity_stopped_at_status_deleted_at" ON "execution_entity" ("stoppedAt", "status", "deletedAt") WHERE (("stoppedAt" IS NOT NULL) AND ("deletedAt" IS NULL));
-- Create index "idx_execution_entity_wait_till_status_deleted_at" to table: "execution_entity"
CREATE INDEX "idx_execution_entity_wait_till_status_deleted_at" ON "execution_entity" ("waitTill", "status", "deletedAt") WHERE (("waitTill" IS NOT NULL) AND ("deletedAt" IS NULL));
-- Create index "idx_execution_entity_workflow_id_started_at" to table: "execution_entity"
CREATE INDEX "idx_execution_entity_workflow_id_started_at" ON "execution_entity" ("workflowId", "startedAt") WHERE (("startedAt" IS NOT NULL) AND ("deletedAt" IS NULL));
-- Set comment to column: "jsonSizeBytes" on table: "execution_entity"
COMMENT ON COLUMN "execution_entity"."jsonSizeBytes" IS 'Byte size of the JSON execution data bundle (run data, workflow snapshot, version id); excludes binary data. 0 means unknown.';
-- Set comment to column: "workflowVersionId" on table: "execution_entity"
COMMENT ON COLUMN "execution_entity"."workflowVersionId" IS 'Version id of the workflow run by this execution; denormalized from the data bundle.';
-- Create "execution_metadata" table
CREATE TABLE "execution_metadata" (
  "id" serial NOT NULL,
  "executionId" integer NOT NULL,
  "key" character varying(255) NOT NULL,
  "value" text NOT NULL,
  CONSTRAINT "PK_17a0b6284f8d626aae88e1c16e4" PRIMARY KEY ("id")
);
-- Create index "IDX_cec8eea3bf49551482ccb4933e" to table: "execution_metadata"
CREATE UNIQUE INDEX "IDX_cec8eea3bf49551482ccb4933e" ON "execution_metadata" ("executionId", "key");
-- Create "folder" table
CREATE TABLE "folder" (
  "id" character varying(36) NOT NULL,
  "name" character varying(128) NOT NULL,
  "parentFolderId" character varying(36) NULL,
  "projectId" character varying(36) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_6278a41a706740c94c02e288df8" PRIMARY KEY ("id"),
  CONSTRAINT "FK_804ea52f6729e3940498bd54d78" FOREIGN KEY ("parentFolderId") REFERENCES "folder" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create index "IDX_14f68deffaf858465715995508" to table: "folder"
CREATE UNIQUE INDEX "IDX_14f68deffaf858465715995508" ON "folder" ("projectId", "id");
-- Create "folder_tag" table
CREATE TABLE "folder_tag" (
  "folderId" character varying(36) NOT NULL,
  "tagId" character varying(36) NOT NULL,
  CONSTRAINT "PK_27e4e00852f6b06a925a4d83a3e" PRIMARY KEY ("folderId", "tagId")
);
-- Create "insights_by_period" table
CREATE TABLE "insights_by_period" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "metaId" integer NOT NULL,
  "type" integer NOT NULL,
  "value" bigint NOT NULL,
  "periodUnit" integer NOT NULL,
  "periodStart" timestamptz(0) NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "PK_b606942249b90cc39b0265f0575" PRIMARY KEY ("id")
);
-- Create index "IDX_60b6a84299eeb3f671dfec7693" to table: "insights_by_period"
CREATE UNIQUE INDEX "IDX_60b6a84299eeb3f671dfec7693" ON "insights_by_period" ("periodStart", "type", "periodUnit", "metaId");
-- Set comment to column: "type" on table: "insights_by_period"
COMMENT ON COLUMN "insights_by_period"."type" IS '0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure';
-- Set comment to column: "periodUnit" on table: "insights_by_period"
COMMENT ON COLUMN "insights_by_period"."periodUnit" IS '0: hour, 1: day, 2: week';
-- Create "insights_metadata" table
CREATE TABLE "insights_metadata" (
  "metaId" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "workflowId" character varying(36) NULL,
  "projectId" character varying(36) NULL,
  "workflowName" character varying(128) NOT NULL,
  "projectName" character varying(255) NOT NULL,
  CONSTRAINT "PK_f448a94c35218b6208ce20cf5a1" PRIMARY KEY ("metaId")
);
-- Create index "IDX_1d8ab99d5861c9388d2dc1cf73" to table: "insights_metadata"
CREATE UNIQUE INDEX "IDX_1d8ab99d5861c9388d2dc1cf73" ON "insights_metadata" ("workflowId");
-- Create "insights_raw" table
CREATE TABLE "insights_raw" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "metaId" integer NOT NULL,
  "type" integer NOT NULL,
  "value" bigint NOT NULL,
  "timestamp" timestamptz(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "PK_ec15125755151e3a7e00e00014f" PRIMARY KEY ("id")
);
-- Create index "IDX_insights_raw_timestamp_id" to table: "insights_raw"
CREATE INDEX "IDX_insights_raw_timestamp_id" ON "insights_raw" ("timestamp", "id");
-- Set comment to column: "type" on table: "insights_raw"
COMMENT ON COLUMN "insights_raw"."type" IS '0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure';
-- Create "installed_nodes" table
CREATE TABLE "installed_nodes" (
  "name" character varying(200) NOT NULL,
  "type" character varying(200) NOT NULL,
  "latestVersion" integer NOT NULL DEFAULT 1,
  "package" character varying(241) NOT NULL,
  CONSTRAINT "PK_8ebd28194e4f792f96b5933423fc439df97d9689" PRIMARY KEY ("name")
);
-- Create "installed_packages" table
CREATE TABLE "installed_packages" (
  "packageName" character varying(214) NOT NULL,
  "installedVersion" character varying(50) NOT NULL,
  "authorName" character varying(70) NULL,
  "authorEmail" character varying(70) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_08cc9197c39b028c1e9beca225940576fd1a5804" PRIMARY KEY ("packageName")
);
-- Create "instance_ai_checkpoints" table
CREATE TABLE "instance_ai_checkpoints" (
  "key" character varying(255) NOT NULL,
  "runId" character varying(255) NULL,
  "threadId" uuid NOT NULL,
  "resourceId" character varying(255) NULL,
  "state" json NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "expiredAt" timestamptz(3) NULL,
  CONSTRAINT "PK_5315a45f0846d1f9d128c18a2ed" PRIMARY KEY ("key"),
  CONSTRAINT "instance_ai_checkpoints_state_tombstone_check" CHECK ((("expiredAt" IS NOT NULL) AND (state IS NULL)) OR ("expiredAt" IS NULL))
);
-- Create index "IDX_2b23f3f24a70bebb990203b011" to table: "instance_ai_checkpoints"
CREATE INDEX "IDX_2b23f3f24a70bebb990203b011" ON "instance_ai_checkpoints" ("threadId");
-- Create index "IDX_768189b506cc26c4fe878b87cb" to table: "instance_ai_checkpoints"
CREATE INDEX "IDX_768189b506cc26c4fe878b87cb" ON "instance_ai_checkpoints" ("runId");
-- Create index "IDX_be9d0eca0b19fb93d4eb74b327" to table: "instance_ai_checkpoints"
CREATE INDEX "IDX_be9d0eca0b19fb93d4eb74b327" ON "instance_ai_checkpoints" ("resourceId");
-- Set comment to column: "key" on table: "instance_ai_checkpoints"
COMMENT ON COLUMN "instance_ai_checkpoints"."key" IS 'Opaque checkpoint key from the agent runtime.';
-- Set comment to column: "runId" on table: "instance_ai_checkpoints"
COMMENT ON COLUMN "instance_ai_checkpoints"."runId" IS 'Run ID parsed from the checkpoint key when available.';
-- Set comment to column: "threadId" on table: "instance_ai_checkpoints"
COMMENT ON COLUMN "instance_ai_checkpoints"."threadId" IS 'Instance AI thread that owns the checkpoint.';
-- Set comment to column: "resourceId" on table: "instance_ai_checkpoints"
COMMENT ON COLUMN "instance_ai_checkpoints"."resourceId" IS 'Resource ID recorded by the agent runtime.';
-- Set comment to column: "state" on table: "instance_ai_checkpoints"
COMMENT ON COLUMN "instance_ai_checkpoints"."state" IS 'Serializable agent state snapshot stored as JSON.';
-- Set comment to column: "expiredAt" on table: "instance_ai_checkpoints"
COMMENT ON COLUMN "instance_ai_checkpoints"."expiredAt" IS 'Soft-delete timestamp: null means live; non-null marks the row as a tombstone.';
-- Create "instance_ai_iteration_logs" table
CREATE TABLE "instance_ai_iteration_logs" (
  "id" character varying(36) NOT NULL,
  "threadId" uuid NOT NULL,
  "taskKey" character varying NOT NULL,
  "entry" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_21c2b214b44bc6c34a6d3551c90" PRIMARY KEY ("id")
);
-- Create index "IDX_02751202c9a2ad75f2d8e14f5e" to table: "instance_ai_iteration_logs"
CREATE INDEX "IDX_02751202c9a2ad75f2d8e14f5e" ON "instance_ai_iteration_logs" ("threadId", "taskKey", "createdAt");
-- Create "instance_ai_mcp_registry_connections" table
CREATE TABLE "instance_ai_mcp_registry_connections" (
  "id" uuid NOT NULL,
  "credentialId" character varying(36) NOT NULL,
  "serverSlug" character varying(255) NOT NULL,
  "toolFilter" json NULL,
  "userId" uuid NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_e34e4d15d78eabbe8217e33ef03" PRIMARY KEY ("id")
);
-- Create index "IDX_16db3adb7b19df1ee55ff06b27" to table: "instance_ai_mcp_registry_connections"
CREATE UNIQUE INDEX "IDX_16db3adb7b19df1ee55ff06b27" ON "instance_ai_mcp_registry_connections" ("userId", "serverSlug", "credentialId");
-- Set comment to column: "toolFilter" on table: "instance_ai_mcp_registry_connections"
COMMENT ON COLUMN "instance_ai_mcp_registry_connections"."toolFilter" IS 'Optional MCP tool filter per registry connection: { mode: "allow" | "exclude", tools: string[] }';
-- Create "instance_ai_messages" table
CREATE TABLE "instance_ai_messages" (
  "id" character varying(36) NOT NULL,
  "threadId" uuid NOT NULL,
  "content" text NOT NULL,
  "role" character varying(16) NOT NULL,
  "type" character varying(32) NULL,
  "resourceId" character varying(255) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_156c6f287225e9befe0181bb02b" PRIMARY KEY ("id")
);
-- Create index "IDX_1eeb64cb9d66a927988de759e6" to table: "instance_ai_messages"
CREATE INDEX "IDX_1eeb64cb9d66a927988de759e6" ON "instance_ai_messages" ("threadId");
-- Create index "IDX_76e212c6867fbaa06bf0decd6f" to table: "instance_ai_messages"
CREATE INDEX "IDX_76e212c6867fbaa06bf0decd6f" ON "instance_ai_messages" ("resourceId");
-- Create "instance_ai_observation_cursors" table
CREATE TABLE "instance_ai_observation_cursors" (
  "observationScopeId" uuid NOT NULL,
  "lastObservedMessageId" character varying(36) NOT NULL,
  "lastObservedAt" timestamptz(3) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_5b6319b2e9a37c1064a72428f9a" PRIMARY KEY ("observationScopeId")
);
-- Set comment to column: "observationScopeId" on table: "instance_ai_observation_cursors"
COMMENT ON COLUMN "instance_ai_observation_cursors"."observationScopeId" IS 'instance_ai_threads.id source stream checkpointed by this cursor';
-- Create "instance_ai_observation_locks" table
CREATE TABLE "instance_ai_observation_locks" (
  "observationScopeId" uuid NOT NULL,
  "taskKind" character varying(20) NOT NULL,
  "holderId" character varying(64) NOT NULL,
  "heldUntil" timestamptz(3) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_fc491dd378b9448655c3c683f85" PRIMARY KEY ("observationScopeId", "taskKind"),
  CONSTRAINT "CHK_instance_ai_observation_locks_taskKind" CHECK (("taskKind")::text = ANY (ARRAY[('observer'::character varying)::text, ('reflector'::character varying)::text]))
);
-- Set comment to column: "observationScopeId" on table: "instance_ai_observation_locks"
COMMENT ON COLUMN "instance_ai_observation_locks"."observationScopeId" IS 'instance_ai_threads.id source stream locked for observation tasks';
-- Set comment to column: "holderId" on table: "instance_ai_observation_locks"
COMMENT ON COLUMN "instance_ai_observation_locks"."holderId" IS 'Ephemeral background-task lock owner token, not a user ID';
-- Create "instance_ai_observational_memory" table
CREATE TABLE "instance_ai_observational_memory" (
  "id" character varying(36) NOT NULL,
  "lookupKey" character varying(255) NOT NULL,
  "scope" character varying(16) NOT NULL,
  "threadId" uuid NULL,
  "resourceId" character varying(255) NOT NULL,
  "activeObservations" text NOT NULL DEFAULT '',
  "originType" character varying(32) NOT NULL,
  "config" text NOT NULL,
  "generationCount" integer NOT NULL DEFAULT 0,
  "lastObservedAt" timestamptz(3) NULL,
  "pendingMessageTokens" integer NOT NULL DEFAULT 0,
  "totalTokensObserved" integer NOT NULL DEFAULT 0,
  "observationTokenCount" integer NOT NULL DEFAULT 0,
  "isObserving" boolean NOT NULL DEFAULT false,
  "isReflecting" boolean NOT NULL DEFAULT false,
  "observedMessageIds" json NULL,
  "observedTimezone" character varying NULL,
  "bufferedObservations" text NULL,
  "bufferedObservationTokens" integer NULL,
  "bufferedMessageIds" json NULL,
  "bufferedReflection" text NULL,
  "bufferedReflectionTokens" integer NULL,
  "bufferedReflectionInputTokens" integer NULL,
  "reflectedObservationLineCount" integer NULL,
  "bufferedObservationChunks" json NULL,
  "isBufferingObservation" boolean NOT NULL DEFAULT false,
  "isBufferingReflection" boolean NOT NULL DEFAULT false,
  "lastBufferedAtTokens" integer NOT NULL DEFAULT 0,
  "lastBufferedAtTime" timestamptz(3) NULL,
  "metadata" json NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_7192dd00cddba039bf1d3e6a098" PRIMARY KEY ("id")
);
-- Create index "IDX_92f13cb6bc694227e069447f7b" to table: "instance_ai_observational_memory"
CREATE INDEX "IDX_92f13cb6bc694227e069447f7b" ON "instance_ai_observational_memory" ("lookupKey");
-- Create index "IDX_a680ac96aae02dc887bbaac512" to table: "instance_ai_observational_memory"
CREATE UNIQUE INDEX "IDX_a680ac96aae02dc887bbaac512" ON "instance_ai_observational_memory" ("scope", "threadId", "resourceId");
-- Create "instance_ai_observations" table
CREATE TABLE "instance_ai_observations" (
  "id" character varying(36) NOT NULL,
  "observationScopeId" uuid NOT NULL,
  "marker" character varying(16) NOT NULL,
  "text" text NOT NULL,
  "parentId" character varying(36) NULL,
  "tokenCount" integer NOT NULL DEFAULT 0,
  "status" character varying(16) NOT NULL,
  "supersededBy" character varying(36) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_4d9b514cdf0f0b577650caf2ac2" PRIMARY KEY ("id"),
  CONSTRAINT "FK_a80e0ee839a2f10ba4b86e19998" FOREIGN KEY ("supersededBy") REFERENCES "instance_ai_observations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_daef2195a4a846eb70eed15e039" FOREIGN KEY ("parentId") REFERENCES "instance_ai_observations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "CHK_instance_ai_observations_marker" CHECK ((marker)::text = ANY (ARRAY[('critical'::character varying)::text, ('important'::character varying)::text, ('info'::character varying)::text, ('completion'::character varying)::text])),
  CONSTRAINT "CHK_instance_ai_observations_status" CHECK ((status)::text = ANY (ARRAY[('active'::character varying)::text, ('superseded'::character varying)::text, ('dropped'::character varying)::text]))
);
-- Create index "IDX_0d5db648188d338df7fb2a8064" to table: "instance_ai_observations"
CREATE INDEX "IDX_0d5db648188d338df7fb2a8064" ON "instance_ai_observations" ("observationScopeId", "status", "createdAt", "id");
-- Create index "IDX_a80e0ee839a2f10ba4b86e1999" to table: "instance_ai_observations"
CREATE INDEX "IDX_a80e0ee839a2f10ba4b86e1999" ON "instance_ai_observations" ("supersededBy");
-- Create index "IDX_daef2195a4a846eb70eed15e03" to table: "instance_ai_observations"
CREATE INDEX "IDX_daef2195a4a846eb70eed15e03" ON "instance_ai_observations" ("parentId");
-- Set comment to column: "id" on table: "instance_ai_observations"
COMMENT ON COLUMN "instance_ai_observations"."id" IS 'Application-generated n8n string ID, not a database UUID';
-- Set comment to column: "observationScopeId" on table: "instance_ai_observations"
COMMENT ON COLUMN "instance_ai_observations"."observationScopeId" IS 'instance_ai_threads.id source stream for this observation log';
-- Create "instance_ai_pending_confirmations" table
CREATE TABLE "instance_ai_pending_confirmations" (
  "requestId" character varying(36) NOT NULL,
  "threadId" uuid NOT NULL,
  "userId" uuid NOT NULL,
  "kind" character varying(16) NOT NULL,
  "runId" character varying(36) NOT NULL,
  "toolCallId" character varying(64) NULL,
  "messageGroupId" character varying(36) NULL,
  "checkpointKey" character varying(255) NULL,
  "checkpointTaskId" character varying(36) NULL,
  "expiresAt" timestamptz(3) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_25c38179c8d45095b168adfff80" PRIMARY KEY ("requestId"),
  CONSTRAINT "CHK_instance_ai_pending_confirmations_kind" CHECK ((kind)::text = ANY (ARRAY[('suspended'::character varying)::text, ('inline'::character varying)::text]))
);
-- Create index "IDX_0babdf6e3b897a86fe4678355e" to table: "instance_ai_pending_confirmations"
CREATE INDEX "IDX_0babdf6e3b897a86fe4678355e" ON "instance_ai_pending_confirmations" ("checkpointKey");
-- Create index "IDX_ba67ee8dc311830a2eea89b6e9" to table: "instance_ai_pending_confirmations"
CREATE INDEX "IDX_ba67ee8dc311830a2eea89b6e9" ON "instance_ai_pending_confirmations" ("threadId");
-- Create index "IDX_d7a4aba7440449865e2b924377" to table: "instance_ai_pending_confirmations"
CREATE INDEX "IDX_d7a4aba7440449865e2b924377" ON "instance_ai_pending_confirmations" ("expiresAt");
-- Create index "IDX_df5fd25c8bbfd2b042602600d8" to table: "instance_ai_pending_confirmations"
CREATE INDEX "IDX_df5fd25c8bbfd2b042602600d8" ON "instance_ai_pending_confirmations" ("userId");
-- Set comment to column: "requestId" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."requestId" IS 'HITL confirmation request identifier.';
-- Set comment to column: "threadId" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."threadId" IS 'Instance AI thread that owns the confirmation.';
-- Set comment to column: "userId" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."userId" IS 'User who is expected to confirm or cancel.';
-- Set comment to column: "kind" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."kind" IS '''suspended'' (resumable from checkpoint) or ''inline'' (orchestrator-held Promise).';
-- Set comment to column: "runId" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."runId" IS 'External run ID; reused on resume for SSE correlation.';
-- Set comment to column: "toolCallId" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."toolCallId" IS 'Suspended tool call awaiting confirmation.';
-- Set comment to column: "messageGroupId" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."messageGroupId" IS 'SSE event correlation group.';
-- Set comment to column: "checkpointKey" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."checkpointKey" IS 'FK to instance_ai_checkpoints.key; also the SDK runId used to resume.';
-- Set comment to column: "checkpointTaskId" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."checkpointTaskId" IS 'Set when the suspended run was a planned-task checkpoint follow-up.';
-- Set comment to column: "expiresAt" on table: "instance_ai_pending_confirmations"
COMMENT ON COLUMN "instance_ai_pending_confirmations"."expiresAt" IS 'TTL for the leader-only sweep; null disables auto-expiry.';
-- Create "instance_ai_resources" table
CREATE TABLE "instance_ai_resources" (
  "id" character varying(255) NOT NULL,
  "workingMemory" text NULL,
  "metadata" json NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_45b5b0b6f715dae4292b86603d8" PRIMARY KEY ("id")
);
-- Create "instance_ai_run_snapshots" table
CREATE TABLE "instance_ai_run_snapshots" (
  "threadId" uuid NOT NULL,
  "runId" character varying(36) NOT NULL,
  "messageGroupId" character varying(36) NULL,
  "runIds" json NULL,
  "tree" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "langsmithRunId" character varying(36) NULL,
  "langsmithTraceId" character varying(36) NULL,
  "traceId" character varying(64) NULL,
  "spanId" character varying(64) NULL,
  CONSTRAINT "PK_0a5fc9690a84950ebf1416fb146" PRIMARY KEY ("threadId", "runId")
);
-- Create index "IDX_d3a2bc880e7a8626802e5474ad" to table: "instance_ai_run_snapshots"
CREATE INDEX "IDX_d3a2bc880e7a8626802e5474ad" ON "instance_ai_run_snapshots" ("threadId", "createdAt");
-- Create index "IDX_d926c16c2ad9728cb9a81790c0" to table: "instance_ai_run_snapshots"
CREATE INDEX "IDX_d926c16c2ad9728cb9a81790c0" ON "instance_ai_run_snapshots" ("threadId", "messageGroupId");
-- Set comment to column: "langsmithRunId" on table: "instance_ai_run_snapshots"
COMMENT ON COLUMN "instance_ai_run_snapshots"."langsmithRunId" IS 'LangSmith run ID (UUID v4, e.g. "f47ac10b-58cc-4372-a567-0e02b2c3d479").';
-- Set comment to column: "langsmithTraceId" on table: "instance_ai_run_snapshots"
COMMENT ON COLUMN "instance_ai_run_snapshots"."langsmithTraceId" IS 'LangSmith trace ID (UUID v4, e.g. "f47ac10b-58cc-4372-a567-0e02b2c3d479").';
-- Set comment to column: "traceId" on table: "instance_ai_run_snapshots"
COMMENT ON COLUMN "instance_ai_run_snapshots"."traceId" IS 'OpenTelemetry trace ID for the root Instance AI run.';
-- Set comment to column: "spanId" on table: "instance_ai_run_snapshots"
COMMENT ON COLUMN "instance_ai_run_snapshots"."spanId" IS 'OpenTelemetry span ID for the root Instance AI run.';
-- Create "instance_ai_threads" table
CREATE TABLE "instance_ai_threads" (
  "id" uuid NOT NULL,
  "resourceId" character varying(255) NOT NULL,
  "title" text NOT NULL DEFAULT '',
  "metadata" json NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "projectId" character varying(36) NOT NULL,
  CONSTRAINT "PK_35575100e45cdedeb89ae0643e9" PRIMARY KEY ("id")
);
-- Create index "IDX_f36dea4d38fe92e0e8f44d5a56" to table: "instance_ai_threads"
CREATE INDEX "IDX_f36dea4d38fe92e0e8f44d5a56" ON "instance_ai_threads" ("resourceId");
-- Create index "IDX_instance_ai_threads_projectId" to table: "instance_ai_threads"
CREATE INDEX "IDX_instance_ai_threads_projectId" ON "instance_ai_threads" ("projectId");
-- Set comment to column: "projectId" on table: "instance_ai_threads"
COMMENT ON COLUMN "instance_ai_threads"."projectId" IS 'Project this thread is scoped to';
-- Create "instance_ai_workflow_snapshots" table
CREATE TABLE "instance_ai_workflow_snapshots" (
  "runId" character varying(36) NOT NULL,
  "workflowName" character varying(255) NOT NULL,
  "resourceId" character varying(255) NULL,
  "status" character varying NULL,
  "snapshot" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_93f2696eb321dfe1d7defe7073f" PRIMARY KEY ("runId", "workflowName")
);
-- Create index "IDX_a371ee6b8e0ebb5635f8baa46d" to table: "instance_ai_workflow_snapshots"
CREATE INDEX "IDX_a371ee6b8e0ebb5635f8baa46d" ON "instance_ai_workflow_snapshots" ("workflowName", "status");
-- Create "instance_version_history" table
CREATE TABLE "instance_version_history" (
  "id" serial NOT NULL,
  "major" integer NOT NULL,
  "minor" integer NOT NULL,
  "patch" integer NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_874f58cb616935bf49d9dbd67e9" PRIMARY KEY ("id")
);
-- Create "invalid_auth_token" table
CREATE TABLE "invalid_auth_token" (
  "token" character varying(512) NOT NULL,
  "expiresAt" timestamptz(3) NOT NULL,
  CONSTRAINT "PK_5779069b7235b256d91f7af1a15" PRIMARY KEY ("token")
);
-- Create "mcp_registry_server" table
CREATE TABLE "mcp_registry_server" (
  "slug" character varying(255) NOT NULL,
  "status" character varying(50) NOT NULL,
  "version" character varying(50) NOT NULL,
  "registryUpdatedAt" timestamp(3) NOT NULL,
  "data" json NOT NULL DEFAULT '{}',
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_12fd89a1fb8489513b0a91f5d31" PRIMARY KEY ("slug"),
  CONSTRAINT "CHK_tmp_mcp_registry_server_status" CHECK ((status)::text = ANY ((ARRAY['active'::character varying, 'deprecated'::character varying])::text[]))
);
-- Set comment to column: "status" on table: "mcp_registry_server"
COMMENT ON COLUMN "mcp_registry_server"."status" IS 'Server status in the MCP registry. Deprecated servers are not surfaced to users.';
-- Set comment to column: "data" on table: "mcp_registry_server"
COMMENT ON COLUMN "mcp_registry_server"."data" IS 'JSON object containing server metadata (icons, remotes, tools, etc.)';
-- Create "migrations" table
CREATE TABLE "migrations" (
  "id" serial NOT NULL,
  "timestamp" bigint NOT NULL,
  "name" character varying NOT NULL,
  CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY ("id")
);
-- Create "oauth_access_tokens" table
CREATE TABLE "oauth_access_tokens" (
  "token" character varying NOT NULL,
  "clientId" character varying NOT NULL,
  "userId" uuid NOT NULL,
  CONSTRAINT "PK_dcd71f96a5d5f4bf79e67d322bf" PRIMARY KEY ("token")
);
-- Create "oauth_authorization_codes" table
CREATE TABLE "oauth_authorization_codes" (
  "code" character varying(255) NOT NULL,
  "clientId" character varying NOT NULL,
  "userId" uuid NOT NULL,
  "redirectUri" character varying NOT NULL,
  "codeChallenge" character varying NOT NULL,
  "codeChallengeMethod" character varying(255) NOT NULL,
  "expiresAt" bigint NOT NULL,
  "state" character varying NULL,
  "used" boolean NOT NULL DEFAULT false,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "resource" character varying NULL,
  "scope" json NOT NULL DEFAULT '["tool:listWorkflows","tool:getWorkflowDetails"]',
  CONSTRAINT "PK_fb91ab932cfbd694061501cc20f" PRIMARY KEY ("code")
);
-- Set comment to column: "expiresAt" on table: "oauth_authorization_codes"
COMMENT ON COLUMN "oauth_authorization_codes"."expiresAt" IS 'Unix timestamp in milliseconds';
-- Set comment to column: "resource" on table: "oauth_authorization_codes"
COMMENT ON COLUMN "oauth_authorization_codes"."resource" IS 'RFC 8707 resource indicator URI (e.g. https://n8n.example.com/mcp-server/http). NULL = legacy flow predating resource indicator support; defaults to the instance canonical MCP resource URL.';
-- Set comment to column: "scope" on table: "oauth_authorization_codes"
COMMENT ON COLUMN "oauth_authorization_codes"."scope" IS 'OAuth scopes granted for this authorization code';
-- Create "oauth_clients" table
CREATE TABLE "oauth_clients" (
  "id" character varying NOT NULL,
  "name" character varying(255) NOT NULL,
  "redirectUris" json NOT NULL,
  "grantTypes" json NOT NULL,
  "clientSecret" character varying(255) NULL,
  "clientSecretExpiresAt" bigint NULL,
  "tokenEndpointAuthMethod" character varying(255) NOT NULL DEFAULT 'none',
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_c4759172d3431bae6f04e678e0d" PRIMARY KEY ("id")
);
-- Set comment to column: "tokenEndpointAuthMethod" on table: "oauth_clients"
COMMENT ON COLUMN "oauth_clients"."tokenEndpointAuthMethod" IS 'Possible values: none, client_secret_basic or client_secret_post';
-- Create "oauth_refresh_tokens" table
CREATE TABLE "oauth_refresh_tokens" (
  "token" character varying(255) NOT NULL,
  "clientId" character varying NOT NULL,
  "userId" uuid NOT NULL,
  "expiresAt" bigint NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "scope" json NOT NULL DEFAULT '["tool:listWorkflows","tool:getWorkflowDetails"]',
  CONSTRAINT "PK_74abaed0b30711b6532598b0392" PRIMARY KEY ("token")
);
-- Set comment to column: "expiresAt" on table: "oauth_refresh_tokens"
COMMENT ON COLUMN "oauth_refresh_tokens"."expiresAt" IS 'Unix timestamp in milliseconds';
-- Set comment to column: "scope" on table: "oauth_refresh_tokens"
COMMENT ON COLUMN "oauth_refresh_tokens"."scope" IS 'OAuth scopes granted for this refresh token';
-- Create "oauth_user_consents" table
CREATE TABLE "oauth_user_consents" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "userId" uuid NOT NULL,
  "clientId" character varying NOT NULL,
  "grantedAt" bigint NOT NULL,
  CONSTRAINT "PK_85b9ada746802c8993103470f05" PRIMARY KEY ("id"),
  CONSTRAINT "UQ_083721d99ce8db4033e2958ebb4" UNIQUE ("userId", "clientId")
);
-- Set comment to column: "grantedAt" on table: "oauth_user_consents"
COMMENT ON COLUMN "oauth_user_consents"."grantedAt" IS 'Unix timestamp in milliseconds';
-- Create "processed_data" table
CREATE TABLE "processed_data" (
  "workflowId" character varying(36) NOT NULL,
  "context" character varying(255) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "value" text NOT NULL,
  CONSTRAINT "PK_ca04b9d8dc72de268fe07a65773" PRIMARY KEY ("workflowId", "context")
);
-- Create "project" table
CREATE TABLE "project" (
  "id" character varying(36) NOT NULL,
  "name" character varying(255) NOT NULL,
  "type" character varying(36) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "icon" json NULL,
  "description" character varying(512) NULL,
  "creatorId" uuid NULL,
  "customTelemetryTags" json NOT NULL DEFAULT '[]',
  CONSTRAINT "PK_4d68b1358bb5b766d3e78f32f57" PRIMARY KEY ("id")
);
-- Set comment to column: "creatorId" on table: "project"
COMMENT ON COLUMN "project"."creatorId" IS 'ID of the user who created the project';
-- Create "project_relation" table
CREATE TABLE "project_relation" (
  "projectId" character varying(36) NOT NULL,
  "userId" uuid NOT NULL,
  "role" character varying NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_1caaa312a5d7184a003be0f0cb6" PRIMARY KEY ("projectId", "userId")
);
-- Create index "IDX_5f0643f6717905a05164090dde" to table: "project_relation"
CREATE INDEX "IDX_5f0643f6717905a05164090dde" ON "project_relation" ("userId");
-- Create index "IDX_61448d56d61802b5dfde5cdb00" to table: "project_relation"
CREATE INDEX "IDX_61448d56d61802b5dfde5cdb00" ON "project_relation" ("projectId");
-- Create index "project_relation_role_idx" to table: "project_relation"
CREATE INDEX "project_relation_role_idx" ON "project_relation" ("role");
-- Create index "project_relation_role_project_idx" to table: "project_relation"
CREATE INDEX "project_relation_role_project_idx" ON "project_relation" ("projectId", "role");
-- Create "project_secrets_provider_access" table
CREATE TABLE "project_secrets_provider_access" (
  "secretsProviderConnectionId" integer NOT NULL,
  "projectId" character varying(36) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "role" character varying(128) NOT NULL DEFAULT 'secretsProviderConnection:user',
  CONSTRAINT "PK_0402b7fcec5415246656f102f83" PRIMARY KEY ("secretsProviderConnectionId", "projectId"),
  CONSTRAINT "CHK_project_secrets_provider_access_role" CHECK ((role)::text = ANY (ARRAY[('secretsProviderConnection:owner'::character varying)::text, ('secretsProviderConnection:user'::character varying)::text]))
);
-- Create "role" table
CREATE TABLE "role" (
  "slug" character varying(128) NOT NULL,
  "displayName" text NULL,
  "description" text NULL,
  "roleType" text NULL,
  "systemRole" boolean NOT NULL DEFAULT false,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_35c9b140caaf6da09cfabb0d675" PRIMARY KEY ("slug")
);
-- Create index "IDX_UniqueRoleDisplayName" to table: "role"
CREATE UNIQUE INDEX "IDX_UniqueRoleDisplayName" ON "role" ("displayName");
-- Set comment to column: "slug" on table: "role"
COMMENT ON COLUMN "role"."slug" IS 'Unique identifier of the role for example: "global:owner"';
-- Set comment to column: "displayName" on table: "role"
COMMENT ON COLUMN "role"."displayName" IS 'Name used to display in the UI';
-- Set comment to column: "description" on table: "role"
COMMENT ON COLUMN "role"."description" IS 'Text describing the scope in more detail of users';
-- Set comment to column: "roleType" on table: "role"
COMMENT ON COLUMN "role"."roleType" IS 'Type of the role, e.g., global, project, or workflow';
-- Set comment to column: "systemRole" on table: "role"
COMMENT ON COLUMN "role"."systemRole" IS 'Indicates if the role is managed by the system and cannot be edited';
-- Create "role_mapping_rule" table
CREATE TABLE "role_mapping_rule" (
  "id" character varying(16) NOT NULL,
  "expression" text NOT NULL,
  "role" character varying(128) NOT NULL,
  "type" character varying(64) NOT NULL,
  "order" integer NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_d772c8ec1a89b52d31c882bc560" PRIMARY KEY ("id"),
  CONSTRAINT "UQ_b33ac896ad3099fc8de36fdc1c4" UNIQUE ("type", "order")
);
-- Create index "IDX_bb66e404c35996b0d694617750" to table: "role_mapping_rule"
CREATE INDEX "IDX_bb66e404c35996b0d694617750" ON "role_mapping_rule" ("role");
-- Set comment to column: "type" on table: "role_mapping_rule"
COMMENT ON COLUMN "role_mapping_rule"."type" IS 'Expected values: ''instance'' (maps to a global role) or ''project'' (maps to a project role; projects linked via role_mapping_rule_project).';
-- Create "role_mapping_rule_project" table
CREATE TABLE "role_mapping_rule_project" (
  "roleMappingRuleId" character varying(16) NOT NULL,
  "projectId" character varying(36) NOT NULL,
  CONSTRAINT "PK_198c5b5aea509d139274efcaf9a" PRIMARY KEY ("roleMappingRuleId", "projectId")
);
-- Create index "IDX_35a78869286c65d9330d02b88f" to table: "role_mapping_rule_project"
CREATE INDEX "IDX_35a78869286c65d9330d02b88f" ON "role_mapping_rule_project" ("projectId");
-- Create "role_scope" table
CREATE TABLE "role_scope" (
  "roleSlug" character varying(128) NOT NULL,
  "scopeSlug" character varying(128) NOT NULL,
  CONSTRAINT "PK_role_scope" PRIMARY KEY ("roleSlug", "scopeSlug")
);
-- Create index "IDX_role_scope_scopeSlug" to table: "role_scope"
CREATE INDEX "IDX_role_scope_scopeSlug" ON "role_scope" ("scopeSlug");
-- Create "scope" table
CREATE TABLE "scope" (
  "slug" character varying(128) NOT NULL,
  "displayName" text NULL,
  "description" text NULL,
  CONSTRAINT "PK_bfc45df0481abd7f355d6187da1" PRIMARY KEY ("slug")
);
-- Set comment to column: "slug" on table: "scope"
COMMENT ON COLUMN "scope"."slug" IS 'Unique identifier of the scope for example: "project:create"';
-- Set comment to column: "displayName" on table: "scope"
COMMENT ON COLUMN "scope"."displayName" IS 'Name used to display in the UI';
-- Set comment to column: "description" on table: "scope"
COMMENT ON COLUMN "scope"."description" IS 'Text describing the scope in more detail of users';
-- Create "secrets_provider_connection" table
CREATE TABLE "secrets_provider_connection" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "providerKey" character varying(128) NOT NULL,
  "type" character varying(36) NOT NULL,
  "encryptedSettings" text NOT NULL,
  "isEnabled" boolean NOT NULL DEFAULT false,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_4350ae85e76f9ba7df1370acb5d" PRIMARY KEY ("id")
);
-- Create index "IDX_secrets_provider_connection_providerKey" to table: "secrets_provider_connection"
CREATE UNIQUE INDEX "IDX_secrets_provider_connection_providerKey" ON "secrets_provider_connection" ("providerKey");
-- Set comment to column: "type" on table: "secrets_provider_connection"
COMMENT ON COLUMN "secrets_provider_connection"."type" IS 'Type of secrets provider. Possible values: awsSecretsManager, gcpSecretsManager, vault, azureKeyVault, infisical';
-- Create "settings" table
CREATE TABLE "settings" (
  "key" character varying(255) NOT NULL,
  "value" text NOT NULL,
  "loadOnStartup" boolean NOT NULL DEFAULT false,
  CONSTRAINT "PK_dc0fe14e6d9943f268e7b119f69ab8bd" PRIMARY KEY ("key")
);
-- Create "shared_credentials" table
CREATE TABLE "shared_credentials" (
  "credentialsId" character varying(36) NOT NULL,
  "projectId" character varying(36) NOT NULL,
  "role" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_8ef3a59796a228913f251779cff" PRIMARY KEY ("credentialsId", "projectId")
);
-- Create "shared_workflow" table
CREATE TABLE "shared_workflow" (
  "workflowId" character varying(36) NOT NULL,
  "projectId" character varying(36) NOT NULL,
  "role" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_5ba87620386b847201c9531c58f" PRIMARY KEY ("workflowId", "projectId")
);
-- Create index "IDX_shared_workflow_projectId" to table: "shared_workflow"
CREATE INDEX "IDX_shared_workflow_projectId" ON "shared_workflow" ("projectId");
-- Create "tag_entity" table
CREATE TABLE "tag_entity" (
  "name" character varying(24) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "id" character varying(36) NOT NULL,
  PRIMARY KEY ("id")
);
-- Create index "idx_812eb05f7451ca757fb98444ce" to table: "tag_entity"
CREATE UNIQUE INDEX "idx_812eb05f7451ca757fb98444ce" ON "tag_entity" ("name");
-- Create index "pk_tag_entity_id" to table: "tag_entity"
CREATE UNIQUE INDEX "pk_tag_entity_id" ON "tag_entity" ("id");
-- Create "test_case_execution" table
CREATE TABLE "test_case_execution" (
  "id" character varying(36) NOT NULL,
  "testRunId" character varying(36) NOT NULL,
  "executionId" integer NULL,
  "status" character varying NOT NULL,
  "runAt" timestamptz(3) NULL,
  "completedAt" timestamptz(3) NULL,
  "errorCode" character varying NULL,
  "errorDetails" json NULL,
  "metrics" json NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "inputs" json NULL,
  "outputs" json NULL,
  "runIndex" integer NULL,
  CONSTRAINT "PK_90c121f77a78a6580e94b794bce" PRIMARY KEY ("id")
);
-- Create index "IDX_8e4b4774db42f1e6dda3452b2a" to table: "test_case_execution"
CREATE INDEX "IDX_8e4b4774db42f1e6dda3452b2a" ON "test_case_execution" ("testRunId");
-- Create "test_run" table
CREATE TABLE "test_run" (
  "id" character varying(36) NOT NULL,
  "workflowId" character varying(36) NOT NULL,
  "status" character varying NOT NULL,
  "errorCode" character varying NULL,
  "errorDetails" json NULL,
  "runAt" timestamptz(3) NULL,
  "completedAt" timestamptz(3) NULL,
  "metrics" json NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "runningInstanceId" character varying(255) NULL,
  "cancelRequested" boolean NOT NULL DEFAULT false,
  "workflowVersionId" character varying(36) NULL,
  "evaluationConfigId" character varying(36) NULL,
  "evaluationConfigSnapshot" jsonb NULL,
  "collectionId" character varying(36) NULL,
  CONSTRAINT "PK_011c050f566e9db509a0fadb9b9" PRIMARY KEY ("id")
);
-- Create index "IDX_d6870d3b6e4c185d33926f423c" to table: "test_run"
CREATE INDEX "IDX_d6870d3b6e4c185d33926f423c" ON "test_run" ("workflowId");
-- Create index "IDX_test_run_collectionId" to table: "test_run"
CREATE INDEX "IDX_test_run_collectionId" ON "test_run" ("collectionId");
-- Create index "IDX_test_run_evaluationConfigId" to table: "test_run"
CREATE INDEX "IDX_test_run_evaluationConfigId" ON "test_run" ("evaluationConfigId");
-- Create "token_exchange_jti" table
CREATE TABLE "token_exchange_jti" (
  "jti" character varying(255) NOT NULL,
  "expiresAt" timestamptz(3) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL,
  CONSTRAINT "PK_d8e8a6f737d530fdd2dd716e89c" PRIMARY KEY ("jti")
);
-- Create "trusted_key" table
CREATE TABLE "trusted_key" (
  "sourceId" character varying(36) NOT NULL,
  "kid" character varying(255) NOT NULL,
  "data" text NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_dc7d93798f3dbb6959f974c97e1" PRIMARY KEY ("sourceId", "kid")
);
-- Create "trusted_key_source" table
CREATE TABLE "trusted_key_source" (
  "id" character varying(36) NOT NULL,
  "type" character varying(32) NOT NULL,
  "config" text NOT NULL,
  "status" character varying(32) NOT NULL DEFAULT 'pending',
  "lastError" text NULL,
  "lastRefreshedAt" timestamptz(3) NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_99e8908ce2c2cdccce487db7fc6" PRIMARY KEY ("id")
);
-- Create "user" table
CREATE TABLE "user" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "email" character varying(255) NULL,
  "firstName" character varying(32) NULL,
  "lastName" character varying(32) NULL,
  "password" character varying(255) NULL,
  "personalizationAnswers" json NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "settings" json NULL,
  "disabled" boolean NOT NULL DEFAULT false,
  "mfaEnabled" boolean NOT NULL DEFAULT false,
  "mfaSecret" text NULL,
  "mfaRecoveryCodes" text NULL,
  "lastActiveAt" date NULL,
  "roleSlug" character varying(128) NOT NULL DEFAULT 'global:member',
  CONSTRAINT "PK_ea8f538c94b6e352418254ed6474a81f" PRIMARY KEY ("id"),
  CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e2" UNIQUE ("email")
);
-- Create index "user_role_idx" to table: "user"
CREATE INDEX "user_role_idx" ON "user" ("roleSlug");
-- Create "user_api_keys" table
CREATE TABLE "user_api_keys" (
  "id" character varying(36) NOT NULL,
  "userId" uuid NOT NULL,
  "label" character varying(100) NOT NULL,
  "apiKey" character varying NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "scopes" json NULL,
  "audience" character varying NOT NULL DEFAULT 'public-api',
  "lastUsedAt" timestamptz(3) NULL,
  CONSTRAINT "PK_978fa5caa3468f463dac9d92e69" PRIMARY KEY ("id")
);
-- Create index "IDX_1ef35bac35d20bdae979d917a3" to table: "user_api_keys"
CREATE UNIQUE INDEX "IDX_1ef35bac35d20bdae979d917a3" ON "user_api_keys" ("apiKey");
-- Create index "IDX_63d7bbae72c767cf162d459fcc" to table: "user_api_keys"
CREATE UNIQUE INDEX "IDX_63d7bbae72c767cf162d459fcc" ON "user_api_keys" ("userId", "label");
-- Create "user_favorites" table
CREATE TABLE "user_favorites" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "userId" uuid NOT NULL,
  "resourceId" character varying(255) NOT NULL,
  "resourceType" character varying(64) NOT NULL,
  CONSTRAINT "PK_6c472a19a7423cfbbf6b7c75939" PRIMARY KEY ("id"),
  CONSTRAINT "UQ_cf6ae658ead9ffc124723413c65" UNIQUE ("userId", "resourceId", "resourceType")
);
-- Create index "IDX_1d11050a381548c42c32cc25c4" to table: "user_favorites"
CREATE INDEX "IDX_1d11050a381548c42c32cc25c4" ON "user_favorites" ("resourceType", "resourceId");
-- Create index "IDX_1dd5c393ad0517be3c31a7af83" to table: "user_favorites"
CREATE INDEX "IDX_1dd5c393ad0517be3c31a7af83" ON "user_favorites" ("userId");
-- Create "variables" table
CREATE TABLE "variables" (
  "key" character varying(50) NOT NULL,
  "type" character varying(50) NOT NULL DEFAULT 'string',
  "value" text NULL,
  "id" character varying(36) NOT NULL,
  "projectId" character varying(36) NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "variables_value_max_len" CHECK ((value IS NULL) OR (char_length(value) <= 1000))
);
-- Create index "variables_global_key_unique" to table: "variables"
CREATE UNIQUE INDEX "variables_global_key_unique" ON "variables" ("key") WHERE ("projectId" IS NULL);
-- Create index "variables_project_key_unique" to table: "variables"
CREATE UNIQUE INDEX "variables_project_key_unique" ON "variables" ("projectId", "key") WHERE ("projectId" IS NOT NULL);
-- Create "webhook_entity" table
CREATE TABLE "webhook_entity" (
  "webhookPath" character varying NOT NULL,
  "method" character varying NOT NULL,
  "node" character varying NOT NULL,
  "webhookId" character varying NULL,
  "pathLength" integer NULL,
  "workflowId" character varying(36) NOT NULL,
  CONSTRAINT "PK_b21ace2e13596ccd87dc9bf4ea6" PRIMARY KEY ("webhookPath", "method")
);
-- Create index "idx_16f4436789e804e3e1c9eeb240" to table: "webhook_entity"
CREATE INDEX "idx_16f4436789e804e3e1c9eeb240" ON "webhook_entity" ("webhookId", "method", "pathLength");
-- Create "workflow_builder_session" table
CREATE TABLE "workflow_builder_session" (
  "id" uuid NOT NULL,
  "workflowId" character varying(36) NOT NULL,
  "userId" uuid NOT NULL,
  "messages" json NOT NULL DEFAULT '[]',
  "previousSummary" text NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "activeVersionCardId" character varying(255) NULL,
  "resumeAfterRestoreMessageId" character varying(255) NULL,
  CONSTRAINT "PK_e69ef0d385986e273423b0e8695" PRIMARY KEY ("id"),
  CONSTRAINT "UQ_ec2aa73632932d485a1d5192ce1" UNIQUE ("workflowId", "userId")
);
-- Set comment to column: "previousSummary" on table: "workflow_builder_session"
COMMENT ON COLUMN "workflow_builder_session"."previousSummary" IS 'Summary of prior conversation from compaction (/compact or auto-compact)';
-- Create "workflow_dependency" table
CREATE TABLE "workflow_dependency" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "workflowId" character varying(36) NOT NULL,
  "workflowVersionId" integer NOT NULL,
  "dependencyType" character varying(32) NOT NULL,
  "dependencyKey" character varying(255) NOT NULL,
  "dependencyInfo" json NULL,
  "indexVersionId" smallint NOT NULL DEFAULT 1,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "publishedVersionId" character varying(36) NULL,
  CONSTRAINT "PK_52325e34cd7a2f0f67b0f3cad65" PRIMARY KEY ("id")
);
-- Create index "IDX_a4ff2d9b9628ea988fa9e7d0bf" to table: "workflow_dependency"
CREATE INDEX "IDX_a4ff2d9b9628ea988fa9e7d0bf" ON "workflow_dependency" ("workflowId");
-- Create index "IDX_e48a201071ab85d9d09119d640" to table: "workflow_dependency"
CREATE INDEX "IDX_e48a201071ab85d9d09119d640" ON "workflow_dependency" ("dependencyKey");
-- Create index "IDX_e7fe1cfda990c14a445937d0b9" to table: "workflow_dependency"
CREATE INDEX "IDX_e7fe1cfda990c14a445937d0b9" ON "workflow_dependency" ("dependencyType");
-- Create index "IDX_workflow_dependency_publishedVersionId" to table: "workflow_dependency"
CREATE INDEX "IDX_workflow_dependency_publishedVersionId" ON "workflow_dependency" ("publishedVersionId");
-- Set comment to column: "workflowVersionId" on table: "workflow_dependency"
COMMENT ON COLUMN "workflow_dependency"."workflowVersionId" IS 'Version of the workflow';
-- Set comment to column: "dependencyType" on table: "workflow_dependency"
COMMENT ON COLUMN "workflow_dependency"."dependencyType" IS 'Type of dependency: "credential", "nodeType", "webhookPath", or "workflowCall"';
-- Set comment to column: "dependencyKey" on table: "workflow_dependency"
COMMENT ON COLUMN "workflow_dependency"."dependencyKey" IS 'ID or name of the dependency';
-- Set comment to column: "dependencyInfo" on table: "workflow_dependency"
COMMENT ON COLUMN "workflow_dependency"."dependencyInfo" IS 'Additional info about the dependency, interpreted based on type';
-- Set comment to column: "indexVersionId" on table: "workflow_dependency"
COMMENT ON COLUMN "workflow_dependency"."indexVersionId" IS 'Version of the index structure';
-- Create "workflow_entity" table
CREATE TABLE "workflow_entity" (
  "name" character varying(128) NOT NULL,
  "active" boolean NOT NULL,
  "nodes" json NOT NULL,
  "connections" json NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "settings" json NULL,
  "staticData" json NULL,
  "pinData" json NULL,
  "versionId" character(36) NOT NULL,
  "triggerCount" integer NOT NULL DEFAULT 0,
  "id" character varying(36) NOT NULL,
  "meta" json NULL,
  "parentFolderId" character varying(36) NULL DEFAULT NULL::character varying,
  "isArchived" boolean NOT NULL DEFAULT false,
  "versionCounter" integer NOT NULL DEFAULT 1,
  "description" text NULL,
  "activeVersionId" character varying(36) NULL,
  "nodeGroups" json NOT NULL DEFAULT '[]',
  "sourceWorkflowId" character varying NULL,
  PRIMARY KEY ("id")
);
-- Create index "IDX_workflow_entity_name" to table: "workflow_entity"
CREATE INDEX "IDX_workflow_entity_name" ON "workflow_entity" ("name");
-- Create index "IDX_workflow_entity_sourceWorkflowId" to table: "workflow_entity"
CREATE INDEX "IDX_workflow_entity_sourceWorkflowId" ON "workflow_entity" ("sourceWorkflowId") WHERE ("sourceWorkflowId" IS NOT NULL);
-- Create index "pk_workflow_entity_id" to table: "workflow_entity"
CREATE UNIQUE INDEX "pk_workflow_entity_id" ON "workflow_entity" ("id");
-- Create "workflow_history" table
CREATE TABLE "workflow_history" (
  "versionId" character varying(36) NOT NULL,
  "workflowId" character varying(36) NOT NULL,
  "authors" character varying(255) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "nodes" json NOT NULL,
  "connections" json NOT NULL,
  "name" character varying(128) NULL,
  "autosaved" boolean NOT NULL DEFAULT false,
  "description" text NULL,
  "nodeGroups" json NOT NULL DEFAULT '[]',
  CONSTRAINT "PK_b6572dd6173e4cd06fe79937b58" PRIMARY KEY ("versionId")
);
-- Create index "IDX_1e31657f5fe46816c34be7c1b4" to table: "workflow_history"
CREATE INDEX "IDX_1e31657f5fe46816c34be7c1b4" ON "workflow_history" ("workflowId");
-- Create "workflow_publication_outbox" table
CREATE TABLE "workflow_publication_outbox" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "workflowId" character varying(36) NOT NULL,
  "publishedVersionId" character varying(36) NOT NULL,
  "status" character varying(20) NOT NULL,
  "errorMessage" text NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_b3e2eeee36a4bd044d56468d311" PRIMARY KEY ("id"),
  CONSTRAINT "CHK_workflow_publication_outbox_status" CHECK ((status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'partial_success'::character varying, 'failed'::character varying])::text[]))
);
-- Create index "IDX_workflow_publication_outbox_active_workflow_status" to table: "workflow_publication_outbox"
CREATE UNIQUE INDEX "IDX_workflow_publication_outbox_active_workflow_status" ON "workflow_publication_outbox" ("workflowId", "status") WHERE ((status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying])::text[]));
-- Set comment to column: "workflowId" on table: "workflow_publication_outbox"
COMMENT ON COLUMN "workflow_publication_outbox"."workflowId" IS 'References workflow_entity.id.';
-- Set comment to column: "publishedVersionId" on table: "workflow_publication_outbox"
COMMENT ON COLUMN "workflow_publication_outbox"."publishedVersionId" IS 'References workflow_history.versionId.';
-- Set comment to column: "errorMessage" on table: "workflow_publication_outbox"
COMMENT ON COLUMN "workflow_publication_outbox"."errorMessage" IS 'Error details for surfacing failed publications to the user.';
-- Create "workflow_publish_history" table
CREATE TABLE "workflow_publish_history" (
  "id" integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  "workflowId" character varying(36) NOT NULL,
  "versionId" character varying(36) NULL,
  "event" character varying(36) NOT NULL,
  "userId" uuid NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_c788f7caf88e91e365c97d6d04a" PRIMARY KEY ("id"),
  CONSTRAINT "CHK_workflow_publish_history_event" CHECK ((event)::text = ANY (ARRAY[('activated'::character varying)::text, ('deactivated'::character varying)::text]))
);
-- Create index "IDX_070b5de842ece9ccdda0d9738b" to table: "workflow_publish_history"
CREATE INDEX "IDX_070b5de842ece9ccdda0d9738b" ON "workflow_publish_history" ("workflowId", "versionId");
-- Set comment to column: "event" on table: "workflow_publish_history"
COMMENT ON COLUMN "workflow_publish_history"."event" IS 'Type of history record: activated (workflow is now active), deactivated (workflow is now inactive)';
-- Create "workflow_published_version" table
CREATE TABLE "workflow_published_version" (
  "workflowId" character varying(36) NOT NULL,
  "publishedVersionId" character varying(36) NOT NULL,
  "createdAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  "updatedAt" timestamptz(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT "PK_5c76fb7ee939fe2530374d3f75a" PRIMARY KEY ("workflowId")
);
-- Create "workflow_statistics" table
CREATE TABLE "workflow_statistics" (
  "count" bigint NULL DEFAULT 0,
  "latestEvent" timestamptz(3) NULL,
  "name" character varying(128) NOT NULL,
  "workflowId" character varying(36) NOT NULL,
  "rootCount" bigint NULL DEFAULT 0,
  "id" serial NOT NULL,
  "workflowName" character varying(128) NULL,
  PRIMARY KEY ("id")
);
-- Create index "IDX_workflow_statistics_workflow_name" to table: "workflow_statistics"
CREATE UNIQUE INDEX "IDX_workflow_statistics_workflow_name" ON "workflow_statistics" ("workflowId", "name");
-- Create "workflows_tags" table
CREATE TABLE "workflows_tags" (
  "workflowId" character varying(36) NOT NULL,
  "tagId" character varying(36) NOT NULL,
  CONSTRAINT "pk_workflows_tags" PRIMARY KEY ("workflowId", "tagId")
);
-- Create index "idx_workflows_tags_workflow_id" to table: "workflows_tags"
CREATE INDEX "idx_workflows_tags_workflow_id" ON "workflows_tags" ("workflowId");
-- Modify "agent_chat_subscriptions" table
ALTER TABLE "agent_chat_subscriptions" ADD CONSTRAINT "FK_e79153bd179c011e779d5016796" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agent_checkpoints" table
ALTER TABLE "agent_checkpoints" ADD CONSTRAINT "FK_5e31c210f896d539964bf99fe32" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agent_execution" table
ALTER TABLE "agent_execution" ADD CONSTRAINT "FK_add2432fb6034cc18b6af299dce" FOREIGN KEY ("threadId") REFERENCES "agent_execution_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agent_execution_threads" table
ALTER TABLE "agent_execution_threads" ADD CONSTRAINT "FK_0468a9dc35597314e641d4722aa" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_0e2f8bf92a7a9c88b89670f701c" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_f00b52d74fe11838e1fe086deea" FOREIGN KEY ("taskVersionId") REFERENCES "agent_history" ("versionId") ON UPDATE NO ACTION ON DELETE SET NULL;
-- Modify "agent_files" table
ALTER TABLE "agent_files" ADD CONSTRAINT "FK_aca4514cb500494b64356c2e164" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agent_history" table
ALTER TABLE "agent_history" ADD CONSTRAINT "FK_8771675f44c58fb40e0feb9ee35" FOREIGN KEY ("publishedById") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_87cd5a8da20304b089ea2f83fec" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agent_task_definition" table
ALTER TABLE "agent_task_definition" ADD CONSTRAINT "FK_f45d0535a2ed59b6c2dd6da98a0" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agent_task_run_lock" table
ALTER TABLE "agent_task_run_lock" ADD CONSTRAINT "FK_b57a2862ae869aab24e54cefd48" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agent_task_snapshot" table
ALTER TABLE "agent_task_snapshot" ADD CONSTRAINT "FK_1acedce6690392ef1611cca8b88" FOREIGN KEY ("versionId") REFERENCES "agent_history" ("versionId") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agents" table
ALTER TABLE "agents" ADD CONSTRAINT "FK_940597dfe9753375309ce6aeea0" FOREIGN KEY ("activeVersionId") REFERENCES "agent_history" ("versionId") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_a30d560207c4071d98aa03c179c" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agents_memory_entries" table
ALTER TABLE "agents_memory_entries" ADD CONSTRAINT "FK_1443a75e59adbfb796071d66393" FOREIGN KEY ("resourceId") REFERENCES "agents_resources" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_28e981fb675e9b44ce02f0ec1dd" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agents_memory_entry_cursors" table
ALTER TABLE "agents_memory_entry_cursors" ADD CONSTRAINT "FK_069e791e428391a5569e7a96b20" FOREIGN KEY ("observationScopeId") REFERENCES "agents_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_746780fd115e5e4352457a3c617" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agents_memory_entry_locks" table
ALTER TABLE "agents_memory_entry_locks" ADD CONSTRAINT "FK_0ccf6d9ea6f44fa1c264fc2f795" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_9594c0983cfee1c8ff49b05848b" FOREIGN KEY ("resourceId") REFERENCES "agents_resources" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agents_memory_entry_sources" table
ALTER TABLE "agents_memory_entry_sources" ADD CONSTRAINT "FK_451d387a182fa8dd8002dfc3a77" FOREIGN KEY ("threadId") REFERENCES "agents_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_4706f6223313959b7437a2b48df" FOREIGN KEY ("memoryEntryId") REFERENCES "agents_memory_entries" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_c38e8a57a36b880e39a52ada2e8" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_cb7c15d22fd068a0806aa57fc03" FOREIGN KEY ("observationId") REFERENCES "agents_observations" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agents_messages" table
ALTER TABLE "agents_messages" ADD CONSTRAINT "FK_0a8057a61afabd2999608ffd0d9" FOREIGN KEY ("threadId") REFERENCES "agents_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agents_observation_cursors" table
ALTER TABLE "agents_observation_cursors" ADD CONSTRAINT "FK_64e92819f4b413661ed6e2c3c3d" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_87aa187d27ea67eafd164905154" FOREIGN KEY ("observationScopeId") REFERENCES "agents_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agents_observation_locks" table
ALTER TABLE "agents_observation_locks" ADD CONSTRAINT "FK_093e44ae20f2518e97d83a95433" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_6b55089892e447c2f82e5ec60ed" FOREIGN KEY ("observationScopeId") REFERENCES "agents_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "agents_observations" table
ALTER TABLE "agents_observations" ADD CONSTRAINT "FK_4cfd8a70ebb0a5b0cf047dca3cf" FOREIGN KEY ("observationScopeId") REFERENCES "agents_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_d206432be97b7ed88d187479b1b" FOREIGN KEY ("agentId") REFERENCES "agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "ai_builder_temporary_workflow" table
ALTER TABLE "ai_builder_temporary_workflow" ADD CONSTRAINT "FK_39b07732e819fb561d74c38763f" FOREIGN KEY ("threadId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_85a87a1ba0f61999fe11dc56325" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "auth_identity" table
ALTER TABLE "auth_identity" ADD CONSTRAINT "auth_identity_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- Modify "chat_hub_agent_tools" table
ALTER TABLE "chat_hub_agent_tools" ADD CONSTRAINT "FK_2b53d796b3dbae91b1a9553c048" FOREIGN KEY ("agentId") REFERENCES "chat_hub_agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_43e70f04c53344f82483d0570f6" FOREIGN KEY ("toolId") REFERENCES "chat_hub_tools" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "chat_hub_agents" table
ALTER TABLE "chat_hub_agents" ADD CONSTRAINT "FK_441ba2caba11e077ce3fbfa2cd8" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_9c61ad497dcbae499c96a6a78ba" FOREIGN KEY ("credentialId") REFERENCES "credentials_entity" ("id") ON UPDATE NO ACTION ON DELETE SET NULL;
-- Modify "chat_hub_messages" table
ALTER TABLE "chat_hub_messages" ADD CONSTRAINT "FK_6afb260449dd7a9b85355d4e0c9" FOREIGN KEY ("executionId") REFERENCES "execution_entity" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_acf8926098f063cdbbad8497fd1" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_chat_hub_messages_agentId" FOREIGN KEY ("agentId") REFERENCES "chat_hub_agents" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_e22538eb50a71a17954cd7e076c" FOREIGN KEY ("sessionId") REFERENCES "chat_hub_sessions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "chat_hub_session_tools" table
ALTER TABLE "chat_hub_session_tools" ADD CONSTRAINT "FK_6596a328affd8d4967ffb303eee" FOREIGN KEY ("toolId") REFERENCES "chat_hub_tools" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_e649bf1295f4ed8d4299ed290f9" FOREIGN KEY ("sessionId") REFERENCES "chat_hub_sessions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "chat_hub_sessions" table
ALTER TABLE "chat_hub_sessions" ADD CONSTRAINT "FK_7bc13b4c7e6afbfaf9be326c189" FOREIGN KEY ("credentialId") REFERENCES "credentials_entity" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_9f9293d9f552496c40e0d1a8f80" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_chat_hub_sessions_agentId" FOREIGN KEY ("agentId") REFERENCES "chat_hub_agents" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_e9ecf8ede7d989fcd18790fe36a" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "chat_hub_tools" table
ALTER TABLE "chat_hub_tools" ADD CONSTRAINT "FK_b8030b47af9213f1fd15450fb7f" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "credential_dependency" table
ALTER TABLE "credential_dependency" ADD CONSTRAINT "FK_5ec8e8c8d3539f3696cf73b43bf" FOREIGN KEY ("credentialId") REFERENCES "credentials_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "credentials_entity" table
ALTER TABLE "credentials_entity" ADD CONSTRAINT "credentials_entity_resolverId_foreign" FOREIGN KEY ("resolverId") REFERENCES "dynamic_credential_resolver" ("id") ON UPDATE NO ACTION ON DELETE SET NULL;
-- Modify "data_table" table
ALTER TABLE "data_table" ADD CONSTRAINT "FK_c2a794257dee48af7c9abf681de" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "data_table_column" table
ALTER TABLE "data_table_column" ADD CONSTRAINT "FK_930b6e8faaf88294cef23484160" FOREIGN KEY ("dataTableId") REFERENCES "data_table" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "dynamic_credential_entry" table
ALTER TABLE "dynamic_credential_entry" ADD CONSTRAINT "FK_a6d1dd080958304a47a02952aab" FOREIGN KEY ("credential_id") REFERENCES "credentials_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_d61a12235d268a49af6a3c09c13" FOREIGN KEY ("resolver_id") REFERENCES "dynamic_credential_resolver" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "dynamic_credential_user_entry" table
ALTER TABLE "dynamic_credential_user_entry" ADD CONSTRAINT "FK_6edec973a6450990977bb854c38" FOREIGN KEY ("resolverId") REFERENCES "dynamic_credential_resolver" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_945ba70b342a066d1306b12ccd2" FOREIGN KEY ("credentialId") REFERENCES "credentials_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_a36dc616fabc3f736bb82410a22" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "evaluation_collection" table
ALTER TABLE "evaluation_collection" ADD CONSTRAINT "FK_a48ce930c3bc7604894b8f0eaad" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_d634a0c93fd7de68a87eab951b2" FOREIGN KEY ("evaluationConfigId") REFERENCES "evaluation_config" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_f4561f38b5a22a4f090d5cd3eae" FOREIGN KEY ("createdById") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE SET NULL;
-- Modify "evaluation_config" table
ALTER TABLE "evaluation_config" ADD CONSTRAINT "FK_fd7542bb123074760285dc1bbf3" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "execution_annotation_tags" table
ALTER TABLE "execution_annotation_tags" ADD CONSTRAINT "FK_a3697779b366e131b2bbdae2976" FOREIGN KEY ("tagId") REFERENCES "annotation_tag_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_c1519757391996eb06064f0e7c8" FOREIGN KEY ("annotationId") REFERENCES "execution_annotations" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "execution_annotations" table
ALTER TABLE "execution_annotations" ADD CONSTRAINT "FK_97f863fa83c4786f19565084960" FOREIGN KEY ("executionId") REFERENCES "execution_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "execution_data" table
ALTER TABLE "execution_data" ADD CONSTRAINT "execution_data_fk" FOREIGN KEY ("executionId") REFERENCES "execution_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "execution_entity" table
ALTER TABLE "execution_entity" ADD CONSTRAINT "fk_execution_entity_workflow_id" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "execution_metadata" table
ALTER TABLE "execution_metadata" ADD CONSTRAINT "FK_31d0b4c93fb85ced26f6005cda3" FOREIGN KEY ("executionId") REFERENCES "execution_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "folder" table
ALTER TABLE "folder" ADD CONSTRAINT "FK_a8260b0b36939c6247f385b8221" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "folder_tag" table
ALTER TABLE "folder_tag" ADD CONSTRAINT "FK_94a60854e06f2897b2e0d39edba" FOREIGN KEY ("folderId") REFERENCES "folder" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_dc88164176283de80af47621746" FOREIGN KEY ("tagId") REFERENCES "tag_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "insights_by_period" table
ALTER TABLE "insights_by_period" ADD CONSTRAINT "FK_6414cfed98daabbfdd61a1cfbc0" FOREIGN KEY ("metaId") REFERENCES "insights_metadata" ("metaId") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "insights_metadata" table
ALTER TABLE "insights_metadata" ADD CONSTRAINT "FK_1d8ab99d5861c9388d2dc1cf733" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_2375a1eda085adb16b24615b69c" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE SET NULL;
-- Modify "insights_raw" table
ALTER TABLE "insights_raw" ADD CONSTRAINT "FK_6e2e33741adef2a7c5d66befa4e" FOREIGN KEY ("metaId") REFERENCES "insights_metadata" ("metaId") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "installed_nodes" table
ALTER TABLE "installed_nodes" ADD CONSTRAINT "FK_73f857fc5dce682cef8a99c11dbddbc969618951" FOREIGN KEY ("package") REFERENCES "installed_packages" ("packageName") ON UPDATE CASCADE ON DELETE CASCADE;
-- Modify "instance_ai_checkpoints" table
ALTER TABLE "instance_ai_checkpoints" ADD CONSTRAINT "FK_2b23f3f24a70bebb990203b011e" FOREIGN KEY ("threadId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "instance_ai_iteration_logs" table
ALTER TABLE "instance_ai_iteration_logs" ADD CONSTRAINT "FK_8bfcc6c51fd3d69b1eae8aebd49" FOREIGN KEY ("threadId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "instance_ai_mcp_registry_connections" table
ALTER TABLE "instance_ai_mcp_registry_connections" ADD CONSTRAINT "FK_1d25707354d2012da256eb2ec0a" FOREIGN KEY ("serverSlug") REFERENCES "mcp_registry_server" ("slug") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_1e826120e7e53ebc4681f026de8" FOREIGN KEY ("credentialId") REFERENCES "credentials_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_8b42c08a531d76410980c639a5b" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "instance_ai_messages" table
ALTER TABLE "instance_ai_messages" ADD CONSTRAINT "FK_1eeb64cb9d66a927988de759e6e" FOREIGN KEY ("threadId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "instance_ai_observation_cursors" table
ALTER TABLE "instance_ai_observation_cursors" ADD CONSTRAINT "FK_5b6319b2e9a37c1064a72428f9a" FOREIGN KEY ("observationScopeId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "instance_ai_observation_locks" table
ALTER TABLE "instance_ai_observation_locks" ADD CONSTRAINT "FK_103e2e5f454860b28ea05a82c74" FOREIGN KEY ("observationScopeId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "instance_ai_observational_memory" table
ALTER TABLE "instance_ai_observational_memory" ADD CONSTRAINT "FK_34018c303885cd37093458e6409" FOREIGN KEY ("threadId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE SET NULL;
-- Modify "instance_ai_observations" table
ALTER TABLE "instance_ai_observations" ADD CONSTRAINT "FK_d54fc84a6c8ac91b5e0db0378a4" FOREIGN KEY ("observationScopeId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "instance_ai_pending_confirmations" table
ALTER TABLE "instance_ai_pending_confirmations" ADD CONSTRAINT "FK_0babdf6e3b897a86fe4678355eb" FOREIGN KEY ("checkpointKey") REFERENCES "instance_ai_checkpoints" ("key") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_ba67ee8dc311830a2eea89b6e96" FOREIGN KEY ("threadId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_df5fd25c8bbfd2b042602600d8e" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "instance_ai_run_snapshots" table
ALTER TABLE "instance_ai_run_snapshots" ADD CONSTRAINT "FK_2f63fa21d09d7918f347ddbdf70" FOREIGN KEY ("threadId") REFERENCES "instance_ai_threads" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "instance_ai_threads" table
ALTER TABLE "instance_ai_threads" ADD CONSTRAINT "FK_instance_ai_threads_projectId" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "oauth_access_tokens" table
ALTER TABLE "oauth_access_tokens" ADD CONSTRAINT "FK_7234a36d8e49a1fa85095328845" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_78b26968132b7e5e45b75876481" FOREIGN KEY ("clientId") REFERENCES "oauth_clients" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "oauth_authorization_codes" table
ALTER TABLE "oauth_authorization_codes" ADD CONSTRAINT "FK_64d965bd072ea24fb6da55468cd" FOREIGN KEY ("clientId") REFERENCES "oauth_clients" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_aa8d3560484944c19bdf79ffa16" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "oauth_refresh_tokens" table
ALTER TABLE "oauth_refresh_tokens" ADD CONSTRAINT "FK_a699f3ed9fd0c1b19bc2608ac53" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_b388696ce4d8be7ffbe8d3e4b69" FOREIGN KEY ("clientId") REFERENCES "oauth_clients" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "oauth_user_consents" table
ALTER TABLE "oauth_user_consents" ADD CONSTRAINT "FK_21e6c3c2d78a097478fae6aaefa" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_a651acea2f6c97f8c4514935486" FOREIGN KEY ("clientId") REFERENCES "oauth_clients" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "processed_data" table
ALTER TABLE "processed_data" ADD CONSTRAINT "FK_06a69a7032c97a763c2c7599464" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "project" table
ALTER TABLE "project" ADD CONSTRAINT "projects_creatorId_foreign" FOREIGN KEY ("creatorId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE SET NULL;
-- Modify "project_relation" table
ALTER TABLE "project_relation" ADD CONSTRAINT "FK_5f0643f6717905a05164090dde7" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_61448d56d61802b5dfde5cdb002" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_c6b99592dc96b0d836d7a21db91" FOREIGN KEY ("role") REFERENCES "role" ("slug") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- Modify "project_secrets_provider_access" table
ALTER TABLE "project_secrets_provider_access" ADD CONSTRAINT "FK_18e5c27d2524b1638b292904e48" FOREIGN KEY ("secretsProviderConnectionId") REFERENCES "secrets_provider_connection" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_bd264b81209355b543878deedb1" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "role_mapping_rule" table
ALTER TABLE "role_mapping_rule" ADD CONSTRAINT "FK_bb66e404c35996b0d6946177501" FOREIGN KEY ("role") REFERENCES "role" ("slug") ON UPDATE CASCADE ON DELETE CASCADE;
-- Modify "role_mapping_rule_project" table
ALTER TABLE "role_mapping_rule_project" ADD CONSTRAINT "FK_35a78869286c65d9330d02b88f5" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_dd7ce4dfa09e95b36a626bd9de3" FOREIGN KEY ("roleMappingRuleId") REFERENCES "role_mapping_rule" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "role_scope" table
ALTER TABLE "role_scope" ADD CONSTRAINT "FK_role" FOREIGN KEY ("roleSlug") REFERENCES "role" ("slug") ON UPDATE CASCADE ON DELETE CASCADE, ADD CONSTRAINT "FK_scope" FOREIGN KEY ("scopeSlug") REFERENCES "scope" ("slug") ON UPDATE CASCADE ON DELETE CASCADE;
-- Modify "shared_credentials" table
ALTER TABLE "shared_credentials" ADD CONSTRAINT "FK_416f66fc846c7c442970c094ccf" FOREIGN KEY ("credentialsId") REFERENCES "credentials_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_812c2852270da1247756e77f5a4" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "shared_workflow" table
ALTER TABLE "shared_workflow" ADD CONSTRAINT "FK_a45ea5f27bcfdc21af9b4188560" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_daa206a04983d47d0a9c34649ce" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "test_case_execution" table
ALTER TABLE "test_case_execution" ADD CONSTRAINT "FK_8e4b4774db42f1e6dda3452b2af" FOREIGN KEY ("testRunId") REFERENCES "test_run" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_e48965fac35d0f5b9e7f51d8c44" FOREIGN KEY ("executionId") REFERENCES "execution_entity" ("id") ON UPDATE NO ACTION ON DELETE SET NULL;
-- Modify "test_run" table
ALTER TABLE "test_run" ADD CONSTRAINT "FK_d6870d3b6e4c185d33926f423c8" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_test_run_collection_id" FOREIGN KEY ("collectionId") REFERENCES "evaluation_collection" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_test_run_evaluation_config_id" FOREIGN KEY ("evaluationConfigId") REFERENCES "evaluation_config" ("id") ON UPDATE NO ACTION ON DELETE SET NULL;
-- Modify "trusted_key" table
ALTER TABLE "trusted_key" ADD CONSTRAINT "FK_8c2938d746943dd8f608d23c891" FOREIGN KEY ("sourceId") REFERENCES "trusted_key_source" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "user" table
ALTER TABLE "user" ADD CONSTRAINT "FK_eaea92ee7bfb9c1b6cd01505d56" FOREIGN KEY ("roleSlug") REFERENCES "role" ("slug") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- Modify "user_api_keys" table
ALTER TABLE "user_api_keys" ADD CONSTRAINT "FK_e131705cbbc8fb589889b02d457" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "user_favorites" table
ALTER TABLE "user_favorites" ADD CONSTRAINT "FK_1dd5c393ad0517be3c31a7af836" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "variables" table
ALTER TABLE "variables" ADD CONSTRAINT "FK_42f6c766f9f9d2edcc15bdd6e9b" FOREIGN KEY ("projectId") REFERENCES "project" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "webhook_entity" table
ALTER TABLE "webhook_entity" ADD CONSTRAINT "fk_webhook_entity_workflow_id" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "workflow_builder_session" table
ALTER TABLE "workflow_builder_session" ADD CONSTRAINT "FK_00290cdeee4d4d7db84709be936" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "FK_7983c618db48f47bf5a4cc1e1e4" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "workflow_dependency" table
ALTER TABLE "workflow_dependency" ADD CONSTRAINT "FK_a4ff2d9b9628ea988fa9e7d0bf8" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "workflow_entity" table
ALTER TABLE "workflow_entity" ADD CONSTRAINT "FK_08d6c67b7f722b0039d9d5ed620" FOREIGN KEY ("activeVersionId") REFERENCES "workflow_history" ("versionId") ON UPDATE NO ACTION ON DELETE RESTRICT, ADD CONSTRAINT "fk_workflow_parent_folder" FOREIGN KEY ("parentFolderId") REFERENCES "folder" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "workflow_history" table
ALTER TABLE "workflow_history" ADD CONSTRAINT "FK_1e31657f5fe46816c34be7c1b4b" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "workflow_publish_history" table
ALTER TABLE "workflow_publish_history" ADD CONSTRAINT "FK_6eab5bd9eedabe9c54bd879fc40" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_b4cfbc7556d07f36ca177f5e473" FOREIGN KEY ("versionId") REFERENCES "workflow_history" ("versionId") ON UPDATE NO ACTION ON DELETE SET NULL, ADD CONSTRAINT "FK_c01316f8c2d7101ec4fa9809267" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "workflow_published_version" table
ALTER TABLE "workflow_published_version" ADD CONSTRAINT "FK_5c76fb7ee939fe2530374d3f75a" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE RESTRICT, ADD CONSTRAINT "FK_df3428a541b802d6a63ac56e330" FOREIGN KEY ("publishedVersionId") REFERENCES "workflow_history" ("versionId") ON UPDATE NO ACTION ON DELETE RESTRICT;
-- Modify "workflows_tags" table
ALTER TABLE "workflows_tags" ADD CONSTRAINT "fk_workflows_tags_tag_id" FOREIGN KEY ("tagId") REFERENCES "tag_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD CONSTRAINT "fk_workflows_tags_workflow_id" FOREIGN KEY ("workflowId") REFERENCES "workflow_entity" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
