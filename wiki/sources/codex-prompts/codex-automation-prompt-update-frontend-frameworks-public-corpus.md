---
title: Run the weekly update for the frontend project frameworks public corpus in th...
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - wiki-ingest
source_pages:
  - codex-prompt-corpus
---

# Run the weekly update for the frontend project frameworks public corpus in th...

## Metadata

- Stable ID: `codex-automation-prompt:update-frontend-frameworks-public-corpus`
- Source kind: `codex-automation`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T17:48:10.486887+00:00`
- Semantic hash: `1fa572abb2cd7c26df3e13b1c601c0338561c2d4a4f134f7b1e069a0855c2161`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Run the weekly update for the frontend project frameworks public corpus in the vipin wiki repository. From the repo root, run `scripts/ingest-frontend-frameworks-public.ps1 -Mode Digest`, summarize additions/changes/removals/errors from its output and `raw/frontend-frameworks-public/manifest.json`, then run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`. Treat the corpus boundary as curated reusable frontend project shells, documentation/wiki frameworks, app frameworks, build tooling, and UI/runtime substrates, not whole GitHub organizations. Use stable IDs (`framework:<slug>`, `github:<owner>/<repo>`, `github-release:<owner>/<repo>:<tag_name>`, `github-candidate:<owner>/<repo>`), `dedupe_key`, and `semantic_hash`; never duplicate already-seen items. Candidate repos stay candidates unless `raw/frontend-frameworks-public/registry.json` explicitly includes them. Use safe public indexing: metadata, reuse profiles, docs/demo links, release idea bullets, links, hashes, categories, languages, shell scores, and license notes only; do not publicly mirror full source code or long unlicensed release text. Keep Quartz/Docusaurus/VitePress/Nextra/Fumadocs/Starlight/Astro/Next/Nuxt/SvelteKit/Remix/Vite/Nitro as project-shell first-class entries, while React/Vue/Svelte/Solid stay marked as UI/runtime substrates unless registry notes say otherwise. If there are scoped changes under `scripts/ingest-frontend-frameworks-public.ps1`, `raw/frontend-frameworks-public/`, `wiki/topics/frontend-frameworks-public.md`, `wiki/entities/frontend-frameworks/`, `wiki/sources/2026-05-16-frontend-frameworks-public-corpus.md`, `wiki/sources/frontend-frameworks/`, `wiki/analyses/frontend-project-shell-taxonomy.md`, `wiki/analyses/frontend-framework-reuse-map.md`, `wiki/home.md`, `wiki/index.md`, `wiki/log.md`, or `wiki/catalog.json`, stage only those paths, commit with message `Update frontend frameworks public corpus`, and push to `origin/main`. Ignore unrelated local changes, especially untracked `GetPdf.pdf` and caches under `.wiki-tmp/`. If no upstream content changed, do not create a noisy commit; report no changes.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
