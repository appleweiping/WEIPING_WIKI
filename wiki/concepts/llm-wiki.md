---
title: LLM Wiki
type: concept
status: active
created: 2026-04-21
updated: 2026-04-22
tags:
  - concept
  - knowledge-base
  - llm
source_pages:
  - 2026-04-21-llm-wiki-pattern
---

# LLM Wiki

An `LLM Wiki` is a knowledge-management pattern in which an LLM continuously compiles raw source material into a persistent, structured, interlinked markdown wiki.

## Core Idea

The key shift is from query-time rediscovery to persistent synthesis.

Instead of retrieving raw chunks from source documents every time a question is asked, the agent incrementally updates durable pages that already contain summaries, cross-links, contradictions, and emerging synthesis.

## Core Layers

1. Raw sources: immutable source-of-truth materials.
2. Wiki: the maintained knowledge layer.
3. Schema: the instruction file that tells the LLM how to operate consistently.

## Why It Matters

- knowledge compounds over time
- cross-references persist
- contradictions can be tracked explicitly
- useful answers do not disappear into chat history
- maintenance work becomes cheap enough to sustain

## Operational Modes

- Ingest: read a source and integrate it into the wiki.
- Query: answer questions from the wiki and optionally file the result.
- Lint: inspect the wiki for gaps, stale claims, or structural issues.

## Practical Extensions

- personalization layer: summaries and prioritization should account for the reader, not only the source
- layered context packs: load L0/L1/L2/L3 context instead of the full wiki every time
- dual output: good work produces both a user-facing answer and durable wiki updates
- divergence check: important pages should preserve counterarguments and data gaps
- structured catalog and search: index files remain useful, but machine-readable cataloging helps at larger scale

## Counterpoints and Gaps

- at larger scale, handwritten markdown indexes alone may become fragile
- graph interfaces can be helpful, but they are secondary to ingest discipline, page quality, and searchable structure
- pure wiki compilation still benefits from selective retrieval over raw sources when the maintained layer is incomplete

## Related

- [[vipin]]
- [[2026-04-21-llm-wiki-pattern]]
- [[2026-04-21-vipin-wiki-bootstrap]]
- [[2026-04-22-karpathy-llm-wiki-zh-compilation]]
- [[personal-knowledge-systems]]

