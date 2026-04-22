---
title: Vipin Wiki Home
type: overview
status: active
created: 2026-04-21
updated: 2026-04-22
tags:
  - wiki
  - overview
---

# Vipin Wiki

`vipin wiki` is a personal knowledge base maintained by an LLM agent.

Its purpose is not just to store documents, but to compile them into an evolving set of linked notes, summaries, entities, concepts, and analyses.

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

