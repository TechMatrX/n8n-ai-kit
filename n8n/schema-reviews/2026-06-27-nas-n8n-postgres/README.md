# NAS n8n Postgres Schema Review - 2026-06-27

Source: read-only Atlas inspection via NAS host `100.73.253.62:5433` -> Postgres container `5432`.

## Summary

- Schema: `public`
- Tables: `111`
- Columns: `840`
- Foreign keys: `148`
- Index blocks: `125`
- Inspect output: `schema.hcl` (5840 lines, 142011 bytes)
- Mermaid ERD source: `schema.mmd`
- Rendered ERD: `schema.svg`, `schema.png`
- SQL export: `schema.sql`
- JSON export: `schema.json`
- Stats: `schema-stats.txt`

## Largest Tables By Relation Size

| Table | Size |
| --- | ---: |
| `data_table_user_V1zRtKHvsME9BgkO` | 392.0 KB |
| `data_table_user_SPGOyAFf0KBfcgp4` | 352.0 KB |
| `workflow_dependency` | 328.0 KB |
| `workflow_history` | 240.0 KB |
| `workflow_entity` | 128.0 KB |
| `insights_by_period` | 120.0 KB |
| `execution_entity` | 112.0 KB |
| `execution_data` | 96.0 KB |
| `credentials_entity` | 80.0 KB |
| `workflow_publish_history` | 48.0 KB |
| `role_scope` | 40.0 KB |
| `mcp_registry_server` | 32.0 KB |
| `migrations` | 24.0 KB |
| `scope` | 16.0 KB |
| `user_api_keys` | 16.0 KB |

## Table Families

| Family | Count |
| --- | ---: |
| `other` | 40 |
| `instance` | 13 |
| `agents` | 10 |
| `agent` | 9 |
| `workflow` | 9 |
| `chat` | 6 |
| `execution` | 5 |
| `oauth` | 5 |
| `data` | 4 |
| `role` | 3 |
| `user` | 3 |
| `project` | 2 |
| `credential` | 1 |
| `credentials` | 1 |

## Notes

- This was a read-only inspection; no migrations were generated or applied.
- Port `5433` remains intentionally public/running on the NAS host for Andy's access.
- The schema includes n8n core tables plus OpenClaw/agent/chat hub extensions.
- The full rendered ERD is large; use the SVG for zooming and the HCL/SQL/JSON exports for exact structure.

## Artifacts

- `schema.hcl` - Atlas inspect output.
- `schema.sql` - SQL schema export.
- `schema.json` - JSON schema export.
- `schema-stats.txt` - Postgres catalog table/index size output in Prometheus-style format.
- `schema.mmd` - Mermaid ERD source.
- `schema.svg` - rendered ERD, best for zooming.
- `schema.png` - rendered ERD preview.
