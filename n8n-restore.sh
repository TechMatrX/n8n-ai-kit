#!/bin/bash
set -eo pipefail

export PGUSER=${PGUSER:-root}
export PGPASSWORD=${PGPASSWORD:-password}
export PGDATABASE=${PGDATABASE:-n8n}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

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
docker compose stop n8n

echo "Ensuring postgres is running..."
docker compose up -d postgres

echo "Waiting for postgres to be ready..."
until docker compose exec postgres pg_isready -U "${PGUSER}" > /dev/null 2>&1; do
    sleep 1
done

echo "Dropping and recreating database..."
docker compose exec postgres psql -U "${PGUSER}" -d postgres -c "DROP DATABASE IF EXISTS ${PGDATABASE};"
docker compose exec postgres psql -U "${PGUSER}" -d postgres -c "CREATE DATABASE ${PGDATABASE};"

echo "Restoring PostgreSQL database..."
docker compose exec -T postgres psql -U "${PGUSER}" "${PGDATABASE}" < "${backup_dir}/database/n8n_backup.sql"

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

mkdir -p ./n8n/backup/workflows ./n8n/backup/credentials
rm -rf ./n8n/backup/workflows/* ./n8n/backup/credentials/*
cp -r "${backup_dir}/workflows/." ./n8n/backup/workflows/ 2>/dev/null || true
cp -r "${backup_dir}/credentials/." ./n8n/backup/credentials/ 2>/dev/null || true

echo "Restarting import and n8n services..."
docker compose up -d n8n-import
docker compose up -d n8n

echo "Restore completed from ${backup_dir}"
