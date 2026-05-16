---
title: Run the weekly update for the Shunyu Yao public corpora in the vipin wiki rep...
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

# Run the weekly update for the Shunyu Yao public corpora in the vipin wiki rep...

## Metadata

- Stable ID: `codex-automation-prompt:update-shunyu-yao-public-corpora`
- Source kind: `codex-automation`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T17:48:10.470319+00:00`
- Semantic hash: `97f655494c4f8c4397face5a1f3a778c962c85ceb1b10511c75bdb90939bc587`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Run the weekly update for the Shunyu Yao public corpora in the vipin wiki repository. From the repo root, run `scripts/ingest-shunyu-yao-public.ps1 -Person All`, summarize additions/changes/removals/errors from both `raw/yao-shunyu-ysymyth/manifest.json` and `raw/yao-shunyu-alfred/manifest.json`, then run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`. Keep the two identities separate: `ysymyth` is the OpenAI language-agents researcher; `alfredyao` is the physics-to-AI Google DeepMind/Anthropic researcher. Use stable IDs and `semantic_hash`; do not duplicate already-seen items, and do not remove old manifest items merely because an upstream source is temporarily blocked or rate-limited. Use safe public indexing: metadata, summaries, links, hashes, categories, and license notes only; do not publicly mirror unclear-license full PDFs, webpages, or source code. If there are scoped changes under `scripts/ingest-shunyu-yao-public.ps1`, `raw/yao-shunyu-ysymyth/`, `raw/yao-shunyu-alfred/`, `wiki/entities/yao-shunyu-ysymyth.md`, `wiki/entities/yao-shunyu-alfred.md`, `wiki/topics/shunyu-yao-public-corpora.md`, `wiki/sources/2026-05-16-yao-shunyu-public-corpora.md`, `wiki/sources/shunyu-yao/`, `wiki/analyses/shunyu-yao-project-taxonomy.md`, `wiki/analyses/shunyu-yao-paper-map.md`, `wiki/analyses/public-corpus-ingest-workflow.md`, `wiki/index.md`, `wiki/log.md`, `wiki/catalog.json`, or `AGENTS.md`, stage only those paths, commit with message `Update Shunyu Yao public corpora`, and push to `origin/main`. Ignore unrelated local changes, especially untracked `GetPdf.pdf`. If no corpus changes occurred, do not create a noisy commit; report no changes.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
