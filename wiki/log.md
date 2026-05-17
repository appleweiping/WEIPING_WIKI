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

## [2026-05-16 03:29] query | personal music preference

- Pages created or updated:
  - [[personal-music-preferences]]
  - [[topics-home]]
  - [[index]]
- Sources used:
  - User chat note about liking `晴天`
  - Public metadata for `告五人 Accusefive × 藤岡靛 Dean Fujioka` `晴れの日（晴天）`
- Notes:
  - Recorded that Vipin likes the `小柔Channel` version and also likes the original version.
  - Preserved both title forms, `晴天` and `晴れの日（晴天）`, for later rediscovery.
  - Added the future rule that each liked song should get a dedicated clickable song page with playable source links when available.
  - Added the future rule that missing task-specific tooling should be installed into the D: drive project-local temporary/cache area rather than producing a degraded deliverable.
  - Installed `yt-dlp.exe` under `.wiki-tmp/tools/yt-dlp/` for media lookup and used it to identify the official `晴れの日（晴天）` playable URL.
  - Split the ambiguous `晴天` memory into two song entries: a likely Jay Chou Japanese-cover branch and the Accusefive / Dean Fujioka branch.

## [2026-05-16 18:05] ingest | skill source repository trace

- Pages created or updated:
  - [[2026-05-16-skill-source-repository-trace]]
  - [[agent-skill-repositories]]
  - [[anbeime-skill]]
  - [[colleague-skill]]
  - [[darwin-skill]]
  - [[mattpocock-skills]]
  - [[nuwa-skill]]
  - [[index]]
- Sources used:
  - Local git remotes and status under `D:/Skill`
  - Public GitHub API metadata for original upstream repositories
- Notes:
  - Classified the migrated local folders as a `skill` corpus rather than generic local projects.
  - Recorded `origin` as Vipin's fork/mirror and `upstream` as the original public source when configured.
  - Preserved current local HEADs, upstream relation, and non-git skill-adjacent folder boundaries.

## [2026-05-16 18:06] ingest | venus team project github archive

- Pages created or updated:
  - [[2026-05-16-venus-team-project-github-archive]]
  - [[undergraduate-projects-netherlands]]
  - [[2026-04-22-computer-software-ui-role-plan-for-5eid0]]
  - [[2026-05-08-how-to-integrate-venus-basestation-with-team-gitlab]]
  - [[index]]
- Sources used:
  - `D:/Undergraduate_project_netherlands/Venus basestation`
  - `D:/Undergraduate_project_netherlands/venus-team-28-gitlab`
- Notes:
  - Recorded the GitHub archive migration that separates the complete Team 28 project snapshot from Vipin's `user-interface-module`.
  - Preserved the public-safety boundary: omit credentials, virtual environments, caches, personal deployment config, and generated Doxygen HTML.
  - Recorded post-migration UI validation: `28` tests passed.

## [2026-05-16 19:51] ingest | weekly research inspiration digest

- Pages created or updated:
  - [[weekly-research-digests]]
  - [[weekly-research-digest-2026-w20]]
  - [[index]]
- Sources used:
  - arXiv API
  - Semantic Scholar API
  - GitHub repository search API
- Notes:
  - Captured one high-signal item each for AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.
  - Stored abstracts/source summaries, links, plain-language core ideas, signal scores, and agent reuse notes.

## [2026-05-16 19:52] ingest | codex prompt corpus

- Pages created or updated:
  - [[codex-prompt-corpus]]
  - [[codex-prompt-taxonomy]]
  - [[index]]
- Sources used:
  - Local Codex session JSONL files
  - Local Codex automation TOML files
- Notes:
  - Selected `492` high-quality user/automation prompts and rejected `1285` noisy or unsafe candidates.
  - Preserved full selected prompt text only after filtering out short, garbled, code/log-like, duplicate, and secret-like material.

## [2026-05-16 19:53] ingest | weekly research inspiration digest

- Pages created or updated:
  - [[weekly-research-digests]]
  - [[weekly-research-digest-2026-w20]]
  - [[index]]
- Sources used:
  - arXiv API
  - Semantic Scholar API
  - GitHub repository search API
- Notes:
  - Captured one high-signal item each for AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.
  - Stored abstracts/source summaries, links, plain-language core ideas, signal scores, and agent reuse notes.

## [2026-05-16 19:55] ingest | weekly research inspiration digest

- Pages created or updated:
  - [[weekly-research-digests]]
  - [[weekly-research-digest-2026-w20]]
  - [[index]]
- Sources used:
  - arXiv API
  - Semantic Scholar API
  - GitHub repository search API
- Notes:
  - Captured one high-signal item each for AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.
  - Stored abstracts/source summaries, links, plain-language core ideas, signal scores, and agent reuse notes.

