---
title: Run the weekly digest for the Lidang public ideas corpus in the vipin wiki re...
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

# Run the weekly digest for the Lidang public ideas corpus in the vipin wiki re...

## Metadata

- Stable ID: `codex-automation-prompt:digest-lidang-public-ideas`
- Source kind: `codex-automation`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T17:48:10.460305+00:00`
- Semantic hash: `7a358d29fa3d0400d27ac5aacb4cb7bcab76a5e34956a421714f363d66bd47a1`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Run the weekly digest for the Lidang public ideas corpus in the vipin wiki repository. From the repo root, run `scripts/ingest-lidang-public.ps1 -Mode Digest`, summarize additions/changes/removals/errors/backfill status from the output and `raw/lidang-public/manifest.json`, then run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`. Weekly digests aggregate only new stable IDs, changed semantic items, and newly promoted high-signal items; raw HTML snapshot changes alone should not duplicate weekly items or churn public summaries. Continue historical backfill attempts for older reachable YouTube/X items, but add them only when their stable IDs are absent. Preserve public/private boundaries: raw HTML may live under `raw/lidang-public/html/`, but public wiki pages should contain metadata, summaries, hashes, confidence labels, and provenance rather than wholesale X/mirror text. If there are scoped changes under `scripts/ingest-lidang-public.ps1`, `raw/lidang-public/`, `wiki/entities/lidang.md`, `wiki/topics/lidang-public-ideas.md`, `wiki/sources/2026-05-16-lidang-public-corpus.md`, `wiki/sources/lidang-public/`, `wiki/analyses/lidang-idea-taxonomy.md`, `wiki/analyses/lidang-weekly-digests.md`, `wiki/index.md`, `wiki/log.md`, or `wiki/catalog.json`, stage only those paths, commit with message `Update Lidang public ideas corpus`, and push to `origin/main`. Ignore unrelated local changes, especially untracked `GetPdf.pdf`. If no digest-worthy changes occurred, do not create a noisy commit; report no changes.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
