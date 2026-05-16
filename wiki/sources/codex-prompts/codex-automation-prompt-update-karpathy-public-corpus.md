---
title: Run the Karpathy public corpus ingest workflow in the vipin wiki repository....
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

# Run the Karpathy public corpus ingest workflow in the vipin wiki repository....

## Metadata

- Stable ID: `codex-automation-prompt:update-karpathy-public-corpus`
- Source kind: `codex-automation`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T17:48:10.499888+00:00`
- Semantic hash: `d8c4a834ae1143f67c605b4f0e4943f36c931a48775e145fce53eae2a0ebd0f7`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Run the Karpathy public corpus ingest workflow in the vipin wiki repository. Use `scripts/ingest-karpathy-public.ps1` from the repo root, summarize additions/changes/removals/errors from its output and `raw/karpathy-public/manifest.json`, then run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`. If there are scoped changes under `scripts/ingest-karpathy-public.ps1`, `raw/karpathy-public/`, `wiki/entities/andrej-karpathy.md`, `wiki/topics/karpathy-public-work.md`, `wiki/sources/2026-05-15-karpathy-public-corpus.md`, `wiki/sources/karpathy-public/`, `wiki/analyses/karpathy-project-taxonomy.md`, `wiki/analyses/karpathy-idea-map.md`, `wiki/index.md`, `wiki/log.md`, or `wiki/catalog.json`, stage only those paths, commit with message `Update Karpathy public corpus`, and push to `origin/main`. Ignore unrelated local changes, especially untracked `GetPdf.pdf` and caches under `.wiki-tmp/`. If no upstream content changed, do not create a noisy commit; report no changes instead.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
