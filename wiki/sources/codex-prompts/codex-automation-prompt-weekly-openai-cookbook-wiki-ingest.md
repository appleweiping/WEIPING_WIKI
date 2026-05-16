---
title: Refresh the OpenAI Cookbook mirror in vipin wiki. Work in D -/Research/vipin's...
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

# Refresh the OpenAI Cookbook mirror in vipin wiki. Work in D:/Research/vipin's...

## Metadata

- Stable ID: `codex-automation-prompt:weekly-openai-cookbook-wiki-ingest`
- Source kind: `codex-automation`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T17:48:10.514893+00:00`
- Semantic hash: `77e829b5a72d2d49b26be2424d739da02f8568fcbf0c1aa0ccd39f0217a21346`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Refresh the OpenAI Cookbook mirror in vipin wiki. Work in D:/Research/vipin's knowledgebase. Ignore unrelated local changes such as GetPdf.pdf. Run .\scripts\ingest-openai-cookbook.ps1 -Root . to fetch https://developers.openai.com/cookbook, map entries to openai/openai-cookbook sources, update raw/openai-cookbook/manifest.json, wiki/topics/openai-cookbook.md, wiki/sources/2026-05-15-openai-cookbook.md, wiki/analyses/openai-cookbook-taxonomy.md, wiki/sources/openai-cookbook/, wiki/index.md, and wiki/log.md. Then run .\scripts\wiki-catalog.ps1 -Root . and .\scripts\wiki-lint.ps1 -Root .. If there are scoped Cookbook/wiki changes, stage only scripts/ingest-openai-cookbook.ps1, raw/openai-cookbook/, wiki/topics/openai-cookbook.md, wiki/sources/2026-05-15-openai-cookbook.md, wiki/analyses/openai-cookbook-taxonomy.md, wiki/sources/openai-cookbook/, wiki/index.md, wiki/log.md, and wiki/catalog.json; commit with message "Update OpenAI Cookbook ingest"; push origin main. Summarize added, changed, and removed Cookbook entries.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
