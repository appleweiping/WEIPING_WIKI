---
title: Log
type: log
status: active
created: 2026-04-21
updated: 2026-05-17
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
## [2026-05-17 14:09] query | Feishu bridge OAuth and live smoke tests

- Pages created or updated:
  - [[lark-cli]]
  - [[feishu-bridge]]
  - [[2026-05-17-larksuite-cli-feishu-bridge]]
  - `wiki/catalog.json`
- Sources used:
  - User-assisted Feishu/Lark OAuth setup in the current session
  - Local `lark-cli` runtime under `.wiki-tmp/tools/lark-cli/v1.0.32/`
- Notes:
  - Completed app configuration, recommended OAuth, and incremental `search:docs:read` authorization.
  - Verified `auth status --verify`, `doctor`, Drive search, Wiki list/fetch, Docs create/fetch, and Base table-list read.
  - Recorded only neutral smoke-test metadata; private Feishu content remains out of the public wiki.
## [2026-05-17 15:13] query | Feishu live form workflow

- Pages created or updated:
  - [[feishu-material-access-workflow]]
  - [[2026-05-17-feishu-form-fill-session]]
  - [[feishu-bridge]]
  - [[chrome-automation]]
  - [[2026-05-17-larksuite-cli-feishu-bridge]]
  - [[index]]
- Sources used:
  - Current chat session and live Feishu shared Base form workflow
  - Local `agent-browser` runtime under `.wiki-tmp/tools/agent-browser/`
  - Existing `feishu-bridge`, `lark-cli`, and `chrome-automation` wiki pages
- Notes:
  - Recorded the API-first/browser-fallback Feishu material access system as a durable workflow.
  - Recorded a successful live Feishu form submission while omitting personal identifiers and submitted private answer text from the public wiki.
  - Preserved practical lessons about Feishu select controls, required-field validation, one-time-submit confirmation dialogs, and final success verification.
## [2026-05-17 15:23] query | automation output commit discipline

- Pages created or updated:
  - `AGENTS.md`
  - [[public-corpus-ingest-workflow]]
  - [[log]]
- Sources used:
  - User instruction that Lidang and other wiki automation outputs should be committed after validation.
  - Local git inspection of the previously reported Lidang automation files.
- Notes:
  - Added a durable rule that wiki automation outputs are official maintenance results and must be validated, scoped, committed, and pushed by default.
  - Clarified that false dirty states with no content diff should be normalized and reported rather than committed as meaningless changes.
  - Checked the Lidang files that appeared modified; their object hashes matched the index and `git diff` showed no substantive content changes after refresh.
## [2026-05-17 15:37] query | README maintenance workflow

- Pages created or updated:
  - [[readme-maintenance-workflow]]
  - `README.md`
  - `AGENTS.md`
  - [[index]]
  - [[log]]
- Sources used:
  - User instruction to add a wiki rule for periodically refreshing the README and committing the result.
  - Existing repository README and wiki operating docs.
- Notes:
  - Added a durable README maintenance workflow.
  - Added future-agent rules to periodically refresh the root README when wiki structure, automation rules, workflows, or validation expectations drift.
  - Clarified that README refreshes should be validated, scoped, committed, and pushed by default.
## [2026-05-17 15:45] query | engineering README refresh

- Pages created or updated:
  - `README.md`
  - [[log]]
- Sources used:
  - User-approved README engineering refresh plan
  - Existing `README.md`, `AGENTS.md`, `.wiki-schema.md`, `WORKFLOWS.md`, `purpose.md`, `wiki/index.md`, and `wiki/overview.md`
- Notes:
  - Rewrote the root README as a public entry point plus future-agent quick-start guide.
  - Added architecture, start-here paths, core workflows, quality gates, automation commit discipline, public/private safety, maintained-page pointers, and README maintenance expectations.
  - Kept detailed knowledge navigation in `wiki/index.md` rather than duplicating the full catalog.
## [2026-05-17 15:59] query | README specialist skill and durable rule memory

- Pages created or updated:
  - `README.md`
  - `AGENTS.md`
  - [[readme-blueprint-generator]]
  - [[2026-05-17-readme-blueprint-generator-skill]]
  - [[readme-maintenance-workflow]]
  - [[agent-skill-installation-workflow]]
  - [[durable-agent-rule-memory]]
  - [[index]]
- Sources used:
  - User instruction to install a top-tier README skill and persist future-agent rule memory.
  - `https://github.com/github/awesome-copilot`
  - Local installed skill under `.codex/skills/readme-blueprint-generator/`
- Notes:
  - Installed and locally adapted the `readme-blueprint-generator` skill for high-quality README rewrites.
  - Rewrote the root README using the specialist workflow with stronger first-impression hierarchy and maintainer quick-start structure.
  - Added the durable rule that future-agent memory requests must be persisted into `AGENTS.md` and relevant wiki workflow pages, then validated, committed, and pushed.
## [2026-05-17 16:42] query | local cc sidecar agent workflow

- Pages created or updated:
  - `AGENTS.md`
  - [[local-cc-sidecar-agent-workflow]]
  - [[2026-05-17-opencode-cc-pixelcat-setup]]
  - [[durable-agent-rule-memory]]
  - [[index]]
- Sources used:
  - User instruction to let future agents call local `cc` directly for multi-agent coding collaboration.
  - Local OpenCode / Claude Code / PixelCat setup and smoke-test results from the current session.
