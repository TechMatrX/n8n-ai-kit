# NAS n8n Postgres Schema Review - 2026-06-26

Source: read-only Atlas inspection via NAS host `100.73.253.62:5433` -> Postgres container `5432`.

## Summary

- Schema: `public`
- Tables: `111`
- Columns: `840`
- Foreign keys: `148`
- Indexes: `125`
- Inspect output: `schema.hcl` (5840 lines)
- Mermaid ERD source: `schema.mmd`
- Rendered ERD: `schema.svg`, `schema.png`
- Stats: `schema-stats.txt`

## Largest Tables By Atlas Size

| Table | Size |
| --- | ---: |
| `data_table_user_V1zRtKHvsME9BgkO` | 392.0 KB |
| `data_table_user_SPGOyAFf0KBfcgp4` | 352.0 KB |
| `workflow_dependency` | 328.0 KB |
| `workflow_history` | 240.0 KB |
| `workflow_entity` | 128.0 KB |
| `insights_by_period` | 112.0 KB |
| `execution_entity` | 112.0 KB |
| `execution_data` | 96.0 KB |
| `credentials_entity` | 80.0 KB |
| `workflow_publish_history` | 48.0 KB |
| `role_scope` | 40.0 KB |
| `mcp_registry_server` | 32.0 KB |
| `migrations` | 24.0 KB |
| `workflow_statistics` | 16.0 KB |
| `user_api_keys` | 16.0 KB |

## Table Families

| Family | Count |
| --- | ---: |
| `other` | 37 |
| `instance` | 14 |
| `agents` | 11 |
| `agent` | 9 |
| `workflow` | 8 |
| `chat` | 6 |
| `execution` | 5 |
| `oauth` | 5 |
| `data` | 4 |
| `role` | 4 |
| `project` | 3 |
| `user` | 3 |
| `credential` | 1 |
| `credentials` | 1 |

## Notes

- This was a read-only inspection; no migrations were generated or applied.
- The schema includes n8n core tables plus OpenClaw/agent/chat hub extensions.
- The full rendered ERD is very large; use the SVG for inspection and the HCL for exact structure.
- Port `5433` is intentionally public on the NAS host for this schema-review test window.

## Artifacts

- `schema.hcl` - Atlas inspect output.
- `schema-stats.txt` - Atlas stats output.
- `schema.mmd` - Mermaid ERD source.
- `schema.svg` - rendered ERD, best for zooming.
- `schema.png` - rendered ERD preview.
