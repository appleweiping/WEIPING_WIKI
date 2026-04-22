---
title: Karpathy Upgrade Session
type: synthesis
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - synthesis
  - session
  - llm-wiki
source_pages:
  - 2026-04-22-karpathy-llm-wiki-zh-compilation
---

# Karpathy Upgrade Session

## Goal

Upgrade `vipin wiki` from a strong starter system into a more complete personal knowledge workbench informed by Karpathy's `LLM Wiki` pattern and the strongest community extensions.

## Changes Landed

- added a first-class reader layer via `reader-context.md`
- added structured contribution tracking via `CONTRIBUTIONS.md`
- added machine-readable catalog generation via `scripts/wiki-catalog.py`
- added scored search via `scripts/wiki-search.py`
- added layered context packs via `scripts/wiki-context.py`
- added divergence-check language to schema, workflows, templates, and lint
- expanded source registry to include meetings and voice-note routes

## Why These Matter

- personalization changes what counts as salient knowledge
- search and context layers reduce the pressure to read the entire wiki every session
- counterpoint sections reduce the chance that the wiki becomes an echo chamber
- source-type-aware ingest makes the system more realistic for day-to-day use

## Counterpoints and Gaps

- this is still file-first rather than database-first
- voice workflows still depend on transcription quality
- richer search is now present, but not yet semantic or embedding-based

## Related

- [[llm-wiki]]
- [[personal-knowledge-systems]]
- [[llm-wiki-vs-rag]]
- [[2026-04-22-karpathy-llm-wiki-zh-compilation]]
