---
title: Log
type: log
status: active
created: 2026-04-21
updated: 2026-06-01
tags:
  - log
---

# Log

## [2026-06-01 16:55] maintenance | Active local roots and refresh audit helper

- Pages/files updated:
  - [[local-active-project-roots]]
  - [[whole-computer-project-map]]
  - [[local-project-roots]]
  - `.codex/skills/vipin-wiki/SKILL.md`
  - `scripts/wiki-maintenance-audit.ps1`
- Notes:
  - Added a detailed public-safe launch map for important non-research local roots such as legal-case automation, Veylora, Medora, Agent Town, Pretext, and portfolio repos.
  - Added an advisory maintenance audit script for stale pages, missing `updated` frontmatter, local-path pages, Agent Hub mentions, and missing counterpoints.
  - Kept no-README/scratch/archive roots at summary level and kept research experiments routed through [[research-project-workbench]].

## [2026-06-01 16:10] maintenance | Whole-computer vipin wiki maintenance map

- Pages/files updated:
  - [[whole-computer-project-map]]
  - [[d-drive-project-map]]
  - [[local-project-roots]]
  - `AGENTS.md`, `CLAUDE.md`, `.opencode/OPENCODE.md`, `.claude/skills/README-skills-layout.md`, `README.md`
  - `.codex/skills/vipin-wiki/SKILL.md`
- Notes:
  - Rebuilt the `vipin-wiki` skill around continuing maintenance, old-content refresh, whole-computer project mapping, and importance-based depth so future agents do not need a fresh prompt.
  - Added `scripts/computer-inventory.ps1` as a shallow public-safe inventory helper for `C:/`, `D:/`, `G:/`, and user-profile junctions.
  - Kept research experiment code, datasets, checkpoints, logs, and progress outside this maintenance scope.

## [2026-06-01 15:35] maintenance | D-drive project map and safety gates

- Added [[d-drive-project-map]] as the first-stop routing page for D-drive infrastructure, public exports, private runtime state, and research isolation.
- Added pre-push safety gate scripts for public-facing repositories and recorded that Agent Hub historical references should carry deprecated context.
- Recorded endpoint-key rotation status privately because provider management APIs returned `401` without a logged-in dashboard session.

## [2026-06-01 11:40] maintenance | D-drive agent infrastructure follow-up

- Pages/files updated:
  - `AGENTS.md`
  - `.gitignore`
  - [[agentmemory-first-agent-collaboration]]
  - [[local-project-roots]]
- Notes:
  - Recorded that agentmemory slots require `AGENTMEMORY_SLOTS=true`.
  - Reclassified raw `memory/sessions/` dumps as local historical noise unless deliberately curated.
  - Refreshed top-level D-drive organization buckets and cleanup boundaries.
  - Kept PixelCat as a resident Claude dependency in the devtools health model.

## [2026-05-18 10:45] analysis | analog-agent deep module review and direction discussion

- Pages created or updated:
  - `D:\Research\Agent-AI4EDA\analog-agent\CLAUDE.md` (full rewrite with per-module assessment, priority roadmap, experiment design, critical questions)
- Source: Claude Code session, full codebase review of 143 Python files (32k LOC)
- Notes: Project assessed at ~65% completion. Core gaps: mock truth default, no trained surrogate, toy baselines, no statistical rigor. Recommended direction: "Surrogate-guided Optimization with Trust-aware Fidelity Selection" for DAC/ICCAD. Recommended dropping LLM claim, demoting Memory layer. Priority roadmap defined (P0: real SPICE + trained surrogate, P1: trust gate experiment + SOTA baselines). Direction discussion pending user decision on 5 critical questions.

## [2026-05-18 10:10] ingest | Agent Hub MCP server and multi-agent upgrade

