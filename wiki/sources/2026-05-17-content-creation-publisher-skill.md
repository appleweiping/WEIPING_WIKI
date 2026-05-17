---
title: 2026-05-17 Content Creation Publisher Skill
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - agent-skills
  - content-creation
  - publishing
source_files:
  - "D:/Research/vipin's knowledgebase/skill/content-creation-publisher/SKILL.md"
  - "D:/Research/vipin's knowledgebase/skill/content-creation-publisher/快速使用指南.md"
source_pages:
  - https://github.com/anbeime/skill/tree/main/skills/content-creation-publisher
---

# 2026-05-17 Content Creation Publisher Skill

## Provenance

- Source: user request to record and install `https://github.com/anbeime/skill/tree/main/skills/content-creation-publisher`.
- Upstream repository: `https://github.com/anbeime/skill.git`.
- Upstream HEAD at inspection: `049efd5f29fb47c9165871caac4e61b4c67cb2c9`.
- Retrieval mode: sparse clone of only `skills/content-creation-publisher`.
- Local source mirror: `skill/content-creation-publisher/`.
- Installed aggregate skill: `.codex/skills/content-creation-publisher/`.
- Installed direct sub-skills: `.codex/skills/baoyu-url-to-markdown/`, `.codex/skills/baoyu-format-markdown/`, `.codex/skills/article-illustrator/`, `.codex/skills/baoyu-post-to-wechat/`, `.codex/skills/baoyu-post-to-x/`.

## What The Skill Is

- EXTRACTED: `content-creation-publisher` is an end-to-end content workflow skill for collecting content, formatting Markdown, adding illustrations, and publishing to WeChat Official Account and X/Twitter.
- EXTRACTED: The aggregate skill contains 5 bundled sub-skills:
  - `baoyu-url-to-markdown`
  - `baoyu-format-markdown`
  - `article-illustrator`
  - `baoyu-post-to-wechat`
  - `baoyu-post-to-x`
- EXTRACTED: The upstream skill declares Python dependencies `requests>=2.28.0` and `pillow>=10.0.0`, plus system dependencies Node.js and Chrome.
- EXTRACTED: The actual command examples in the sub-skills use Bun to execute TypeScript scripts through `npx -y bun ...`.
- INFERRED: In this local Codex environment, Bun is a practical runtime requirement for most executable sub-skill scripts.

## Functional Modules

| Module | Function | Main use |
| --- | --- | --- |
| `baoyu-url-to-markdown` | Fetches a URL through Chrome CDP and converts rendered HTML to clean Markdown. | Article/news/paper webpage capture, including login-required pages via wait mode. |
| `baoyu-format-markdown` | Formats Markdown or plain text with frontmatter, titles, summaries, headings, lists, code blocks, and CJK typography fixes. | Clean up collected or original articles before publishing. |
| `article-illustrator` | Analyzes an article and generates illustration plans and images for places that need visual support. | Add explanatory, conceptual, or atmosphere-building images. |
| `baoyu-post-to-wechat` | Publishes article or image-text content to a WeChat Official Account via browser automation or API. | WeChat article / image-text publishing. |
| `baoyu-post-to-x` | Publishes regular posts, image/video posts, quote tweets, or X Articles through real Chrome with CDP. | X/Twitter posting and long-form X Articles. |

## Concrete Contributions

- EXTRACTED: The aggregate skill packages a complete pipeline: webpage URL -> Markdown extraction -> Markdown formatting -> illustration -> WeChat/X publishing.
- EXTRACTED: `baoyu-url-to-markdown` supports auto capture after page load and wait mode for pages that require login or manual interaction.
- EXTRACTED: `baoyu-format-markdown` handles frontmatter, title extraction/generation, summary generation, heading/list/code formatting, CJK/English spacing, ASCII quote conversion, and CJK emphasis fixes.
- EXTRACTED: `article-illustrator` supports illustration planning with six illustration types: `infographic`, `scene`, `flowchart`, `comparison`, `framework`, and `timeline`.
- EXTRACTED: `article-illustrator` records eight style families in the quick guide: `notion`, `elegant`, `warm`, `minimal`, `blueprint`, `watercolor`, `editorial`, and `scientific`.
- EXTRACTED: `baoyu-post-to-wechat` supports browser mode and API mode, with preferences read from project or user `EXTEND.md` files.
- EXTRACTED: `baoyu-post-to-x` supports regular posts with images, video posts, quote tweets, and long-form Markdown X Articles.
- INFERRED: The main contribution is workflow composition: it turns separate content operations into reusable agent-triggered publishing workflows rather than only providing isolated scripts.

