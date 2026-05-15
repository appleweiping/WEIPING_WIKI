---
title: 2026-05-15 Karpathy Public Corpus
type: source
status: active
created: 2026-05-15
updated: 2026-05-16
tags:
  - karpathy
  - batch-ingest
  - public-corpus
  - ai
source_pages:
  - https://api.github.com/users/karpathy
  - https://karpathy.ai/
  - https://karpathy.github.io/feed.xml
  - https://www.youtube.com/feeds/videos.xml?channel_id=UCXUPKJO5MZQN11PqgIvyuvQ
  - https://karpathy.ai/tweets.html
---

# 2026-05-15 Karpathy Public Corpus

## Provenance

- GitHub profile/API: https://api.github.com/users/karpathy
- GitHub repositories API: https://api.github.com/users/karpathy/repos?per_page=100&sort=updated
- GitHub gists API: https://api.github.com/users/karpathy/gists?per_page=100
- Personal homepage: https://karpathy.ai/
- Blog RSS: https://karpathy.github.io/feed.xml
- YouTube RSS: https://www.youtube.com/feeds/videos.xml?channel_id=UCXUPKJO5MZQN11PqgIvyuvQ
- Curated tweet/status links: https://karpathy.ai/tweets.html
- Manifest: `raw/karpathy-public/manifest.json`
- Local repo cache: `.wiki-tmp/karpathy-repos`; this is operational cache, not public wiki content.

## Crawl Snapshot

- GitHub profile login: `karpathy`
- GitHub display name: Andrej
- Public repos discovered: 63
- Manifest entries: 172
- New entries this run: 0
- Changed entries this run: 1
- Removed entries this run: 0
- Crawl errors recorded: 0

## Source Kinds

- `blog-rss-item`: 10
- `curated-status-link`: 70
- `github-gist`: 13
- `github-repository`: 63
- `personal-homepage`: 1
- `youtube-video`: 15

## License / Public Handling Counts

- `Apache-2.0`: 2
- `BSD-3-Clause`: 1
- `MIT`: 19
- `NOASSERTION`: 135
- `YouTube-standard`: 15

## Ingest Policy

- EXTRACTED: Public GitHub repository metadata, README/license files, file trees, git tags, blog RSS items, YouTube feed metadata, gists, homepage links, and curated tweet/status URLs are captured where accessible.
- INFERRED: Unlicensed source text/code should be treated as local preservation plus public summary, not as permission for wholesale public redistribution.
- The wiki may publish metadata, summaries, hashes, categories, and links for unlicensed material.
- Full local preservation can live in ignored caches or private raw folders; public pages must retain mirror/distribution policy fields.
- Re-run with `scripts/ingest-karpathy-public.ps1` to refresh the corpus.

## Related

- [[andrej-karpathy]]
- [[karpathy-public-work]]
- [[karpathy-project-taxonomy]]
- [[karpathy-idea-map]]