- Pages created or updated:
  - [[agent-hub-mcp-server]] (new concept page)
  - `CLAUDE.md` (full rewrite: 5-agent system, 20 tools, quality gate, invoke methods)
  - `AGENTS.md` (Haiku role, Agent Hub section, pipeline example, auto-retry, quality gate)
  - `README.md` (multi-agent collaboration section)
  - `.claude/skills/README-skills-layout.md` (agent-hub reference)
  - `.claude/skills/lidang-perspective/` (new skill, nuwa-distilled)
  - `.claude/settings.json` (Agent Teams enabled)
- Source: Claude Code session, building on Codex architecture review
- Notes: Renamed `D:\cc` to `D:\devtools`. All path references updated across 16+ files. Agent Hub provides 20 MCP tools for real-time collaboration. Daemon auto-starts on boot.

## [2026-05-18 01:44] analysis | multi-agent collaboration architecture review

- Pages created or updated:
  - `AGENTS.md`
  - `CLAUDE.md`
  - [[local-cc-sidecar-agent-workflow]]
  - [[model-collaboration-context-and-reference-intake]]
  - [[2026-05-18-multi-agent-collaboration-architecture-review]]
  - [[index]]
  - [[log]]
- Sources used:
  - User feedback that prior model collaboration was too shallow and that DeepSeek / `鲸鱼` requests must be treated as real delegation.
  - User-provided Claude Code analysis of current collaboration architecture.
  - Live repository inspection of `AGENTS.md`, `.claude/skills`, `.codex/skills`, and maintained wiki concept pages.
  - Read-only Opus review through `D:\cc\cc.cmd` with a full context pack.
- Notes:
  - Fixed DeepSeek delegation bullet indentation in `AGENTS.md`.
  - Added a long-context `cc` handoff rule: pipe large prompts through stdin and treat generic readiness output as failed delegation.
  - Added a quick routing reference for Opus, Sonnet, DeepSeek / `鲸鱼`, and Codex-only fallback.
  - Added a minimal root `CLAUDE.md` so direct Claude Code sessions route back to `AGENTS.md` and understand read-only partner mode.
  - Recorded which proposed improvements are adopted now, deferred, or rejected.

## [2026-05-18 01:10] query | model collaboration context packing and reference intake

- Pages created or updated:
  - `AGENTS.md`
  - [[agent-collaboration-tone-and-model-roles]]
  - [[local-cc-sidecar-agent-workflow]]
  - [[research-ideation-policy]]
  - [[model-collaboration-context-and-reference-intake]]
  - [[2026-05-18-user-feedback-model-collaboration-context-intake]]
  - [[index]]
  - [[log]]
- Sources used:
  - User report that prior cc-family collaboration felt like low-context prompting rather than real delegation.
  - Existing local CC workflow, research ideation policy, and collaboration tone rules.
- Notes:
  - Added a durable rule that partner handoffs must carry the full relevant conversation state, fixed decisions, scoped artifacts, and explicit output format.
  - Added a durable rule that software/project/web-reference work should read the whole relevant source material deeply enough to understand the operating pattern, not a toy README skim.
  - Added a source note recording the user feedback so the rule has provenance.

## [2026-05-18 00:44] query | explicit DeepSeek delegation intent

- Pages created or updated:
  - `AGENTS.md`
  - [[agent-collaboration-tone-and-model-roles]]
  - [[log]]
- Sources used:
  - User report that a new chat misread "叫鲸鱼执行" as a local CLI discovery task.
  - Existing collaboration tone and DeepSeek role rules.
- Notes:
  - Added a durable routing rule that `叫/让/请 + 鲸鱼/DeepSeek + 执行/看/评审/总结/分析/监视` is an explicit DeepSeek delegation request.
  - Clarified that Codex should gather compact read-only local snapshots for filesystem tasks before handing them to DeepSeek, and must not claim DeepSeek directly accessed local files.
  - Clarified that DeepSeek unavailability must be stated plainly instead of silently downgrading to Codex-only, and that `监视` defaults to a one-time check unless recurring automation is requested.

## [2026-05-17 23:06] query | local cc usage environments

- Pages created or updated:
  - [[2026-05-17-where-can-local-cc-be-used]]
  - [[queries-home]]
  - [[index]]
  - [[log]]
