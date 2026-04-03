# Personal Blog Monorepo

Hugo-based monorepo hosting 3 personal blogs, deployed via Cloudflare Pages.

## Sites

| Site | Directory | Description |
|------|-----------|-------------|
| Tempo | `sites/tempo/` | Personal blog |
| LW Studio | `sites/lw-studio/` | LW Studio blog |
| Purmuurfuuur | `sites/purmuurfuuur/` | Purmuurfuuur blog |

## Local Development

### Sync content from Obsidian vault

```bash
make sync                # sync all 3 sites
./scripts/sync-content.sh tempo  # sync a single site
```

### Serve locally

```bash
make serve-tempo   # http://localhost:1313
make serve-lw      # http://localhost:1314
make serve-pur     # http://localhost:1315
```

### Build

```bash
make build-all     # build all sites with --minify
make build-tempo   # build a single site
```

## Notes

- This is a **private repository** — content is not open source.
- Content originates from an Obsidian vault and is synced via `scripts/sync-content.sh`.
- Each site is independently deployable to Cloudflare Pages.
