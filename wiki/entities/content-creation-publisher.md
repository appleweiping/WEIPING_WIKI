---
title: Content Creation Publisher
type: entity
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - entity
  - agent-skills
  - content-creation
  - publishing
source_pages:
  - 2026-05-17-content-creation-publisher-skill
---

# Content Creation Publisher

## Role In The Wiki

`content-creation-publisher` is a project-local installed skill pack for content collection, Markdown cleanup, article illustration, and publishing to WeChat Official Account or X/Twitter.

## Current Claims

- EXTRACTED: The upstream source path is `https://github.com/anbeime/skill/tree/main/skills/content-creation-publisher`.
- EXTRACTED: The upstream repository HEAD at inspection was `049efd5f29fb47c9165871caac4e61b4c67cb2c9`.
- EXTRACTED: The source mirror was stored at `skill/content-creation-publisher/`.
- EXTRACTED: The aggregate skill was installed at `.codex/skills/content-creation-publisher/`.
- EXTRACTED: Five bundled sub-skills were also installed directly for easier triggering:
  - `.codex/skills/baoyu-url-to-markdown/`
  - `.codex/skills/baoyu-format-markdown/`
  - `.codex/skills/article-illustrator/`
  - `.codex/skills/baoyu-post-to-wechat/`
  - `.codex/skills/baoyu-post-to-x/`
- EXTRACTED: The skill depends on Node.js / Bun-style TypeScript execution and Chrome CDP for browser automation.
- INFERRED: The best default interaction is to call the aggregate skill for whole workflows and call sub-skills directly for narrow tasks.

## What It Does

The skill pack covers five content operations:

1. Capture webpage content as Markdown.
2. Format or beautify Markdown.
3. Generate article illustration plans and images.
4. Publish article or image-text content to WeChat Official Account.
5. Publish posts, media, quote tweets, or long-form articles to X/Twitter.

## Concrete Usage

### Whole Workflow

Use this when the task spans several stages:

```text
采集这篇文章，优化格式，配图，然后发布到微信。
采集这个 URL，格式化成 Markdown，然后发到 X。
把这篇 Markdown 优化排版、生成配图，并准备公众号发布。
```

Expected flow:

```text
URL / draft
-> baoyu-url-to-markdown
-> baoyu-format-markdown
-> article-illustrator
-> baoyu-post-to-wechat or baoyu-post-to-x
```

### Targeted Use

- `baoyu-url-to-markdown`: "把这个 URL 转成 Markdown"; supports `--wait` for pages that need login or manual loading.
- `baoyu-format-markdown`: "优化这篇文章的格式"; outputs `{filename}-formatted.md` and can run CJK spacing/emphasis fixes.
- `article-illustrator`: "给文章配图"; creates `imgs/illustration-[slug].png` and inserts Markdown image links.
- `baoyu-post-to-wechat`: "发布到微信公众号"; supports browser mode and API mode.
- `baoyu-post-to-x`: "发布到 X"; supports posts, images, videos, quote tweets, and X Articles.

### Runtime Pattern

The upstream scripts expect Bun. In this local environment, use the project-local temporary Bun if a global `bun` or `npx` is unavailable:

```powershell
.\.wiki-tmp\tools\bun\bun.exe .codex\skills\baoyu-format-markdown\scripts\main.ts article.md
.\.wiki-tmp\tools\bun\bun.exe .codex\skills\baoyu-url-to-markdown\scripts\main.ts https://example.com -o output.md
.\.wiki-tmp\tools\bun\bun.exe .codex\skills\baoyu-post-to-x\scripts\x-browser.ts "Hello" --image .\photo.png
```

Do not use `--submit` for WeChat or X until the user has explicitly confirmed that a live post should be created.

## Local Routing

- Source mirror: `D:/Research/vipin's knowledgebase/skill/content-creation-publisher/`.
- Aggregate installed skill: `D:/Research/vipin's knowledgebase/.codex/skills/content-creation-publisher/`.
- Direct installed sub-skills:
  - `D:/Research/vipin's knowledgebase/.codex/skills/baoyu-url-to-markdown/`
  - `D:/Research/vipin's knowledgebase/.codex/skills/baoyu-format-markdown/`
  - `D:/Research/vipin's knowledgebase/.codex/skills/article-illustrator/`
  - `D:/Research/vipin's knowledgebase/.codex/skills/baoyu-post-to-wechat/`
  - `D:/Research/vipin's knowledgebase/.codex/skills/baoyu-post-to-x/`
- Temporary Bun runtime used for validation: `D:/Research/vipin's knowledgebase/.wiki-tmp/tools/bun/bun.exe` (not source; do not commit).

## Contribution Summary

- EXTRACTED: The pack combines capture, formatting, illustration, and platform publishing into one reusable workflow.
- EXTRACTED: It uses Chrome CDP for rendered-page capture and browser-based publishing.
- EXTRACTED: It supports project-level and user-level `EXTEND.md` preference files for Baoyu sub-skills.
- EXTRACTED: It provides concrete CLI scripts for URL capture, Markdown formatting, WeChat posting, and X posting.
- INFERRED: Its value for Vipin is strongest as a practical publishing bridge after analysis, PPT, or article-drafting work.

## Counterpoints And Gaps

- UNVERIFIED: Live WeChat and X publishing were not tested.
- AMBIGUOUS: Some helper examples reference skills not installed here, such as `paper-analysis-assistant`, `ppt-generator`, or `product-marketing-copywriter`.
- AMBIGUOUS: The long-term preferred runtime should be standardized: global Bun, project-local Bun, or wrapper scripts.
- INFERRED: Because this skill can publish publicly, future agents should require explicit confirmation before any live posting action.

## Related Pages

- [[2026-05-17-content-creation-publisher-skill]]
- [[anbeime-skill]]
- [[agent-skill-repositories]]
