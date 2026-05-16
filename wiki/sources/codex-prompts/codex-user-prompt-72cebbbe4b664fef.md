---
title: Read the docs folder first.
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

# Read the docs folder first.

## Metadata

- Stable ID: `codex-user-prompt:72cebbbe4b664fef`
- Source kind: `codex-session-user`
- Category: `wiki-ingest`
- Timestamp: `2026-05-14T20:42:26.998Z`
- Semantic hash: `72cebbbe4b664fef6515f19f547a05544906119078760d379640828adb41dce5`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Read the docs folder first.

Task:
Implement the ingestion pipeline skeleton.

Scope:
- FileObject
- HealthDocument
- ParsingJob
- ExtractionJob
- TimelineEvent
- IngestionService
- LocalFileStorage
- MockDocumentParser

Non-goals:
- Do not implement real OCR yet.
- Do not call the LLM yet.
- Do not build UI.

Validation:
Uploading or creating a mock document should create FileObject, HealthDocument, ParsingJob, ExtractionJob, and TimelineEvent records with valid states.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
