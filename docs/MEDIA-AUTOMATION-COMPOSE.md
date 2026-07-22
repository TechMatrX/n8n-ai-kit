# Media Automation Compose

`docker-compose.automation.yml` is the bounded NAS deployment for n8n. It owns
only n8n, task runners, n8n PostgreSQL, the PostgreSQL compatibility forwarder,
and the n8n Cloudflare tunnel.

RabbitMQ, MinIO, Redpanda, Authentik, and Meilisearch are external platform
capabilities. This project consumes them through capability networks and stable
endpoints; it never creates or owns them.

Render the target without changing live services:

```bash
docker compose --env-file .env -f docker-compose.automation.yml config
```

The live cutover requires a verified `n8n-backup.sh` result, pre/post workflow
and credential counts, preserved ports `5678` and `5433`, and an automatic
rollback to `n8n-nas-bundle` if PostgreSQL, n8n, runners, tunnel, or protected
routes fail their gates.
