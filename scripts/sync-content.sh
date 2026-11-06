#!/usr/bin/env bash
set -euo pipefail

VAULT_BASE="${VAULT_BASE:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/ravi-obsidian/Personal/blogs}"
REPO_BASE="$(cd "$(dirname "$0")/.." && pwd)"
SITES=(tempo lw-studio purmuurfuuur draft-zero pikmin)
IMAGE_COLLISION=0

# Guard: report images that the sync replaced although git already has them.
# Obsidian gives pasted images generic names (post-0.jpg), so a new post can
# overwrite an older post's image and rsync gives no error.
# If two or more posts use a replaced image, the sync fails (exit 1) after all
# sites are synced, so `make publish` stops before it commits and pushes.
check_replaced_images() {
  local site="$1"
  local posts_dir="$REPO_BASE/sites/$site/content/posts"
  local path name refs count
  while IFS= read -r -d '' path; do
    name="${path##*/}"
    refs=$(grep -rlF -- "/images/$name" "$posts_dir" 2>/dev/null || true)
    count=$(printf '%s' "$refs" | grep -c . || true)
    if [[ "$count" -ge 2 ]]; then
      IMAGE_COLLISION=1
      echo "ERROR: $site: the vault replaced images/$name, and $count posts use it:" >&2
    else
      echo "WARNING: $site: the vault replaced images/$name. Posts that use it:" >&2
    fi
    if [[ -n "$refs" ]]; then
      printf '%s\n' "$refs" | sed "s|^$posts_dir/|  |" >&2
    else
      echo "  (none)" >&2
    fi
  done < <(git -C "$REPO_BASE" diff -z --name-only --diff-filter=M HEAD -- "sites/$site/static/images/")
}

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

  check_replaced_images "$site"

  echo "Done: $site"
}

if [[ $# -gt 0 ]]; then
  sync_site "$1"
else
  for site in "${SITES[@]}"; do
    sync_site "$site"
  done
fi

if [[ "$IMAGE_COLLISION" -eq 1 ]]; then
  echo "Sync stopped: one new image probably overwrote an older post's image." >&2
  echo "Fix it in the vault: give the new image its own name, update its post," >&2
  echo "and restore the old image with: git show HEAD:<image path> > <vault image path>" >&2
  echo "Then sync again." >&2
  exit 1
fi
