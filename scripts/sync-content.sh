#!/usr/bin/env bash
set -euo pipefail

VAULT_BASE="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/ravi-obsidian/Personal/blogs"
REPO_BASE="$(cd "$(dirname "$0")/.." && pwd)"
SITES=(tempo lw-studio purmuurfuuur draft-zero pikmin)

sync_site() {
  local site="$1"
  echo "Syncing $site..."
  rsync -av --delete \
    "$VAULT_BASE/$site/posts/" \
    "$REPO_BASE/sites/$site/content/posts/"
  rsync -av --delete \
    "$VAULT_BASE/$site/images/" \
    "$REPO_BASE/sites/$site/static/images/"
  # Obsidian uses ../images/ (relative to the .md file), Hugo needs /images/ (absolute)
  find "$REPO_BASE/sites/$site/content/posts/" -name "*.md" \
    -exec sed -i '' 's|\](\.\.\/images/|](/images/|g' {} +

  # Guard: fail if any image looks like an LFS pointer (real images are always >1KB)
  bad=$(find "$REPO_BASE/sites/$site/static/images/" -type f -size -500c 2>/dev/null)
  if [ -n "$bad" ]; then
    echo "WARNING: possible LFS pointer files found in $site/static/images/:" >&2
    echo "$bad" >&2
    echo "Run 'git lfs pull' or restore from git history before committing." >&2
  fi

  echo "Done: $site"
}

if [[ $# -gt 0 ]]; then
  sync_site "$1"
else
  for site in "${SITES[@]}"; do
    sync_site "$site"
  done
fi