- Sources used:
  - User question with PixelCat management-panel screenshot.
  - [[local-cc-sidecar-agent-workflow]]
  - [[2026-05-17-opencode-cc-pixelcat-setup]]
- Notes:
  - Preserved the distinction between `cc` as a local command-line Claude Code entrypoint, PixelCat as the local proxy/control plane, VSCode/OpenCode/Codex as configurable local tool surfaces, and generic Claude web/app chat as a separate environment.
  - Avoided recording screenshot-visible account, quota, balance, or API-key details in the public wiki.
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
  - [[queries-home]]
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
## [2026-05-17 21:43] query | email assistant skill

- Pages created or updated:
  - [[email-assistant-skill]]
  - [[2026-05-17-email-assistant-skill]]
  - [[index]]
  - [[log]]
- Sources used:
  - User-approved personal email assistant skill plan.
  - `benchflow-ai/skillsbench` Gmail skill at upstream HEAD `30d31e972211c2287e63257a5f5c05eba5d74bba`.
  - `glebis/claude-skills` Gmail search skill.
  - `openai/skills` repository search.
  - Local installed skill under `.codex/skills/email-assistant/`.
- Notes:
  - Installed and customized `email-assistant` for API-first Gmail/Google Workspace triage across `umn` and `vipinapple`.
  - Stored OAuth material under ignored `.wiki-tmp/email-assistant/auth/` paths and added send/delete/label confirmation gates.
  - Validated dependency install, skill frontmatter, JavaScript syntax, no-account behavior, missing-credentials behavior, and fail-closed send/label gates; live Gmail tests remain pending user OAuth.
## [2026-05-17 22:38] ingest | WeChat Channels video publishing and LLM hex anime project

- Pages created or updated:
  - [[wechat-video-channel-publish-skill]]
  - [[2026-05-17-wechat-video-channel-publish-skill]]
  - [[2026-05-17-llm-hex-anime-video-project]]
  - [[index]]
  - [[log]]
- Sources used:
  - `https://github.com/JamesWuHK/wechat-video-channel-publish-skill`
  - `D:/video creation/projects/llm-hex-anime/`
  - Local installed skill files under `.codex/skills/wechat-video-channel-publish/`
- Notes:
  - Installed a dedicated 视频号 publishing skill after confirming the existing WeChat publisher only covered公众号 article/image-text flows.
  - Patched the skill build command for Windows and validated dependency install, build, CLI help, and upload help without login or upload.
  - Created a D-drive LLM ability-hexagon anime video project with model data, storyboard, prompt packs, generated radar/cover/subtitle assets, preview MP4, and a reviewed 视频号 upload command template.
  - Recorded that `tencent upload`, including `--draft`, is a live-account action requiring explicit user confirmation.
## [2026-05-17 22:01] query | communication assistant skill

- Pages created or updated:
  - [[communication-assistant-skill]]
  - [[2026-05-17-communication-assistant-skill]]
  - [[email-assistant-skill]]
  - [[2026-05-17-email-assistant-skill]]
  - [[index]]
  - [[log]]
- Sources used:
  - User-approved communication assistant plan.
  - GitHub references: `op7418/Claude-to-IM-skill`, `fastclaw-ai/weclaw`, `huohuoer/wechat-cli`, `cluic/wxauto`, `NapNeko/NapCatQQ`, `tencent-connect/openclaw-qqbot`, `steipete/warelay`.
  - Local installed skill under `.codex/skills/communication-assistant/`.
- Notes:
  - Installed a unified communication router skill with a shared outbox and prefill-first safety model for WhatsApp, WeChat, QQ, Feishu/Lark, and email reuse.
  - Added adapter references that prefer QR/login-state/session-based paths and explicitly avoid password storage.
  - Validated `pnpm install`, `node --check`, outbox create/show/mark/cancel/list smoke tests, and confirmed the runtime state is confined to ignored `.wiki-tmp/communication-assistant/`.
## [2026-05-17 22:57] query | nuwa prompt for lidang skill distillation

