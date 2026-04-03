#!/bin/bash
# Remove duplicate # Title line from post bodies (Hugo renders title from frontmatter)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for site in tempo lw-studio purmuurfuuur; do
    echo "Fixing $site..."
    count=0
    for f in "$REPO_ROOT/sites/$site/content/posts/"*.md; do
        [ -f "$f" ] || continue
        python3 -c "
import re, sys
with open(sys.argv[1], 'r') as fh:
    content = fh.read()
# Match: end of frontmatter (---), optional blank lines, then # heading line, then optional blank line
fixed = re.sub(r'(---\n)\n*# [^\n]+\n\n?', r'\1\n', content, count=1)
if fixed != content:
    with open(sys.argv[1], 'w') as fh:
        fh.write(fixed)
    print(f'  fixed: {sys.argv[1].split(\"/\")[-1]}')
" "$f" && ((count++)) || true
    done
    echo "  $site: $count files fixed"
done
echo "Done."
