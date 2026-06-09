#!/bin/bash
set -eo pipefail

export PGUSER=${PGUSER:-root}
export PGPASSWORD=${PGPASSWORD:-password}
export PGDATABASE=${PGDATABASE:-n8n}
export N8N_EXPORT_FORMAT=${N8N_EXPORT_FORMAT:-split}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

COMPOSE_ARGS=()
HOST_BACKUP_DIR="./n8n/backup"

if [ -f "./docker-compose.nas.yml" ] && [ -f "./.env" ]; then
    set -a
    # shellcheck disable=SC1091
    source "./.env"
    set +a

    if [ -n "${NAS_ROOT:-}" ]; then
        COMPOSE_ARGS=(-f docker-compose.yml -f docker-compose.nas.yml)
        HOST_BACKUP_DIR="${NAS_ROOT}/backup"
    fi
fi

docker_compose() {
    docker compose "${COMPOSE_ARGS[@]}" "$@"
}

resolve_storage_mount() {
    local mount_spec
    mount_spec=$(docker inspect n8n --format '{{range .Mounts}}{{if eq .Destination "/home/node/.n8n"}}{{.Type}}|{{.Source}}|{{.Name}}{{end}}{{end}}' 2>/dev/null || true)
    if [ -n "${mount_spec}" ]; then
        echo "${mount_spec}"
    else
        echo "volume||$(basename "${SCRIPT_DIR}")_n8n_storage"
    fi
}

timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="./backups/${timestamp}"

for dir in workflows credentials entities database volume; do
    mkdir -p "${backup_dir}/${dir}"
done

mkdir -p "${HOST_BACKUP_DIR}/workflows" "${HOST_BACKUP_DIR}/credentials" "${HOST_BACKUP_DIR}/entities"

mount_spec=$(resolve_storage_mount)
mount_type=${mount_spec%%|*}
mount_rest=${mount_spec#*|}
mount_source=${mount_rest%%|*}
mount_name=${mount_rest##*|}

echo "Exporting n8n backup payloads..."
docker_compose exec n8n mkdir -p /backup/workflows /backup/credentials /backup/entities
docker_compose exec n8n sh -lc 'rm -rf /backup/workflows/* /backup/credentials/* /backup/entities/* 2>/dev/null || true'

case "${N8N_EXPORT_FORMAT}" in
    split)
        docker_compose exec n8n n8n export:workflow --backup --output=/backup/workflows
        docker_compose exec n8n n8n export:credentials --backup --output=/backup/credentials
        cp -r "${HOST_BACKUP_DIR}/workflows/." "${backup_dir}/workflows/" 2>/dev/null || true
        cp -r "${HOST_BACKUP_DIR}/credentials/." "${backup_dir}/credentials/" 2>/dev/null || true
        ;;
    entities)
        docker_compose exec n8n n8n export:entities --outputDir=/backup/entities
        cp -r "${HOST_BACKUP_DIR}/entities/." "${backup_dir}/entities/" 2>/dev/null || true
        ;;
    both)
        docker_compose exec n8n n8n export:workflow --backup --output=/backup/workflows
        docker_compose exec n8n n8n export:credentials --backup --output=/backup/credentials
        docker_compose exec n8n n8n export:entities --outputDir=/backup/entities
        cp -r "${HOST_BACKUP_DIR}/workflows/." "${backup_dir}/workflows/" 2>/dev/null || true
        cp -r "${HOST_BACKUP_DIR}/credentials/." "${backup_dir}/credentials/" 2>/dev/null || true
        cp -r "${HOST_BACKUP_DIR}/entities/." "${backup_dir}/entities/" 2>/dev/null || true
        ;;
    *)
        echo "Unsupported N8N_EXPORT_FORMAT=${N8N_EXPORT_FORMAT}. Use split, entities, or both." >&2
        exit 1
        ;;
esac

echo "Clearing temporary export files..."
docker_compose exec n8n sh -lc 'rm -rf /backup/workflows/* /backup/credentials/* /backup/entities/* 2>/dev/null || true'
rm -rf "${HOST_BACKUP_DIR}/workflows/"* "${HOST_BACKUP_DIR}/credentials/"* "${HOST_BACKUP_DIR}/entities/"* 2>/dev/null || true

echo "Backing up PostgreSQL database..."
docker_compose exec postgres pg_dump -U "${PGUSER}" "${PGDATABASE}" > "${backup_dir}/database/n8n_backup.sql"

if [ "${mount_type}" = "bind" ]; then
    storage_source="${mount_source}"
    storage_label="${mount_source}"
else
    storage_source="${mount_name}"
    storage_label="${mount_name}"
fi

echo "Backing up n8n volume ${storage_label}..."
docker run --rm \
    -v "${storage_source}:/source:ro" \
    -v "${backup_dir}/volume:/dest" \
    alpine:latest \
    tar czf /dest/n8n_storage.tar.gz -C /source .

echo "Backup completed at ${backup_dir}"
