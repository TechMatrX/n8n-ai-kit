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

if [ -z "$1" ]; then
    echo "Usage: ./n8n-restore.sh YYYYMMDD_HHMMSS"
    exit 1
fi

timestamp=$1
backup_dir="./backups/${timestamp}"

if [ ! -d "${backup_dir}" ]; then
    echo "Backup directory ${backup_dir} not found"
    exit 1
fi

volume_name=$(resolve_volume_name)

echo "Stopping n8n service..."
docker_compose stop n8n

echo "Ensuring postgres is running..."
docker_compose up -d postgres

echo "Waiting for postgres to be ready..."
until docker_compose exec postgres pg_isready -U "${PGUSER}" > /dev/null 2>&1; do
    sleep 1
done

run_psql_postgres() {
    docker_compose exec postgres psql -v ON_ERROR_STOP=1 -U "${PGUSER}" -d postgres "$@"
}

wait_for_stable_postgres() {
    until docker_compose exec postgres pg_isready -U "${PGUSER}" > /dev/null 2>&1; do
        sleep 1
    done
    sleep 2
}

echo "Dropping and recreating database..."
for attempt in 1 2 3 4 5; do
    if run_psql_postgres -c "DROP DATABASE IF EXISTS ${PGDATABASE};" && \
       run_psql_postgres -c "CREATE DATABASE ${PGDATABASE};"; then
        break
    fi

    if [ "${attempt}" -eq 5 ]; then
        echo "Failed to reset database ${PGDATABASE} after ${attempt} attempts" >&2
        exit 1
    fi

    echo "Postgres reset attempt ${attempt} failed, waiting for stability before retrying..."
    wait_for_stable_postgres
done

echo "Restoring PostgreSQL database..."
docker_compose exec -T postgres psql -U "${PGUSER}" "${PGDATABASE}" < "${backup_dir}/database/n8n_backup.sql"

echo "Restoring n8n volume ${volume_name}..."
docker run --rm \
    -v "${volume_name}:/dest" \
    -v "${backup_dir}/volume:/source" \
    alpine:latest \
    sh -c "cd /dest && tar xzf /source/n8n_storage.tar.gz"

echo "Fixing ownership and permissions on restored n8n volume..."
docker run --rm \
    -v "${volume_name}:/dest" \
    alpine:latest \
    sh -c "chown -R 1000:1000 /dest && find /dest -type d -exec chmod 750 {} \\; && find /dest -type f -exec chmod 640 {} \\;"

mkdir -p "${HOST_BACKUP_DIR}/workflows" "${HOST_BACKUP_DIR}/credentials"
rm -rf "${HOST_BACKUP_DIR}/workflows/"* "${HOST_BACKUP_DIR}/credentials/"* 2>/dev/null || true
cp -r "${backup_dir}/workflows/." "${HOST_BACKUP_DIR}/workflows/" 2>/dev/null || true
cp -r "${backup_dir}/credentials/." "${HOST_BACKUP_DIR}/credentials/" 2>/dev/null || true

echo "Restarting import and n8n services..."
N8N_IMPORT_MODE=restore docker compose "${COMPOSE_ARGS[@]}" up -d n8n-import
docker_compose up -d n8n

echo "Restore completed from ${backup_dir}"
