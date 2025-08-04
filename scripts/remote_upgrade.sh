#!/usr/bin/env bash
# Pull latest repo, then run the real upgrader.
set -euo pipefail
TAG="\${1:-latest}"
REPO_DIR="\$HOME/paperless-vps"
git -C "\$REPO_DIR" pull --ff-only
bash "\$REPO_DIR/scripts/upgrade_paperless.sh" "\$TAG"