- Notes:
  - Added a durable rule that substantial coding work can use `D:\cc\cc.cmd` as a bounded sidecar agent instead of requiring the user to open Claude Code manually.
  - Recorded verified versions, D-drive entrypoints, PixelCat proxy status, model smoke tests, and safety boundaries without publishing auth tokens or private chat/video contents.
  - Clarified that Codex remains coordinator/integrator and must verify sidecar output before edits, commits, or pushes.
## [2026-05-17 19:25] query | strict cc multi-agent roles

- Pages created or updated:
  - `AGENTS.md`
  - [[local-cc-sidecar-agent-workflow]]
  - [[2026-05-17-opencode-cc-pixelcat-setup]]
  - [[index]]
- Sources used:
  - User-approved strict CC multi-agent plan from the current chat.
  - Existing local CC sidecar workflow and PixelCat/OpenCode/Claude Code setup notes.
- Notes:
  - Upgraded the sidecar rule to a strict threshold-based three-role system: Codex Coordinator, Opus Reviewer, and Sonnet Scanner.
  - Added forced trigger thresholds, Sonnet-to-Opus escalation, lightweight exemptions, fixed handoff prompt contract, command templates, safety gates, and coordinator verification duties.
  - Explicitly kept OpenCode out of this coding multi-agent workflow while preserving it as an installed tool fact in the setup source note.
## [2026-05-17 19:42] query | PixelCat preflight for cc family

- Pages created or updated:
  - `AGENTS.md`
  - [[local-cc-sidecar-agent-workflow]]
  - [[2026-05-17-opencode-cc-pixelcat-setup]]
  - [[index]]
- Sources used:
  - User instruction and screenshot clarifying that the PixelCat management panel must be open for local `cc` family tools.
  - Local check showing `127.0.0.1:8990` listening during the session.
- Notes:
  - Added a mandatory PixelCat preflight before `cc` sidecar calls.
  - Future agents should check `127.0.0.1:8990`, launch `D:\cc\pixelcat-app.exe` when needed, wait briefly, and re-check before treating `cc` as unavailable.
  - Recorded that public wiki pages must not expose screenshot-visible PixelCat account details, API keys, balances, quota, or usage data.
## [2026-05-17 20:34] query | agent collaboration tone and model roles

- Pages created or updated:
  - `AGENTS.md`
  - [[agent-collaboration-tone-and-model-roles]]
  - [[local-cc-sidecar-agent-workflow]]
  - [[durable-agent-rule-memory]]
  - [[index]]
- Sources used:
  - User instruction to make future agent collaboration feel more human and partner-like.
- Notes:
  - Added a durable rule to use warmer user-facing language and frame Opus, Sonnet, DeepSeek, and Codex-created agents as collaborators rather than impersonal tools.
  - Recorded that Codex remains the main coordinator, Codex-created concurrent agents can be described as Codex's `分身`, and DeepSeek should default to Pro when used.
## [2026-05-17 20:52] query | DeepSeek nickname

- Pages created or updated:
  - `AGENTS.md`
  - [[agent-collaboration-tone-and-model-roles]]
  - [[log]]
- Sources used:
  - User note that DeepSeek also has the nickname `鲸鱼`.
- Notes:
  - Added `鲸鱼` as the warmer Chinese nickname future agents may use for DeepSeek when it fits the conversation.
## [2026-05-17 21:17] analysis | research project workbench audit

- Pages created or updated:
  - [[research-project-workbench]]
  - [[uncertainty]]
  - [[truce-rec]]
  - [[tgl-rec]]
  - [[2026-05-17-research-project-roots-deep-review]]
  - [[2026-05-17-research-project-workbench-audit]]
  - [[index]]
- Sources used:
  - `D:/Research/Uncertainty`
  - `D:/Research/TRUCE-Rec`
  - `D:/Research/TGL-Rec`
  - Project `AGENTS.md`, README, canonical docs, `.codex/skills`, git status, `git ls-files`, `rg --files`, and artifact-size inventory.
- Notes:
  - Added an upper-level research project workbench route for the three local LLM4Rec repositories.
  - Expanded the three project entity pages with defended claims, current gates, startup packets, module maps, file-area boundaries, git-state reminders, and future-agent entry commands.
  - Recorded the coverage strategy: classify git-tracked text-like files and inventory raw/data/output/log/archive artifacts by metadata only, without copying sensitive or large contents into public wiki.

## [2026-05-17 21:32] analysis | analog-agent workbench extension

- Pages created or updated:
  - `AGENTS.md`
  - [[research-project-workbench]]
  - [[analog-agent]]
  - [[2026-05-17-research-project-roots-deep-review]]
  - [[2026-05-17-research-project-workbench-audit]]
  - [[index]]
- Sources used:
  - `D:/Research/Agent-AI4EDA/analog-agent`
  - `AGENTS.md`, `README.md`, `docs/configured_truth_user_action_boundary.md`, `docs/repo-map.md`, `docs/related_work_map.md`, `docs/stop_conditions.md`
  - `configs/default.yaml`, `configs/benchmarks/multi_task_suite_v1.yaml`, `configs/simulator/ngspice.yaml`
  - `git status`, `git remote -v`, `git ls-files`, `rg --files`, and artifact-size inventory.
- Notes:
  - Added analog-agent to the research project workbench as the AI4EDA/SPICE counterpart to the three LLM4Rec projects.
  - Persisted the broader workbench rule in `AGENTS.md`: use the workbench as routing memory, then rescan and obey each target project's local rules.
  - Expanded analog-agent's entity page with current contribution, SPICE/configured-truth claim gates, startup packet, module map, file inventory, artifact boundaries, git reminder, and future-agent entry commands.
