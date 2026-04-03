#!/usr/bin/env bash
set -euo pipefail

VAULT_BASE="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/ravi-obsidian/Personal/blogs"
REPO_BASE="$(cd "$(dirname "$0")/.." && pwd)"
SITES=(tempo lw-studio purmuurfuuur)

sync_site() {
  local site="$1"
  echo "Syncing $site..."
  rsync -av --delete \
    "$VAULT_BASE/$site/posts/" \
    "$REPO_BASE/sites/$site/content/posts/"
  rsync -av --delete \
    "$VAULT_BASE/$site/images/" \
    "$REPO_BASE/sites/$site/static/images/"
  echo "Done: $site"
}

if [[ $# -gt 0 ]]; then
  sync_site "$1"
else
  for site in "${SITES[@]}"; do
    sync_site "$site"
  done
fi
