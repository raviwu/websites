---
name: blog-publish
description: Sync blog content from Obsidian vault, check for changes, and deploy. Use when user says "publish", "deploy", "sync", "發佈", "部署", "同步", "有沒有更新", "check updates", or asks to push blog changes live.
---

# Blog Publish

Sync blog posts and images from the Obsidian vault to this Hugo repo, then commit and push to trigger Cloudflare Pages auto-deployment.

## Sites

| Site | Directory | URL | Content in Vault |
|------|-----------|-----|-----------------|
| tempo | `sites/tempo/` | https://tempo-3z6.pages.dev | `Personal/blogs/tempo/` |
| lw-studio | `sites/lw-studio/` | https://lw-studio.pages.dev | `Personal/blogs/lw-studio/` |
| draft-zero | `sites/draft-zero/` | https://draft-zero.pages.dev | `Personal/blogs/draft-zero/` |
| purmuurfuuur | `sites/purmuurfuuur/` | https://purmuurfuuur.pages.dev | `Personal/blogs/purmuurfuuur/` |

## Steps

1. **Run sync to check for changes:**

```bash
./scripts/sync-content.sh
```

2. **Check what changed:**

```bash
git status --short
```

If no changes → tell user "所有站都是最新的，沒有需要發佈的變更。" and stop.

3. **Show a summary** of new/modified/deleted files, grouped by site.

4. **Ask for confirmation** before committing.

5. **Build locally to verify** (optional, if user wants to preview):

```bash
make serve-tempo    # port 1313
make serve-lw       # port 1314
make serve-pur      # port 1315
make serve-dz       # port 1316
```

6. **Commit and push:**

```bash
git add -A
git commit -m "publish: <summary of changes>"
git push
```

7. **Report:** Confirm push succeeded. Cloudflare auto-deploys within 1–2 minutes.

## New Post

If the user wants to create a new post, create it in the **Obsidian vault** (not this repo directly):

**Vault path:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/ravi-obsidian/Personal/blogs/<site>/posts/`

**Template:**
```yaml
---
title: "<title>"
date: YYYY-MM-DD
tags: [<tags>]
image: "/images/<image-filename>"
draft: true
blog: "<blog name>"
---
```

Place images in `Personal/blogs/<site>/images/` in the vault.

Default to `draft: true`. Remind user to set `draft: false` when ready to publish.

Then run sync + push as above.

## Important

- **Never force push**
- **Always show changes and confirm before committing**
- `draft: true` posts are hidden from production but visible in local preview (`-D` flag)
- Vault is the source of truth — always edit there, then sync here
