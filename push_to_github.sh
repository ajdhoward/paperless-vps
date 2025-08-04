#!/usr/bin/env bash
# push_to_github.sh  –  initialise and push the C:\Paperless project

set -euo pipefail

# --------- configuration ---------------------------------------------------
GITHUB_USER="ajdhoward"
REPO_NAME="paperless-vps"
VISIBILITY="public"          # ← now PUBLIC
DEFAULT_BRANCH="main"
COMMIT_MSG="Initial commit of Paperless-VPS stack"
# --------------------------------------------------------------------------

cd "$(dirname "$0")"         # switch into the script’s directory

# 1) initialise Git if needed
if [ ! -d .git ]; then
  echo ">> Initialising new Git repository…"
  git init -b "$DEFAULT_BRANCH"
fi

# 2) stage & commit any untracked or changed files
git add .
if ! git diff --cached --quiet; then
  echo ">> Creating local commit…"
  git commit -m "$COMMIT_MSG"
else
  echo ">> Nothing new to commit."
fi

# 3) create (or point) the GitHub repo as PUBLIC
if ! git remote get-url origin &>/dev/null; then
  echo ">> Creating '$GITHUB_USER/$REPO_NAME' on GitHub (public)…"
  gh repo create "$GITHUB_USER/$REPO_NAME" \
      --"$VISIBILITY" --source=. --remote=origin --confirm
else
  echo ">> Remote 'origin' already set."
fi

# 4) push to GitHub
echo ">> Pushing to GitHub…"
git push -u origin "$DEFAULT_BRANCH"

echo
echo "✅  Repo is live at:"
echo "   https://github.com/$GITHUB_USER/$REPO_NAME"
