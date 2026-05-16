---
title: Lidang Public Ideas
type: topic
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - lidang
  - public-ideas
  - heuristics
source_pages:
  - https://www.youtube.com/feeds/videos.xml?channel_id=UC4gzU_8MxRDiQrSFOiT79tQ
  - https://x.com/lidangzzz
---

# Lidang Public Ideas

This hub tracks Lidang's public idea stream as a high-frequency corpus. The system favors batch summaries, confidence labels, and topic clustering over one page per short post.

## Current Corpus Shape

- `x-profile-probe`: 1
- `x-status-manual-search`: 1
- `youtube-video`: 15

## Core Use

- Use [[lidang-idea-taxonomy]] to navigate topics.
- Use [[2026-05-16-what-indexes-did-lidang-recommend]] for the SP500 / Nasdaq-100 clarification.
- Use [[lidang-weekly-digests]] for chronological batches.
- Use high-signal single-item pages only when an item is substantial enough to justify durable retrieval.
- Use source confidence labels before citing any X-derived item.

## Maintenance Rules For Future Agents

- Treat HTML as a first-class raw source format for X/profile probes; store reachable snapshots under `raw/lidang-public/html/`.
- Use `semantic_hash` rather than raw full HTML hash for wiki churn decisions.
- Never create a second item for a stable ID that already exists in `raw/lidang-public/manifest.json`.
- Continue backfill attempts for older reachable YouTube/X items, but add them only when their stable IDs are absent.
- Do not flood `wiki/index.md` with every short post.
- Keep X mirror text out of public pages unless a license-safe source exists.
- Record failed mirror probes because failures are operationally useful.
- Prefer weekly synthesis over raw accumulation.

## Related

- [[lidang]]
- [[2026-05-16-lidang-public-corpus]]
- [[lidang-idea-taxonomy]]
- [[lidang-weekly-digests]]

## Counterpoints And Gaps

- The current corpus is not a complete X archive.
- YouTube RSS only exposes recent videos, so historical video backfill remains dependent on optional tooling or future source access.
- Short-form public statements can be context-dependent and should not be over-interpreted without source review.
