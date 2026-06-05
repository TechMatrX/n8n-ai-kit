#!/usr/bin/env bash
set -euo pipefail

BUNDLE_DIR="${1:-dist/nas-deploy}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

mkdir -p "${BUNDLE_DIR}"

cp docker-compose.yml "${BUNDLE_DIR}/"
cp docker-compose.nas.yml "${BUNDLE_DIR}/"
cp .env.nas.example "${BUNDLE_DIR}/"
cp NAS-DS218-SETUP.md "${BUNDLE_DIR}/"
cp NAS-CONTAINER-MANAGER-IMPORT.md "${BUNDLE_DIR}/"
cp n8n-render-nas-compose.sh "${BUNDLE_DIR}/"
cp n8n-deploy-nas.sh "${BUNDLE_DIR}/"

cat > "${BUNDLE_DIR}/NEXT-STEPS.txt" <<'EOF'
1. Copy this folder to the NAS working location.
2. Copy .env.nas.example to .env and fill real values.
3. Create NAS folders:
   /volume1/docker/n8n-ai-kit/
   - backup/
   - n8n/
   - n8n-files/
   - postgres/
   - shared/
4. Load env:
   set -a; source ./.env; set +a
5. Render merged compose:
   ./n8n-render-nas-compose.sh
6. Review docker-compose.nas.merged.yml
7. First rehearsal deploy:
   ./n8n-deploy-nas.sh --skip-pull
EOF

chmod +x "${BUNDLE_DIR}/n8n-render-nas-compose.sh"
chmod +x "${BUNDLE_DIR}/n8n-deploy-nas.sh"

echo "Prepared NAS bundle at: ${BUNDLE_DIR}"
echo "Files:"
ls -1 "${BUNDLE_DIR}"
