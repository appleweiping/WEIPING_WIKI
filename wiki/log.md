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
## [2026-05-16 15:49] ingest | frontend frameworks public corpus

- Pages created or updated:
  - [[frontend-frameworks-public]]
  - [[2026-05-16-frontend-frameworks-public-corpus]]
  - [[frontend-project-shell-taxonomy]]
  - [[frontend-framework-reuse-map]]
  - `wiki/entities/frontend-frameworks/`
  - `wiki/sources/frontend-frameworks/`
- Sources used:
  - GitHub repository, language, tree, and release APIs for the curated registry in `raw/frontend-frameworks-public/registry.json`
- Notes:
  - Captured 12 frameworks, 28 official repositories, 69 release records, and 103 candidate repositories.
  - New entries this run: 0.
  - Changed semantic entries this run: 1.
  - Removed entries this run: 0.
  - Crawl errors recorded: 0.

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
## [2026-05-16 13:18] query | lidang sp500 and nasdaq100 clue

- Pages created or updated:
  - [[2026-05-16-what-indexes-did-lidang-recommend]]
  - [[sources/lidang-public/x-status-2041009459175026831-sp500-nasdaq100]]
  - [[lidang]]
  - [[lidang-public-ideas]]
  - [[index]]
- Sources used:
  - https://x.com/lidangzzz
  - https://x.com/lidangzzz/status/2041009459175026831
  - `raw/lidang-public/html/2026-05-16/x-com-lidangzzz.html`
- Notes:
  - Preserved the answer that `SP500/纳100` means S&P 500 and Nasdaq-100.
  - Recorded the source-confidence boundary: profile HTML plus non-authoritative web/mirror snippets, not financial advice.

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

## [2026-05-16 02:54] ingest | tencent docs pvz fusion edition

- Pages created or updated:
  - [[2026-05-16-qq-doc-pvz-fusion-mobile-pc]]
  - [[pvz-fusion-edition]]
- Sources used:
  - https://docs.qq.com/doc/DSk9tUnNKTGdFVFBJ
- Notes:
  - Captured public Tencent Docs metadata for `关于植物大战僵尸融合版（手机加PC端）`.
  - Browser rendering showed the document body is permission-gated and asks for login.
  - Recorded follow-up rules for authorized export or logged-in capture before summarizing installation/download details.

## [2026-05-16 03:16] ingest | pvz fusion authorized visual extraction

- Pages created or updated:
  - [[2026-05-16-qq-doc-pvz-fusion-mobile-pc]]
  - [[pvz-fusion-edition]]
- Sources used:
  - User-opened authorized Tencent Docs browser view
  - Local screenshots of the visible document body
- Notes:
  - Added visible link labels for mobile, PC, no-MOD PC, game body, and advanced plant MOD/plugin entries.
  - Extracted the PC MOD workflow around `BepInEx\plugins`, game root layout, and `.zip` plant packages.
  - Left exact target URLs and checksum/provenance verification as follow-up items because Tencent Docs normal copy did not expose the body links.
