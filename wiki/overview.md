---
title: Overview
type: overview
status: active
created: 2026-04-21
updated: 2026-05-13
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

## Notes

- Search and context assembly now use a shared parser/index core so catalog, search, context, status, and lint share one interpretation of pages.
- The default query loop is fast answer first, durable ingest second.
- Private holdings stay outside public indexes and public logs.
- Collection-style ingest is now a first-class workflow alongside one-by-one ingest.
- Generated graph artifacts remain optional because Quartz provides website search, backlinks, and graph navigation.
- A project-local Codex skill now routes future agents through the wiki's query, ingest, crystallization, maintenance, and public/private safety workflows.