- Pages created or updated:
  - [[2026-05-17-how-to-ask-nuwa-to-distill-lidang]]
  - [[index]]
  - [[log]]
- Sources used:
  - Local `huashu-nuwa` skill instructions.
  - Existing local `lidang-perspective` skill.
  - [[lidang]]
  - [[lidang-idea-taxonomy]]
- Notes:
  - Preserved a copy-paste prompt for asking Nuwa, with Opus as the deep review partner, to update the Lidang perspective skill.
  - Recorded that the existing `lidang-perspective` skill should be reused and deepened rather than duplicated.
## [2026-05-18 00:07] query | VS Code black screen repair runbook

- Pages created or updated:
  - [[2026-05-18-vscode-black-screen-repair-runbook]]
  - [[index]]
  - [[log]]
- Sources used:
  - Live repair session for Microsoft VS Code black-screen behavior.
  - Local VS Code paths and status output, including `Code.exe`, `argv.json`, `code.cmd --status`, logs, and backup directories.
- Notes:
  - Recorded the full diagnosis and repair sequence: process/path confirmation, cache and state cleanup, clean-profile tests, renderer status inspection, hardware-rendering configuration, winget repair failure, official user installer fallback, and final verification.
  - Documented the Cursor misclassification and restoration so future agents verify the target executable before touching VS Code-family apps.
  - Preserved a fast next-time runbook while avoiding public exposure of sensitive `settings.json` contents.
## [2026-05-18 11:51] query | PixelCat CC partner outage runbook

- Pages created or updated:
  - [[2026-05-18-pixelcat-cc-502-credentials-disabled-runbook]]
  - [[local-cc-sidecar-agent-workflow]]
  - [[agent-hub-mcp-server]]
  - [[2026-05-18-multi-agent-collaboration-architecture-review]]
  - [[2026-05-17-opencode-cc-pixelcat-setup]]
  - [[2026-05-18-user-feedback-model-collaboration-context-intake]]
  - [[2026-05-17-where-can-local-cc-be-used]]
  - [[email-assistant-skill]]
  - [[2026-05-17-email-assistant-skill]]
  - [[queries-home]]
  - [[index]]
  - [[log]]
- Sources used:
  - User-provided PixelCat management-panel screenshot showing HTTP 502 and disabled upstream credentials.
  - Local checks of `D:\devtools\cc.cmd`, PixelCat on `127.0.0.1:8990`, and the Agent Hub daemon on port 9800.
  - New `scripts/Test-LocalCcPartner.ps1` health check output.
- Notes:
  - Diagnosed the failure as PixelCat/ccmax upstream credential/network state rather than a Claude Code installation, prompt, or model-name problem.
  - Added a reusable PixelCat/CC health check that detects the `upstream_credentials_disabled` 502 case before future agents spend time retrying `cc`.
  - Updated Agent Hub and collaboration docs so Opus/Sonnet/Haiku calls fall back quickly and record a clear limitation when the CC family is unavailable.
  - Cleaned the related wiki lint gaps by indexing the collaboration-context source note and adding counterpoint/gap sections to current multi-agent pages.
  - Corrected stale `D:\cc` references in current runbooks to the live `D:\devtools` runtime while preserving historical log context.
## [2026-05-18 12:34] query | PixelCat binary refresh check

- Pages created or updated:
  - [[2026-05-17-opencode-cc-pixelcat-setup]]
  - [[2026-05-18-pixelcat-cc-502-credentials-disabled-runbook]]
  - [[log]]
- Sources used:
  - User-provided instruction to replace the old PixelCat binary with the freshly downloaded `PixelCat-beta-1029da-Windows-x64.zip`.
  - Local replacement and health-check outputs.
- Notes:
  - Replaced only `D:\devtools\pixelcat-app.exe`, backed up the old executable, and left PixelCat config/credentials and other Agent Hub files untouched.
  - Confirmed the refreshed binary starts and listens on `127.0.0.1:8990`.
  - Confirmed the remaining failure is still PixelCat/ccmax upstream credential state: `upstream_credentials_disabled` with HTTP 502.
