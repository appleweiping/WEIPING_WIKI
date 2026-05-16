---
title: 2026-05-16 Yao Shunyu Public Corpora
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - shunyu-yao
  - public-corpus
  - batch-ingest
source_pages:
  - https://ysymyth.github.io/
  - https://github.com/ysymyth
  - https://alfredyao.github.io/
  - https://github.com/alfredyao
---

# 2026-05-16 Yao Shunyu Public Corpora

## Provenance

- ysymyth homepage: https://ysymyth.github.io/
- ysymyth GitHub API: https://api.github.com/users/ysymyth
- alfredyao homepage: https://alfredyao.github.io/
- alfredyao GitHub API: https://api.github.com/users/alfredyao
- alfredyao CV pointer: https://alfredyao.github.io/Shunyu_Yao_CV.pdf
- arXiv API query: author `Shunyu Yao` with identity/category filters.
- GitHub API calls should use `GITHUB_TOKEN` or `GH_TOKEN` from the process, user, or machine environment; this raises the rate limit and keeps repository metadata source confidence at `github-api`.

## Snapshot

- `ysymyth` entries: 57, new 0, changed 0, errors 0.
- `alfredyao` entries: 16, new 0, changed 0, errors 0.

## Public Handling

- EXTRACTED: Public metadata, URLs, repo license metadata, page summaries, and hashes are safe for public wiki indexing.
- INFERRED: Unclear-license full PDFs, source code, and webpage text are not mirrored wholesale.
- AMBIGUOUS: arXiv author search can mix same-name authors; entries are filtered by title/category and identity context.

## Related

- [[yao-shunyu-ysymyth]]
- [[yao-shunyu-alfred]]
- [[shunyu-yao-public-corpora]]
- [[shunyu-yao-project-taxonomy]]
- [[shunyu-yao-paper-map]]

## Counterpoints And Gaps

- arXiv author search can include same-name collisions, so the ingest applies category and title filters.
- Google Scholar is recorded as a pointer when available but is not treated as a stable machine-readable source.
