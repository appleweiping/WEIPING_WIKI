---
title: Public Corpus Ingest Workflow
type: analysis
status: active
created: 2026-05-16
updated: 2026-05-18
tags:
  - wiki-workflow
  - public-corpus
  - automation
source_pages:
  - AGENTS.md
  - wiki/sources/2026-05-16-yao-shunyu-public-corpora.md
---

# Public Corpus Ingest Workflow

Use this workflow when the user asks for a complete public corpus such as full GitHub, projects, public releases, papers, posts, and recurring updates.

## Trigger Pattern

- User asks for complete GitHub, all projects, all public releases, all papers, and recurring updates.
- User emphasizes that the corpus is important and future agents must remember the workflow.

## Required Steps

- Disambiguate same-name people before crawling.
- Create separate entity pages, manifests, raw directories, and source pages for distinct identities.
- Use stable item IDs and `semantic_hash` to prevent duplicate captures and noisy commits.
- Use safe public indexing: metadata, summaries, links, hashes, categories, and license notes.
- Do not publicly mirror unclear-license full PDFs, source code, or long webpage text.
- Add or update an automation that reruns the ingest, validates, commits scoped changes, and pushes.
- Treat automation outputs as official wiki maintenance. If a run changes raw manifests, source pages, topic pages, analysis pages, `wiki/catalog.json`, `wiki/index.md`, or `wiki/log.md`, stage those scoped outputs, commit them, and push after validation.

## Validation

- Run manifest duplicate checks.
- Run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`.
- Ignore unrelated local changes such as `GetPdf.pdf` unless the user explicitly asks otherwise.
- Before committing, inspect `git diff --stat` and the relevant file diffs so generated changes are real content changes and do not leak private data.
- If `git status` reports automation-managed files as modified but hashes and `git diff` show no real content changes, treat it as false dirty state from line endings or index metadata. Refresh/normalize the index and report that there was no substantive automation output to commit.
- Never leave real automation output uncommitted at the end of the turn unless validation fails or the user explicitly asks to pause.

## Counterpoints And Gaps

- This workflow is a default pattern, not permission to ignore source-specific licenses or identity ambiguity.
- Some public platforms block automated access; record crawl errors and use stable fallback sources instead of inventing completeness.
- Automation commits still need scope discipline: do not stage unrelated local edits just because an automation run touched nearby wiki sections.
