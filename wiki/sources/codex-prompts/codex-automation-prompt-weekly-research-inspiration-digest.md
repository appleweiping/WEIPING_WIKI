---
title: Run the weekly research inspiration digest in the vipin wiki repository. From...
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

# Run the weekly research inspiration digest in the vipin wiki repository. From...

## Metadata

- Stable ID: `codex-automation-prompt:weekly-research-inspiration-digest`
- Source kind: `codex-automation`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T17:48:10.385442+00:00`
- Semantic hash: `e1c83e292b4386f5b32161f30737e9ccfd4af3e3b2a145494ce84827e514575c`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Run the weekly research inspiration digest in the vipin wiki repository. From the repo root, run `scripts/ingest-weekly-research-digest.ps1`, inspect output and `raw/weekly-research-digests/manifest.json`, then run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`. Capture exactly one high-signal weekly item for each track: AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology. Prefer a blend of arXiv/Semantic Scholar/PapersWithCode/GitHub/official research surfaces when available. Preserve abstracts or source summaries, concise plain-language core idea, canonical links, signal score, comparison/chart data, and agent reuse notes. Do not copy long paper text or full webpages. Treat the digest as inspiration and routing, not exhaustive literature review or final evidence. If there are scoped changes under `scripts/ingest-weekly-research-digest.ps1`, `raw/weekly-research-digests/`, `wiki/topics/weekly-research-digests.md`, `wiki/analyses/weekly-research-digest-*.md`, `wiki/sources/weekly-research-digests/`, `wiki/index.md`, `wiki/log.md`, or `wiki/catalog.json`, stage only those paths, commit with message `Add weekly research inspiration digest`, and push to `origin/main`. Ignore unrelated local changes, especially untracked `GetPdf.pdf` and caches under `.wiki-tmp/`. If no digest-worthy content changed, do not create a noisy commit; report no changes.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