## Concrete Usage

### Normal Aggregate Commands

Use the aggregate skill when the user asks for a whole content workflow:

```text
采集这篇文章，优化格式，配图，然后发布到微信。
采集这篇文章并发布到微信和 X。
优化这篇 Markdown 文章并配图。
批量采集这些 URL 并优化格式。
```

The aggregate flow is:

```text
URL or Markdown draft
-> baoyu-url-to-markdown, if input is a URL
-> baoyu-format-markdown
-> article-illustrator, if illustrations are requested
-> baoyu-post-to-wechat and/or baoyu-post-to-x, if publishing is requested
```

### Direct Sub-Skill Commands

Use sub-skills directly for targeted tasks:

```text
把这个 URL 转成 Markdown。
格式化这个 Markdown 文件，修复中英文间距。
为这篇文章生成 notion 风格 infographic 配图。
发布到微信公众号。
把这段内容发到 X，并附上这张图片。
```

### Script-Level Examples

After resolving each skill directory as `SKILL_DIR`, the upstream examples use:

```powershell
# URL to Markdown
bun ${SKILL_DIR}/scripts/main.ts <url>
bun ${SKILL_DIR}/scripts/main.ts <url> --wait
bun ${SKILL_DIR}/scripts/main.ts <url> -o output.md

# Markdown formatting
bun ${SKILL_DIR}/scripts/main.ts article.md
bun ${SKILL_DIR}/scripts/main.ts article.md --quotes
bun ${SKILL_DIR}/scripts/main.ts article.md --no-spacing

# X/Twitter regular post
bun ${SKILL_DIR}/scripts/x-browser.ts "Hello" --image ./photo.png
bun ${SKILL_DIR}/scripts/x-browser.ts "Hello" --image ./photo.png --submit

# X Article
bun ${SKILL_DIR}/scripts/x-article.ts article.md --cover ./cover.jpg

# WeChat image-text / article publishing
bun ${SKILL_DIR}/scripts/wechat-browser.ts --markdown article.md --images ./images/
bun ${SKILL_DIR}/scripts/wechat-article.ts article.md
```

Prefer preview modes first. Only use `--submit` after the user explicitly wants a live post and has reviewed the content.

## Local Runtime Notes

- EXTRACTED: Chrome exists locally at `C:/Program Files/Google/Chrome/Application/chrome.exe`.
- EXTRACTED: Codex provides `node.exe`, but `npm`, `npx`, and `bun` were not on PATH during inspection.
- EXTRACTED: A temporary local Bun runtime was downloaded to `.wiki-tmp/tools/bun/bun.exe` for validation and is not intended for Git tracking.
- EXTRACTED: The following installed scripts started successfully with Bun: `baoyu-format-markdown/scripts/main.ts`, `baoyu-post-to-x/scripts/x-browser.ts`, and `baoyu-url-to-markdown/scripts/main.ts` displayed its usage text.
- INFERRED: For future use, either call `.wiki-tmp/tools/bun/bun.exe` directly, install Bun globally, or add a project-local wrapper before running the TypeScript scripts.
- UNVERIFIED: WeChat and X live publishing were not tested because they require authenticated accounts and can create public posts.

## Safety And Operational Boundaries

- Always preview before live publishing.
- Do not publish to WeChat or X without explicit user confirmation.
- Watch for copyright, platform policy, and account-rate limits when collecting and republishing web content.
- For login-required pages, use wait mode and avoid storing credentials in wiki pages.
- Treat `.baoyu-skills/EXTEND.md` and `$HOME/.baoyu-skills/.../EXTEND.md` as configuration that may contain account defaults or profile paths; do not expose secrets in public wiki pages.

## Related

- [[content-creation-publisher]]
- [[anbeime-skill]]
- [[agent-skill-repositories]]
