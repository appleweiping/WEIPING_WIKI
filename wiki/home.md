---
title: Vipin Wiki Home
type: overview
status: active
created: 2026-04-21
updated: 2026-05-10
tags:
  - wiki
  - overview
---

# Vipin Wiki

`vipin wiki` is a personal knowledge base maintained by an LLM agent.

Its purpose is not just to store documents, but to compile them into an evolving set of linked notes, summaries, entities, concepts, and analyses.

## Dashboard

- [[index]] - Full public catalog.
- [[queries-home]] - Reusable answers already preserved from conversations.
- [[topics-home]] - Durable subject clusters.
- [[synthesis-home]] - Longer-running synthesis pages.
- [[comparisons-home]] - Tradeoff and comparison notes.
- [[overview]] - Current structure and active domains.
- [[log]] - Chronological work record.

## Active Research And Knowledge Areas

- [[llm-based-recommendation]]
- [[personal-knowledge-systems]]
- [[llm-wiki]]
- [[university-housing]]
- [[2026-04-21-llm-rec-research-map]]

## Recent Durable Answers

- [[2026-05-08-which-umn-meal-plan-to-choose]]
- [[2026-05-08-how-to-choose-umn-apartment-vs-residence-hall-for-private-bedroom]]
- [[2026-05-08-how-to-integrate-venus-basestation-with-team-gitlab]]
- [[2026-05-05-how-to-solve-oauth-rt-rbac-security-quiz]]
- [[2026-05-05-how-to-understand-quantization-and-bit-rate]]

## Open Questions

- How should uncertainty be represented in LLM-based recommendation systems?
- Which recommendation papers deserve stable concept pages instead of source-only notes?
- Which repeated course/project questions should become topic pages?
- What website views make this knowledge base easier to revisit weekly?

## System Files

- [[index]]
- [[log]]
- [[overview]]

At the repository root, the main operating files are:

- `.wiki-schema.md`
- `WORKFLOWS.md`
- `reader-context.md`
- `CONTRIBUTIONS.md`
- `purpose.md`
- `AGENTS.md`

## Core Principle

Instead of re-deriving knowledge from raw files on every question, the agent incrementally builds a persistent wiki that accumulates understanding over time.

## Current Seed Pages

- [[index]]
- [[log]]
- [[overview]]
- [[vipin]]
- [[llm-wiki]]
- [[llm-based-recommendation]]
- [[personal-knowledge-systems]]
- [[llm-wiki-vs-rag]]
- [[2026-04-22-karpathy-llm-wiki-zh-compilation]]
- [[2026-04-21-llm-wiki-pattern]]
- [[2026-04-21-vipin-wiki-bootstrap]]

## Operating Loop

1. Add a source to `raw/`.
2. Ask the agent to ingest it.
3. Review updated wiki pages.
4. Ask new questions.
5. File useful answers back into the wiki.

## Near-Term Goals

- Establish a reliable ingest, search, and context workflow.
- Strengthen personalization, divergence checks, and durable query filing.
- Build core pages around Vipin's interests, projects, and long-term themes.
- Keep a running synthesis instead of scattered chat history.

