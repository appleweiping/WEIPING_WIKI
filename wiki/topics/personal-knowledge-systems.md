---
title: Personal Knowledge Systems
type: topic
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - topic
  - knowledge-systems
  - llm-wiki
source_pages:
  - 2026-04-21-llm-wiki-pattern
  - 2026-04-22-karpathy-llm-wiki-zh-compilation
---

# Personal Knowledge Systems

## Scope

This topic covers systems that help one person accumulate, structure, revisit, and refine knowledge over time.

## Core Questions

- when should knowledge be compiled into durable pages versus retrieved on demand?
- what kinds of maintenance should be automated?
- how should reader preferences shape summaries and organization?
- what breaks first as the wiki grows?

## Key Pages

- [[llm-wiki]]
- [[llm-wiki-vs-rag]]
- [[2026-04-22-karpathy-llm-wiki-zh-compilation]]

## Major Claims

- personal knowledge systems fail more from maintenance burden than from lack of information
- a durable middle layer can make future queries cheaper and higher quality
- personalization and context layering become critical as the wiki scales

## Counterpoints and Gaps

- markdown-only systems may still need structured indexing or database support at larger scale
- too much automation can create a polished but weakly trusted wiki if sourcing gets sloppy
- graph-heavy interfaces can distract from the real bottlenecks of ingest quality and durable retrieval

## Next Sources To Ingest

- practical case studies of long-running Obsidian-based research vaults
- critiques of markdown-only PKM scaling
- examples of speech-first capture workflows
