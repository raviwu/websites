# Personal Blog Monorepo

Hugo-based monorepo hosting 4 personal blogs, deployed via Cloudflare Pages.

## Sites

| Site | Directory | URL | Theme | Description |
|------|-----------|-----|-------|-------------|
| Tempo | `sites/tempo/` | https://tempo.pages.dev | Blowfish | 天頗的故事 — 貓咪圖文 (2012–2013) |
| LW Studio | `sites/lw-studio/` | https://lw-studio.pages.dev | Stack | 經濟學、哲學、翻譯 (2013–2024) |
| Draft Zero | `sites/draft-zero/` | https://draft-zero.pages.dev | Stack | 人生的初稿 (2006–2009) |
| PurMuurFuuur | `sites/purmuurfuuur/` | https://purmuurfuuur.pages.dev | Stack | 生活記事 (2010–2026) |

## Local Development

### Sync content from Obsidian vault

```bash
make sync                          # sync all 4 sites
./scripts/sync-content.sh tempo    # sync a single site
```

### Serve locally

```bash
make serve-tempo   # http://localhost:1313
make serve-lw      # http://localhost:1314
make serve-pur     # http://localhost:1315
make serve-dz      # http://localhost:1316
```

### Build

```bash
make build-all     # build all sites with --minify
make build-tempo   # build a single site
```

## Publishing workflow

1. Write or edit posts in Obsidian vault under `Personal/blogs/<site>/posts/`
2. New posts: set `draft: true` in frontmatter until ready
3. `make sync` to copy content to this repo
4. `git add -A && git commit -m "publish: <summary>" && git push`
5. Cloudflare Pages auto-deploys within 1–2 minutes

## Draft support

- `draft: true` in frontmatter → hidden from production, visible in local preview (`hugo server -D`)
- `draft: false` → published on next deploy

## Notes

- Content originates from Obsidian vault and is synced via `scripts/sync-content.sh`
- Each site is independently deployed as a Cloudflare Pages project
- Cloudflare Pages auto-builds on every push to `main`