## [2026-05-18 12:55] query | PixelCat TUN and exit-node attempt

- Pages created or updated:
  - [[2026-05-18-pixelcat-cc-502-credentials-disabled-runbook]]
  - [[2026-05-17-opencode-cc-pixelcat-setup]]
  - [[log]]
- Sources used:
  - Local Clash Verge, PixelCat config, network adapter, public-IP, and health-check outputs.
- Notes:
  - Launched Clash Verge and confirmed local proxy port `127.0.0.1:7897`, but no active real Clash profile was configured.
  - PixelCat through the local proxy still returned `upstream_credentials_disabled`; direct and proxied public IP were identical.
  - TUN forcing attempts were overwritten by Clash Verge, no virtual adapter appeared, and all temporary PixelCat/Clash config changes were restored.
  - Clarified that PixelCat panel address `127.0.0.1:8990` is the local API endpoint; outbound proxy/TUN routing is separate and would not replace that displayed address.
## [2026-05-18 13:02] query | PixelCat no-TUN exit routing

- Pages created or updated:
  - [[2026-05-18-pixelcat-cc-502-credentials-disabled-runbook]]
  - [[local-cc-sidecar-agent-workflow]]
  - [[2026-05-17-opencode-cc-pixelcat-setup]]
  - `scripts/Test-LocalCcPartner.ps1`
  - [[log]]
- Sources used:
  - User question about changing IP without the provider's virtual VPN application.
  - Prior local PixelCat, Clash Verge, and health-check results.
- Notes:
  - Recorded that a provider VPN/TUN app is not strictly required if PixelCat can use a trusted alternative exit such as a self-owned VPS SSH dynamic proxy, trusted HTTP/SOCKS proxy, WARP-style route, hotspot, or another physical network.
  - Clarified the invariant that `cc.cmd` must keep calling PixelCat on `127.0.0.1:8990`; proxy ports such as `7897` are outbound exits only.
  - Added verification guidance: first prove the proxy changes public IP, then configure PixelCat outbound proxy, restart if needed, and rerun `scripts/Test-LocalCcPartner.ps1`.
  - Recorded that `429 Too Many Requests` is an upstream rate-limit/retry-exhaustion signal, not evidence that the local API address should be replaced.
## [2026-05-18 13:31] query | CC-family fallback to Codex parallel selves

- Pages created or updated:
  - [[2026-05-18-pixelcat-cc-502-credentials-disabled-runbook]]
  - [[local-cc-sidecar-agent-workflow]]
  - [[log]]
- Sources used:
  - User instruction that future agents should remember to replace unavailable CC-family roles with Codex's `分身`.
  - Current PixelCat/CC health-check state showing `upstream_credentials_disabled`.
- Notes:
  - Added the durable rule that when Opus/Sonnet/Haiku are blocked, their collaboration slots should default to Codex parallel selves / `分身`.
  - Clarified that DeepSeek Pro remains a separate optional partner for its own strengths, not the automatic replacement for every CC-family role.
## [2026-05-18 13:45] query | automation model policy

- Pages created or updated:
  - [[codex-automation-model-policy]]
  - [[durable-agent-rule-memory]]
  - [[index]]
  - [[log]]
- Sources used:
  - User instruction to reset all automations to GPT-5.5 high intelligence and preserve that as a future-agent hard rule.
  - Local audit of `C:\Users\admin\.codex\automations`.
- Notes:
  - Updated seven cron automations from `low` or `medium` reasoning to `high` via the Codex app automation API.
  - Verified all local cron automations now use `model = "gpt-5.5"` and `reasoning_effort = "high"`.
  - Recorded that heartbeat automations may not expose model/reasoning fields and are not noncompliant solely for lacking them.
## [2026-05-18 14:09] ingest | openai cookbook mirror

- Pages created or updated:
  - [[openai-cookbook]]
  - [[2026-05-15-openai-cookbook]]
  - [[openai-cookbook-taxonomy]]
  - `wiki/sources/openai-cookbook/`
