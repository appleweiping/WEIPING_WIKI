---
title: PLEASE IMPLEMENT THIS PLAN -
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - automation
source_pages:
  - codex-prompt-corpus
---

# PLEASE IMPLEMENT THIS PLAN:

## Metadata

- Stable ID: `codex-user-prompt:7cbf27b02da1e40b`
- Source kind: `codex-session-user`
- Category: `automation`
- Timestamp: `2026-05-15T20:32:49.929Z`
- Semantic hash: `7cbf27b02da1e40bba929c3b6dc6ed8bea3371b88b3ebe9f9a2b8d8cee26136c`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# OpenAI Cookbook Wiki Ingest + Weekly Auto-Update Plan

## Summary
- Treat `https://developers.openai.com/cookbook` as the canonical discovery surface and `openai/openai-cookbook` as the preferred full-text source when content is license-traceable.
- Build a public wiki mirror/index because the OpenAI Cookbook GitHub repo is MIT-licensed; preserve attribution and license notes.
- Set up a weekly Codex automation that re-crawls Cookbook links, detects added/changed/removed pages, updates wiki pages, commits, and pushes.

## Key Changes
- Add a durable Cookbook hub:
 - `wiki/topics/openai-cookbook.md`: top-level taxonomy, why it matters, how to use it.
 - `wiki/sources/2026-05-15-openai-cookbook.md`: batch source note with provenance, crawl date, source URLs, license basis, and update policy.
 - `wiki/analyses/openai-cookbook-taxonomy.md`: categorized map of all Cookbook content.
- Create per-item wiki pages for every discovered Cookbook article/example:
 - filename derived from Cookbook path slug.
 - include canonical developers URL, GitHub/raw source URL when found, title, category, tags, summary, “what this teaches”, implementation use cases, and update hash.
 - include full mirrored text/code only when source is traceable to the MIT-licensed OpenAI Cookbook repo; otherwise store structured summary + link only.
- Add a machine-readable manifest:
 - `raw/openai-cookbook/manifest.json`
 - records URL, path, category, title, source kind, content hash, first seen, last seen, last changed, wiki page path.
- Update `wiki/index.md`, `wiki/log.md`, and relevant topic pages so future agents can find Cookbook material quickly.

## Classification Scheme
- Primary categories:
 - Agents SDK / agent workflows
 - Responses API / tool orchestration
 - ChatGPT / GPT Actions
 - Codex / coding agents
 - Evaluation / eval flywheels
 - RAG / file search / retrieval
 - Vector databases
 - Fine-tuning / reinforcement fine-tuning
 - Realtime / voice / transcription
 - Multimodal / image / video
 - gpt-oss / open-weight deployment
 - GPT-5 / prompting / model behavior
 - Structured outputs / function calling
 - Deep Research / MCP
 - Third-party integrations
- Secondary tags are inferred from path and page content: `notebook`, `article`, `production-pattern`, `quickstart`, `eval`, `rag`, `agent`, `voice`, `enterprise`, `codex`, etc.

## Automation Design
- Add a repo script, e.g. `scripts/ingest-openai-cookbook.ps1`, that:
 - fetches the Cookbook index from `developers.openai.com/cookbook`;
 - extracts `/cookbook/examples/...` and `/cookbook/articles/...` links;
 - resolves matching GitHub/raw source files when possible;
 - computes content hashes;
 - updates the manifest and wiki pages only when changed;
 - appends a concise log entry;
 - runs wiki catalog/lint validation.
- Create a weekly Codex automation:
 - schedule: weekly.
 - prompt: run the Cookbook ingest script, summarize additions/changes/removals, validate, commit scoped wiki/raw/script changes, push to `origin/main`.
 - commit message pattern: `Update OpenAI Cookbook ingest`.
- Automation must ignore unrelated local changes, including the existing untracked `GetPdf.pdf`.

## Test Plan
- Dry-run crawl verifies:
 - Cookbook index is reachable.
 - link count is nonzero and close to current observed baseline of about 235 Cookbook links.
 - each URL maps to exactly one manifest entry.
- Validation verifies:
 - generated wiki pages have frontmatter, source URL, category, summary, and hash.
 - `wiki/index.md` links the Cookbook hub and taxonomy.
 - `scripts/wiki-catalog.ps1` and `scripts/wiki-lint.ps1` pass.
 - no private paths or credentials are written to public wiki pages.
- Automation acceptance:
 - first run creates the full ingest.
 - second run with no upstream changes produces no content commit or only a “no changes” report.
 - new upstream Cookbook link creates a new manifest entry, wiki page, index/taxonomy update, log entry, commit, and push.

## Assumptions
- Public full-text mirroring is allowed only for content traceable to the MIT-licensed OpenAI Cookbook repository; developers-only pages without a clear licensed source are summarized and linked instead of copied wholesale.
- The wiki remains public, so the ingest must avoid private notes, API keys, local credentials, or non-public cache paths.
- Weekly auto-update and automatic commit/push are the default chosen behavior.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
