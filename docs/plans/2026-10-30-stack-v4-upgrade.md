# Stack Theme v3 → v4 Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the four Stack-themed sites from `hugo-theme-stack/v3@v3.34.2` to `hugo-theme-stack/v4` so every build is free of deprecation warnings, with no visible regression.

**Architecture:** One site per task, smallest override surface first (pikmin as pilot), each task a self-contained commit that builds clean and passes a visual comparison against a pre-upgrade baseline. Existing local overrides (`custom.scss`, `render-image.html`) are kept and only moved where v4 requires it; adopting new v4 features is out of scope.

**Tech Stack:** Hugo `v0.163.0+extended` (local, Homebrew), Hugo Modules, Stack v4 (latest `v4.0.3`, 2026-05-25), Cloudflare Pages (auto-deploy on `git push`), Playwright MCP for screenshots.

**Spec:** No separate spec. Source of requirements: the Stack v4 upgrade guide <https://stack.cai.im/guide/upgrade-to-v4/> and the v4.0.0 release notes <https://github.com/CaiJimmy/hugo-theme-stack/releases/tag/v4.0.0>.

## Global Constraints

- Sites in scope: `sites/pikmin`, `sites/purmuurfuuur`, `sites/draft-zero`, `sites/lw-studio`. `sites/tempo` uses Blowfish and is out of scope.
- Module path becomes `github.com/CaiJimmy/hugo-theme-stack/v4` (in `hugo.toml` `[[module.imports]]` and `go.mod`).
- Stack v4 requires Hugo `>= 0.157.0`. The Cloudflare Pages build must run at least that version.
- v4 renamed Chinese locale codes: `zh-tw` → `zh-hant-tw`. `defaultContentLanguage` must use the new code, or the theme's Chinese i18n strings will not load.
- Do not edit `content/posts/` — post content is owned by the Obsidian vault and synced with `rsync --delete`. `content/page/` is repo-owned and safe to edit.
- Acceptance per site: `hugo --minify` exits 0 and prints zero `WARN` / `ERROR` lines.
- No push per task. One push at the end, after Ravi approves the visual comparison.

## Baseline (measured 2026-10-30, Hugo v0.163.0)

| Site | Warnings today |
|------|----------------|
| pikmin | `.Site.LanguageCode`, `.Language.LanguageDirection`, `.Site.Data` (all from theme v3) |
| purmuurfuuur | the three above + config key `languageCode` |
| draft-zero | the three above + config key `languageCode` |
| lw-studio | the three above + config key `languageCode` |

Site-specific surface:

| Site | `custom.scss` | `layouts/_default/_markup/render-image.html` | Other |
|------|---------------|-----------------------------------------------|-------|
| pikmin | grid article list | — | `locale = "zh-tw"`, `[pagination]` |
| purmuurfuuur | grid article list | yes | `[pagination]` |
| draft-zero | color tokens | yes | `paginate = 20`, `sidebar.compact = true` |
| lw-studio | color tokens | yes | `paginate = 20`, `favicon = "favicon.ico"` in `static/`, `toc` + `tag-cloud` widgets |

## Review Focus

1. **Chinese UI strings fall back to English** after the `zh-tw` rename — expect "搜尋", "歸檔", "標籤" etc. in the rendered HTML, not "Search", "Archives".
2. **`render-image.html` override silently stops winning** because v4 ships `layouts/_markup/render-image.html` and the override lives at the legacy `_default/_markup/` path — expect post images to keep `loading="lazy"` and the `../images/` → `/images/` rewrite.
3. **`custom.scss` selectors no longer match** v4 markup (`.article-list` grid in pikmin/purmuurfuuur, color tokens in draft-zero/lw-studio) — expect the same column count and colors as baseline.
4. **Cloudflare Pages builds an older Hugo** than `0.157.0` — expect the deploy to fail loudly; verify the version before pushing.
5. **lw-studio favicon disappears** because v4 resolves `favicon` from `assets/` instead of `static/`.

---

### Task 0: Prerequisites and visual baseline

**Files:** none in repo. Screenshots go to the session scratchpad.

- [ ] **Step 1: Confirm the Cloudflare Pages Hugo version (Ravi).** In each of the four Pages projects, check Settings → Environment variables for `HUGO_VERSION`. Required: unset-but-latest or `>= 0.157.0`. If it is pinned lower, raise it to `0.163.0` before Task 5. Record the value in this plan.
  - Recorded 2026-11-03 from each live site's `<meta name="generator">` (the dashboard setting itself was not read): pikmin **Hugo 0.147.0 — below 0.157.0, must be raised before push**; purmuurfuuur, draft-zero, lw-studio Hugo 0.159.1 (OK).
- [ ] **Step 2: Capture baseline screenshots.** For each site, run `hugo server -p <port>` (ports from `Makefile`) and use Playwright to capture, at 1280px and 390px width, in light and dark mode: home, one post with images, `/tags/`, `/page/search/?keyword=<a word from a post>`, `/page/archives/`. Expected: 5 pages × 2 widths × 2 schemes per site, saved as `baseline-<site>-<page>-<width>-<scheme>.png`.

### Task 1: pikmin (pilot)

**Files:**
- Modify: `sites/pikmin/hugo.toml` (module path, `defaultContentLanguage`, `locale`)
- Modify: `sites/pikmin/go.mod`, `sites/pikmin/go.sum` (via `hugo mod get`)
- Modify: `sites/pikmin/assets/jsconfig.json` (regenerated by Hugo; commit the v4 path)