## [2026-05-16 19:57] ingest | weekly research inspiration digest

- Pages created or updated:
  - [[weekly-research-digests]]
  - [[weekly-research-digest-2026-w20]]
  - [[index]]
- Sources used:
  - arXiv API
  - Semantic Scholar API
  - GitHub repository search API
- Notes:
  - Captured one high-signal item each for AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.
  - Stored abstracts/source summaries, links, plain-language core ideas, signal scores, and agent reuse notes.

## [2026-05-16 20:00] ingest | weekly research inspiration digest

- Pages created or updated:
  - [[weekly-research-digests]]
  - [[weekly-research-digest-2026-w20]]
  - [[index]]
- Sources used:
  - arXiv API
  - Semantic Scholar API
  - GitHub repository search API
- Notes:
  - Captured one high-signal item each for AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.
  - Stored abstracts/source summaries, links, plain-language core ideas, signal scores, and agent reuse notes.

## [2026-05-16 20:03] ingest | codex prompt corpus

- Pages created or updated:
  - [[codex-prompt-corpus]]
  - [[codex-prompt-taxonomy]]
  - [[index]]
- Sources used:
  - Local Codex session JSONL files
  - Local Codex automation TOML files
- Notes:
  - Selected `362` high-quality user/automation prompts and rejected `1415` noisy or unsafe candidates.
  - Preserved full selected prompt text only after filtering out short, garbled, code/log-like, duplicate, and secret-like material.

## [2026-05-16 20:07] ingest | codex prompt corpus

- Pages created or updated:
  - [[codex-prompt-corpus]]
  - [[codex-prompt-taxonomy]]
  - [[index]]
- Sources used:
  - Local Codex session JSONL files
  - Local Codex automation TOML files
- Notes:
  - Selected `357` high-quality user/automation prompts and rejected `1420` noisy or unsafe candidates.
  - Preserved full selected prompt text only after filtering out short, garbled, code/log-like, duplicate, and secret-like material.

## [2026-05-16 20:11] ingest | weekly research inspiration digest

- Pages created or updated:
  - [[weekly-research-digests]]
  - [[weekly-research-digest-2026-w20]]
  - [[index]]
- Sources used:
  - arXiv API
  - Semantic Scholar API
  - GitHub repository search API
- Notes:
  - Captured one high-signal item each for AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.
  - Stored abstracts/source summaries, links, plain-language core ideas, signal scores, and agent reuse notes.

## [2026-05-16 20:14] ingest | weekly research inspiration digest

- Pages created or updated:
  - [[weekly-research-digests]]
  - [[weekly-research-digest-2026-w20]]
  - [[index]]
- Sources used:
  - arXiv API
  - Semantic Scholar API
  - GitHub repository search API
- Notes:
  - Captured one high-signal item each for AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.
  - Stored abstracts/source summaries, links, plain-language core ideas, signal scores, and agent reuse notes.

## [2026-05-16 20:16] ingest | codex prompt corpus

- Pages created or updated:
  - [[codex-prompt-corpus]]
  - [[codex-prompt-taxonomy]]
  - [[index]]
- Sources used:
  - Local Codex session JSONL files
  - Local Codex automation TOML files
- Notes:
  - Selected `353` high-quality user/automation prompts and rejected `1424` noisy or unsafe candidates.
  - Preserved full selected prompt text only after filtering out short, garbled, code/log-like, duplicate, and secret-like material.

## [2026-05-16 20:25] ingest | canvas outage and syllabus transfer-credit blocker

- Pages created or updated:
  - [[canvas-lms]]
  - [[2026-05-16-canvas-hack-recovery-note]]
  - [[university-of-minnesota]]
  - [[index]]
- Sources used:
  - User-provided chat note
- Notes:
  - Recorded that Canvas was recently hacked/unavailable and is expected to recover on 2026-05-18.
  - Added the practical blocker: the user cannot retrieve course syllabi from Canvas, which blocks UMN transfer-credit review because UMN needs school syllabi.
## [2026-05-17 00:50] analysis | HTML PPT skill and deck workflow

- Pages created or updated:
  - [[html-ppt-agent-workflow]]
  - [[2026-05-17-html-ppt-skill-and-deck-session]]
  - [[html-ppt-template-workflow-results]]
  - [[index]]
- Sources used:
  - Chat/session record from the `frontend-slides` and `beautiful-html-templates` setup/testing work
  - Local files under `.codex/skills/frontend-slides/`, `skill/llm4ppt(html)/`, and `D:/ppt/`
- Notes:
  - Recorded the D-drive project-local `frontend-slides` installation, local template-library integration, and default template-backed generation rule.
  - Preserved the two validated deck outputs separately: `life-did-not-spare-you` and `beauty-love`.
  - Recorded only minimal neutral metadata for the Beauty-Love image pack and avoided public visual-detail expansion.

