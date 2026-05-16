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

- Stable ID: `codex-user-prompt:bed42e1493ef08d3`
- Source kind: `codex-session-user`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T17:40:21.522Z`
- Semantic hash: `bed42e1493ef08d3cae2f71085b9bc74ddb729021428ab34bc0cda69361b9702`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# Codex Prompt Corpus + Weekly Research Digest Plan

## Summary
- Build two durable wiki corpora: `codex-prompts-public` for high-quality local Codex prompts, and `weekly-research-digests` for five weekly inspiration tracks: AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.
- Treat user-authored prompts and automation prompts as first-class sources; exclude short, garbled, code/log-like, pasted-server, or sensitive prompts.
- Use public full-text selected prompt pages because the user chose `Public全文精选`, but still redact secrets and reject risky/private items.
- Set all new crawl/update automations to afternoon local time, with `model = "gpt-5.5"` and `reasoning_effort = "medium"`.

## Key Changes
- Add `scripts/ingest-codex-prompts-public.ps1` with `-Root`, `-DryRun`, `-SkipValidation`, and `-SinceDays`:
 - Read `C:\Users\admin\.codex\sessions\**\*.jsonl`, `archived_sessions\*.jsonl`, `session_index.jsonl`, and `automations\*\automation.toml`.
 - Extract only user prompts and automation prompts; ignore assistant/tool/system/developer payloads.
 - Filter out prompts that are too short, mostly code/logs, high-gibberish, high-symbol, duplicated, secret-like, or pasted stack traces/config dumps.
 - Store manifest/inbox under `raw/codex-prompts-public/` with stable IDs like `codex-user-prompt:<hash>` and `codex-automation-prompt:<automation_id>`, plus `dedupe_key`, `semantic_hash`, source path, timestamp, category, and rejection reason when excluded.
- Add wiki outputs:
 - `wiki/topics/codex-prompt-corpus.md` as the prompt corpus hub.
 - `wiki/sources/codex-prompts/<stable-id>.md` for selected full-text prompt entries.
 - `wiki/analyses/codex-prompt-taxonomy.md` grouped by research workflow, automation, coding agent workflow, wiki/ingest, project strategy, personal rules, and prompt engineering patterns.
 - Update `wiki/index.md`, `wiki/log.md`, and `wiki/catalog.json`.
- Add `scripts/ingest-weekly-research-digest.ps1`:
 - Query arXiv/Semantic Scholar/PapersWithCode/GitHub/official blogs where available.
 - Pick one high-signal item per category per week using recency, relevance, citation/social/project signal, source quality, and novelty-to-wiki checks.
 - Save abstracts, links, concise plain-language core idea, why it matters, agent reuse angle, and small comparison/chart data.
 - Avoid copying long paper text; store summaries, metadata, URLs, hashes, and provenance.
- Add weekly digest wiki outputs:
 - `wiki/topics/weekly-research-digests.md`.
 - `wiki/analyses/weekly-research-digest-YYYY-Www.md`.
 - Optional `wiki/sources/weekly-research-digests/YYYY-Www-<category>.md` when an item deserves its own page.
 - Include tables/charts for category, source, date, signal score, method idea, repo/demo link, and “what an agent should remember.”
- Add or update agent memory/rules:
 - Record that crawl automations should not run very early; prefer noon/afternoon.
 - Record that automation model defaults should remain `gpt-5.5`.
 - Record prompt corpus filtering rules so future agents do not ingest noisy prompts.

## Automation
- Add `update-codex-prompt-corpus`:
 - Schedule weekly Wednesday 14:30 local time.
 - Run `scripts/ingest-codex-prompts-public.ps1 -SinceDays 14`.
 - Validate with `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`.
 - Commit `Update Codex prompt corpus` only when selected prompts, semantic hashes, manifest, or taxonomy changed.
- Add `weekly-research-inspiration-digest`:
 - Schedule weekly Friday 15:30 local time.
 - Run `scripts/ingest-weekly-research-digest.ps1`.
 - Commit `Add weekly research inspiration digest` only when a new weekly digest or evidence changes.
- Audit existing content-crawl automations and move early crawl times to noon/afternoon where safe, while preserving cadence and `gpt-5.5`.

## Test Plan
- Dry run prompt ingest and confirm it discovers sessions, archived sessions, and automation prompts without writing files.
- Verify prompt filtering with fixtures for short text, good long prompts, code dumps, logs, mojibake, secrets, duplicated prompts, and automation TOML prompts.
- Dry run weekly digest and confirm exactly five category picks with abstracts, links, summaries, and chart data.
- Run real ingest, then check no duplicate stable IDs and no private paths/secrets in public pages.
- Run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, `git diff --check`, and targeted manifest duplicate checks.

## Assumptions
- `Public全文精选` means selected high-quality prompts may be published in full after safety filtering; rejected or sensitive prompts stay out of public wiki.
- Weekly digest prioritizes inspiration and agent reuse over exhaustive literature review.
- Afternoon automation timing means no new crawl/update automation before 12:00 local time unless the user explicitly requests it.
- Existing unrelated `GetPdf.pdf` remains ignored.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
