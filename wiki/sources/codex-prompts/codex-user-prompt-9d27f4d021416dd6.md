---
title: PLEASE IMPLEMENT THIS PLAN -
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - automation
source_pages:
  - codex-prompt-corpus
---

# PLEASE IMPLEMENT THIS PLAN:

## Metadata

- Stable ID: `codex-user-prompt:9d27f4d021416dd6`
- Source kind: `codex-session-user`
- Category: `automation`
- Timestamp: `2026-05-16T12:34:55.573Z`
- Semantic hash: `9d27f4d021416dd658835f81c40508c7f1cbc7163ee08459ac0de181698bb387`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# 热门前端框架 Public Corpus 与定时更新计划

## Summary
- 建一个新的 `frontend-frameworks-public` corpus，覆盖 12 个主流+创新前端框架：React, Vue, Angular, Svelte, Solid, Qwik, Astro, Next.js, Nuxt, SvelteKit, Remix/React Router, TanStack Start。
- 边界定义为“官方框架相关 repo 集”，不抓整个 Meta/Vercel/Google org；每个项目保存 GitHub 元数据、README 摘要、release 要点、链接、hash、分类和语言/技术栈索引。
- 公共 wiki 只放 curated Markdown 摘要和导航；raw 层保存 manifest 与 provenance，避免公开镜像不明许可的全文代码或超长 release body。

## Key Changes
- 新增 ingest 脚本 `scripts/ingest-frontend-frameworks-public.ps1`，接口：
 - `-Root .`
 - `-Mode Light|Digest`，默认 `Digest`
 - `-SkipValidation`
 - `-DryRun`
- 新增 raw 层：
 - `raw/frontend-frameworks-public/manifest.json`
 - `raw/frontend-frameworks-public/inbox/YYYY-MM-DD-digest.json`
 - `raw/frontend-frameworks-public/registry.json`
- `registry.json` 初始框架边界：
 - React: `facebook/react`, `reactjs/react.dev`
 - Vue: `vuejs/core`, `vuejs/docs`, `vuejs/router`, `vuejs/pinia`, `vuejs/devtools`
 - Angular: `angular/angular`, `angular/angular-cli`, `angular/angular.dev`, `angular/components`
 - Svelte: `sveltejs/svelte`, `sveltejs/kit`, `sveltejs/svelte.dev`
 - Solid: `solidjs/solid`, `solidjs/solid-start`, `solidjs/solid-docs`
 - Qwik: `QwikDev/qwik`, `BuilderIO/qwik`
 - Astro: `withastro/astro`, `withastro/docs`, `withastro/starlight`
 - Next.js: `vercel/next.js`
 - Nuxt: `nuxt/nuxt`, `nuxt/ui`, `nuxt/content`, `nuxt/image`
 - Remix/React Router: `remix-run/react-router`, `remix-run/remix`
 - TanStack Start: `TanStack/router`, `TanStack/start`
- Stable IDs:
 - Framework: `framework:<slug>`
 - Repo: `github:<owner>/<repo>`
 - Release: `github-release:<owner>/<repo>:<tag_name>`
 - Registry candidate: `github-candidate:<owner>/<repo>`
- Wiki outputs:
 - `wiki/topics/frontend-frameworks-public.md` as the clickable hub.
 - `wiki/entities/frontend-frameworks/<framework>.md` for each framework.
 - `wiki/sources/frontend-frameworks/<owner>-<repo>.md` for each repo.
 - `wiki/sources/frontend-frameworks/releases/<owner>-<repo>-<tag>.md` only for meaningful releases.
 - `wiki/analyses/frontend-framework-taxonomy.md` grouped by UI framework, meta-framework, compiler/runtime, router/state, docs/tooling.
 - `wiki/analyses/frontend-framework-idea-map.md` explaining what each project is trying to do and what ideas/releases introduced.
- Add home/index links so the user can click from wiki home/index into framework, repo, release, language, and category pages.

## Ingest Behavior
- GitHub source coverage per repo:
 - repo metadata, stars/forks, topics, license, default branch, latest commit SHA, languages API, repo tree sample, README path/hash, changelog path/hash if present.
 - GitHub releases via `/repos/{owner}/{repo}/releases`, including tag, published date, author, prerelease flag, URL, body hash, and short summary.
 - Do not copy full source code into public wiki.
- Classification fields:
 - `framework_slug`, `ecosystem_role`, `primary_language`, `file_extension_profile`, `license`, `public_handling`, `source_confidence`, `semantic_hash`.
 - `ecosystem_role` values: `ui-framework`, `meta-framework`, `compiler-runtime`, `router`, `state-management`, `docs`, `devtools`, `component-system`, `content`, `image`, `starter-or-examples`.
- Release summaries:
 - Extract high-signal bullets from release body: breaking changes, new APIs, compiler/runtime changes, routing/data changes, migration notes.
 - Store full release body hash and canonical GitHub URL; public page uses concise summary.
- Candidate discovery:
 - For each registry owner/org, list repos weekly and record candidates only when repo name/topic/description matches framework-specific keywords.
 - Candidates go into manifest as `candidate` and a “Needs Review” section, but are not promoted to official corpus pages until a future registry update confirms them.

## Automation
- Add Codex automation `update-frontend-frameworks-public-corpus`.
- Schedule: weekly Monday after existing corpus jobs, model `gpt-5.5`, reasoning `medium`.
- Prompt behavior:
 - Run `scripts/ingest-frontend-frameworks-public.ps1 -Mode Digest`.
 - Inspect output and `raw/frontend-frameworks-public/manifest.json`.
 - Run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`.
 - Stage only the frontend-framework corpus paths, `wiki/index.md`, `wiki/log.md`, and `wiki/catalog.json`.
 - Commit `Update frontend frameworks public corpus` and push `origin/main` only when stable IDs, semantic hashes, releases, or registry evidence changed.
 - Ignore unrelated local changes such as `GetPdf.pdf` and caches.

## Test Plan
- Dry run:
 - `scripts/ingest-frontend-frameworks-public.ps1 -DryRun`
 - Confirm it discovers all 12 frameworks and does not write files.
- First real ingest:
 - Confirm manifest has no duplicate stable IDs.
 - Confirm every repo page links back to its framework and taxonomy.
 - Confirm every release page links to repo, framework, and GitHub release URL.
- Validation:
 - `scripts/wiki-catalog.ps1`
 - `scripts/wiki-lint.ps1`
 - `git diff --check`
- Acceptance criteria:
 - From `wiki/topics/frontend-frameworks-public.md`, user can click into each framework, then each official repo, then each captured release.
 - Search works for framework names, repo names, languages, file extensions, and release ideas.
 - Public pages contain summaries/links/hashes, not full unlicensed code dumps.

## Assumptions
- “完整 GitHub” means complete within the curated official framework-related repo registry, not entire owner organizations.
- First version prioritizes high-quality navigability over exhaustive ecosystem breadth.
- Weekly updates are enough; urgent one-off refreshes can run the same script manually.
- Existing `GITHUB_TOKEN` or `GH_TOKEN` should be used when available to avoid rate limits; unauthenticated fallback records rate-limit errors instead of inventing missing data.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
