---
title: LLM Wiki Pattern
type: source
status: ingested
created: 2026-04-21
updated: 2026-04-21
tags:
  - source
  - knowledge-base
  - llm
origin: chat
provenance: User provided an idea brief in chat describing a pattern for building personal knowledge bases using LLMs.
---

# LLM Wiki Pattern

## Source Summary

The source describes a pattern for building personal knowledge bases where an LLM does not merely retrieve from raw documents at query time, but incrementally maintains a persistent wiki between the human and the raw sources.

## Key Claims

- Traditional RAG repeatedly rediscovers relevant knowledge from scratch at query time.
- A maintained wiki compounds understanding because synthesis is stored persistently.
- The wiki should be LLM-authored and LLM-maintained, while the human focuses on curation and interpretation.
- Three layers matter:
  - raw sources
  - wiki
  - schema/instruction file
- Three recurring operations matter:
  - ingest
  - query
  - lint
- `index.md` and `log.md` help the agent navigate and maintain the system without requiring full RAG infrastructure at small scale.

## Concrete Design Ideas Mentioned

- use Obsidian as the browsing and editing environment
- keep raw sources immutable
- file good answers back into the wiki
- optionally add local search tools as the wiki scales
- optionally use local image downloads so the agent can inspect visuals separately

## Relevance To This Repository

This source directly motivates the structure of `vipin wiki`.

It establishes:

- why the wiki exists
- why `AGENTS.md` is important
- why `index.md` and `log.md` should be maintained carefully

## Related Pages

- [[llm-wiki]]
- [[vipin]]
- [[2026-04-21-vipin-wiki-bootstrap]]

