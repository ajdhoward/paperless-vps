#!/usr/bin/env bash
#
# upgrade_paperless.sh — bump Paperless-NGX to <tag>, back up, migrate, fix template
set -euo pipefail

# locate repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${SCRIPT_DIR%/scripts}"
cd "$REPO_DIR"

# parameters
TAG="${1:-latest}"
BACKUP_ROOT="${2:-$HOME/paperless-backups}"
TS=$(date +%s)
BACKUP_DIR="${BACKUP_ROOT}/${TS}"

echo "==> Backing up to ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"
docker exec paperless-vps-postgres-1 pg_dump -U paperless | gzip > "${BACKUP_DIR}/db.sql.gz"
rsync -a data/media    "${BACKUP_DIR}/media"    || echo "(media copy skipped)"
rsync -a data/postgres "${BACKUP_DIR}/postgres" || echo "(postgres copy skipped)"

echo "==> Upgrading to tag: ${TAG}"
sed -i -E "s|(ghcr.io/paperless-ngx/paperless-ngx:)[^[:space:]]+|\1${TAG}|g" docker-compose.yml

docker compose pull paperless renamer
docker compose up -d paperless renamer

echo "==> Migrating database"
docker compose exec paperless python manage.py migrate --noinput

if grep -qE '^PAPERLESS_FILENAME_FORMAT=\{correspondent\}' .env; then
  echo "==> Fixing filename template"
  sed -i 's|PAPERLESS_FILENAME_FORMAT={correspondent}/{document_type}/{created_year}-{created_month}-{created_day}_{title}|PAPERLESS_FILENAME_FORMAT={{ correspondent }}/{{ document_type }}/{{ created_year }}-{{ created_month }}-{{ created_day }}_{{ title }}|' .env
  docker compose restart paperless renamer
fi

echo -n "→ Now running Paperless v"; curl -s http://127.0.0.1:8050/api/health/ | jq -r '.version'
echo "✅  Upgrade complete."
