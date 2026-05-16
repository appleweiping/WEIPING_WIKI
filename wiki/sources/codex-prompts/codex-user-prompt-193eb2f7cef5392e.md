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

- Stable ID: `codex-user-prompt:193eb2f7cef5392e`
- Source kind: `codex-session-user`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T00:03:48.885Z`
- Semantic hash: `193eb2f7cef5392e69974c437e29fd39de9e7bc7f5e9cdc26d36ce8e3a00301e`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# 姚顺宇 / 姚顺雨 Public Corpus Ingest + Auto-Update

## Summary
- Build two separate public corpora in `vipin wiki`:
 - **姚顺雨 / Shunyu Yao / `ysymyth`**: OpenAI researcher focused on language agents, ReAct, ToT, SWE-agent, SWE-bench, tau-bench, CUA, Deep Research.
 - **姚顺宇 / Dr. Shunyu Yao / `alfredyao.github.io`**: physics-to-AI researcher, Google DeepMind / Anthropic, quantum physics, RL, agentic coding, non-Hermitian skin effect, scramblon/quantum gravity work.
- Do not mix the two people. Use distinct entity IDs, source directories, manifests, and automation prompts.
- Use **safe public indexing**: commit metadata, summaries, links, hashes, categories, and license notes; avoid committing unlicensed full PDFs/code/text unless clearly redistributable.
- Add a durable “public corpus ingest workflow” so future agents recognize this repeated prompt pattern and know how to implement it.

## Key Changes
- Add one script: `scripts/ingest-shunyu-yao-public.ps1` with `-Person ysymyth|alfredyao|All`, `-DryRun`, and `-SkipValidation`.
- Store machine-readable manifests:
 - `raw/yao-shunyu-ysymyth/manifest.json`
 - `raw/yao-shunyu-alfred/manifest.json`
- Create durable wiki pages:
 - `wiki/entities/yao-shunyu-ysymyth.md` for 姚顺雨.
 - `wiki/entities/yao-shunyu-alfred.md` for 姚顺宇.
 - `wiki/topics/shunyu-yao-public-corpora.md` as the hub that explicitly separates the two.
 - `wiki/sources/2026-05-16-yao-shunyu-public-corpora.md` as the batch provenance note.
 - `wiki/analyses/shunyu-yao-project-taxonomy.md` for projects/repos/products.
 - `wiki/analyses/shunyu-yao-paper-map.md` for papers, theses, benchmarks, and research themes.
 - `wiki/analyses/public-corpus-ingest-workflow.md` documenting the reusable workflow/prompt pattern.
- Update `AGENTS.md` with a short pointer: when a user asks for “完整 GitHub / 所有项目 / 公开发布信息 / 所有论文 / 定时更新”, use the public-corpus ingest workflow and first disambiguate same-name people.
- Update `wiki/index.md`, `wiki/log.md`, and `wiki/catalog.json`.

## Source Coverage
- For **姚顺雨 / `ysymyth`**, crawl:
 - Homepage/blog: `https://ysymyth.github.io/` and `https://ysymyth.github.io/blog/`
 - GitHub API: `https://api.github.com/users/ysymyth`, repos, gists, releases, README/license metadata.
 - Linked project repos from homepage: ReAct, Tree of Thoughts, SWE-agent, SWE-bench, WebShop, tau-bench, InterCode, Reflexion, Cognitive Architectures, and future linked repos.
 - Papers from homepage links, arXiv IDs, thesis PDF metadata, project pages, talks/YouTube links.
- For **姚顺宇 / `alfredyao`**, crawl:
 - Homepage: `https://alfredyao.github.io/`
 - CV PDF metadata: `https://alfredyao.github.io/Shunyu_Yao_CV.pdf`
 - Google Scholar link from CV as a pointer only; use arXiv/Crossref/Semantic Scholar/OpenAlex where available for machine-readable paper metadata.
 - Linked writing pages, LinkedIn pointer metadata, and any GitHub links found from official pages or verified paper/project pages.
 - Physics/AI paper metadata around non-Hermitian skin effect, quantum chaos/gravity, scramblons, RL numerics, and agentic coding contributions.

## Manifest And Page Rules
- Stable manifest IDs:
 - `person:ysymyth`, `person:alfredyao`
 - `github:<owner>/<repo>`
 - `paper:arxiv:<id>` or `paper:doi:<doi>` or `paper:title-hash:<hash>`
 - `post:<canonical-url-hash>`
 - `talk:<platform>:<id>`
 - `project:<canonical-url-hash>`
- Each item records: `person_key`, canonical URL, source kind, title, authors/owners, venue/date, repo/path, license, content hash, semantic hash, first seen, last seen, last changed, wiki page, category, tags, public handling, crawl errors.
- Per-item wiki pages are created for repos, major projects, papers, theses, talks, and high-signal posts. Short/low-signal updates stay in batch digest pages.
- Public pages summarize and classify; they do not mirror unlicensed PDFs, full webpages, or source code.

## Classification
- Shared categories:
 - Language agents / agent architectures
 - Tool use / computer use / digital automation
 - Software engineering agents and benchmarks
 - Evaluation / benchmark design
 - Reinforcement learning and reasoning
 - Human-agent interaction / user simulation
 - Quantum chaos / quantum gravity
 - Non-Hermitian topology / condensed matter
 - Physics-to-AI research transition
 - Public essays / research philosophy
- Every page includes a “do not confuse with” note in metadata or source note, but not over-emphasized in prose.

## Automation
- Create weekly Codex automation: `Update Shunyu Yao Public Corpora`.
- Prompt: run `scripts/ingest-shunyu-yao-public.ps1 -Person All`, summarize additions/changes/removals/errors, run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`, commit scoped changes with `Update Shunyu Yao public corpora`, and push `origin/main`.
- No noisy commits: if stable IDs and semantic hashes are unchanged, report no changes and do not commit.
- Ignore unrelated local changes, especially existing untracked `GetPdf.pdf`.

## Test Plan
- Dry-run verifies both people resolve to distinct canonical homes and manifests.
- Validation checks:
 - no duplicate stable IDs;
 - every item has `person_key`, `source_kind`, canonical URL, category, semantic hash, first seen, and public handling;
 - all public pages have frontmatter, source URLs, summary, confidence labels, and no private path leaks;
 - `wiki-catalog.ps1`, `wiki-lint.ps1`, and `git diff --check` pass.
- Repeat-run acceptance:
 - first run creates the corpora;
 - second run with no upstream changes is no-op;
 - a new paper/repo/post creates exactly one manifest entry, wiki update, log entry, commit, and push.

## Assumptions
- “姚顺宇” means the DeepMind/Anthropic physics-to-AI researcher at `alfredyao.github.io`, not the AIGC/product person at `shunyuyao.github.io`.
- “姚顺雨” means `ysymyth.github.io` / GitHub `ysymyth`.
- Public GitHub redistribution stays license-safe: summaries, metadata, hashes, and links are public; unclear-license full text/code/PDFs are not committed wholesale.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
