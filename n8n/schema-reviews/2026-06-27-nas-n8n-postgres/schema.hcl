table "agent_chat_subscriptions" {
  schema = schema.public
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Agent that owns this subscription"
  }
  column "integrationType" {
    null    = false
    type    = character_varying(64)
    comment = "Chat integration platform for this subscription"
  }
  column "credentialId" {
    null    = false
    type    = character_varying(255)
    comment = "Credential connection that owns this subscription"
  }
  column "threadId" {
    null    = false
    type    = character_varying(255)
    comment = "Platform thread ID the agent is subscribed to"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_76598cf91038bee1f3ac94c94bc" {
    columns = [column.agentId, column.integrationType, column.credentialId, column.threadId]
  }
  foreign_key "FK_e79153bd179c011e779d5016796" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  check "CHK_agent_chat_subscriptions_integrationType" {
    expr = "((\"integrationType\")::text = ANY ((ARRAY['telegram'::character varying, 'slack'::character varying, 'linear'::character varying])::text[]))"
  }
}
table "agent_checkpoints" {
  schema = schema.public
  column "runId" {
    null = false
    type = character_varying(255)
  }
  column "agentId" {
    null = true
    type = character_varying(255)
  }
  column "state" {
    null = true
    type = text
  }
  column "expired" {
    null    = false
    type    = boolean
    default = false
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_50a27cbafa6806c9b162304b5fd" {
    columns = [column.runId]
  }
  foreign_key "FK_5e31c210f896d539964bf99fe32" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_5e31c210f896d539964bf99fe3" {
    columns = [column.agentId]
  }
}
table "agent_execution" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "threadId" {
    null = false
    type = character_varying(128)
  }
  column "status" {
    null = false
    type = character_varying(16)
  }
  column "startedAt" {
    null = true
    type = timestamptz(3)
  }
  column "stoppedAt" {
    null = true
    type = timestamptz(3)
  }
  column "duration" {
    null    = false
    type    = integer
    default = 0
  }
  column "userMessage" {
    null = false
    type = text
  }
  column "assistantResponse" {
    null = false
    type = text
  }
  column "model" {
    null = true
    type = character_varying(255)
  }
  column "promptTokens" {
    null = true
    type = integer
  }
  column "completionTokens" {
    null = true
    type = integer
  }
  column "totalTokens" {
    null = true
    type = integer
  }
  column "cost" {
    null = true
    type = double_precision
  }
  column "toolCalls" {
    null = true
    type = json
  }
  column "timeline" {
    null = true
    type = json
  }
  column "error" {
    null = true
    type = text
  }
  column "hitlStatus" {
    null = true
    type = character_varying(16)
  }
  column "source" {
    null = true
    type = character_varying(32)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_ba438acc8532addc12d1ef17049" {
    columns = [column.id]
  }
  foreign_key "FK_add2432fb6034cc18b6af299dce" {
    columns     = [column.threadId]
    ref_columns = [table.agent_execution_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_63d3c3a68b9cebf05f967f0b1c" {
    columns = [column.threadId, column.createdAt]
  }
  check "CHK_agent_execution_hitlStatus" {
    expr = "((\"hitlStatus\")::text = ANY (ARRAY[('suspended'::character varying)::text, ('resumed'::character varying)::text]))"
  }
  check "CHK_agent_execution_status" {
    expr = "((status)::text = ANY (ARRAY[('success'::character varying)::text, ('error'::character varying)::text]))"
  }
}
table "agent_execution_threads" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(128)
  }
  column "agentId" {
    null = false
    type = character_varying(36)
  }
  column "agentName" {
    null = false
    type = character_varying(255)
  }
  column "projectId" {
    null = false
    type = character_varying(255)
  }
  column "sessionNumber" {
    null    = false
    type    = integer
    default = 0
  }
  column "totalPromptTokens" {
    null    = false
    type    = integer
    default = 0
  }
  column "totalCompletionTokens" {
    null    = false
    type    = integer
    default = 0
  }
  column "totalCost" {
    null    = false
    type    = double_precision
    default = 0
  }
  column "totalDuration" {
    null    = false
    type    = integer
    default = 0
  }
  column "title" {
    null = true
    type = character_varying(255)
  }
  column "emoji" {
    null = true
    type = character_varying(8)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "taskId" {
    null    = true
    type    = character_varying(32)
    comment = "Published task ID that triggered this session; not an FK because published runs can outlive draft task definition rows"
  }
  column "taskVersionId" {
    null    = true
    type    = character_varying(36)
    comment = "Published agent_history version that supplied the task snapshot"
  }
  column "parentThreadId" {
    null    = true
    type    = character_varying(128)
    comment = "Parent session thread id that delegated this subagent run."
  }
  column "parentAgentId" {
    null    = true
    type    = character_varying(36)
    comment = "Saved agent id of the parent that delegated this subagent run."
  }
  primary_key "PK_22373dbf6ba6929d8ac50093309" {
    columns = [column.id]
  }
  foreign_key "FK_0468a9dc35597314e641d4722aa" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_0e2f8bf92a7a9c88b89670f701c" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_f00b52d74fe11838e1fe086deea" {
    columns     = [column.taskVersionId]
    ref_columns = [table.agent_history.column.versionId]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "IDX_0468a9dc35597314e641d4722a" {
    columns = [column.agentId]
  }
  index "IDX_0e2f8bf92a7a9c88b89670f701" {
    columns = [column.projectId]
  }
  index "IDX_agent_execution_threads_taskVersionId" {
    columns = [column.taskVersionId]
  }
}
table "agent_files" {
  schema = schema.public
  column "id" {
    null    = false
    type    = character_varying(16)
    comment = "Application-generated n8n nano ID"
  }
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Agent that owns this uploaded file"
  }
  column "binaryDataId" {
    null    = false
    type    = text
    comment = "Opaque BinaryDataService reference (mode-prefixed, e.g. \"filesystem-v2:<uuid>\"); not an FK to binary_data, which only has rows in DB storage mode"
  }
  column "fileName" {
    null = false
    type = character_varying(255)
  }
  column "mimeType" {
    null = false
    type = character_varying(255)
  }
  column "fileSizeBytes" {
    null    = false
    type    = integer
    comment = "Uploaded file size in bytes"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_692920e59217af7d124cd95106f" {
    columns = [column.id]
  }
  foreign_key "FK_aca4514cb500494b64356c2e164" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_45dafc48fe2ce95eac30fc8ffd" {
    columns = [column.agentId, column.createdAt]
  }
}
table "agent_history" {
  schema = schema.public
  column "versionId" {
    null = false
    type = character_varying(36)
  }
  column "agentId" {
    null = false
    type = character_varying(36)
  }
  column "schema" {
    null    = true
    type    = json
    comment = "Frozen snapshot of the published AgentJsonConfig"
  }
  column "tools" {
    null    = true
    type    = json
    comment = "Frozen map of `toolId → { code, descriptor }` at publish time"
  }
  column "skills" {
    null    = true
    type    = json
    comment = "Frozen map of `skillId → AgentSkill` at publish time"
  }
  column "publishedById" {
    null = true
    type = uuid
  }
  column "author" {
    null = false
    type = character_varying(255)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_65ffcfe7a8e112fb826311fb092" {
    columns = [column.versionId]
  }
  foreign_key "FK_8771675f44c58fb40e0feb9ee35" {
    columns     = [column.publishedById]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_87cd5a8da20304b089ea2f83fec" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_87cd5a8da20304b089ea2f83fe" {
    columns = [column.agentId]
  }
}
table "agent_task_definition" {
  schema = schema.public
  column "id" {
    null    = false
    type    = character_varying(32)
    comment = "Application-generated task ID referenced from agent JSON config"
  }
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Owning agent; task definitions are deleted when the agent is deleted"
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "objective" {
    null    = false
    type    = text
    comment = "User-authored instruction sent to the agent when this task runs"
  }
  column "cronExpression" {
    null    = false
    type    = character_varying(128)
    comment = "Cron schedule evaluated using the instance timezone"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_1756c11c637903e97629a7a784a" {
    columns = [column.id]
  }
  foreign_key "FK_f45d0535a2ed59b6c2dd6da98a0" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_f45d0535a2ed59b6c2dd6da98a" {
    columns = [column.agentId]
  }
}
table "agent_task_run_lock" {
  schema = schema.public
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Published agent whose scheduled task run is locked"
  }
  column "taskId" {
    null    = false
    type    = character_varying(32)
    comment = "Published task ID whose scheduled run is locked"
  }
  column "holderId" {
    null    = false
    type    = uuid
    comment = "Ephemeral lock owner token generated by the running main"
  }
  column "heldUntil" {
    null    = false
    type    = timestamptz(3)
    comment = "Time after which another main can claim this task run lock"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_f593adaf7230e964d3c25deda64" {
    columns = [column.agentId, column.taskId]
  }
  foreign_key "FK_b57a2862ae869aab24e54cefd48" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "agent_task_snapshot" {
  schema = schema.public
  column "versionId" {
    null    = false
    type    = character_varying(36)
    comment = "Published agent_history version this task snapshot belongs to"
  }
  column "taskId" {
    null    = false
    type    = character_varying(32)
    comment = "Stable task ID referenced from the published agent JSON config"
  }
  column "enabled" {
    null    = false
    type    = boolean
    comment = "Published enabled state for this task at publish time"
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "objective" {
    null    = false
    type    = text
    comment = "User-authored instruction sent to the agent when this task runs"
  }
  column "cronExpression" {
    null    = false
    type    = character_varying(128)
    comment = "Cron schedule evaluated using the instance timezone"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_2142a8bcda2360c3c5e34f82640" {
    columns = [column.versionId, column.taskId]
  }
  foreign_key "FK_1acedce6690392ef1611cca8b88" {
    columns     = [column.versionId]
    ref_columns = [table.agent_history.column.versionId]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "agents" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "description" {
    null = true
    type = character_varying(512)
  }
  column "projectId" {
    null = false
    type = character_varying(255)
  }
  column "integrations" {
    null    = false
    type    = json
    default = "[]"
  }
  column "schema" {
    null = true
    type = json
  }
  column "tools" {
    null    = false
    type    = json
    default = "{}"
  }
  column "skills" {
    null    = false
    type    = json
    default = "{}"
  }
  column "versionId" {
    null = true
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "activeVersionId" {
    null = true
    type = character_varying(36)
  }
  primary_key "PK_9c653f28ae19c5884d5baf6a1d9" {
    columns = [column.id]
  }
  foreign_key "FK_940597dfe9753375309ce6aeea0" {
    columns     = [column.activeVersionId]
    ref_columns = [table.agent_history.column.versionId]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_a30d560207c4071d98aa03c179c" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_a30d560207c4071d98aa03c179" {
    columns = [column.projectId]
  }
  index "IDX_agents_projectId" {
    columns = [column.projectId]
  }
}
table "agents_memory_entries" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Agent that owns this episodic memory entry"
  }
  column "resourceId" {
    null    = false
    type    = character_varying(255)
    comment = "agents_resources.id partition used for episodic recall scope"
  }
  column "content" {
    null = false
    type = text
  }
  column "contentHash" {
    null = false
    type = character_varying(64)
  }
  column "status" {
    null = false
    type = character_varying(16)
  }
  column "supersededBy" {
    null    = true
    type    = character_varying(36)
    comment = "Self-reference to replacement memory entry"
  }
  column "embeddingModel" {
    null    = true
    type    = character_varying(128)
    comment = "Embedding model used to produce embedding"
  }
  column "embedding" {
    null    = true
    type    = json
    comment = "Embedding vector for episodic recall"
  }
  column "metadata" {
    null    = true
    type    = json
    comment = "Optional system metadata for ranking and debugging"
  }
  column "lastSeenAt" {
    null    = false
    type    = timestamptz(3)
    comment = "Last time equivalent content was observed; updatedAt tracks row mutation time"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_bfbc45dc88f66fae4e4b4a15fec" {
    columns = [column.id]
  }
  foreign_key "FK_0edf1226b77ddc525eae4938079" {
    columns     = [column.supersededBy]
    ref_columns = [table.agents_memory_entries.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "FK_1443a75e59adbfb796071d66393" {
    columns     = [column.resourceId]
    ref_columns = [table.agents_resources.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_28e981fb675e9b44ce02f0ec1dd" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_0edf1226b77ddc525eae493807" {
    columns = [column.supersededBy]
  }
  index "IDX_1443a75e59adbfb796071d6639" {
    columns = [column.resourceId]
  }
  index "IDX_a03e04e94bea8439dd166d4b52" {
    unique  = true
    columns = [column.agentId, column.resourceId, column.contentHash]
  }
  index "IDX_aff2807b31eccbafe59d0474f0" {
    columns = [column.agentId, column.resourceId, column.status, column.createdAt, column.id]
  }
  check "CHK_agents_memory_entries_status" {
    expr = "((status)::text = ANY (ARRAY[('active'::character varying)::text, ('superseded'::character varying)::text, ('dropped'::character varying)::text]))"
  }
}
table "agents_memory_entry_cursors" {
  schema = schema.public
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Agent that owns this cursor"
  }
  column "observationScopeId" {
    null    = false
    type    = character_varying(255)
    comment = "agents_threads.id source stream indexed into episodic memory"
  }
  column "lastIndexedObservationId" {
    null    = false
    type    = character_varying(36)
    comment = "Last observation-log row indexed into episodic memory"
  }
  column "lastIndexedObservationCreatedAt" {
    null    = false
    type    = timestamptz(3)
    comment = "Creation timestamp for the last indexed observation-log row"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_b31a1d5c009a27f4cc5ef8f102a" {
    columns = [column.agentId, column.observationScopeId]
  }
  foreign_key "FK_069e791e428391a5569e7a96b20" {
    columns     = [column.observationScopeId]
    ref_columns = [table.agents_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_746780fd115e5e4352457a3c617" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_069e791e428391a5569e7a96b2" {
    columns = [column.observationScopeId]
  }
}
table "agents_memory_entry_locks" {
  schema = schema.public
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Agent that owns this lock"
  }
  column "resourceId" {
    null    = false
    type    = character_varying(255)
    comment = "agents_resources.id partition locked for episodic indexing"
  }
  column "holderId" {
    null    = false
    type    = character_varying(64)
    comment = "Ephemeral background-task lock owner token"
  }
  column "heldUntil" {
    null = false
    type = timestamptz(3)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_a8e0f570d04a174292bea104ae6" {
    columns = [column.agentId, column.resourceId]
  }
  foreign_key "FK_0ccf6d9ea6f44fa1c264fc2f795" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_9594c0983cfee1c8ff49b05848b" {
    columns     = [column.resourceId]
    ref_columns = [table.agents_resources.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_9594c0983cfee1c8ff49b05848" {
    columns = [column.resourceId]
  }
}
table "agents_memory_entry_sources" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Agent that owns the linked episodic memory entry source"
  }
  column "memoryEntryId" {
    null    = false
    type    = character_varying(36)
    comment = "Episodic memory entry linked to this source evidence"
  }
  column "observationId" {
    null    = false
    type    = character_varying(36)
    comment = "Observation-log row used as source evidence"
  }
  column "threadId" {
    null    = false
    type    = character_varying(255)
    comment = "Source conversation thread that produced the linked observation"
  }
  column "evidenceHash" {
    null    = false
    type    = character_varying(64)
    comment = "Bounded hash used to deduplicate exact evidence links"
  }
  column "evidenceText" {
    null    = false
    type    = text
    comment = "Exact source evidence text from the observation, not recall scope"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_278f05e98e74baaaa93f52b4bab" {
    columns = [column.id]
  }
  foreign_key "FK_451d387a182fa8dd8002dfc3a77" {
    columns     = [column.threadId]
    ref_columns = [table.agents_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_4706f6223313959b7437a2b48df" {
    columns     = [column.memoryEntryId]
    ref_columns = [table.agents_memory_entries.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_c38e8a57a36b880e39a52ada2e8" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_cb7c15d22fd068a0806aa57fc03" {
    columns     = [column.observationId]
    ref_columns = [table.agents_observations.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_451d387a182fa8dd8002dfc3a7" {
    columns = [column.threadId]
  }
  index "IDX_a353ac251315ef0af6ad3c9f0a" {
    unique  = true
    columns = [column.memoryEntryId, column.observationId, column.evidenceHash]
  }
  index "IDX_cb7c15d22fd068a0806aa57fc0" {
    columns = [column.observationId]
  }
  index "IDX_f9573af4ed653f13b0ba1f7b12" {
    columns = [column.agentId, column.threadId]
  }
}
table "agents_messages" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "threadId" {
    null = false
    type = character_varying(255)
  }
  column "resourceId" {
    null = false
    type = character_varying(255)
  }
  column "role" {
    null = false
    type = character_varying(36)
  }
  column "type" {
    null = true
    type = character_varying(36)
  }
  column "content" {
    null = false
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_81020dc608dfb0af1ede386d907" {
    columns = [column.id]
  }
  foreign_key "FK_0a8057a61afabd2999608ffd0d9" {
    columns     = [column.threadId]
    ref_columns = [table.agents_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_agents_messages_threadId_createdAt" {
    columns = [column.threadId, column.createdAt]
  }
  index "IDX_fc7bf858660bfafd19181e8e35" {
    columns = [column.threadId, column.createdAt]
  }
}
table "agents_observation_cursors" {
  schema = schema.public
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Agent that owns this cursor"
  }
  column "observationScopeId" {
    null    = false
    type    = character_varying(255)
    comment = "agents_threads.id source stream checkpointed by this cursor"
  }
  column "lastObservedMessageId" {
    null = false
    type = character_varying(36)
  }
  column "lastObservedAt" {
    null = false
    type = timestamptz(3)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_eb777ac57ab872d38f8ebd19317" {
    columns = [column.agentId, column.observationScopeId]
  }
  foreign_key "FK_64e92819f4b413661ed6e2c3c3d" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_87aa187d27ea67eafd164905154" {
    columns     = [column.observationScopeId]
    ref_columns = [table.agents_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_87aa187d27ea67eafd16490515" {
    columns = [column.observationScopeId]
  }
}
table "agents_observation_locks" {
  schema = schema.public
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Agent that owns this lock"
  }
  column "observationScopeId" {
    null    = false
    type    = character_varying(255)
    comment = "agents_threads.id source stream locked for observation tasks"
  }
  column "taskKind" {
    null = false
    type = character_varying(20)
  }
  column "holderId" {
    null    = false
    type    = character_varying(64)
    comment = "Ephemeral background-task lock owner token, not a user ID"
  }
  column "heldUntil" {
    null = false
    type = timestamptz(3)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_7e2e315162ac3d80587e15ac2c3" {
    columns = [column.agentId, column.observationScopeId, column.taskKind]
  }
  foreign_key "FK_093e44ae20f2518e97d83a95433" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_6b55089892e447c2f82e5ec60ed" {
    columns     = [column.observationScopeId]
    ref_columns = [table.agents_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_6b55089892e447c2f82e5ec60e" {
    columns = [column.observationScopeId]
  }
  check "CHK_agents_observation_locks_taskKind" {
    expr = "((\"taskKind\")::text = ANY (ARRAY[('observer'::character varying)::text, ('reflector'::character varying)::text]))"
  }
}
table "agents_observations" {
  schema = schema.public
  column "id" {
    null    = false
    type    = character_varying(36)
    comment = "Application-generated n8n string ID, not a database UUID"
  }
  column "agentId" {
    null    = false
    type    = character_varying(36)
    comment = "Agent that owns this observation row"
  }
  column "observationScopeId" {
    null    = false
    type    = character_varying(255)
    comment = "agents_threads.id source stream for this observation log"
  }
  column "marker" {
    null = false
    type = character_varying(16)
  }
  column "text" {
    null = false
    type = text
  }
  column "parentId" {
    null = true
    type = character_varying(36)
  }
  column "tokenCount" {
    null    = false
    type    = integer
    default = 0
  }
  column "status" {
    null = false
    type = character_varying(16)
  }
  column "supersededBy" {
    null = true
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_9ad319654d12c2649f7caf27135" {
    columns = [column.id]
  }
  foreign_key "FK_127ee1078ffa952bb37b511efad" {
    columns     = [column.supersededBy]
    ref_columns = [table.agents_observations.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "FK_4cfd8a70ebb0a5b0cf047dca3cf" {
    columns     = [column.observationScopeId]
    ref_columns = [table.agents_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_501e2d1701a10e24fb69ab5fc5f" {
    columns     = [column.parentId]
    ref_columns = [table.agents_observations.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "FK_d206432be97b7ed88d187479b1b" {
    columns     = [column.agentId]
    ref_columns = [table.agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_07cb1e4a302629c5fa5d74d2bb" {
    columns = [column.agentId, column.observationScopeId, column.status]
  }
  index "IDX_127ee1078ffa952bb37b511efa" {
    columns = [column.supersededBy]
  }
  index "IDX_4cfd8a70ebb0a5b0cf047dca3c" {
    columns = [column.observationScopeId]
  }
  index "IDX_501e2d1701a10e24fb69ab5fc5" {
    columns = [column.parentId]
  }
  check "CHK_agents_observations_marker" {
    expr = "((marker)::text = ANY (ARRAY[('critical'::character varying)::text, ('important'::character varying)::text, ('info'::character varying)::text, ('completion'::character varying)::text]))"
  }
  check "CHK_agents_observations_status" {
    expr = "((status)::text = ANY (ARRAY[('active'::character varying)::text, ('superseded'::character varying)::text, ('dropped'::character varying)::text]))"
  }
}
table "agents_resources" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(255)
  }
  column "metadata" {
    null = true
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_fa6b20b2d31a9991529dbf8ef7d" {
    columns = [column.id]
  }
}
table "agents_threads" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(128)
  }
  column "resourceId" {
    null = false
    type = character_varying(255)
  }
  column "title" {
    null = true
    type = character_varying(255)
  }
  column "metadata" {
    null = true
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_4a3feb0a13ffe315c009cce64e5" {
    columns = [column.id]
  }
  index "IDX_54fa1b94f34a409beafae567a4" {
    columns = [column.resourceId]
  }
}
table "ai_builder_temporary_workflow" {
  schema = schema.public
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "threadId" {
    null = false
    type = uuid
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_85a87a1ba0f61999fe11dc56325" {
    columns = [column.workflowId]
  }
  foreign_key "FK_39b07732e819fb561d74c38763f" {
    columns     = [column.threadId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_85a87a1ba0f61999fe11dc56325" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_39b07732e819fb561d74c38763" {
    columns = [column.threadId]
  }
}
table "annotation_tag_entity" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(16)
  }
  column "name" {
    null = false
    type = character_varying(24)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_69dfa041592c30bbc0d4b84aa00" {
    columns = [column.id]
  }
  index "IDX_ae51b54c4bb430cf92f48b623f" {
    unique  = true
    columns = [column.name]
  }
}
table "auth_identity" {
  schema = schema.public
  column "userId" {
    null = true
    type = uuid
  }
  column "providerId" {
    null = false
    type = character_varying(255)
  }
  column "providerType" {
    null = false
    type = character_varying(32)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key {
    columns = [column.providerId, column.providerType]
  }
  foreign_key "auth_identity_userId_fkey" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
}
table "auth_provider_sync_history" {
  schema = schema.public
  column "id" {
    null = false
    type = serial
  }
  column "providerType" {
    null = false
    type = character_varying(32)
  }
  column "runMode" {
    null = false
    type = text
  }
  column "status" {
    null = false
    type = text
  }
  column "startedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP")
  }
  column "endedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP")
  }
  column "scanned" {
    null = false
    type = integer
  }
  column "created" {
    null = false
    type = integer
  }
  column "updated" {
    null = false
    type = integer
  }
  column "disabled" {
    null = false
    type = integer
  }
  column "error" {
    null = true
    type = text
  }
  primary_key {
    columns = [column.id]
  }
}
table "binary_data" {
  schema = schema.public
  column "fileId" {
    null = false
    type = uuid
  }
  column "sourceType" {
    null    = false
    type    = character_varying(50)
    comment = "Source the file belongs to, e.g. 'execution'"
  }
  column "sourceId" {
    null    = false
    type    = character_varying(255)
    comment = "ID of the source, e.g. execution ID"
  }
  column "data" {
    null    = false
    type    = bytea
    comment = "Raw, not base64 encoded"
  }
  column "mimeType" {
    null = true
    type = character_varying(255)
  }
  column "fileName" {
    null = true
    type = character_varying(255)
  }
  column "fileSize" {
    null    = false
    type    = integer
    comment = "In bytes"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_fc3691585b39408bb0551122af6" {
    columns = [column.fileId]
  }
  index "IDX_56900edc3cfd16612e2ef2c6a8" {
    columns = [column.sourceType, column.sourceId]
  }
  check "CHK_binary_data_sourceType" {
    expr = "((\"sourceType\")::text = ANY ((ARRAY['execution'::character varying, 'chat_message_attachment'::character varying, 'agent_file'::character varying])::text[]))"
  }
}
table "chat_hub_agent_tools" {
  schema = schema.public
  column "agentId" {
    null = false
    type = uuid
  }
  column "toolId" {
    null = false
    type = uuid
  }
  primary_key "PK_cc8806fdea48297a7d497035d72" {
    columns = [column.agentId, column.toolId]
  }
  foreign_key "FK_2b53d796b3dbae91b1a9553c048" {
    columns     = [column.agentId]
    ref_columns = [table.chat_hub_agents.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_43e70f04c53344f82483d0570f6" {
    columns     = [column.toolId]
    ref_columns = [table.chat_hub_tools.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "chat_hub_agents" {
  schema = schema.public
  column "id" {
    null = false
    type = uuid
  }
  column "name" {
    null = false
    type = character_varying(256)
  }
  column "description" {
    null = true
    type = character_varying(512)
  }
  column "systemPrompt" {
    null = false
    type = text
  }
  column "ownerId" {
    null = false
    type = uuid
  }
  column "credentialId" {
    null = true
    type = character_varying(36)
  }
  column "provider" {
    null    = false
    type    = character_varying(16)
    comment = "ChatHubProvider enum: \"openai\", \"anthropic\", \"google\", \"n8n\""
  }
  column "model" {
    null    = false
    type    = character_varying(64)
    comment = "Model name used at the respective Model node, ie. \"gpt-4\""
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "icon" {
    null = true
    type = json
  }
  column "files" {
    null    = false
    type    = json
    default = "[]"
  }
  column "suggestedPrompts" {
    null    = false
    type    = json
    default = "[]"
  }
  primary_key "PK_f39a3b36bbdf0e2979ddb21cf78" {
    columns = [column.id]
  }
  foreign_key "FK_441ba2caba11e077ce3fbfa2cd8" {
    columns     = [column.ownerId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_9c61ad497dcbae499c96a6a78ba" {
    columns     = [column.credentialId]
    ref_columns = [table.credentials_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
}
table "chat_hub_messages" {
  schema = schema.public
  column "id" {
    null = false
    type = uuid
  }
  column "sessionId" {
    null = false
    type = uuid
  }
  column "previousMessageId" {
    null = true
    type = uuid
  }
  column "revisionOfMessageId" {
    null = true
    type = uuid
  }
  column "retryOfMessageId" {
    null = true
    type = uuid
  }
  column "type" {
    null    = false
    type    = character_varying(16)
    comment = "ChatHubMessageType enum: \"human\", \"ai\", \"system\", \"tool\", \"generic\""
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "content" {
    null = false
    type = text
  }
  column "provider" {
    null    = true
    type    = character_varying(16)
    comment = "ChatHubProvider enum: \"openai\", \"anthropic\", \"google\", \"n8n\""
  }
  column "model" {
    null    = true
    type    = character_varying(256)
    comment = "Model name used at the respective Model node, ie. \"gpt-4\""
  }
  column "workflowId" {
    null = true
    type = character_varying(36)
  }
  column "executionId" {
    null = true
    type = integer
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "agentId" {
    null    = true
    type    = uuid
    comment = "ID of the custom agent (if provider is \"custom-agent\")"
  }
  column "status" {
    null    = false
    type    = character_varying(16)
    default = "success"
    comment = "ChatHubMessageStatus enum, eg. \"success\", \"error\", \"running\", \"cancelled\""
  }
  column "attachments" {
    null    = true
    type    = json
    comment = "File attachments for the message (if any), stored as JSON. Files are stored as base64-encoded data URLs."
  }
  primary_key "PK_7704a5add6baed43eef835f0bfb" {
    columns = [column.id]
  }
  foreign_key "FK_1f4998c8a7dec9e00a9ab15550e" {
    columns     = [column.revisionOfMessageId]
    ref_columns = [table.chat_hub_messages.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_25c9736e7f769f3a005eef4b372" {
    columns     = [column.retryOfMessageId]
    ref_columns = [table.chat_hub_messages.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_6afb260449dd7a9b85355d4e0c9" {
    columns     = [column.executionId]
    ref_columns = [table.execution_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_acf8926098f063cdbbad8497fd1" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_chat_hub_messages_agentId" {
    columns     = [column.agentId]
    ref_columns = [table.chat_hub_agents.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_e22538eb50a71a17954cd7e076c" {
    columns     = [column.sessionId]
    ref_columns = [table.chat_hub_sessions.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_e5d1fa722c5a8d38ac204746662" {
    columns     = [column.previousMessageId]
    ref_columns = [table.chat_hub_messages.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_chat_hub_messages_sessionId" {
    columns = [column.sessionId]
  }
}
table "chat_hub_session_tools" {
  schema = schema.public
  column "sessionId" {
    null = false
    type = uuid
  }
  column "toolId" {
    null = false
    type = uuid
  }
  primary_key "PK_87aea76ff4c274c4a5ac838ebe3" {
    columns = [column.sessionId, column.toolId]
  }
  foreign_key "FK_6596a328affd8d4967ffb303eee" {
    columns     = [column.toolId]
    ref_columns = [table.chat_hub_tools.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_e649bf1295f4ed8d4299ed290f9" {
    columns     = [column.sessionId]
    ref_columns = [table.chat_hub_sessions.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "chat_hub_sessions" {
  schema = schema.public
  column "id" {
    null = false
    type = uuid
  }
  column "title" {
    null = false
    type = character_varying(256)
  }
  column "ownerId" {
    null = false
    type = uuid
  }
  column "lastMessageAt" {
    null = false
    type = timestamptz(3)
  }
  column "credentialId" {
    null = true
    type = character_varying(36)
  }
  column "provider" {
    null    = true
    type    = character_varying(16)
    comment = "ChatHubProvider enum: \"openai\", \"anthropic\", \"google\", \"n8n\""
  }
  column "model" {
    null    = true
    type    = character_varying(256)
    comment = "Model name used at the respective Model node, ie. \"gpt-4\""
  }
  column "workflowId" {
    null = true
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "agentId" {
    null    = true
    type    = uuid
    comment = "ID of the custom agent (if provider is \"custom-agent\")"
  }
  column "agentName" {
    null    = true
    type    = character_varying(128)
    comment = "Cached name of the custom agent (if provider is \"custom-agent\")"
  }
  column "type" {
    null    = false
    type    = character_varying(16)
    default = "production"
  }
  primary_key "PK_1eafef1273c70e4464fec703412" {
    columns = [column.id]
  }
  foreign_key "FK_7bc13b4c7e6afbfaf9be326c189" {
    columns     = [column.credentialId]
    ref_columns = [table.credentials_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_9f9293d9f552496c40e0d1a8f80" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_chat_hub_sessions_agentId" {
    columns     = [column.agentId]
    ref_columns = [table.chat_hub_agents.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_e9ecf8ede7d989fcd18790fe36a" {
    columns     = [column.ownerId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_chat_hub_sessions_owner_lastmsg_id" {
    on {
      column = column.ownerId
    }
    on {
      desc   = true
      column = column.lastMessageAt
    }
    on {
      column = column.id
    }
  }
  check "CHK_chat_hub_sessions_type" {
    expr = "((type)::text = ANY (ARRAY[('production'::character varying)::text, ('manual'::character varying)::text]))"
  }
}
table "chat_hub_tools" {
  schema = schema.public
  column "id" {
    null = false
    type = uuid
  }
  column "name" {
    null = false
    type = character_varying(255)
  }
  column "type" {
    null = false
    type = character_varying(255)
  }
  column "typeVersion" {
    null = false
    type = double_precision
  }
  column "ownerId" {
    null = false
    type = uuid
  }
  column "definition" {
    null = false
    type = json
  }
  column "enabled" {
    null    = false
    type    = boolean
    default = true
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_696d26426c704fba79b2c195ef5" {
    columns = [column.id]
  }
  foreign_key "FK_b8030b47af9213f1fd15450fb7f" {
    columns     = [column.ownerId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_4c72ebdb265d1775bf61147af0" {
    unique  = true
    columns = [column.ownerId, column.name]
  }
}
table "credential_dependency" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "credentialId" {
    null = false
    type = character_varying(36)
  }
  column "dependencyType" {
    null = false
    type = character_varying(64)
  }
  column "dependencyId" {
    null = false
    type = character_varying(255)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_80212729ed0ffa0709417ab28f4" {
    columns = [column.id]
  }
  foreign_key "FK_5ec8e8c8d3539f3696cf73b43bf" {
    columns     = [column.credentialId]
    ref_columns = [table.credentials_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_5ec8e8c8d3539f3696cf73b43b" {
    columns = [column.credentialId]
  }
  index "IDX_91ee85fa9619dd6776725e117b" {
    columns = [column.dependencyType, column.dependencyId]
  }
  index "IDX_credential_dependency_credentialId_dependencyType_dependenc" {
    unique  = true
    columns = [column.credentialId, column.dependencyType, column.dependencyId]
  }
}
table "credentials_entity" {
  schema = schema.public
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "data" {
    null = false
    type = text
  }
  column "type" {
    null = false
    type = character_varying(128)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "isManaged" {
    null    = false
    type    = boolean
    default = false
  }
  column "isGlobal" {
    null    = false
    type    = boolean
    default = false
  }
  column "isResolvable" {
    null    = false
    type    = boolean
    default = false
  }
  column "resolvableAllowFallback" {
    null    = false
    type    = boolean
    default = false
  }
  column "resolverId" {
    null = true
    type = character_varying(16)
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "credentials_entity_resolverId_foreign" {
    columns     = [column.resolverId]
    ref_columns = [table.dynamic_credential_resolver.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "idx_07fde106c0b471d8cc80a64fc8" {
    columns = [column.type]
  }
  index "pk_credentials_entity_id" {
    unique  = true
    columns = [column.id]
  }
}
table "data_table" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "projectId" {
    null = false
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_e226d0001b9e6097cbfe70617cb" {
    columns = [column.id]
  }
  foreign_key "FK_c2a794257dee48af7c9abf681de" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  unique "UQ_b23096ef747281ac944d28e8b0d" {
    columns = [column.projectId, column.name]
  }
}
table "data_table_column" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "type" {
    null    = false
    type    = character_varying(32)
    comment = "Expected: string, number, boolean, or date (not enforced as a constraint)"
  }
  column "index" {
    null    = false
    type    = integer
    comment = "Column order, starting from 0 (0 = first column)"
  }
  column "dataTableId" {
    null = false
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_673cb121ee4a8a5e27850c72c51" {
    columns = [column.id]
  }
  foreign_key "FK_930b6e8faaf88294cef23484160" {
    columns     = [column.dataTableId]
    ref_columns = [table.data_table.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  unique "UQ_8082ec4890f892f0bc77473a123" {
    columns = [column.dataTableId, column.name]
  }
}
table "data_table_user_SPGOyAFf0KBfcgp4" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "requestId" {
    null = true
    type = text
  }
  column "jobId" {
    null = true
    type = text
  }
  column "status" {
    null = true
    type = text
  }
  column "payloadJson" {
    null = true
    type = text
  }
  column "resultJson" {
    null = true
    type = text
  }
  column "updatedAtIso" {
    null = true
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_9960a93a33db14782944ee8a19d" {
    columns = [column.id]
  }
}
table "data_table_user_V1zRtKHvsME9BgkO" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "workerId" {
    null = true
    type = text
  }
  column "status" {
    null = true
    type = text
  }
  column "drain" {
    null = true
    type = boolean
  }
  column "activeJobs" {
    null = true
    type = double_precision
  }
  column "maxConcurrentJobs" {
    null = true
    type = double_precision
  }
  column "capacityAvailable" {
    null = true
    type = boolean
  }
  column "supportedMediaTypes" {
    null = true
    type = text
  }
  column "supportedProfiles" {
    null = true
    type = text
  }
  column "comfyReachable" {
    null = true
    type = boolean
  }
  column "artifactStorageEnabled" {
    null = true
    type = boolean
  }
  column "rabbitmqEnabled" {
    null = true
    type = boolean
  }
  column "rabbitmqQueue" {
    null = true
    type = text
  }
  column "heartbeatJson" {
    null = true
    type = text
  }
  column "updatedAtIso" {
    null = true
    type = timestamptz(3)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_1fae78f527bce05f567894db2b3" {
    columns = [column.id]
  }
}
table "deployment_key" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "type" {
    null = false
    type = character_varying(64)
  }
  column "value" {
    null = false
    type = text
  }
  column "algorithm" {
    null = true
    type = character_varying(20)
  }
  column "status" {
    null = false
    type = character_varying(20)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_94bb7aeb5def5a0284a5fe9f9a0" {
    columns = [column.id]
  }
  index "IDX_deployment_key_data_encryption_active" {
    unique  = true
    columns = [column.type]
    where   = "(((status)::text = 'active'::text) AND ((type)::text = 'data_encryption'::text))"
  }
  index "IDX_deployment_key_instance_id_active" {
    unique  = true
    columns = [column.type]
    where   = "(((status)::text = 'active'::text) AND ((type)::text = 'instance.id'::text))"
  }
  index "IDX_deployment_key_jwe_private_key_active" {
    unique  = true
    columns = [column.type, column.algorithm]
    where   = "(((status)::text = 'active'::text) AND ((type)::text = 'jwe.private-key'::text))"
  }
  index "IDX_deployment_key_signing_binary_data_active" {
    unique  = true
    columns = [column.type]
    where   = "(((status)::text = 'active'::text) AND ((type)::text = 'signing.binary_data'::text))"
  }
  index "IDX_deployment_key_signing_hmac_active" {
    unique  = true
    columns = [column.type]
    where   = "(((status)::text = 'active'::text) AND ((type)::text = 'signing.hmac'::text))"
  }
  index "IDX_deployment_key_signing_jwt_active" {
    unique  = true
    columns = [column.type]
    where   = "(((status)::text = 'active'::text) AND ((type)::text = 'signing.jwt'::text))"
  }
}
table "dynamic_credential_entry" {
  schema = schema.public
  column "credential_id" {
    null = false
    type = character_varying(16)
  }
  column "subject_id" {
    null = false
    type = character_varying(2048)
  }
  column "resolver_id" {
    null = false
    type = character_varying(16)
  }
  column "data" {
    null = false
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_5135ffcabecad4727ff6b9b803d" {
    columns = [column.credential_id, column.subject_id, column.resolver_id]
  }
  foreign_key "FK_a6d1dd080958304a47a02952aab" {
    columns     = [column.credential_id]
    ref_columns = [table.credentials_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_d61a12235d268a49af6a3c09c13" {
    columns     = [column.resolver_id]
    ref_columns = [table.dynamic_credential_resolver.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_62476b94b56d9dc7ed9ed75d3d" {
    columns = [column.subject_id]
  }
  index "IDX_d61a12235d268a49af6a3c09c1" {
    columns = [column.resolver_id]
  }
}
table "dynamic_credential_resolver" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(16)
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "type" {
    null = false
    type = character_varying(128)
  }
  column "config" {
    null    = false
    type    = text
    comment = "Encrypted resolver configuration (JSON encrypted as string)"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_b76cfb088dcdaf5275e9980bb64" {
    columns = [column.id]
  }
  index "IDX_9c9ee9df586e60bb723234e499" {
    columns = [column.type]
  }
}
table "dynamic_credential_user_entry" {
  schema = schema.public
  column "credentialId" {
    null = false
    type = character_varying(16)
  }
  column "userId" {
    null = false
    type = uuid
  }
  column "resolverId" {
    null = false
    type = character_varying(16)
  }
  column "data" {
    null = false
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_74f548e633abc66dc27c8f0ca77" {
    columns = [column.credentialId, column.userId, column.resolverId]
  }
  foreign_key "FK_6edec973a6450990977bb854c38" {
    columns     = [column.resolverId]
    ref_columns = [table.dynamic_credential_resolver.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_945ba70b342a066d1306b12ccd2" {
    columns     = [column.credentialId]
    ref_columns = [table.credentials_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_a36dc616fabc3f736bb82410a22" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_6edec973a6450990977bb854c3" {
    columns = [column.resolverId]
  }
  index "IDX_a36dc616fabc3f736bb82410a2" {
    columns = [column.userId]
  }
}
table "evaluation_collection" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "description" {
    null = true
    type = text
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "evaluationConfigId" {
    null = false
    type = character_varying(36)
  }
  column "createdById" {
    null = true
    type = uuid
  }
  column "insightsCache" {
    null = true
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_e720b6efc1e45b878ebb0b2ca30" {
    columns = [column.id]
  }
  foreign_key "FK_a48ce930c3bc7604894b8f0eaad" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_d634a0c93fd7de68a87eab951b2" {
    columns     = [column.evaluationConfigId]
    ref_columns = [table.evaluation_config.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_f4561f38b5a22a4f090d5cd3eae" {
    columns     = [column.createdById]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "IDX_a48ce930c3bc7604894b8f0eaa" {
    columns = [column.workflowId]
  }
  index "IDX_d634a0c93fd7de68a87eab951b" {
    columns = [column.evaluationConfigId]
  }
}
table "evaluation_config" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "status" {
    null    = false
    type    = character_varying(16)
    default = "valid"
  }
  column "invalidReason" {
    null = true
    type = character_varying(64)
  }
  column "datasetSource" {
    null = false
    type = character_varying(32)
  }
  column "datasetRef" {
    null = false
    type = json
  }
  column "startNodeName" {
    null = false
    type = character_varying(255)
  }
  column "endNodeName" {
    null = false
    type = character_varying(255)
  }
  column "metrics" {
    null = false
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_59c14dccf8989df94070c2dcfda" {
    columns = [column.id]
  }
  foreign_key "FK_fd7542bb123074760285dc1bbf3" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_fd7542bb123074760285dc1bbf" {
    columns = [column.workflowId]
  }
  unique "UQ_3c3c99a712e971835c52292e44c" {
    columns = [column.workflowId, column.name]
  }
}
table "event_destinations" {
  schema = schema.public
  column "id" {
    null = false
    type = uuid
  }
  column "destination" {
    null = false
    type = jsonb
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key {
    columns = [column.id]
  }
}
table "execution_annotation_tags" {
  schema = schema.public
  column "annotationId" {
    null = false
    type = integer
  }
  column "tagId" {
    null = false
    type = character_varying(24)
  }
  primary_key "PK_979ec03d31294cca484be65d11f" {
    columns = [column.annotationId, column.tagId]
  }
  foreign_key "FK_a3697779b366e131b2bbdae2976" {
    columns     = [column.tagId]
    ref_columns = [table.annotation_tag_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_c1519757391996eb06064f0e7c8" {
    columns     = [column.annotationId]
    ref_columns = [table.execution_annotations.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_a3697779b366e131b2bbdae297" {
    columns = [column.tagId]
  }
  index "IDX_c1519757391996eb06064f0e7c" {
    columns = [column.annotationId]
  }
}
table "execution_annotations" {
  schema = schema.public
  column "id" {
    null = false
    type = serial
  }
  column "executionId" {
    null = false
    type = integer
  }
  column "vote" {
    null = true
    type = character_varying(6)
  }
  column "note" {
    null = true
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_7afcf93ffa20c4252869a7c6a23" {
    columns = [column.id]
  }
  foreign_key "FK_97f863fa83c4786f19565084960" {
    columns     = [column.executionId]
    ref_columns = [table.execution_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_97f863fa83c4786f1956508496" {
    unique  = true
    columns = [column.executionId]
  }
}
table "execution_data" {
  schema = schema.public
  column "executionId" {
    null = false
    type = integer
  }
  column "workflowData" {
    null = false
    type = json
  }
  column "data" {
    null = false
    type = text
  }
  column "workflowVersionId" {
    null = true
    type = character_varying(36)
  }
  primary_key {
    columns = [column.executionId]
  }
  foreign_key "execution_data_fk" {
    columns     = [column.executionId]
    ref_columns = [table.execution_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "execution_entity" {
  schema = schema.public
  column "id" {
    null = false
    type = serial
  }
  column "finished" {
    null = false
    type = boolean
  }
  column "mode" {
    null = false
    type = character_varying
  }
  column "retryOf" {
    null = true
    type = character_varying
  }
  column "retrySuccessId" {
    null = true
    type = character_varying
  }
  column "startedAt" {
    null = true
    type = timestamptz(3)
  }
  column "stoppedAt" {
    null = true
    type = timestamptz(3)
  }
  column "waitTill" {
    null = true
    type = timestamptz(3)
  }
  column "status" {
    null = false
    type = character_varying
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "deletedAt" {
    null = true
    type = timestamptz(3)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "storedAt" {
    null    = false
    type    = character_varying(2)
    default = "db"
  }
  column "tracingContext" {
    null = true
    type = json
  }
  column "deduplicationKey" {
    null = true
    type = character_varying(255)
  }
  column "jsonSizeBytes" {
    null    = false
    type    = bigint
    default = 0
    comment = "Byte size of the JSON execution data bundle (run data, workflow snapshot, version id); excludes binary data. 0 means unknown."
  }
  column "workflowVersionId" {
    null    = true
    type    = character_varying(36)
    default = sql("NULL::character varying")
    comment = "Version id of the workflow run by this execution; denormalized from the data bundle."
  }
  primary_key "pk_e3e63bbf986767844bbe1166d4e" {
    columns = [column.id]
  }
  foreign_key "fk_execution_entity_workflow_id" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_execution_entity_deduplicationKey" {
    unique  = true
    columns = [column.deduplicationKey]
    where   = "(\"deduplicationKey\" IS NOT NULL)"
  }
  index "IDX_execution_entity_deletedAt" {
    columns = [column.deletedAt]
  }
  index "IDX_execution_entity_workflowId_status_id" {
    columns = [column.workflowId, column.status, column.id]
    where   = "(\"deletedAt\" IS NULL)"
  }
  index "idx_execution_entity_stopped_at_status_deleted_at" {
    columns = [column.stoppedAt, column.status, column.deletedAt]
    where   = "((\"stoppedAt\" IS NOT NULL) AND (\"deletedAt\" IS NULL))"
  }
  index "idx_execution_entity_wait_till_status_deleted_at" {
    columns = [column.waitTill, column.status, column.deletedAt]
    where   = "((\"waitTill\" IS NOT NULL) AND (\"deletedAt\" IS NULL))"
  }
  index "idx_execution_entity_workflow_id_started_at" {
    columns = [column.workflowId, column.startedAt]
    where   = "((\"startedAt\" IS NOT NULL) AND (\"deletedAt\" IS NULL))"
  }
  check "execution_entity_storedAt_check" {
    expr = "((\"storedAt\")::text = ANY (ARRAY[('db'::character varying)::text, ('fs'::character varying)::text, ('s3'::character varying)::text]))"
  }
}
table "execution_metadata" {
  schema = schema.public
  column "id" {
    null = false
    type = serial
  }
  column "executionId" {
    null = false
    type = integer
  }
  column "key" {
    null = false
    type = character_varying(255)
  }
  column "value" {
    null = false
    type = text
  }
  primary_key "PK_17a0b6284f8d626aae88e1c16e4" {
    columns = [column.id]
  }
  foreign_key "FK_31d0b4c93fb85ced26f6005cda3" {
    columns     = [column.executionId]
    ref_columns = [table.execution_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_cec8eea3bf49551482ccb4933e" {
    unique  = true
    columns = [column.executionId, column.key]
  }
}
table "folder" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "parentFolderId" {
    null = true
    type = character_varying(36)
  }
  column "projectId" {
    null = false
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_6278a41a706740c94c02e288df8" {
    columns = [column.id]
  }
  foreign_key "FK_804ea52f6729e3940498bd54d78" {
    columns     = [column.parentFolderId]
    ref_columns = [table.folder.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_a8260b0b36939c6247f385b8221" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_14f68deffaf858465715995508" {
    unique  = true
    columns = [column.projectId, column.id]
  }
}
table "folder_tag" {
  schema = schema.public
  column "folderId" {
    null = false
    type = character_varying(36)
  }
  column "tagId" {
    null = false
    type = character_varying(36)
  }
  primary_key "PK_27e4e00852f6b06a925a4d83a3e" {
    columns = [column.folderId, column.tagId]
  }
  foreign_key "FK_94a60854e06f2897b2e0d39edba" {
    columns     = [column.folderId]
    ref_columns = [table.folder.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_dc88164176283de80af47621746" {
    columns     = [column.tagId]
    ref_columns = [table.tag_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "insights_by_period" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "metaId" {
    null = false
    type = integer
  }
  column "type" {
    null    = false
    type    = integer
    comment = "0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure"
  }
  column "value" {
    null = false
    type = bigint
  }
  column "periodUnit" {
    null    = false
    type    = integer
    comment = "0: hour, 1: day, 2: week"
  }
  column "periodStart" {
    null    = true
    type    = timestamptz(0)
    default = sql("CURRENT_TIMESTAMP")
  }
  primary_key "PK_b606942249b90cc39b0265f0575" {
    columns = [column.id]
  }
  foreign_key "FK_6414cfed98daabbfdd61a1cfbc0" {
    columns     = [column.metaId]
    ref_columns = [table.insights_metadata.column.metaId]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_60b6a84299eeb3f671dfec7693" {
    unique  = true
    columns = [column.periodStart, column.type, column.periodUnit, column.metaId]
  }
}
table "insights_metadata" {
  schema = schema.public
  column "metaId" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "workflowId" {
    null = true
    type = character_varying(36)
  }
  column "projectId" {
    null = true
    type = character_varying(36)
  }
  column "workflowName" {
    null = false
    type = character_varying(128)
  }
  column "projectName" {
    null = false
    type = character_varying(255)
  }
  primary_key "PK_f448a94c35218b6208ce20cf5a1" {
    columns = [column.metaId]
  }
  foreign_key "FK_1d8ab99d5861c9388d2dc1cf733" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_2375a1eda085adb16b24615b69c" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "IDX_1d8ab99d5861c9388d2dc1cf73" {
    unique  = true
    columns = [column.workflowId]
  }
}
table "insights_raw" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "metaId" {
    null = false
    type = integer
  }
  column "type" {
    null    = false
    type    = integer
    comment = "0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure"
  }
  column "value" {
    null = false
    type = bigint
  }
  column "timestamp" {
    null    = false
    type    = timestamptz(0)
    default = sql("CURRENT_TIMESTAMP")
  }
  primary_key "PK_ec15125755151e3a7e00e00014f" {
    columns = [column.id]
  }
  foreign_key "FK_6e2e33741adef2a7c5d66befa4e" {
    columns     = [column.metaId]
    ref_columns = [table.insights_metadata.column.metaId]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_insights_raw_timestamp_id" {
    columns = [column.timestamp, column.id]
  }
}
table "installed_nodes" {
  schema = schema.public
  column "name" {
    null = false
    type = character_varying(200)
  }
  column "type" {
    null = false
    type = character_varying(200)
  }
  column "latestVersion" {
    null    = false
    type    = integer
    default = 1
  }
  column "package" {
    null = false
    type = character_varying(241)
  }
  primary_key "PK_8ebd28194e4f792f96b5933423fc439df97d9689" {
    columns = [column.name]
  }
  foreign_key "FK_73f857fc5dce682cef8a99c11dbddbc969618951" {
    columns     = [column.package]
    ref_columns = [table.installed_packages.column.packageName]
    on_update   = CASCADE
    on_delete   = CASCADE
  }
}
table "installed_packages" {
  schema = schema.public
  column "packageName" {
    null = false
    type = character_varying(214)
  }
  column "installedVersion" {
    null = false
    type = character_varying(50)
  }
  column "authorName" {
    null = true
    type = character_varying(70)
  }
  column "authorEmail" {
    null = true
    type = character_varying(70)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_08cc9197c39b028c1e9beca225940576fd1a5804" {
    columns = [column.packageName]
  }
}
table "instance_ai_checkpoints" {
  schema = schema.public
  column "key" {
    null    = false
    type    = character_varying(255)
    comment = "Opaque checkpoint key from the agent runtime."
  }
  column "runId" {
    null    = true
    type    = character_varying(255)
    comment = "Run ID parsed from the checkpoint key when available."
  }
  column "threadId" {
    null    = false
    type    = uuid
    comment = "Instance AI thread that owns the checkpoint."
  }
  column "resourceId" {
    null    = true
    type    = character_varying(255)
    comment = "Resource ID recorded by the agent runtime."
  }
  column "state" {
    null    = true
    type    = json
    comment = "Serializable agent state snapshot stored as JSON."
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "expiredAt" {
    null    = true
    type    = timestamptz(3)
    comment = "Soft-delete timestamp: null means live; non-null marks the row as a tombstone."
  }
  primary_key "PK_5315a45f0846d1f9d128c18a2ed" {
    columns = [column.key]
  }
  foreign_key "FK_2b23f3f24a70bebb990203b011e" {
    columns     = [column.threadId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_2b23f3f24a70bebb990203b011" {
    columns = [column.threadId]
  }
  index "IDX_768189b506cc26c4fe878b87cb" {
    columns = [column.runId]
  }
  index "IDX_be9d0eca0b19fb93d4eb74b327" {
    columns = [column.resourceId]
  }
  check "instance_ai_checkpoints_state_tombstone_check" {
    expr = "(((\"expiredAt\" IS NOT NULL) AND (state IS NULL)) OR (\"expiredAt\" IS NULL))"
  }
}
table "instance_ai_iteration_logs" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "threadId" {
    null = false
    type = uuid
  }
  column "taskKey" {
    null = false
    type = character_varying
  }
  column "entry" {
    null = false
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_21c2b214b44bc6c34a6d3551c90" {
    columns = [column.id]
  }
  foreign_key "FK_8bfcc6c51fd3d69b1eae8aebd49" {
    columns     = [column.threadId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_02751202c9a2ad75f2d8e14f5e" {
    columns = [column.threadId, column.taskKey, column.createdAt]
  }
}
table "instance_ai_mcp_registry_connections" {
  schema = schema.public
  column "id" {
    null = false
    type = uuid
  }
  column "credentialId" {
    null = false
    type = character_varying(36)
  }
  column "serverSlug" {
    null = false
    type = character_varying(255)
  }
  column "toolFilter" {
    null    = true
    type    = json
    comment = "Optional MCP tool filter per registry connection: { mode: \"allow\" | \"exclude\", tools: string[] }"
  }
  column "userId" {
    null = false
    type = uuid
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_e34e4d15d78eabbe8217e33ef03" {
    columns = [column.id]
  }
  foreign_key "FK_1d25707354d2012da256eb2ec0a" {
    columns     = [column.serverSlug]
    ref_columns = [table.mcp_registry_server.column.slug]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_1e826120e7e53ebc4681f026de8" {
    columns     = [column.credentialId]
    ref_columns = [table.credentials_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_8b42c08a531d76410980c639a5b" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_16db3adb7b19df1ee55ff06b27" {
    unique  = true
    columns = [column.userId, column.serverSlug, column.credentialId]
  }
}
table "instance_ai_messages" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "threadId" {
    null = false
    type = uuid
  }
  column "content" {
    null = false
    type = text
  }
  column "role" {
    null = false
    type = character_varying(16)
  }
  column "type" {
    null = true
    type = character_varying(32)
  }
  column "resourceId" {
    null = true
    type = character_varying(255)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_156c6f287225e9befe0181bb02b" {
    columns = [column.id]
  }
  foreign_key "FK_1eeb64cb9d66a927988de759e6e" {
    columns     = [column.threadId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_1eeb64cb9d66a927988de759e6" {
    columns = [column.threadId]
  }
  index "IDX_76e212c6867fbaa06bf0decd6f" {
    columns = [column.resourceId]
  }
}
table "instance_ai_observation_cursors" {
  schema = schema.public
  column "observationScopeId" {
    null    = false
    type    = uuid
    comment = "instance_ai_threads.id source stream checkpointed by this cursor"
  }
  column "lastObservedMessageId" {
    null = false
    type = character_varying(36)
  }
  column "lastObservedAt" {
    null = false
    type = timestamptz(3)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_5b6319b2e9a37c1064a72428f9a" {
    columns = [column.observationScopeId]
  }
  foreign_key "FK_5b6319b2e9a37c1064a72428f9a" {
    columns     = [column.observationScopeId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "instance_ai_observation_locks" {
  schema = schema.public
  column "observationScopeId" {
    null    = false
    type    = uuid
    comment = "instance_ai_threads.id source stream locked for observation tasks"
  }
  column "taskKind" {
    null = false
    type = character_varying(20)
  }
  column "holderId" {
    null    = false
    type    = character_varying(64)
    comment = "Ephemeral background-task lock owner token, not a user ID"
  }
  column "heldUntil" {
    null = false
    type = timestamptz(3)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_fc491dd378b9448655c3c683f85" {
    columns = [column.observationScopeId, column.taskKind]
  }
  foreign_key "FK_103e2e5f454860b28ea05a82c74" {
    columns     = [column.observationScopeId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  check "CHK_instance_ai_observation_locks_taskKind" {
    expr = "((\"taskKind\")::text = ANY (ARRAY[('observer'::character varying)::text, ('reflector'::character varying)::text]))"
  }
}
table "instance_ai_observational_memory" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "lookupKey" {
    null = false
    type = character_varying(255)
  }
  column "scope" {
    null = false
    type = character_varying(16)
  }
  column "threadId" {
    null = true
    type = uuid
  }
  column "resourceId" {
    null = false
    type = character_varying(255)
  }
  column "activeObservations" {
    null    = false
    type    = text
    default = ""
  }
  column "originType" {
    null = false
    type = character_varying(32)
  }
  column "config" {
    null = false
    type = text
  }
  column "generationCount" {
    null    = false
    type    = integer
    default = 0
  }
  column "lastObservedAt" {
    null = true
    type = timestamptz(3)
  }
  column "pendingMessageTokens" {
    null    = false
    type    = integer
    default = 0
  }
  column "totalTokensObserved" {
    null    = false
    type    = integer
    default = 0
  }
  column "observationTokenCount" {
    null    = false
    type    = integer
    default = 0
  }
  column "isObserving" {
    null    = false
    type    = boolean
    default = false
  }
  column "isReflecting" {
    null    = false
    type    = boolean
    default = false
  }
  column "observedMessageIds" {
    null = true
    type = json
  }
  column "observedTimezone" {
    null = true
    type = character_varying
  }
  column "bufferedObservations" {
    null = true
    type = text
  }
  column "bufferedObservationTokens" {
    null = true
    type = integer
  }
  column "bufferedMessageIds" {
    null = true
    type = json
  }
  column "bufferedReflection" {
    null = true
    type = text
  }
  column "bufferedReflectionTokens" {
    null = true
    type = integer
  }
  column "bufferedReflectionInputTokens" {
    null = true
    type = integer
  }
  column "reflectedObservationLineCount" {
    null = true
    type = integer
  }
  column "bufferedObservationChunks" {
    null = true
    type = json
  }
  column "isBufferingObservation" {
    null    = false
    type    = boolean
    default = false
  }
  column "isBufferingReflection" {
    null    = false
    type    = boolean
    default = false
  }
  column "lastBufferedAtTokens" {
    null    = false
    type    = integer
    default = 0
  }
  column "lastBufferedAtTime" {
    null = true
    type = timestamptz(3)
  }
  column "metadata" {
    null = true
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_7192dd00cddba039bf1d3e6a098" {
    columns = [column.id]
  }
  foreign_key "FK_34018c303885cd37093458e6409" {
    columns     = [column.threadId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "IDX_92f13cb6bc694227e069447f7b" {
    columns = [column.lookupKey]
  }
  index "IDX_a680ac96aae02dc887bbaac512" {
    unique  = true
    columns = [column.scope, column.threadId, column.resourceId]
  }
}
table "instance_ai_observations" {
  schema = schema.public
  column "id" {
    null    = false
    type    = character_varying(36)
    comment = "Application-generated n8n string ID, not a database UUID"
  }
  column "observationScopeId" {
    null    = false
    type    = uuid
    comment = "instance_ai_threads.id source stream for this observation log"
  }
  column "marker" {
    null = false
    type = character_varying(16)
  }
  column "text" {
    null = false
    type = text
  }
  column "parentId" {
    null = true
    type = character_varying(36)
  }
  column "tokenCount" {
    null    = false
    type    = integer
    default = 0
  }
  column "status" {
    null = false
    type = character_varying(16)
  }
  column "supersededBy" {
    null = true
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_4d9b514cdf0f0b577650caf2ac2" {
    columns = [column.id]
  }
  foreign_key "FK_a80e0ee839a2f10ba4b86e19998" {
    columns     = [column.supersededBy]
    ref_columns = [table.instance_ai_observations.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "FK_d54fc84a6c8ac91b5e0db0378a4" {
    columns     = [column.observationScopeId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_daef2195a4a846eb70eed15e039" {
    columns     = [column.parentId]
    ref_columns = [table.instance_ai_observations.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "IDX_0d5db648188d338df7fb2a8064" {
    columns = [column.observationScopeId, column.status, column.createdAt, column.id]
  }
  index "IDX_a80e0ee839a2f10ba4b86e1999" {
    columns = [column.supersededBy]
  }
  index "IDX_daef2195a4a846eb70eed15e03" {
    columns = [column.parentId]
  }
  check "CHK_instance_ai_observations_marker" {
    expr = "((marker)::text = ANY (ARRAY[('critical'::character varying)::text, ('important'::character varying)::text, ('info'::character varying)::text, ('completion'::character varying)::text]))"
  }
  check "CHK_instance_ai_observations_status" {
    expr = "((status)::text = ANY (ARRAY[('active'::character varying)::text, ('superseded'::character varying)::text, ('dropped'::character varying)::text]))"
  }
}
table "instance_ai_pending_confirmations" {
  schema = schema.public
  column "requestId" {
    null    = false
    type    = character_varying(36)
    comment = "HITL confirmation request identifier."
  }
  column "threadId" {
    null    = false
    type    = uuid
    comment = "Instance AI thread that owns the confirmation."
  }
  column "userId" {
    null    = false
    type    = uuid
    comment = "User who is expected to confirm or cancel."
  }
  column "kind" {
    null    = false
    type    = character_varying(16)
    comment = "'suspended' (resumable from checkpoint) or 'inline' (orchestrator-held Promise)."
  }
  column "runId" {
    null    = false
    type    = character_varying(36)
    comment = "External run ID; reused on resume for SSE correlation."
  }
  column "toolCallId" {
    null    = true
    type    = character_varying(64)
    comment = "Suspended tool call awaiting confirmation."
  }
  column "messageGroupId" {
    null    = true
    type    = character_varying(36)
    comment = "SSE event correlation group."
  }
  column "checkpointKey" {
    null    = true
    type    = character_varying(255)
    comment = "FK to instance_ai_checkpoints.key; also the SDK runId used to resume."
  }
  column "checkpointTaskId" {
    null    = true
    type    = character_varying(36)
    comment = "Set when the suspended run was a planned-task checkpoint follow-up."
  }
  column "expiresAt" {
    null    = true
    type    = timestamptz(3)
    comment = "TTL for the leader-only sweep; null disables auto-expiry."
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_25c38179c8d45095b168adfff80" {
    columns = [column.requestId]
  }
  foreign_key "FK_0babdf6e3b897a86fe4678355eb" {
    columns     = [column.checkpointKey]
    ref_columns = [table.instance_ai_checkpoints.column.key]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_ba67ee8dc311830a2eea89b6e96" {
    columns     = [column.threadId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_df5fd25c8bbfd2b042602600d8e" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_0babdf6e3b897a86fe4678355e" {
    columns = [column.checkpointKey]
  }
  index "IDX_ba67ee8dc311830a2eea89b6e9" {
    columns = [column.threadId]
  }
  index "IDX_d7a4aba7440449865e2b924377" {
    columns = [column.expiresAt]
  }
  index "IDX_df5fd25c8bbfd2b042602600d8" {
    columns = [column.userId]
  }
  check "CHK_instance_ai_pending_confirmations_kind" {
    expr = "((kind)::text = ANY (ARRAY[('suspended'::character varying)::text, ('inline'::character varying)::text]))"
  }
}
table "instance_ai_resources" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(255)
  }
  column "workingMemory" {
    null = true
    type = text
  }
  column "metadata" {
    null = true
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_45b5b0b6f715dae4292b86603d8" {
    columns = [column.id]
  }
}
table "instance_ai_run_snapshots" {
  schema = schema.public
  column "threadId" {
    null = false
    type = uuid
  }
  column "runId" {
    null = false
    type = character_varying(36)
  }
  column "messageGroupId" {
    null = true
    type = character_varying(36)
  }
  column "runIds" {
    null = true
    type = json
  }
  column "tree" {
    null = false
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "langsmithRunId" {
    null    = true
    type    = character_varying(36)
    comment = "LangSmith run ID (UUID v4, e.g. \"f47ac10b-58cc-4372-a567-0e02b2c3d479\")."
  }
  column "langsmithTraceId" {
    null    = true
    type    = character_varying(36)
    comment = "LangSmith trace ID (UUID v4, e.g. \"f47ac10b-58cc-4372-a567-0e02b2c3d479\")."
  }
  column "traceId" {
    null    = true
    type    = character_varying(64)
    comment = "OpenTelemetry trace ID for the root Instance AI run."
  }
  column "spanId" {
    null    = true
    type    = character_varying(64)
    comment = "OpenTelemetry span ID for the root Instance AI run."
  }
  primary_key "PK_0a5fc9690a84950ebf1416fb146" {
    columns = [column.threadId, column.runId]
  }
  foreign_key "FK_2f63fa21d09d7918f347ddbdf70" {
    columns     = [column.threadId]
    ref_columns = [table.instance_ai_threads.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_d3a2bc880e7a8626802e5474ad" {
    columns = [column.threadId, column.createdAt]
  }
  index "IDX_d926c16c2ad9728cb9a81790c0" {
    columns = [column.threadId, column.messageGroupId]
  }
}
table "instance_ai_threads" {
  schema = schema.public
  column "id" {
    null = false
    type = uuid
  }
  column "resourceId" {
    null = false
    type = character_varying(255)
  }
  column "title" {
    null    = false
    type    = text
    default = ""
  }
  column "metadata" {
    null = true
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "projectId" {
    null    = false
    type    = character_varying(36)
    comment = "Project this thread is scoped to"
  }
  primary_key "PK_35575100e45cdedeb89ae0643e9" {
    columns = [column.id]
  }
  foreign_key "FK_instance_ai_threads_projectId" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_f36dea4d38fe92e0e8f44d5a56" {
    columns = [column.resourceId]
  }
  index "IDX_instance_ai_threads_projectId" {
    columns = [column.projectId]
  }
}
table "instance_ai_workflow_snapshots" {
  schema = schema.public
  column "runId" {
    null = false
    type = character_varying(36)
  }
  column "workflowName" {
    null = false
    type = character_varying(255)
  }
  column "resourceId" {
    null = true
    type = character_varying(255)
  }
  column "status" {
    null = true
    type = character_varying
  }
  column "snapshot" {
    null = false
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_93f2696eb321dfe1d7defe7073f" {
    columns = [column.runId, column.workflowName]
  }
  index "IDX_a371ee6b8e0ebb5635f8baa46d" {
    columns = [column.workflowName, column.status]
  }
}
table "instance_version_history" {
  schema = schema.public
  column "id" {
    null = false
    type = serial
  }
  column "major" {
    null = false
    type = integer
  }
  column "minor" {
    null = false
    type = integer
  }
  column "patch" {
    null = false
    type = integer
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_874f58cb616935bf49d9dbd67e9" {
    columns = [column.id]
  }
}
table "invalid_auth_token" {
  schema = schema.public
  column "token" {
    null = false
    type = character_varying(512)
  }
  column "expiresAt" {
    null = false
    type = timestamptz(3)
  }
  primary_key "PK_5779069b7235b256d91f7af1a15" {
    columns = [column.token]
  }
}
table "mcp_registry_server" {
  schema = schema.public
  column "slug" {
    null = false
    type = character_varying(255)
  }
  column "status" {
    null    = false
    type    = character_varying(50)
    comment = "Server status in the MCP registry. Deprecated servers are not surfaced to users."
  }
  column "version" {
    null = false
    type = character_varying(50)
  }
  column "registryUpdatedAt" {
    null = false
    type = timestamp(3)
  }
  column "data" {
    null    = false
    type    = json
    default = "{}"
    comment = "JSON object containing server metadata (icons, remotes, tools, etc.)"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_12fd89a1fb8489513b0a91f5d31" {
    columns = [column.slug]
  }
  check "CHK_tmp_mcp_registry_server_status" {
    expr = "((status)::text = ANY ((ARRAY['active'::character varying, 'deprecated'::character varying])::text[]))"
  }
}
table "migrations" {
  schema = schema.public
  column "id" {
    null = false
    type = serial
  }
  column "timestamp" {
    null = false
    type = bigint
  }
  column "name" {
    null = false
    type = character_varying
  }
  primary_key "PK_8c82d7f526340ab734260ea46be" {
    columns = [column.id]
  }
}
table "oauth_access_tokens" {
  schema = schema.public
  column "token" {
    null = false
    type = character_varying
  }
  column "clientId" {
    null = false
    type = character_varying
  }
  column "userId" {
    null = false
    type = uuid
  }
  primary_key "PK_dcd71f96a5d5f4bf79e67d322bf" {
    columns = [column.token]
  }
  foreign_key "FK_7234a36d8e49a1fa85095328845" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_78b26968132b7e5e45b75876481" {
    columns     = [column.clientId]
    ref_columns = [table.oauth_clients.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "oauth_authorization_codes" {
  schema = schema.public
  column "code" {
    null = false
    type = character_varying(255)
  }
  column "clientId" {
    null = false
    type = character_varying
  }
  column "userId" {
    null = false
    type = uuid
  }
  column "redirectUri" {
    null = false
    type = character_varying
  }
  column "codeChallenge" {
    null = false
    type = character_varying
  }
  column "codeChallengeMethod" {
    null = false
    type = character_varying(255)
  }
  column "expiresAt" {
    null    = false
    type    = bigint
    comment = "Unix timestamp in milliseconds"
  }
  column "state" {
    null = true
    type = character_varying
  }
  column "used" {
    null    = false
    type    = boolean
    default = false
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "resource" {
    null    = true
    type    = character_varying
    comment = "RFC 8707 resource indicator URI (e.g. https://n8n.example.com/mcp-server/http). NULL = legacy flow predating resource indicator support; defaults to the instance canonical MCP resource URL."
  }
  column "scope" {
    null    = false
    type    = json
    default = "[\"tool:listWorkflows\",\"tool:getWorkflowDetails\"]"
    comment = "OAuth scopes granted for this authorization code"
  }
  primary_key "PK_fb91ab932cfbd694061501cc20f" {
    columns = [column.code]
  }
  foreign_key "FK_64d965bd072ea24fb6da55468cd" {
    columns     = [column.clientId]
    ref_columns = [table.oauth_clients.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_aa8d3560484944c19bdf79ffa16" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "oauth_clients" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying
  }
  column "name" {
    null = false
    type = character_varying(255)
  }
  column "redirectUris" {
    null = false
    type = json
  }
  column "grantTypes" {
    null = false
    type = json
  }
  column "clientSecret" {
    null = true
    type = character_varying(255)
  }
  column "clientSecretExpiresAt" {
    null = true
    type = bigint
  }
  column "tokenEndpointAuthMethod" {
    null    = false
    type    = character_varying(255)
    default = "none"
    comment = "Possible values: none, client_secret_basic or client_secret_post"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_c4759172d3431bae6f04e678e0d" {
    columns = [column.id]
  }
}
table "oauth_refresh_tokens" {
  schema = schema.public
  column "token" {
    null = false
    type = character_varying(255)
  }
  column "clientId" {
    null = false
    type = character_varying
  }
  column "userId" {
    null = false
    type = uuid
  }
  column "expiresAt" {
    null    = false
    type    = bigint
    comment = "Unix timestamp in milliseconds"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "scope" {
    null    = false
    type    = json
    default = "[\"tool:listWorkflows\",\"tool:getWorkflowDetails\"]"
    comment = "OAuth scopes granted for this refresh token"
  }
  primary_key "PK_74abaed0b30711b6532598b0392" {
    columns = [column.token]
  }
  foreign_key "FK_a699f3ed9fd0c1b19bc2608ac53" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_b388696ce4d8be7ffbe8d3e4b69" {
    columns     = [column.clientId]
    ref_columns = [table.oauth_clients.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "oauth_user_consents" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "userId" {
    null = false
    type = uuid
  }
  column "clientId" {
    null = false
    type = character_varying
  }
  column "grantedAt" {
    null    = false
    type    = bigint
    comment = "Unix timestamp in milliseconds"
  }
  primary_key "PK_85b9ada746802c8993103470f05" {
    columns = [column.id]
  }
  foreign_key "FK_21e6c3c2d78a097478fae6aaefa" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_a651acea2f6c97f8c4514935486" {
    columns     = [column.clientId]
    ref_columns = [table.oauth_clients.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  unique "UQ_083721d99ce8db4033e2958ebb4" {
    columns = [column.userId, column.clientId]
  }
}
table "processed_data" {
  schema = schema.public
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "context" {
    null = false
    type = character_varying(255)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "value" {
    null = false
    type = text
  }
  primary_key "PK_ca04b9d8dc72de268fe07a65773" {
    columns = [column.workflowId, column.context]
  }
  foreign_key "FK_06a69a7032c97a763c2c7599464" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "project" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "name" {
    null = false
    type = character_varying(255)
  }
  column "type" {
    null = false
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "icon" {
    null = true
    type = json
  }
  column "description" {
    null = true
    type = character_varying(512)
  }
  column "creatorId" {
    null    = true
    type    = uuid
    comment = "ID of the user who created the project"
  }
  column "customTelemetryTags" {
    null    = false
    type    = json
    default = "[]"
  }
  primary_key "PK_4d68b1358bb5b766d3e78f32f57" {
    columns = [column.id]
  }
  foreign_key "projects_creatorId_foreign" {
    columns     = [column.creatorId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
}
table "project_relation" {
  schema = schema.public
  column "projectId" {
    null = false
    type = character_varying(36)
  }
  column "userId" {
    null = false
    type = uuid
  }
  column "role" {
    null = false
    type = character_varying
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_1caaa312a5d7184a003be0f0cb6" {
    columns = [column.projectId, column.userId]
  }
  foreign_key "FK_5f0643f6717905a05164090dde7" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_61448d56d61802b5dfde5cdb002" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_c6b99592dc96b0d836d7a21db91" {
    columns     = [column.role]
    ref_columns = [table.role.column.slug]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "IDX_5f0643f6717905a05164090dde" {
    columns = [column.userId]
  }
  index "IDX_61448d56d61802b5dfde5cdb00" {
    columns = [column.projectId]
  }
  index "project_relation_role_idx" {
    columns = [column.role]
  }
  index "project_relation_role_project_idx" {
    columns = [column.projectId, column.role]
  }
}
table "project_secrets_provider_access" {
  schema = schema.public
  column "secretsProviderConnectionId" {
    null = false
    type = integer
  }
  column "projectId" {
    null = false
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "role" {
    null    = false
    type    = character_varying(128)
    default = "secretsProviderConnection:user"
  }
  primary_key "PK_0402b7fcec5415246656f102f83" {
    columns = [column.secretsProviderConnectionId, column.projectId]
  }
  foreign_key "FK_18e5c27d2524b1638b292904e48" {
    columns     = [column.secretsProviderConnectionId]
    ref_columns = [table.secrets_provider_connection.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_bd264b81209355b543878deedb1" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  check "CHK_project_secrets_provider_access_role" {
    expr = "((role)::text = ANY (ARRAY[('secretsProviderConnection:owner'::character varying)::text, ('secretsProviderConnection:user'::character varying)::text]))"
  }
}
table "role" {
  schema = schema.public
  column "slug" {
    null    = false
    type    = character_varying(128)
    comment = "Unique identifier of the role for example: \"global:owner\""
  }
  column "displayName" {
    null    = true
    type    = text
    comment = "Name used to display in the UI"
  }
  column "description" {
    null    = true
    type    = text
    comment = "Text describing the scope in more detail of users"
  }
  column "roleType" {
    null    = true
    type    = text
    comment = "Type of the role, e.g., global, project, or workflow"
  }
  column "systemRole" {
    null    = false
    type    = boolean
    default = false
    comment = "Indicates if the role is managed by the system and cannot be edited"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_35c9b140caaf6da09cfabb0d675" {
    columns = [column.slug]
  }
  index "IDX_UniqueRoleDisplayName" {
    unique  = true
    columns = [column.displayName]
  }
}
table "role_mapping_rule" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(16)
  }
  column "expression" {
    null = false
    type = text
  }
  column "role" {
    null = false
    type = character_varying(128)
  }
  column "type" {
    null    = false
    type    = character_varying(64)
    comment = "Expected values: 'instance' (maps to a global role) or 'project' (maps to a project role; projects linked via role_mapping_rule_project)."
  }
  column "order" {
    null = false
    type = integer
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_d772c8ec1a89b52d31c882bc560" {
    columns = [column.id]
  }
  foreign_key "FK_bb66e404c35996b0d6946177501" {
    columns     = [column.role]
    ref_columns = [table.role.column.slug]
    on_update   = CASCADE
    on_delete   = CASCADE
  }
  index "IDX_bb66e404c35996b0d694617750" {
    columns = [column.role]
  }
  unique "UQ_b33ac896ad3099fc8de36fdc1c4" {
    columns = [column.type, column.order]
  }
}
table "role_mapping_rule_project" {
  schema = schema.public
  column "roleMappingRuleId" {
    null = false
    type = character_varying(16)
  }
  column "projectId" {
    null = false
    type = character_varying(36)
  }
  primary_key "PK_198c5b5aea509d139274efcaf9a" {
    columns = [column.roleMappingRuleId, column.projectId]
  }
  foreign_key "FK_35a78869286c65d9330d02b88f5" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_dd7ce4dfa09e95b36a626bd9de3" {
    columns     = [column.roleMappingRuleId]
    ref_columns = [table.role_mapping_rule.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_35a78869286c65d9330d02b88f" {
    columns = [column.projectId]
  }
}
table "role_scope" {
  schema = schema.public
  column "roleSlug" {
    null = false
    type = character_varying(128)
  }
  column "scopeSlug" {
    null = false
    type = character_varying(128)
  }
  primary_key "PK_role_scope" {
    columns = [column.roleSlug, column.scopeSlug]
  }
  foreign_key "FK_role" {
    columns     = [column.roleSlug]
    ref_columns = [table.role.column.slug]
    on_update   = CASCADE
    on_delete   = CASCADE
  }
  foreign_key "FK_scope" {
    columns     = [column.scopeSlug]
    ref_columns = [table.scope.column.slug]
    on_update   = CASCADE
    on_delete   = CASCADE
  }
  index "IDX_role_scope_scopeSlug" {
    columns = [column.scopeSlug]
  }
}
table "scope" {
  schema = schema.public
  column "slug" {
    null    = false
    type    = character_varying(128)
    comment = "Unique identifier of the scope for example: \"project:create\""
  }
  column "displayName" {
    null    = true
    type    = text
    comment = "Name used to display in the UI"
  }
  column "description" {
    null    = true
    type    = text
    comment = "Text describing the scope in more detail of users"
  }
  primary_key "PK_bfc45df0481abd7f355d6187da1" {
    columns = [column.slug]
  }
}
table "secrets_provider_connection" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "providerKey" {
    null = false
    type = character_varying(128)
  }
  column "type" {
    null    = false
    type    = character_varying(36)
    comment = "Type of secrets provider. Possible values: awsSecretsManager, gcpSecretsManager, vault, azureKeyVault, infisical"
  }
  column "encryptedSettings" {
    null = false
    type = text
  }
  column "isEnabled" {
    null    = false
    type    = boolean
    default = false
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_4350ae85e76f9ba7df1370acb5d" {
    columns = [column.id]
  }
  index "IDX_secrets_provider_connection_providerKey" {
    unique  = true
    columns = [column.providerKey]
  }
}
table "settings" {
  schema = schema.public
  column "key" {
    null = false
    type = character_varying(255)
  }
  column "value" {
    null = false
    type = text
  }
  column "loadOnStartup" {
    null    = false
    type    = boolean
    default = false
  }
  primary_key "PK_dc0fe14e6d9943f268e7b119f69ab8bd" {
    columns = [column.key]
  }
}
table "shared_credentials" {
  schema = schema.public
  column "credentialsId" {
    null = false
    type = character_varying(36)
  }
  column "projectId" {
    null = false
    type = character_varying(36)
  }
  column "role" {
    null = false
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_8ef3a59796a228913f251779cff" {
    columns = [column.credentialsId, column.projectId]
  }
  foreign_key "FK_416f66fc846c7c442970c094ccf" {
    columns     = [column.credentialsId]
    ref_columns = [table.credentials_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_812c2852270da1247756e77f5a4" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "shared_workflow" {
  schema = schema.public
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "projectId" {
    null = false
    type = character_varying(36)
  }
  column "role" {
    null = false
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_5ba87620386b847201c9531c58f" {
    columns = [column.workflowId, column.projectId]
  }
  foreign_key "FK_a45ea5f27bcfdc21af9b4188560" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_daa206a04983d47d0a9c34649ce" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_shared_workflow_projectId" {
    columns = [column.projectId]
  }
}
table "tag_entity" {
  schema = schema.public
  column "name" {
    null = false
    type = character_varying(24)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "id" {
    null = false
    type = character_varying(36)
  }
  primary_key {
    columns = [column.id]
  }
  index "idx_812eb05f7451ca757fb98444ce" {
    unique  = true
    columns = [column.name]
  }
  index "pk_tag_entity_id" {
    unique  = true
    columns = [column.id]
  }
}
table "test_case_execution" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "testRunId" {
    null = false
    type = character_varying(36)
  }
  column "executionId" {
    null = true
    type = integer
  }
  column "status" {
    null = false
    type = character_varying
  }
  column "runAt" {
    null = true
    type = timestamptz(3)
  }
  column "completedAt" {
    null = true
    type = timestamptz(3)
  }
  column "errorCode" {
    null = true
    type = character_varying
  }
  column "errorDetails" {
    null = true
    type = json
  }
  column "metrics" {
    null = true
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "inputs" {
    null = true
    type = json
  }
  column "outputs" {
    null = true
    type = json
  }
  column "runIndex" {
    null = true
    type = integer
  }
  primary_key "PK_90c121f77a78a6580e94b794bce" {
    columns = [column.id]
  }
  foreign_key "FK_8e4b4774db42f1e6dda3452b2af" {
    columns     = [column.testRunId]
    ref_columns = [table.test_run.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_e48965fac35d0f5b9e7f51d8c44" {
    columns     = [column.executionId]
    ref_columns = [table.execution_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "IDX_8e4b4774db42f1e6dda3452b2a" {
    columns = [column.testRunId]
  }
}
table "test_run" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "status" {
    null = false
    type = character_varying
  }
  column "errorCode" {
    null = true
    type = character_varying
  }
  column "errorDetails" {
    null = true
    type = json
  }
  column "runAt" {
    null = true
    type = timestamptz(3)
  }
  column "completedAt" {
    null = true
    type = timestamptz(3)
  }
  column "metrics" {
    null = true
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "runningInstanceId" {
    null = true
    type = character_varying(255)
  }
  column "cancelRequested" {
    null    = false
    type    = boolean
    default = false
  }
  column "workflowVersionId" {
    null = true
    type = character_varying(36)
  }
  column "evaluationConfigId" {
    null = true
    type = character_varying(36)
  }
  column "evaluationConfigSnapshot" {
    null = true
    type = jsonb
  }
  column "collectionId" {
    null = true
    type = character_varying(36)
  }
  primary_key "PK_011c050f566e9db509a0fadb9b9" {
    columns = [column.id]
  }
  foreign_key "FK_d6870d3b6e4c185d33926f423c8" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_test_run_collection_id" {
    columns     = [column.collectionId]
    ref_columns = [table.evaluation_collection.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_test_run_evaluation_config_id" {
    columns     = [column.evaluationConfigId]
    ref_columns = [table.evaluation_config.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "IDX_d6870d3b6e4c185d33926f423c" {
    columns = [column.workflowId]
  }
  index "IDX_test_run_collectionId" {
    columns = [column.collectionId]
  }
  index "IDX_test_run_evaluationConfigId" {
    columns = [column.evaluationConfigId]
  }
}
table "token_exchange_jti" {
  schema = schema.public
  column "jti" {
    null = false
    type = character_varying(255)
  }
  column "expiresAt" {
    null = false
    type = timestamptz(3)
  }
  column "createdAt" {
    null = false
    type = timestamptz(3)
  }
  primary_key "PK_d8e8a6f737d530fdd2dd716e89c" {
    columns = [column.jti]
  }
}
table "trusted_key" {
  schema = schema.public
  column "sourceId" {
    null = false
    type = character_varying(36)
  }
  column "kid" {
    null = false
    type = character_varying(255)
  }
  column "data" {
    null = false
    type = text
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_dc7d93798f3dbb6959f974c97e1" {
    columns = [column.sourceId, column.kid]
  }
  foreign_key "FK_8c2938d746943dd8f608d23c891" {
    columns     = [column.sourceId]
    ref_columns = [table.trusted_key_source.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "trusted_key_source" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "type" {
    null = false
    type = character_varying(32)
  }
  column "config" {
    null = false
    type = text
  }
  column "status" {
    null    = false
    type    = character_varying(32)
    default = "pending"
  }
  column "lastError" {
    null = true
    type = text
  }
  column "lastRefreshedAt" {
    null = true
    type = timestamptz(3)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_99e8908ce2c2cdccce487db7fc6" {
    columns = [column.id]
  }
}
table "user" {
  schema = schema.public
  column "id" {
    null    = false
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "email" {
    null = true
    type = character_varying(255)
  }
  column "firstName" {
    null = true
    type = character_varying(32)
  }
  column "lastName" {
    null = true
    type = character_varying(32)
  }
  column "password" {
    null = true
    type = character_varying(255)
  }
  column "personalizationAnswers" {
    null = true
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "settings" {
    null = true
    type = json
  }
  column "disabled" {
    null    = false
    type    = boolean
    default = false
  }
  column "mfaEnabled" {
    null    = false
    type    = boolean
    default = false
  }
  column "mfaSecret" {
    null = true
    type = text
  }
  column "mfaRecoveryCodes" {
    null = true
    type = text
  }
  column "lastActiveAt" {
    null = true
    type = date
  }
  column "roleSlug" {
    null    = false
    type    = character_varying(128)
    default = "global:member"
  }
  primary_key "PK_ea8f538c94b6e352418254ed6474a81f" {
    columns = [column.id]
  }
  foreign_key "FK_eaea92ee7bfb9c1b6cd01505d56" {
    columns     = [column.roleSlug]
    ref_columns = [table.role.column.slug]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "user_role_idx" {
    columns = [column.roleSlug]
  }
  unique "UQ_e12875dfb3b1d92d7d7c5377e2" {
    columns = [column.email]
  }
}
table "user_api_keys" {
  schema = schema.public
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "userId" {
    null = false
    type = uuid
  }
  column "label" {
    null = false
    type = character_varying(100)
  }
  column "apiKey" {
    null = false
    type = character_varying
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "scopes" {
    null = true
    type = json
  }
  column "audience" {
    null    = false
    type    = character_varying
    default = "public-api"
  }
  column "lastUsedAt" {
    null = true
    type = timestamptz(3)
  }
  primary_key "PK_978fa5caa3468f463dac9d92e69" {
    columns = [column.id]
  }
  foreign_key "FK_e131705cbbc8fb589889b02d457" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_1ef35bac35d20bdae979d917a3" {
    unique  = true
    columns = [column.apiKey]
  }
  index "IDX_63d7bbae72c767cf162d459fcc" {
    unique  = true
    columns = [column.userId, column.label]
  }
}
table "user_favorites" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "userId" {
    null = false
    type = uuid
  }
  column "resourceId" {
    null = false
    type = character_varying(255)
  }
  column "resourceType" {
    null = false
    type = character_varying(64)
  }
  primary_key "PK_6c472a19a7423cfbbf6b7c75939" {
    columns = [column.id]
  }
  foreign_key "FK_1dd5c393ad0517be3c31a7af836" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_1d11050a381548c42c32cc25c4" {
    columns = [column.resourceType, column.resourceId]
  }
  index "IDX_1dd5c393ad0517be3c31a7af83" {
    columns = [column.userId]
  }
  unique "UQ_cf6ae658ead9ffc124723413c65" {
    columns = [column.userId, column.resourceId, column.resourceType]
  }
}
table "variables" {
  schema = schema.public
  column "key" {
    null = false
    type = character_varying(50)
  }
  column "type" {
    null    = false
    type    = character_varying(50)
    default = "string"
  }
  column "value" {
    null = true
    type = text
  }
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "projectId" {
    null = true
    type = character_varying(36)
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "FK_42f6c766f9f9d2edcc15bdd6e9b" {
    columns     = [column.projectId]
    ref_columns = [table.project.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "variables_global_key_unique" {
    unique  = true
    columns = [column.key]
    where   = "(\"projectId\" IS NULL)"
  }
  index "variables_project_key_unique" {
    unique  = true
    columns = [column.projectId, column.key]
    where   = "(\"projectId\" IS NOT NULL)"
  }
  check "variables_value_max_len" {
    expr = "((value IS NULL) OR (char_length(value) <= 1000))"
  }
}
table "webhook_entity" {
  schema = schema.public
  column "webhookPath" {
    null = false
    type = character_varying
  }
  column "method" {
    null = false
    type = character_varying
  }
  column "node" {
    null = false
    type = character_varying
  }
  column "webhookId" {
    null = true
    type = character_varying
  }
  column "pathLength" {
    null = true
    type = integer
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  primary_key "PK_b21ace2e13596ccd87dc9bf4ea6" {
    columns = [column.webhookPath, column.method]
  }
  foreign_key "fk_webhook_entity_workflow_id" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "idx_16f4436789e804e3e1c9eeb240" {
    columns = [column.webhookId, column.method, column.pathLength]
  }
}
table "workflow_builder_session" {
  schema = schema.public
  column "id" {
    null = false
    type = uuid
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "userId" {
    null = false
    type = uuid
  }
  column "messages" {
    null    = false
    type    = json
    default = "[]"
  }
  column "previousSummary" {
    null    = true
    type    = text
    comment = "Summary of prior conversation from compaction (/compact or auto-compact)"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "activeVersionCardId" {
    null = true
    type = character_varying(255)
  }
  column "resumeAfterRestoreMessageId" {
    null = true
    type = character_varying(255)
  }
  primary_key "PK_e69ef0d385986e273423b0e8695" {
    columns = [column.id]
  }
  foreign_key "FK_00290cdeee4d4d7db84709be936" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "FK_7983c618db48f47bf5a4cc1e1e4" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  unique "UQ_ec2aa73632932d485a1d5192ce1" {
    columns = [column.workflowId, column.userId]
  }
}
table "workflow_dependency" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "workflowVersionId" {
    null    = false
    type    = integer
    comment = "Version of the workflow"
  }
  column "dependencyType" {
    null    = false
    type    = character_varying(32)
    comment = "Type of dependency: \"credential\", \"nodeType\", \"webhookPath\", or \"workflowCall\""
  }
  column "dependencyKey" {
    null    = false
    type    = character_varying(255)
    comment = "ID or name of the dependency"
  }
  column "dependencyInfo" {
    null    = true
    type    = json
    comment = "Additional info about the dependency, interpreted based on type"
  }
  column "indexVersionId" {
    null    = false
    type    = smallint
    default = 1
    comment = "Version of the index structure"
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "publishedVersionId" {
    null = true
    type = character_varying(36)
  }
  primary_key "PK_52325e34cd7a2f0f67b0f3cad65" {
    columns = [column.id]
  }
  foreign_key "FK_a4ff2d9b9628ea988fa9e7d0bf8" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_a4ff2d9b9628ea988fa9e7d0bf" {
    columns = [column.workflowId]
  }
  index "IDX_e48a201071ab85d9d09119d640" {
    columns = [column.dependencyKey]
  }
  index "IDX_e7fe1cfda990c14a445937d0b9" {
    columns = [column.dependencyType]
  }
  index "IDX_workflow_dependency_publishedVersionId" {
    columns = [column.publishedVersionId]
  }
}
table "workflow_entity" {
  schema = schema.public
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "active" {
    null = false
    type = boolean
  }
  column "nodes" {
    null = false
    type = json
  }
  column "connections" {
    null = false
    type = json
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "settings" {
    null = true
    type = json
  }
  column "staticData" {
    null = true
    type = json
  }
  column "pinData" {
    null = true
    type = json
  }
  column "versionId" {
    null = false
    type = character(36)
  }
  column "triggerCount" {
    null    = false
    type    = integer
    default = 0
  }
  column "id" {
    null = false
    type = character_varying(36)
  }
  column "meta" {
    null = true
    type = json
  }
  column "parentFolderId" {
    null    = true
    type    = character_varying(36)
    default = sql("NULL::character varying")
  }
  column "isArchived" {
    null    = false
    type    = boolean
    default = false
  }
  column "versionCounter" {
    null    = false
    type    = integer
    default = 1
  }
  column "description" {
    null = true
    type = text
  }
  column "activeVersionId" {
    null = true
    type = character_varying(36)
  }
  column "nodeGroups" {
    null    = false
    type    = json
    default = "[]"
  }
  column "sourceWorkflowId" {
    null = true
    type = character_varying
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "FK_08d6c67b7f722b0039d9d5ed620" {
    columns     = [column.activeVersionId]
    ref_columns = [table.workflow_history.column.versionId]
    on_update   = NO_ACTION
    on_delete   = RESTRICT
  }
  foreign_key "fk_workflow_parent_folder" {
    columns     = [column.parentFolderId]
    ref_columns = [table.folder.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_workflow_entity_name" {
    columns = [column.name]
  }
  index "IDX_workflow_entity_sourceWorkflowId" {
    columns = [column.sourceWorkflowId]
    where   = "(\"sourceWorkflowId\" IS NOT NULL)"
  }
  index "pk_workflow_entity_id" {
    unique  = true
    columns = [column.id]
  }
}
table "workflow_history" {
  schema = schema.public
  column "versionId" {
    null = false
    type = character_varying(36)
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "authors" {
    null = false
    type = character_varying(255)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "nodes" {
    null = false
    type = json
  }
  column "connections" {
    null = false
    type = json
  }
  column "name" {
    null = true
    type = character_varying(128)
  }
  column "autosaved" {
    null    = false
    type    = boolean
    default = false
  }
  column "description" {
    null = true
    type = text
  }
  column "nodeGroups" {
    null    = false
    type    = json
    default = "[]"
  }
  primary_key "PK_b6572dd6173e4cd06fe79937b58" {
    columns = [column.versionId]
  }
  foreign_key "FK_1e31657f5fe46816c34be7c1b4b" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_1e31657f5fe46816c34be7c1b4" {
    columns = [column.workflowId]
  }
}
table "workflow_publication_outbox" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "workflowId" {
    null    = false
    type    = character_varying(36)
    comment = "References workflow_entity.id."
  }
  column "publishedVersionId" {
    null    = false
    type    = character_varying(36)
    comment = "References workflow_history.versionId."
  }
  column "status" {
    null = false
    type = character_varying(20)
  }
  column "errorMessage" {
    null    = true
    type    = text
    comment = "Error details for surfacing failed publications to the user."
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_b3e2eeee36a4bd044d56468d311" {
    columns = [column.id]
  }
  index "IDX_workflow_publication_outbox_active_workflow_status" {
    unique  = true
    columns = [column.workflowId, column.status]
    where   = "((status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying])::text[]))"
  }
  check "CHK_workflow_publication_outbox_status" {
    expr = "((status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'partial_success'::character varying, 'failed'::character varying])::text[]))"
  }
}
table "workflow_publish_history" {
  schema = schema.public
  column "id" {
    null = false
    type = integer
    identity {
      generated = BY_DEFAULT
    }
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "versionId" {
    null = true
    type = character_varying(36)
  }
  column "event" {
    null    = false
    type    = character_varying(36)
    comment = "Type of history record: activated (workflow is now active), deactivated (workflow is now inactive)"
  }
  column "userId" {
    null = true
    type = uuid
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_c788f7caf88e91e365c97d6d04a" {
    columns = [column.id]
  }
  foreign_key "FK_6eab5bd9eedabe9c54bd879fc40" {
    columns     = [column.userId]
    ref_columns = [table.user.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_b4cfbc7556d07f36ca177f5e473" {
    columns     = [column.versionId]
    ref_columns = [table.workflow_history.column.versionId]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "FK_c01316f8c2d7101ec4fa9809267" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "IDX_070b5de842ece9ccdda0d9738b" {
    columns = [column.workflowId, column.versionId]
  }
  check "CHK_workflow_publish_history_event" {
    expr = "((event)::text = ANY (ARRAY[('activated'::character varying)::text, ('deactivated'::character varying)::text]))"
  }
}
table "workflow_published_version" {
  schema = schema.public
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "publishedVersionId" {
    null = false
    type = character_varying(36)
  }
  column "createdAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  column "updatedAt" {
    null    = false
    type    = timestamptz(3)
    default = sql("CURRENT_TIMESTAMP(3)")
  }
  primary_key "PK_5c76fb7ee939fe2530374d3f75a" {
    columns = [column.workflowId]
  }
  foreign_key "FK_5c76fb7ee939fe2530374d3f75a" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = RESTRICT
  }
  foreign_key "FK_df3428a541b802d6a63ac56e330" {
    columns     = [column.publishedVersionId]
    ref_columns = [table.workflow_history.column.versionId]
    on_update   = NO_ACTION
    on_delete   = RESTRICT
  }
}
table "workflow_statistics" {
  schema = schema.public
  column "count" {
    null    = true
    type    = bigint
    default = 0
  }
  column "latestEvent" {
    null = true
    type = timestamptz(3)
  }
  column "name" {
    null = false
    type = character_varying(128)
  }
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "rootCount" {
    null    = true
    type    = bigint
    default = 0
  }
  column "id" {
    null = false
    type = serial
  }
  column "workflowName" {
    null = true
    type = character_varying(128)
  }
  primary_key {
    columns = [column.id]
  }
  index "IDX_workflow_statistics_workflow_name" {
    unique  = true
    columns = [column.workflowId, column.name]
  }
}
table "workflows_tags" {
  schema = schema.public
  column "workflowId" {
    null = false
    type = character_varying(36)
  }
  column "tagId" {
    null = false
    type = character_varying(36)
  }
  primary_key "pk_workflows_tags" {
    columns = [column.workflowId, column.tagId]
  }
  foreign_key "fk_workflows_tags_tag_id" {
    columns     = [column.tagId]
    ref_columns = [table.tag_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "fk_workflows_tags_workflow_id" {
    columns     = [column.workflowId]
    ref_columns = [table.workflow_entity.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "idx_workflows_tags_workflow_id" {
    columns = [column.workflowId]
  }
}
schema "public" {
  comment = "standard public schema"
}