- [ ] **Step 1:** Change the module import path to `github.com/CaiJimmy/hugo-theme-stack/v4`. Set `defaultContentLanguage = "zh-hant-tw"` and `locale = "zh-hant-tw"`.
- [ ] **Step 2:** Run `cd sites/pikmin && hugo mod get github.com/CaiJimmy/hugo-theme-stack/v4@v4.0.3 && hugo mod tidy`. Expected: `go.mod` requires only `.../v4 v4.0.3`.
- [ ] **Step 3:** Run `hugo --minify 2>&1 | grep -E 'WARN|ERROR'`. Expected: no output.
- [ ] **Step 4:** Check Review Focus 1 and 3: `grep -c '搜尋' public/index.html` ≥ 1; `public/index.html` `<html lang=...>` is a `zh-Hant-TW`-family value; published dates on a post render in Chinese format.
- [ ] **Step 5:** Capture the same screenshot set as Task 0 and compare with the baseline (fresh-context subagent returns a per-page verdict: same / intended v4 difference / regression). Expected: no regression.
- [ ] **Step 6:** Commit: `chore(pikmin): upgrade Stack theme to v4`.

### Task 2: purmuurfuuur

**Files:**
- Modify: `sites/purmuurfuuur/hugo.toml` (module path; `languageCode` → `locale = "zh-hant-tw"`; `defaultContentLanguage = "zh-hant-tw"`)
- Modify: `sites/purmuurfuuur/go.mod`, `go.sum`, `assets/jsconfig.json`
- Move: `sites/purmuurfuuur/layouts/_default/_markup/render-image.html` → `sites/purmuurfuuur/layouts/_markup/render-image.html` (content unchanged)

**Interfaces:** Consumes the config pattern proven in Task 1.

- [ ] **Step 1:** Apply the Task 1 config changes plus the `languageCode` → `locale` rename, then move `render-image.html` with `git mv`.
- [ ] **Step 2:** Run `hugo mod get github.com/CaiJimmy/hugo-theme-stack/v4@v4.0.3 && hugo mod tidy`, then `hugo --minify 2>&1 | grep -E 'WARN|ERROR'`. Expected: no output.
- [ ] **Step 3:** Check Review Focus 2: in one built post that has images, every `<img>` inside the article body has `loading="lazy"` and an `src` starting with `/images/`.
- [ ] **Step 4:** Screenshot comparison as in Task 1 Step 5. Expected: 3/2/1-column grid unchanged.
- [ ] **Step 5:** Commit: `chore(purmuurfuuur): upgrade Stack theme to v4`.

### Task 3: draft-zero

**Files:** as Task 2, under `sites/draft-zero/`, plus `paginate = 20` → `[pagination]` `pagerSize = 20`.

- [ ] **Step 1:** Apply the Task 2 changes. Replace `paginate = 20` with a `[pagination]` table holding `pagerSize = 20`. Keep `sidebar.compact = true`.
- [ ] **Step 2:** Build check as Task 2 Step 2. Expected: no output.
- [ ] **Step 3:** Check pagination: the home page lists 20 posts and `public/page/2/index.html` exists (draft-zero has more than 20 posts — confirm with `ls content/posts | wc -l` first).
- [ ] **Step 4:** Check Review Focus 2 as in Task 2 Step 3, then screenshot comparison. Expected: teal color tokens and compact sidebar unchanged.
- [ ] **Step 5:** Commit: `chore(draft-zero): upgrade Stack theme to v4`.

### Task 4: lw-studio

**Files:** as Task 3, under `sites/lw-studio/`, plus:
- Move: `sites/lw-studio/static/favicon.ico` → `sites/lw-studio/assets/favicon.ico` (config value `favicon = "favicon.ico"` unchanged)

- [ ] **Step 1:** Apply the Task 3 changes and move the favicon with `git mv`.
- [ ] **Step 2:** Build check. Expected: no output.
- [ ] **Step 3:** Check Review Focus 5: `public/index.html` has a `<link rel="icon" ...>` whose `href` resolves to a file present in `public/`.
- [ ] **Step 4:** Check the `toc` page widget renders on a post with headings, and the `tag-cloud` widget renders on home. Then Review Focus 2 and the screenshot comparison. Expected: dark-default amber scheme unchanged.
- [ ] **Step 5:** Commit: `chore(lw-studio): upgrade Stack theme to v4`.

### Task 5: Final verification and deploy

- [ ] **Step 1:** Run `make build-all`. Expected: exit 0; the only `WARN` lines (if any) come from `sites/tempo`, which is out of scope — list them for Ravi.
- [ ] **Step 2:** Restore build side effects: `git status --short` shows no modified `assets/jsconfig.json` beyond the committed v4 path.
- [ ] **Step 3:** Fresh-context reviewer checks the whole diff (`git diff 60d1ae8..HEAD`) against this plan.
- [ ] **Step 4:** Ravi reviews the screenshot comparisons and confirms. Then `git push`, and poll each live site until the home page reflects v4 (for example, the new `<html lang>` value). Expected: all four sites serve HTTP 200 with the new markup.

## Rollback

Each site is one commit. `git revert <commit>` and push restores v3 for that site only.

## Out of scope

- Adopting v4 features (Mermaid, alerts, PhotoSwipe v5 lightbox via the theme's own `render-image.html`, `SortBy = "lastmod"`).
- Dropping the local `render-image.html` override in favor of v4's hook. Possible follow-up: it would enable v4 lightbox/gallery, but changes how every post image renders.
- `sites/tempo` (Blowfish).
