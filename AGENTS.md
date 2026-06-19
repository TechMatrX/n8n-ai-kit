# n8n AI Kit Agent Instructions

## Purpose

This repo owns the self-hosted n8n and local AI runtime environment used by the
AI Media Platform. It provides Docker Compose infrastructure, environment
patterns, and workflow/runtime assets around n8n.

Platform-level architecture, ADRs, runbooks, and roadmap live in:

```text
/Users/andy/Studio/ai/ai-media-platform
https://github.com/TechMatrX/ai-media-platform
```

## Ownership Boundary

This repo owns:

- Docker Compose runtime for n8n and local AI services
- n8n environment/runtime configuration patterns
- workflow assets and operational notes that belong with the n8n stack

This repo does not own:

- worker implementation; use `media-worker-daemon`
- host-neutral n8n agent guidance; use `n8n-foundry`
- OpenClaw adapter delivery behavior; use `openclaw-workspace-plugins`
- platform-wide architecture decisions; update `ai-media-platform`
- secrets, `.env`, backups, generated runtime data, or `.codebase-memory/`

## Commands

Configuration validation:

```bash
docker compose config
git diff --check
```

Runtime commands, only when intentionally operating the local stack:

```bash
docker compose up
docker compose pull
docker compose down
```

Use profile-specific Docker commands only when the task explicitly calls for
that runtime mode.

## Codebase Knowledge Graph

This runtime uses `codebase-memory-mcp` to maintain a knowledge graph of the
codebase. Prefer MCP graph tools over grep/glob/file-search for code discovery.

Priority order:

1. `search_graph` - find functions, classes, routes, and variables by pattern.
2. `trace_path` - trace who calls a function or what it calls.
3. `get_code_snippet` - read specific function or class source code.
4. `query_graph` - run Cypher queries for complex patterns.
5. `get_architecture` - get a high-level project summary.

Fallback order:

- If `search_graph` and `trace_path` do not produce enough useful code results,
  prefer `search_code` before raw grep/glob.
- Fall back to grep/glob when searching string literals, error messages, config
  values, non-code files, or when graph/search_code results are insufficient.

## Safety

- Do not commit `.env`, local backups, credentials, generated volumes, or
  `.codebase-memory/`.
- Do not restart or recreate running services unless the task requires it.
- Prefer changing env pins and compose files over clicking updates in running
  container UIs.
- Preserve upstream starter-kit material unless the change is intentionally part
  of Andy's local platform fork.

## Integration Contracts

- n8n workflows submit media jobs to the worker execution plane.
- n8n callback workflows receive worker completion and update media job state.
- Protected local services should be referenced through credentials and env
  config, not hardcoded secrets.

## Documentation

- Keep n8n stack implementation notes in this repo.
- Keep cross-repo topology, ADRs, and runbooks in `ai-media-platform`.
