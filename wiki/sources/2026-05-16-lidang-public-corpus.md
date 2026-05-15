---
title: 2026-05-16 Lidang Public Corpus
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - lidang
  - public-corpus
  - ideas
source_pages:
  - https://www.youtube.com/feeds/videos.xml?channel_id=UC4gzU_8MxRDiQrSFOiT79tQ
  - https://www.youtube.com/@lidangzzz
  - https://x.com/lidangzzz
---

# 2026-05-16 Lidang Public Corpus

## Provenance

- YouTube RSS: https://www.youtube.com/feeds/videos.xml?channel_id=UC4gzU_8MxRDiQrSFOiT79tQ
- YouTube channel: https://www.youtube.com/@lidangzzz
- X canonical profile: https://x.com/lidangzzz
- Auxiliary non-authoritative mirror probes:
  - https://twstalker.com/lidangzzz
  - https://rattibha.com/lidangzzz
  - https://twicopy.com/lidangzzz/
- Manifest: `raw/lidang-public/manifest.json`
- Daily captures: `raw/lidang-public/inbox/`
- Raw HTML snapshots: `raw/lidang-public/html/YYYY-MM-DD/`

## Crawl Snapshot

- Mode: `Digest`
- YouTube RSS title: `立党 lidang`
- YouTube RSS exposed entries: 15
- Manifest entries: 16
- New entries this run: 0
- Changed semantic entries this run: 0
- Removed entries this run: 0
- Crawl errors recorded: 3
- Historical YouTube backfill status: `tool-unavailable`

## Source Kinds

- `x-profile-probe`: 1
- `youtube-video`: 15

## X / Mirror Probe Results

- https://x.com/lidangzzz: status `200`, ok `True`, status links 0, raw HTML `raw/lidang-public/html/2026-05-16/x-com-lidangzzz.html`, crawl `ok-no-status-links-found`, backfill `no-status-links-found`, note ``
- https://twstalker.com/lidangzzz: status `ERR`, ok `False`, status links 0, raw HTML ``, crawl `error`, backfill `unreachable-or-blocked`, note `Exception calling 'DownloadData' with '1' argument(s): 'The remote server returned an error: (403) Forbidden.'`
- https://rattibha.com/lidangzzz: status `ERR`, ok `False`, status links 0, raw HTML ``, crawl `error`, backfill `unreachable-or-blocked`, note `Exception calling 'DownloadData' with '1' argument(s): 'The remote server returned an error: (403) Forbidden.'`
- https://twicopy.com/lidangzzz/: status `ERR`, ok `False`, status links 0, raw HTML ``, crawl `error`, backfill `unreachable-or-blocked`, note `Exception calling 'DownloadData' with '1' argument(s): 'The remote server returned an error: (525) <none>.'`

## Dedup And Backfill Rules

- EXTRACTED: Stable IDs are mandatory: `youtube:<video_id>`, `x-status:<status_id>`, and `x-profile:lidangzzz`.
- INFERRED: `semantic_hash` drives change detection; volatile full HTML changes are raw evidence, not wiki-update triggers by themselves.
- EXTRACTED: `dedupe_key` must be stable and must not use a run-specific timestamp or full HTML hash.
- INFERRED: Repeated Light or Digest runs should not duplicate items, refresh `last_seen` noisily, or append new log entries unless a new stable ID or semantic change appears.
- INFERRED: Backfill should continue until reachable older YouTube/X items are marked `seen`, `unreachable`, `blocked`, `tool-unavailable`, or `no-status-links-found`.

## Public Handling Policy

- EXTRACTED: YouTube RSS is an official feed and can be used for public metadata.
- EXTRACTED: X canonical profile is the preferred public identity URL.
- EXTRACTED: Reachable X/profile HTML is cached as raw evidence because HTML preserves links and extraction opportunities better than lossy Markdown.
- AMBIGUOUS: Third-party mirrors may be incomplete, blocked, stale, or non-authoritative.
- INFERRED: Full X text from mirrors should not be mirrored publicly unless a reliable licensed source is added.
- INFERRED: This corpus should emphasize weekly clustering and high-signal pages because the source stream is frequent and uneven in density.

## Related

- [[lidang]]
- [[lidang-public-ideas]]
- [[lidang-idea-taxonomy]]
- [[lidang-weekly-digests]]
