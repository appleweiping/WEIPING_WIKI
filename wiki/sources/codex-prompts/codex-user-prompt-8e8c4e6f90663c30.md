---
title: PLEASE IMPLEMENT THIS PLAN -
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - wiki-ingest
source_pages:
  - codex-prompt-corpus
---

# PLEASE IMPLEMENT THIS PLAN:

## Metadata

- Stable ID: `codex-user-prompt:8e8c4e6f90663c30`
- Source kind: `codex-session-user`
- Category: `wiki-ingest`
- Timestamp: `2026-05-15T23:18:58.716Z`
- Semantic hash: `8e8c4e6f90663c3039a2635ce6ebc372d955ea4e805764ff965d96b8a68391fc`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# Improve Lidang Ingest: HTML Snapshots + Dedup/Backfill Guarantees

## Summary
- Yes: use HTML as a first-class raw source format. For X especially, save reachable official/profile HTML snapshots because HTML preserves structure, scripts, links, and future extraction opportunities better than lossy Markdown.
- Keep public wiki pages as curated Markdown summaries, but store raw/cached HTML under `raw/lidang-public/html/` with hashes and provenance.
- Strengthen the automation so future Codex runs never duplicate already-seen items, only mark real changes, and keep trying to backfill older uncollected items.

## Key Changes
- Update `scripts/ingest-lidang-public.ps1`:
 - Save reachable HTML responses for X canonical profile and mirrors to `raw/lidang-public/html/`.
 - Add manifest fields: `raw_html_path`, `raw_html_hash`, `semantic_hash`, `first_seen`, `last_seen`, `last_changed`, `crawl_status`, `backfill_status`.
 - Keep `id` stable:
 - YouTube: `youtube:<video_id>`
 - X status: `x-status:<status_id>`
 - X profile probe: `x-profile:lidangzzz`
 - Use `semantic_hash` for change detection, not volatile full HTML alone.
 - Treat raw HTML changes as source snapshots, but avoid wiki churn unless extracted item metadata or summary actually changes.
- Add backfill logic:
 - YouTube RSS remains daily/current source.
 - Add optional historical YouTube metadata backfill using a project-local tool/cache when available, storing old video IDs without duplicating RSS items.
 - For X, parse official HTML and mirrors for status IDs when available; if no status links appear, preserve HTML snapshot and record `no-status-links-found`.
- Update wiki guidance:
 - `wiki/topics/lidang-public-ideas.md` records that HTML snapshots are preferred raw evidence for X/profile pages.
 - `wiki/sources/2026-05-16-lidang-public-corpus.md` records dedupe/backfill rules so future agents know not to re-ingest the same item.
 - `wiki/analyses/lidang-weekly-digests.md` explains that weekly digests aggregate only new/changed semantic items.

## Automation Rules
- Daily Light:
 - Fetch current RSS, X profile HTML, and mirror HTML.
 - Append/update manifest only when a new stable `id` appears or semantic metadata changes.
 - Save raw HTML snapshots with content hash, but do not create duplicate items.
- Weekly Digest:
 - Generate/update wiki only for new items, changed semantic items, or newly promoted high-signal items.
 - Continue attempting historical backfill until all reachable older YouTube/X items are marked `seen`, `unreachable`, or `blocked`.
- Commit policy:
 - No commit for pure repeat crawls with no new IDs and no semantic changes.
 - Commit scoped changes only under Lidang raw/script/wiki paths.

## Test Plan
- Run Light twice: second run must report zero new item IDs and no duplicate manifest entries.
- Run Digest twice: second run must not create duplicate weekly items or noisy wiki/log churn.
- Validate:
 - HTML snapshots exist for reachable X/profile pages.
 - manifest parses with Python `json`.
 - every item has stable `id`, `dedupe_key`, `semantic_hash`, and `first_seen`.
 - `wiki-catalog.ps1`, `wiki-lint.ps1`, and `git diff --check` pass.
- Acceptance:
 - Existing 16 entries remain stable.
 - New future videos/status links are added once.
 - Old/backfilled items are added only if their stable ID was not already present.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
