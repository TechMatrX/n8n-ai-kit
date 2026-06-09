#!/bin/bash
set -eo pipefail

export PGUSER=${PGUSER:-root}
export PGPASSWORD=${PGPASSWORD:-password}
export PGDATABASE=${PGDATABASE:-n8n}

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

resolve_volume_name() {
    local live_name
    live_name=$(docker inspect n8n --format '{{range .Mounts}}{{if eq .Destination "/home/node/.n8n"}}{{.Name}}{{end}}{{end}}' 2>/dev/null || true)
    if [ -n "${live_name}" ]; then
        echo "${live_name}"
    else
        echo "$(basename "${SCRIPT_DIR}")_n8n_storage"
    fi
}

timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="./backups/${timestamp}"

for dir in workflows credentials database volume; do
    mkdir -p "${backup_dir}/${dir}"
done

mkdir -p "${HOST_BACKUP_DIR}/workflows" "${HOST_BACKUP_DIR}/credentials"

volume_name=$(resolve_volume_name)

echo "Exporting n8n workflows and credentials..."
docker_compose exec n8n mkdir -p /backup/workflows /backup/credentials
docker_compose exec n8n sh -lc 'rm -rf /backup/workflows/* /backup/credentials/* 2>/dev/null || true'
docker_compose exec n8n n8n export:workflow --backup --output=/backup/workflows
docker_compose exec n8n n8n export:credentials --backup --output=/backup/credentials

cp -r "${HOST_BACKUP_DIR}/workflows/." "${backup_dir}/workflows/" 2>/dev/null || true
cp -r "${HOST_BACKUP_DIR}/credentials/." "${backup_dir}/credentials/" 2>/dev/null || true

echo "Clearing temporary export files..."
docker_compose exec n8n sh -lc 'rm -rf /backup/workflows/* /backup/credentials/* 2>/dev/null || true'
rm -rf "${HOST_BACKUP_DIR}/workflows/"* "${HOST_BACKUP_DIR}/credentials/"* 2>/dev/null || true

echo "Backing up PostgreSQL database..."
docker_compose exec postgres pg_dump -U "${PGUSER}" "${PGDATABASE}" > "${backup_dir}/database/n8n_backup.sql"

echo "Backing up n8n volume ${volume_name}..."
docker run --rm \
    -v "${volume_name}:/source:ro" \
    -v "${backup_dir}/volume:/dest" \
    alpine:latest \
    tar czf /dest/n8n_storage.tar.gz -C /source .

echo "Backup completed at ${backup_dir}"