- Sources used:
  - https://developers.openai.com/cookbook
  - https://github.com/openai/openai-cookbook
- Notes:
  - Mirrored 235 Cookbook article/example pages.
  - New manifest entries this run: 0.
  - Changed source hashes this run: 0.
  - Manifest stored at `raw/openai-cookbook/manifest.json`.
## [2026-05-18 14:12] lint | automation outputs and mattpocock skill audit

- Pages created or updated:
  - [[mattpocock-skills]]
  - [[2026-05-16-skill-source-repository-trace]]
  - [[log]]
- Sources used:
  - Current workspace diff for Shunyu Yao automation outputs.
  - Current workspace diff for OpenAI Cookbook mirror automation outputs.
  - `raw/lidang-public/inbox/2026-05-18-light.json`.
  - `.claude/skills/mattpocock-skills`.
  - `scripts/Test-LocalCcPartner.ps1`.
- Notes:
  - Audited the Shunyu Yao automation changes as conservative maintenance: failed crawls now preserve previous manifest entries and record crawl errors without inventing new facts.
  - Audited the OpenAI Cookbook mirror refresh as source-preserving maintenance: 235 entries remain, no URLs were added or removed, and the page count matches the manifest.
  - Audited the new Lidang light capture as public-safe failed-crawl evidence with one metadata-only X profile probe and no private-path leak.
  - Audited the Matt Pocock Claude skill install as MIT-licensed, provenance-matched, and secret-scan clean; nested `.git` metadata was moved to ignored `.wiki-tmp` backup so the skill can be committed as normal source files.
  - Confirmed CC-family partners are still blocked by PixelCat `upstream_credentials_disabled`, so this review used Codex-side verification rather than a real Opus/Sonnet pass.

## [2026-05-18 20:25] bootstrap | OpenCode promoted to full collaboration partner

- Pages created or updated:
  - `AGENTS.md` — added OpenCode to CC partner table, role assignments, collaboration patterns, and new `## OpenCode Partner Policy` section
  - `CLAUDE.md` — updated to 6-agent system, added OpenCode identity and invocation path
  - `README.md` — updated to 6-agent system, added OpenCode to agent roles table and getting started
  - `.claude/skills/README-skills-layout.md` — added OpenCode directory reference
  - `.opencode/OPENCODE.md` — created OpenCode-specific operating guide
  - [[local-cc-sidecar-agent-workflow]] — updated OpenCode status from excluded to full partner
  - [[2026-05-17-opencode-cc-pixelcat-setup]] — updated OpenCode status note
- Sources used:
  - Existing `AGENTS.md`, `CLAUDE.md`, `README.md` operating docs
  - User request to integrate OpenCode as CC-family fusion partner
- Notes:
  - OpenCode (claude-opus-4-7 via OpenCode CLI) is now a full read/write collaboration partner, not excluded.
  - Positioned as CC-family fusion: combines Opus reasoning depth with Codex-style task decomposition and sub-agent orchestration.
  - Independent entry point: does not depend on PixelCat, Agent Hub daemon, or cc.cmd.
  - Coordinates with other agents via git state and wiki/log.md (always available) plus Agent Hub shared state (when daemon is running).
  - System upgraded from 5-agent to 6-agent collaboration.

## [2026-05-31 18:50] ingest | public voice sample archive

- Pages created or updated:
  - [[2026-05-31-voice-sample]]
  - [[index]]
  - [[log]]
  - `raw/voice-notes/README.md`
- Sources used:
  - User-provided `voice sample.zip`.
- Notes:
  - Added `raw/voice-notes/voice sample.zip` as a public raw source archive, preserving the original filename.
  - Recorded archive hash and MP3 member filenames for future voice-related work.

## [2026-06-01 10:18] maintenance | agentmemory-first infrastructure refresh

- Pages created or updated:
  - [[agentmemory-first-agent-collaboration]]
  - [[implicit-skill-routing]]
  - [[agent-resources]]
  - [[agent-hub-mcp-server]]
  - [[agent-skill-installation-workflow]]
  - [[agent-skill-repositories]]
  - [[local-cc-sidecar-agent-workflow]]
  - [[index]]
  - [[log]]