## [2026-05-17 01:49] ingest | PaperOrchestra skill pack

- Pages created or updated:
  - [[paper-orchestra]]
  - [[2026-05-17-paper-orchestra-github]]
  - [[agent-skill-repositories]]
  - [[research-projects]]
  - [[index]]
- Sources used:
  - `https://github.com/Ar9av/PaperOrchestra.git`
  - Local mirror under `skill/paper-orchestra/`
  - Installed project-local skills under `.codex/skills/`
- Notes:
  - Recorded PaperOrchestra's host-agent-pluggable multi-agent paper-writing pipeline, installed skills, deterministic helpers, and contribution boundaries.
  - Installed 9 PaperOrchestra skills plus shared reference material under the D-drive project-local `.codex/skills/` path.
  - Preserved the source repository under `skill/paper-orchestra/` after removing nested clone metadata.

## [2026-05-17 01:59] query | PaperOrchestra usage pattern

- Pages created or updated:
  - [[paper-orchestra]]
  - [[2026-05-17-paper-orchestra-github]]
- Sources used:
  - Local `paper-orchestra` skill files and host-integration docs under `skill/paper-orchestra/`
  - User question asking whether concrete usage had been recorded
- Notes:
  - Added the official usage pattern: prepare `workspace/inputs/`, invoke `paper-orchestra` as the orchestrator, use `agent-research-aggregator` only when raw logs need structuring, and reserve individual sub-skills for targeted tasks.

## [2026-05-17 02:24] ingest | content creation publisher skill

- Pages created or updated:
  - [[content-creation-publisher]]
  - [[2026-05-17-content-creation-publisher-skill]]
  - [[anbeime-skill]]
  - [[agent-skill-repositories]]
  - [[index]]
- Sources used:
  - `https://github.com/anbeime/skill/tree/main/skills/content-creation-publisher`
  - Local mirror under `skill/content-creation-publisher/`
  - Installed project-local skills under `.codex/skills/`
- Notes:
  - Recorded the skill's content capture, Markdown formatting, article illustration, WeChat publishing, and X/Twitter publishing modules.
  - Installed the aggregate `content-creation-publisher` skill plus 5 direct sub-skills: `baoyu-url-to-markdown`, `baoyu-format-markdown`, `article-illustrator`, `baoyu-post-to-wechat`, and `baoyu-post-to-x`.
  - Recorded concrete usage patterns, local Bun runtime notes, and the live-publishing confirmation boundary.

## [2026-05-17 02:45] ingest | frontend design and chrome automation skills

- Pages created or updated:
  - [[frontend-design]]
  - [[chrome-automation]]
  - [[2026-05-17-anbeime-frontend-design-and-chrome-automation]]
  - [[agent-skill-installation-workflow]]
  - [[anbeime-skill]]
  - [[agent-skill-repositories]]
  - [[index]]
  - `AGENTS.md`
- Sources used:
  - `https://github.com/anbeime/skill/tree/main/skills/frontend-design/frontend-design`
  - `https://github.com/anbeime/skill/tree/main/skills/chrome-automation/chrome-automation`
  - Local D-drive mirrors under `skill/frontend-design/` and `skill/chrome-automation/`
  - Installed project-local skills under `.codex/skills/`
- Notes:
  - Installed both skills, documented concrete usage, and added a D-drive runtime override for `chrome-automation`.
  - Installed/verified narrow runtime dependencies in `.wiki-tmp/`: Bun, Rust toolchain, and `agent-browser`.
  - Re-ran real smoke tests: `agent-browser 0.27.0`, Chrome CDP open/get-title/get-url/screenshot on `https://example.com`.
  - Added the durable anti-toyification workflow for future skill installs.
## [2026-05-17 13:47] ingest | Feishu bridge and Lark CLI skill installation

- Pages created or updated:
  - [[feishu-bridge]]
  - [[lark-cli]]
  - [[2026-05-17-larksuite-cli-feishu-bridge]]
  - [[agent-skill-installation-workflow]]
  - [[agent-skill-repositories]]
  - [[index]]
- Sources used:
  - `https://github.com/larksuite/cli`
  - Local D-drive runtime under `.wiki-tmp/tools/lark-cli/v1.0.32/`
  - Installed skills under `.codex/skills/lark-*` and `.codex/skills/feishu-bridge/`
- Notes:
  - Installed official Lark/Feishu CLI runtime and selected official `lark-*` skills for Docs, Wiki, Drive, Base, Sheets, IM, and related workflows.
  - Created `feishu-bridge` as the API-first/browser-fallback router for Feishu/Lark materials and forms.
  - Verified binary checksum, CLI version/help, selected skill validation, and browser-fill fallback; marked real Feishu read/write tests as pending OAuth and user-approved test resources.
