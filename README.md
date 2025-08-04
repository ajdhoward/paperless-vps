# paperless-vps

Self-hosted **Paperless-NGX** on Ubuntu 22/24 with Tailscale-only access and an
hourly housekeeping side-car that keeps the on-disk folder hierarchy in sync
with metadata.

```bash
# quick start on the VPS
git clone https://github.com/ajdhoward/paperless-vps.git
cd paperless-vps
cp .env.example .env   # fill in secrets
bash scripts/init.sh
docker compose exec paperless manage.py createsuperuser
```

Everything is bind-mounted under `./data/` so upgrades & backups never touch
the Git repo itself.