- Sources used:
  - User request to retire Agent Hub, make agentmemory active, improve implicit skill use, and prepare `agent-resources` / `devtools` for public-safe open source.
  - Current local docs and configs under `vipin-wiki`, `D:\agent-resources`, and `D:\devtools`.
- Notes:
  - Marked Agent Hub as deprecated historical infrastructure.
  - Recorded agentmemory as the active collaboration/memory layer and markdown `memory/` as historical/superseded.
  - Added durable implicit skill-routing rules so agents invoke skills by task intent rather than waiting for explicit skill names.
  - Replaced remaining active ARIS Claude skill handoff wording with agentmemory signals/actions and explicit context packs.
  - Removed tracked `memory/sessions/*.md` dumps from the public Git index while leaving local files in place.
  - Removed active Agent Hub state dependencies from the wiki dashboard/token scripts; they now use agentmemory/default local token state and only read legacy metrics from an explicit environment variable.
  - Removed a secret-bearing key memory file from public Git, rewrote `vipin-wiki` history, force-pushed the clean history, and verified a fresh remote clone has zero exact-key/history hits.

## [2026-06-01 16:42] maintenance | vipinknowledge continuous maintenance system

- Pages created or updated:
  - [[vipinknowledge-maintenance-system]]
  - [[index]]
  - [[log]]
  - `.codex/skills/vipin-wiki/SKILL.md`
  - `.claude/skills/vipin-wiki/SKILL.md`
  - `scripts/wiki.py`
  - `scripts/wiki-maintain.ps1`
- Sources used:
  - User-approved implementation plan for weekly whole-computer maintenance, safe auto commit/push, and shallow all-drive scanning.
  - Existing [[whole-computer-project-map]], [[d-drive-project-map]], [[local-active-project-roots]], and [[local-project-roots]].
- Notes:
  - Added `python scripts/wiki.py maintain --scope whole-computer --json` as the canonical ignored-report command for weekly maintenance.
  - Rebuilt the Codex `vipin-wiki` skill as a mode router with separate references for scan depth, weekly maintenance, self-upgrade, and automation safety.
  - Added a Claude/OpenCode-visible adapter skill so non-Codex partners can trigger the same maintenance workflow.
  - Recorded scoped automation gates: report first, update curated wiki/skill/docs only when evidence changed, validate, then stage and push only scoped files.

## [2026-06-01 16:44] ingest | University of Minnesota AZ hold guidance

- Pages created or updated:
  - [[2026-06-01-umn-az-hold-esl-course-information]]
  - [[university-of-minnesota]]
  - [[index]]
  - [[log]]
  - `raw/inbox/2026-06-01-umn-az-hold.txt`
- Sources used:
  - User-provided pasted text about AZ holds, English proficiency scores, ESL course registration, MN Battery Test, transfer exemptions, and MELP contact information.
- Notes:
  - Preserved the provided passage verbatim in both the raw inbox text file and the source note's verbatim text block.
  - Marked the source as user-provided and not independently verified.

## [2026-06-01 17:10] maintenance | commit discipline for cross-chat wiki outputs

- Pages created or updated:
  - `AGENTS.md`
  - [[vipinknowledge-maintenance-system]]
  - [[log]]
- Sources used:
  - User instruction that obvious same-session/cross-chat wiki, raw, memory, and documentation outputs should be committed rather than left behind as trivial adjacent dirty work.
- Notes:
  - Added the durable rule that deliberate, public-safe, validated wiki/raw/memory/doc outputs should be included in a scoped commit even when they were produced by another active chat.
  - Preserved the guard against committing source-unclear, sensitive, conflicting, incomplete, external-project, or validation-failing work.

## [2026-06-01 17:28] maintenance | Obsidian-compatible vault upgrade

