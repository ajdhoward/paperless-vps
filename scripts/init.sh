#!/usr/bin/env bash
# Installs prerequisites (Docker, Compose, Tailscale) and launches Paperless

set -euo pipefail

echo ">> Updating apt cache..."
sudo apt update -qq

need_pkg() { dpkg -s "$1" &>/dev/null || sudo apt install -y "$1"; }
for p in docker.io docker-compose-plugin tailscale git; do
  need_pkg "$p"
done

# Join Tailscale if not already up
if ! sudo tailscale status &>/dev/null; then
  echo ">> Tailscale not running. Paste an auth key (https://login.tailscale.com/admin/settings/keys)"
  read -rp "Auth key: " TSKEY
  sudo tailscale up --authkey "$TSKEY"
fi

# Ensure bind-mount directories exist
mkdir -p ./data/{postgres,media,consume,export}

echo ">> Pulling container images…"
docker compose pull

echo ">> Starting Paperless stack…"
docker compose up -d

echo
echo "✅  Finished. Open http://$(tailscale ip -4):8050 inside your Tailnet,"
echo "   then run: docker compose exec paperless manage.py createsuperuser"
