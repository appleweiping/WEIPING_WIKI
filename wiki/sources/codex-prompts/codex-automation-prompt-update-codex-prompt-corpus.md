---
title: Run the weekly update for the selected local Codex prompt corpus in the vipin...
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

# Run the weekly update for the selected local Codex prompt corpus in the vipin...

## Metadata

- Stable ID: `codex-automation-prompt:update-codex-prompt-corpus`
- Source kind: `codex-automation`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T17:48:10.373912+00:00`
- Semantic hash: `788b04c573b7a3fa893e3e5afe9d72aa00cdf411ca0b9e2a8c4b974a7fe2070e`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Run the weekly update for the selected local Codex prompt corpus in the vipin wiki repository. From the repo root, run `scripts/ingest-codex-prompts-public.ps1 -SinceDays 14`, inspect output and `raw/codex-prompts-public/manifest.json`, then run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`. Treat user-authored prompts and automation prompts as first-class sources, but only preserve clean, high-quality prompts. Exclude short prompts, duplicate prompts, garbled/mojibake text, code/log/traceback/server dumps, copied repository files, and secret-like/private material. Public pages may include full selected prompt text only after filtering; rejected candidate details stay as raw audit metadata and should not create public full-text pages. Respect stable IDs (`codex-user-prompt:<hash>`, `codex-automation-prompt:<automation_id>`), `dedupe_key`, and `semantic_hash`; never duplicate already-seen prompts. If there are scoped changes under `scripts/ingest-codex-prompts-public.ps1`, `raw/codex-prompts-public/`, `wiki/topics/codex-prompt-corpus.md`, `wiki/sources/codex-prompts/`, `wiki/analyses/codex-prompt-taxonomy.md`, `wiki/index.md`, `wiki/log.md`, or `wiki/catalog.json`, stage only those paths, commit with message `Update Codex prompt corpus`, and push to `origin/main`. Ignore unrelated local changes, especially untracked `GetPdf.pdf` and caches under `.wiki-tmp/`. If no selected prompt metadata or semantic hash changed, do not create a noisy commit; report no changes.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
