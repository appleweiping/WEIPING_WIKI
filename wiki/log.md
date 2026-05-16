---
title: Log
type: log
status: active
created: 2026-04-21
updated: 2026-05-15
tags:
  - log
---

# Log
## [2026-05-16 00:56] ingest | lidang public ideas corpus

- Pages created or updated:
  - [[lidang]]
  - [[lidang-public-ideas]]
  - [[2026-05-16-lidang-public-corpus]]
  - [[lidang-idea-taxonomy]]
  - [[lidang-weekly-digests]]
  - `wiki/sources/lidang-public/`
- Sources used:
  - https://www.youtube.com/feeds/videos.xml?channel_id=UC4gzU_8MxRDiQrSFOiT79tQ
  - https://www.youtube.com/@lidangzzz
  - https://x.com/lidangzzz
  - auxiliary mirror probes listed in the manifest
- Notes:
  - Ingested 16 public corpus entries in `Digest` mode.
  - New entries this run: 0.
  - Changed entries this run: 1.
  - Removed entries this run: 0.
  - Crawl errors recorded: 3.
  - Manifest stored at `raw/lidang-public/manifest.json`.
## [2026-05-16 00:57] ingest | lidang public ideas corpus

- Pages created or updated:
  - [[lidang]]
  - [[lidang-public-ideas]]
  - [[2026-05-16-lidang-public-corpus]]
  - [[lidang-idea-taxonomy]]
  - [[lidang-weekly-digests]]
  - `wiki/sources/lidang-public/`
- Sources used:
  - https://www.youtube.com/feeds/videos.xml?channel_id=UC4gzU_8MxRDiQrSFOiT79tQ
  - https://www.youtube.com/@lidangzzz
  - https://x.com/lidangzzz
  - auxiliary mirror probes listed in the manifest
- Notes:
  - Ingested 16 public corpus entries in `Digest` mode.
  - New entries this run: 0.
  - Changed entries this run: 1.
  - Removed entries this run: 0.
  - Crawl errors recorded: 3.
  - Manifest stored at `raw/lidang-public/manifest.json`.
## [2026-05-16 01:25] ingest | lidang html snapshots and dedupe rules

- Pages created or updated:
  - [[lidang]]
  - [[lidang-public-ideas]]
  - [[2026-05-16-lidang-public-corpus]]
  - [[lidang-idea-taxonomy]]
  - [[lidang-weekly-digests]]
  - `wiki/sources/lidang-public/`
- Sources used:
  - https://www.youtube.com/feeds/videos.xml?channel_id=UC4gzU_8MxRDiQrSFOiT79tQ
  - https://www.youtube.com/@lidangzzz
  - https://x.com/lidangzzz
  - auxiliary mirror probes listed in the manifest
- Notes:
  - Added raw HTML snapshot tracking under `raw/lidang-public/html/`.
  - Enforced stable IDs, `dedupe_key`, `semantic_hash`, and backfill status fields.
  - Ingested 16 public corpus entries in `Digest` mode.
  - New entries this run: 0.
  - Changed semantic entries this run: 0.
  - Removed entries this run: 0.
  - Crawl errors recorded: 4.
## [2026-05-16 02:15] ingest | shunyu yao public corpora

- Pages created or updated:
  - [[yao-shunyu-ysymyth]]
  - [[yao-shunyu-alfred]]
  - [[shunyu-yao-public-corpora]]
  - [[2026-05-16-yao-shunyu-public-corpora]]
  - [[shunyu-yao-project-taxonomy]]
  - [[shunyu-yao-paper-map]]
  - [[public-corpus-ingest-workflow]]
- Sources used:
  - https://ysymyth.github.io/
  - https://github.com/ysymyth
  - https://alfredyao.github.io/
  - https://github.com/alfredyao
  - arXiv API metadata
- Notes:
  - Created separate public corpora for `ysymyth` and `alfredyao`.
  - Stored manifests under `raw/yao-shunyu-ysymyth/` and `raw/yao-shunyu-alfred/`.
  - Added reusable public-person corpus workflow guidance for future agents.

## [2026-05-16 02:44] ingest | shunyu yao github token support

- Pages created or updated:
  - [[shunyu-yao-public-corpora]]
  - [[2026-05-16-yao-shunyu-public-corpora]]
- Sources used:
  - GitHub API rate limit check
  - `scripts/ingest-shunyu-yao-public.ps1`
- Notes:
  - Configured the local user environment so the ingest can use `GITHUB_TOKEN`.
  - Updated the ingest script to read `GITHUB_TOKEN` or `GH_TOKEN` from process, user, or machine environment before falling back to unauthenticated access.
  - Re-ran the corpus ingest with authenticated GitHub API access; repository metadata now resolves with `github-api` confidence and no crawl errors.
