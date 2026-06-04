---
title: WEIPING_WIKI Rename Upgrade
type: analysis
status: active
created: 2026-06-04
updated: 2026-06-04
tags:
  - weiping-wiki
  - maintenance
  - rename
  - agentmemory
source_pages:
  - weiping-wiki-maintenance-system
  - whole-computer-project-map
  - d-drive-project-map
source_files:
  - AGENTS.md
  - README.md
  - CLAUDE.md
  - .wiki-schema.md
  - purpose.md
  - reader-context.md
---

# WEIPING_WIKI Rename Upgrade

## Summary

EXTRACTED: On 2026-06-04, the public identity of this repository was upgraded from the historical `vipin wiki` / `vipinknowledge` / `vipin-wiki` naming family to `WEIPING_WIKI` / `Weiping Wiki`.

INFERRED: This is an operating-identity rename, not a rewrite of research project evidence. Existing research pages, experiment conclusions, datasets, checkpoints, server state, and dirty repo-local markdown `memory/` files are out of scope unless a later task explicitly targets them.

## Current Naming Rule

- Use `WEIPING_WIKI` for the system/project identity.
- Use `Weiping Wiki` in natural prose.
- Use `weiping-wiki` as the current skill name.
- Treat `vipin wiki`, `vipinknowledge`, and `vipin-wiki` as historical aliases for old paths, old prompts, old wiki slugs, and compatibility automation.
- Do not change GitHub remotes, public URLs, generated site wiring, or filesystem paths merely because the operating identity changed.

## Memory And Collaboration Boundary

EXTRACTED: The active collaboration layer is `agentmemory`; the repo-local markdown `memory/` tree is historical/superseded unless the user explicitly asks to work with it.

INFERRED: Rename/upgrade work should continue to be agentmemory-first: recall active context when it matters, record durable decisions after important work, and promote public-safe stable knowledge into `wiki/` rather than dual-writing raw session dumps.

## Public And Private Boundary

EXTRACTED: Public-facing durable knowledge belongs in `wiki/`; sensitive material belongs in ignored private layers or other local-only state.

INFERRED: The rename should not expose private paths, private chats, credentials, account state, logs, DBs, or raw personal material. It should also avoid changing raw source folders, private wiki layers, and existing dirty memory files unless a future task explicitly scopes them.

## Research Integrity Boundary

EXTRACTED: Research project pages and external project workbenches keep their own evidence gates. Wiki maintenance must not fabricate evidence, weaken claim labels, or alter experiment progress.

INFERRED: For this rename, safe edits are limited to identity, routing, maintenance-system language, index/log/catalog metadata, and compatibility alias pages. Any future research-facing rename should be treated as a separate evidence-audited task.

## Files To Prefer Going Forward

- Current maintenance concept: [[weiping-wiki-maintenance-system]]
- Historical alias page: [[vipinknowledge-maintenance-system]]
- First routing maps: [[whole-computer-project-map]] and [[d-drive-project-map]]
- Active collaboration model: [[agentmemory-first-agent-collaboration]]

## Counterpoints And Gaps

- Some generated artifacts, site adapter config, old analysis pages, and ingested historical prompts still contain old names. That is expected where they are historical records or compatibility surfaces.
- The local repository folder remains `D:\Research\vipin's knowledgebase` in this pass; changing filesystem paths or GitHub remotes would require a separate migration plan.
