---
title: LLM Wiki vs RAG
type: comparison
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - comparison
  - llm-wiki
  - rag
source_pages:
  - 2026-04-21-llm-wiki-pattern
  - 2026-04-22-karpathy-llm-wiki-zh-compilation
---

# LLM Wiki vs RAG

## Summary

RAG optimizes retrieval from raw material at query time.

An LLM wiki optimizes durable synthesis during ingest and maintenance.

## Compared Items

- RAG-style document QA
- LLM-maintained wiki compilation

## Similarities

- both can start from the same raw documents
- both can use markdown or text as source material
- both can answer grounded questions when configured well

## Differences

- RAG keeps raw chunks central; an LLM wiki keeps maintained pages central
- RAG synthesizes mainly at question time; an LLM wiki synthesizes during ingest and revision
- RAG can scale broader across large corpora; an LLM wiki compounds better for curated long-term domains

## Tradeoffs

- RAG is better for wide retrieval over large, fast-changing corpora
- an LLM wiki is better for compounding understanding, cross-links, contradictions, and reusable analyses
- an LLM wiki demands stronger maintenance rules, page hygiene, and durable workflow discipline

## Counterpoints and Gaps

- markdown-only wiki systems can hit scale and indexing problems that structured retrieval systems handle better
- RAG plus good memory layers may cover some of the same ground if the system stores durable intermediate outputs
- in practice, many teams will want a hybrid: curated wiki pages plus retrieval over raw material

## Recommendation

For Vipin's research-heavy, curated, evolving use case, the wiki model should be primary and RAG should be treated as an auxiliary retrieval layer rather than the center of the system.
