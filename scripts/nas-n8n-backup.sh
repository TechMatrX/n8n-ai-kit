#!/usr/bin/env bash
set -euo pipefail

NAS_HOST="${NAS_HOST:-openclaw@100.73.253.62}"
NAS_IDENTITY_FILE="${NAS_IDENTITY_FILE:-${HOME}/.ssh/id_ed25519_openclaw}"
NAS_BUNDLE_DIR="${NAS_BUNDLE_DIR:-/volume1/docker/n8n-ai-kit/n8n-nas-bundle}"
NAS_DOCKER_BIN="${NAS_DOCKER_BIN:-/usr/local/bin/docker}"
N8N_EXPORT_FORMAT="${N8N_EXPORT_FORMAT:-both}"
COPY_LOCAL="${COPY_LOCAL:-1}"
LOCAL_BACKUP_DIR="${LOCAL_BACKUP_DIR:-backups}"
DRY_RUN="${DRY_RUN:-0}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: scripts/nas-n8n-backup.sh [--dry-run] [--no-copy]

Runs the NAS n8n backup script over SSH using the known OpenClaw NAS route.

Environment overrides:
  NAS_HOST             default: openclaw@100.73.253.62
  NAS_IDENTITY_FILE    default: ~/.ssh/id_ed25519_openclaw
  NAS_BUNDLE_DIR       default: /volume1/docker/n8n-ai-kit/n8n-nas-bundle
  NAS_DOCKER_BIN       default: /usr/local/bin/docker
  N8N_EXPORT_FORMAT    default: both
  COPY_LOCAL           default: 1
  LOCAL_BACKUP_DIR     default: backups
  DRY_RUN              default: 0

The wrapper never prints NAS .env values.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --no-copy)
      COPY_LOCAL=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

ssh_args=(-i "${NAS_IDENTITY_FILE}" "${NAS_HOST}")

if [ "${DRY_RUN}" = "1" ]; then
  echo "Dry run only. Would run NAS backup with:"
  echo "  NAS_HOST=${NAS_HOST}"
  echo "  NAS_BUNDLE_DIR=${NAS_BUNDLE_DIR}"
  echo "  NAS_DOCKER_BIN=${NAS_DOCKER_BIN}"
  echo "  N8N_EXPORT_FORMAT=${N8N_EXPORT_FORMAT}"
  echo "  COPY_LOCAL=${COPY_LOCAL}"
  ssh "${ssh_args[@]}" "cd '${NAS_BUNDLE_DIR}' && test -f .env && test -x ./n8n-backup.sh && sudo -n '${NAS_DOCKER_BIN}' ps >/dev/null && pwd"
  exit 0
fi

remote_output=$(
  ssh "${ssh_args[@]}" \
    "cd '${NAS_BUNDLE_DIR}' && \
     tmp_bin=\$(mktemp -d '${NAS_BUNDLE_DIR}/.tmp-docker-wrapper.XXXXXX') && \
     trap 'rm -rf \"\${tmp_bin}\"' EXIT && \
     printf '%s\n' '#!/bin/sh' 'if [ \"\$#\" -eq 0 ]; then exit 0; fi' 'exec sudo -n ${NAS_DOCKER_BIN} \"\$@\"' > \"\${tmp_bin}/docker\" && \
     chmod +x \"\${tmp_bin}/docker\" && \
     set -a && . ./.env && set +a && \
     export PATH=\"\${tmp_bin}:\$PATH\" && \
     export N8N_EXPORT_FORMAT='${N8N_EXPORT_FORMAT}' && \
     export PGUSER=\"\$POSTGRES_USER\" && \
     export PGPASSWORD=\"\$POSTGRES_PASSWORD\" && \
     export PGDATABASE=\"\$POSTGRES_DB\" && \
     ./n8n-backup.sh"
)

printf '%s\n' "${remote_output}"

backup_rel=$(printf '%s\n' "${remote_output}" | awk '/Backup completed at / {print $NF}' | tail -1)
if [ -z "${backup_rel}" ]; then
  echo "Could not determine remote backup path from n8n-backup.sh output." >&2
  exit 1
fi

backup_name="$(basename "${backup_rel}")"
remote_backup="${NAS_BUNDLE_DIR}/${backup_rel#./}"

echo "Remote backup: ${remote_backup}"

if [ "${COPY_LOCAL}" = "1" ]; then
  mkdir -p "${REPO_ROOT}/${LOCAL_BACKUP_DIR}"
  echo "Copying backup to ${REPO_ROOT}/${LOCAL_BACKUP_DIR}/${backup_name} ..."
  rsync -a -e "ssh -i ${NAS_IDENTITY_FILE}" \
    "${NAS_HOST}:${remote_backup}/" \
    "${REPO_ROOT}/${LOCAL_BACKUP_DIR}/${backup_name}/"
  echo "Local backup: ${REPO_ROOT}/${LOCAL_BACKUP_DIR}/${backup_name}"
fi