- Pages created or updated:
  - [[obsidian-feature-parity]]
  - [[obsidian-dashboard]]
  - [[bases/README]]
  - [[obsidian-compatible-commands]]
  - [[slides/README]]
  - [[index]]
  - [[log]]
  - `.obsidian/`
  - `wiki/bases/*.base`
  - `wiki/canvases/vipinknowledge-map.canvas`
  - `wiki/commands/obsidian-compatible-commands.md`
  - `wiki/slides/README.md`
  - `wiki/_templates/daily.md`
  - `wiki/_templates/web-clip.md`
  - `scripts/wiki_obsidian.py`
  - `scripts/wiki.py`
  - `scripts/wiki_core.py`
- Sources used:
  - Obsidian official Help pages for core plugins, Bases, Properties, Web Clipper, and CLI.
  - JSON Canvas 1.0 specification.
  - Obsidian GitHub organization pages for open components such as JSON Canvas and Web Clipper.
- Notes:
  - Recorded that Obsidian core is proprietary, so this project adapts documented behavior and open file formats instead of claiming source-level parity.
  - Added real local-first artifacts for opening the repository as an Obsidian vault: settings, Bases, Canvas, bookmarks, workspaces, generated dashboard, command page, slides home, daily/web-clip templates, and CLI reports for backlinks, outgoing links, search, quick switcher, outline, preview, footnotes, tags, properties, tasks, word count, random notes, external links, format audit, slides, and daily/unique notes.

## [2026-06-01 17:55] infrastructure | devtools agentmemory cleanup and mem0 mapping

- Pages created or updated:
  - [[agentmemory-first-agent-collaboration]]
  - [[log]]
- Sources used:
  - Local implementation pass over `D:\devtools`, `D:\devtools-public`, upstream `rohitg00/agentmemory`, and upstream `mem0ai/mem0`.
- Notes:
  - Recorded that `agentmemory` remains the active local runtime while mem0 is absorbed as an architecture reference, not maintained as a fork.
  - Captured the service contract: agentmemory 0.9.24, iii 0.11.2, `http://localhost:3111`, all tools, slots enabled, and MCP tool-surface health checks.
  - Marked OpenMemory, old Agent Hub mailbox/state paths, tracked runtime DB/log files, and old C-drive npm agentmemory paths as inactive surfaces.

## [2026-06-01 18:45] infrastructure | workstation maintenance skill and drive-organization guardrails

- Pages created or updated:
  - [[whole-computer-project-map]]
  - [[d-drive-project-map]]
  - [[local-project-roots]]
  - [[vipinknowledge-maintenance-system]]
  - [[index]]
  - [[log]]
  - `AGENTS.md`
  - `README.md`
  - `CLAUDE.md`
  - `.opencode/OPENCODE.md`
  - `.codex/skills/vipin-wiki/SKILL.md`
  - `.claude/skills/vipin-wiki/SKILL.md`
  - `.claude/skills/README-skills-layout.md`
- Sources used:
  - Live preflight over `vipinknowledge`, `agent-resources`, `devtools`, `devtools-public`, agentmemory, and `D:/devtools/health-check.ps1`.
  - New shared skill at `D:/agent-resources/skills/vipin/workstation-maintenance`.
- Notes:
  - Added a two-layer maintenance rule: `workstation-maintenance` owns physical C:/D:/G: inventory, move plans, approved batches, and rollback; `vipin-wiki` owns public-safe map/index/log/catalog updates.
  - Reaffirmed `D:/Research` as a hard no-move boundary for workstation organization.
  - Generated a dry-run workstation inventory with 3,026 classified entries and 669 low-risk move-eligible file candidates; `D:/Research` entries were 0.
  - Tightened move-plan generation to default to a 30-day age gate and 100-item batch cap: 531 old low-risk candidates remain executable, 138 recent candidates are deferred, and executable reparse points, directories, git worktree items, and recently modified files are all 0.
  - Generated 13 granular approval-candidate batches by file type and part number; no physical file move was executed.
  - Added and tested non-moving batch preflight support; `batch-downloads-installers-old` preflight passed with 1 checked item and 0 moves.
  - Actual C/D file moves remain gated on explicit user approval of generated batch IDs.
