---
title: Run the daily light capture for the Lidang public ideas corpus in the vipin w...
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

# Run the daily light capture for the Lidang public ideas corpus in the vipin w...

## Metadata

- Stable ID: `codex-automation-prompt:light-crawl-lidang-public-ideas`
- Source kind: `codex-automation`
- Category: `automation`
- Timestamp: `2026-05-16T17:48:10.449700+00:00`
- Semantic hash: `e1ad0cd438e98b89b3d78b053862b7de2bd0bc2a4c9cc996cba13a4123327497`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Run the daily light capture for the Lidang public ideas corpus in the vipin wiki repository. From the repo root, run `scripts/ingest-lidang-public.ps1 -Mode Light -SkipValidation`. Inspect the output and `raw/lidang-public/manifest.json`. Treat HTML as a first-class raw source: reachable X/profile HTML snapshots belong under `raw/lidang-public/html/`, while public wiki pages remain curated Markdown summaries. Respect stable IDs (`youtube:<video_id>`, `x-status:<status_id>`, `x-profile:lidangzzz`), `dedupe_key`, and `semantic_hash`; never duplicate an already-seen item, and do not treat volatile full HTML changes as semantic updates. Commit only when a new stable ID, changed semantic metadata, or new raw HTML/provenance record creates a scoped change under `raw/lidang-public/` or `scripts/ingest-lidang-public.ps1`. Stage only those paths, commit with message `Capture Lidang public ideas`, and push to `origin/main`. Ignore unrelated local changes, especially untracked `GetPdf.pdf` and caches under `.wiki-tmp/`. If no new public metadata or raw evidence changed, do not create a noisy commit; report no changes.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
