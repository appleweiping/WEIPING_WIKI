---
title: Overview
type: overview
status: active
created: 2026-04-21
updated: 2026-05-24
tags:
  - overview
  - structure
---

# Overview

This page describes the current operating shape of `vipin wiki`.

## Layers

- Public wiki: `wiki/`
- Private local-only wiki: maintained in a separate local-only layer
- Raw sources: `raw/`
- Reader layer: `reader-context.md`
- Operating layer: `AGENTS.md`, `.wiki-schema.md`, `WORKFLOWS.md`, `CONTRIBUTIONS.md`, `.codex/skills/vipin-wiki/`, and `scripts/`
- Public website layer: `site/` publishes the public `wiki/` layer through Quartz and GitHub Pages.

## Active Public Domains

- [[llm-wiki]]
- [[llm-based-recommendation]]
- [[personal-knowledge-systems]]
- [[2026-04-21-llm-rec-research-map]]

## Section Entrypoints

- [[home]]
- [[index]]
- [[queries-home]]
- [[synthesis-home]]
- [[timelines-home]]
- [[topics-home]]
- [[comparisons-home]]

## Automation Modules (2026-05-24)

Five new operational scripts added to `scripts/`:

- `wiki-scheduler.py` — automated ingest scheduler (10 jobs, cron-style, daemon mode, Windows Task Scheduler install)
- `wiki-graph.py` — knowledge graph query CLI (search, neighbors, path, communities, god nodes, bridges, export)
- `wiki-dashboard.py` — agent performance dashboard (terminal + HTML, token summary inline)
- `wiki-tokens.py` — token usage tracker (per-agent cost, 7-day rolling, HTML section)
- `ingest_github.py` + `ingest_karpathy.py` — Python ingest base replacing PowerShell scripts

## Notes

- Search and context assembly now use a shared parser/index core so catalog, search, context, status, and lint share one interpretation of pages.
- The default query loop is fast answer first, durable ingest second.
- Private holdings stay outside public indexes and public logs.
- Collection-style ingest is now a first-class workflow alongside one-by-one ingest.
- Generated graph artifacts remain optional because Quartz provides website search, backlinks, and graph navigation.
- A project-local Codex skill now routes future agents through the wiki's query, ingest, crystallization, maintenance, and public/private safety workflows.
- Knowledge graph (graphify) is updated incrementally via post-commit hook; `wiki-graph.py` provides query interface.
