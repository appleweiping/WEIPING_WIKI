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

- Stable ID: `codex-user-prompt:e4f43c728942913c`
- Source kind: `codex-session-user`
- Category: `wiki-ingest`
- Timestamp: `2026-05-15T21:44:24.639Z`
- Semantic hash: `e4f43c728942913cd8587cf8f51ce808035ea2dead64558569f37e21d23cfac1`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# Karpathy Public Corpus Ingest + Auto-Update

## Summary
- Build a serious Karpathy public corpus inside `vipin wiki`: GitHub projects, official/personal sites, blog/RSS, YouTube feed, public gists, and official curated tweet/status links.
- User choices locked:
 - GitHub: deep ingest all public repos, not only popular ones.
 - X/Twitter: use official/traceable sources such as `karpathy.ai/tweets.html`, website/blog/repo-linked statuses; avoid brittle third-party mirrors by default.
 - Preservation: fetch as much full public content as practical, but separate local archival from public GitHub redistribution when license is unclear.
- Create a weekly automation that re-crawls, detects new/changed/removed items, updates wiki pages and manifests, validates, commits, and pushes scoped changes.

## Key Changes
- Add `scripts/ingest-karpathy-public.ps1` modeled after the existing Cookbook ingest, with `-DryRun`, `-SkipValidation`, and stable no-op behavior.
- Crawl these canonical surfaces:
 - GitHub user/repos/gists/releases/trees/README/license APIs: `https://api.github.com/users/karpathy`
 - personal homepage: `https://karpathy.ai/`
 - blog RSS: `https://karpathy.github.io/feed.xml`
 - YouTube RSS: `https://www.youtube.com/feeds/videos.xml?channel_id=UCXUPKJO5MZQN11PqgIvyuvQ`
 - curated tweets page: `https://karpathy.ai/tweets.html`
- Add machine-readable records under `raw/karpathy-public/manifest.json` with source kind, URL, repo/path, license, hash, first seen, last changed, distribution policy, wiki page path, and crawl errors.
- Add local archival policy:
 - License-safe or clearly redistributable content may be committed.
 - Unlicensed repo/source/full post caches are stored as local-only or summarized publicly with provenance, hash, and link.
 - Public wiki pages never pretend unlicensed material is freely redistributable.
- Add durable wiki pages:
 - `wiki/entities/andrej-karpathy.md`
 - `wiki/topics/karpathy-public-work.md`
 - `wiki/sources/2026-05-15-karpathy-public-corpus.md`
 - `wiki/analyses/karpathy-project-taxonomy.md`
 - `wiki/analyses/karpathy-idea-map.md`
 - per-item pages for repos, posts, videos, gists, and curated statuses.
- Update `wiki/index.md`, `wiki/log.md`, and `wiki/catalog.json`.

## Classification
- Primary categories:
 - LLM education / from-scratch pedagogy
 - Minimal implementations
 - LLM training and inference systems
 - Tokenization and language modeling
 - Research automation / agentic science
 - Neural network fundamentals
 - Vision / multimodal / captioning
 - Research tooling and paper workflows
 - Browser / JavaScript ML experiments
 - Personal heuristics / AI philosophy / learning advice
 - Talks, courses, and videos
- Each item page includes:
 - source URL, source kind, license, fetched time, hash
 - category and tags
 - concise summary
 - what it teaches
 - why it matters for Vipin/wiki/research/agent workflows
 - related Karpathy items
 - public mirror status: full mirror, partial excerpt, summary-only, or local-only archive.

## Automation
- Create a weekly Codex automation named `Update Karpathy Public Corpus`.
- Prompt: run `scripts/ingest-karpathy-public.ps1`, summarize additions/changes/removals/errors, run `scripts/wiki-catalog.ps1` and `scripts/wiki-lint.ps1`, commit scoped changes with `Update Karpathy public corpus`, and push `origin/main`.
- Ignore unrelated local changes, especially existing untracked `GetPdf.pdf`.
- Avoid noisy commits: if upstream hashes and generated pages are unchanged, produce a no-change report and do not commit.

## Test Plan
- Dry-run checks:
 - GitHub repo count is nonzero and close to the observed baseline of 63 public repos.
 - Blog RSS item count is nonzero.
 - YouTube feed count is nonzero and includes the current channel videos.
 - Curated tweet/status extraction from `karpathy.ai/tweets.html` is nonzero.
- Validation checks:
 - every generated wiki page has frontmatter, source URL, category, summary, hash, and mirror policy
 - all repo pages include README/license/release/tree metadata when available
 - `wiki/index.md` links the Karpathy hub, source note, taxonomy, and idea map
 - `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check` pass
 - no private paths, credentials, or local-only cache contents leak into public wiki pages
- Acceptance:
 - first run creates the full corpus
 - second run with no upstream changes is no-op
 - new repo/post/video/gist/status creates manifest entry, wiki page/update, log entry, validation, commit, and push
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
