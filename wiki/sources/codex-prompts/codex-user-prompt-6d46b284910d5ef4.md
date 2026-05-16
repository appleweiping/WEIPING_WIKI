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

- Stable ID: `codex-user-prompt:6d46b284910d5ef4`
- Source kind: `codex-session-user`
- Category: `wiki-ingest`
- Timestamp: `2026-05-15T22:44:52.225Z`
- Semantic hash: `6d46b284910d5ef43fd8238f262116c5e0f812045d809aee20f7cc970a454d92`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# 立党老师 Public Ideas Corpus Ingest + Auto-Update

## Summary
- Build a `vipin wiki` corpus for 立党老师 / `lidangzzz`, optimized for high-frequency, low-to-medium-density public ideas rather than project-heavy sources.
- Verified starting points:
 - YouTube RSS works for channel `UC4gzU_8MxRDiQrSFOiT79tQ`, title `立党 lidang`, currently exposes 15 recent videos.
 - X handle is treated as `@lidangzzz`; official X is canonical, third-party mirrors are auxiliary and clearly marked non-authoritative.
 - Existing wiki has no maintained 立党 corpus yet; only a separate local `lidang-perspective` skill exists.
- Use batch aggregation by week/month plus high-signal single-item pages, not one wiki page per short post.

## Key Changes
- Add `scripts/ingest-lidang-public.ps1` with modes:
 - `-Mode Light`: daily capture of new metadata, links, hashes, mirrors, video RSS items, and candidate high-signal posts.
 - `-Mode Digest`: weekly clustering, de-duplication, taxonomy updates, wiki page generation, catalog/lint validation.
 - `-DryRun` and `-SkipValidation` for safe checks.
- Store machine-readable state under `raw/lidang-public/manifest.json` and daily capture batches under `raw/lidang-public/inbox/`.
- Create durable wiki surfaces:
 - `wiki/entities/lidang.md`
 - `wiki/topics/lidang-public-ideas.md`
 - `wiki/sources/2026-05-16-lidang-public-corpus.md`
 - `wiki/analyses/lidang-idea-taxonomy.md`
 - `wiki/analyses/lidang-weekly-digests.md`
 - `wiki/sources/lidang-public/` for weekly/monthly batches and high-signal single items only.
- Public handling:
 - Official URLs, timestamps, metadata, short summaries, hashes, and source provenance are public wiki-safe.
 - Full X text from mirrors is local/cache-only unless redistribution is clearly allowed.
 - YouTube transcripts are fetched only when legally/technically available; otherwise store title, URL, metadata, and summary from accessible public text.

## Classification And Data Model
- Primary categories:
 - AI coding / agent workflows
 - 转码 / 职业路径
 - 移民 / 身份 / 制度入口
 - 创业 / Delaware / 公司工具
 - 开源工程 / 工具链
 - 教育 / 学科选择 / CS learning
 - 经济 / 房地产 / 社会观察
 - 法律规则 / 治理 / rule-as-script
 - 日常启发式 / 判断框架
 - 争议性观点 / 需复核观点
- Manifest item fields:
 - `id`, `source_kind`, `canonical_url`, `mirror_urls`, `published_at`, `captured_at`, `content_hash`, `source_confidence`, `category`, `tags`, `engagement`, `importance_score`, `dedupe_key`, `wiki_page`, `public_handling`.
- Wiki generation rule:
 - Daily short posts stay in weekly batch pages unless importance score crosses a threshold.
 - Single-item pages are reserved for long posts, high-engagement posts, videos, repeated themes, or ideas that materially update the taxonomy.

## Automation
- Create two Codex automations:
 - Daily light crawl: run `scripts/ingest-lidang-public.ps1 -Mode Light`, update raw candidate queue and manifest, avoid wiki churn, commit only scoped raw/manifest changes when new public metadata appears.
 - Weekly digest: run `scripts/ingest-lidang-public.ps1 -Mode Digest`, update wiki pages, taxonomy, index, log, catalog, validate, commit with `Update Lidang public ideas corpus`, and push `origin/main`.
- Ignore unrelated local changes, especially existing untracked `GetPdf.pdf`.
- If mirrors fail or X blocks access, record crawl errors in the manifest and keep the automation non-destructive.

## Test Plan
- Dry-run verifies:
 - YouTube RSS returns nonzero entries and channel title `立党 lidang`.
 - X canonical account URL and at least one auxiliary discovery source are reachable or errors are recorded.
 - manifest item IDs and hashes are stable across repeated runs.
- Validation verifies:
 - generated pages have frontmatter, source URLs, category, summary, confidence, and public handling policy.
 - weekly batch pages link back to the topic hub, taxonomy, and source note.
 - high-frequency items do not flood `wiki/index.md`; index links only hubs, analyses, batch pages, and high-signal single pages.
 - `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check` pass.
- Acceptance:
 - first digest creates the corpus.
 - daily light runs capture new candidates without noisy wiki churn.
 - weekly digest clusters new public content into readable summaries and pushes scoped changes.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
