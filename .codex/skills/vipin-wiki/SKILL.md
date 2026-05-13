---
name: vipin-wiki
description: Maintain the project-local `vipin wiki` knowledge base. Use when Codex is asked to answer from the wiki, ingest raw/source material, crystallize a reusable chat answer, update wiki pages, run wiki search/status/lint/catalog/graph/site workflows, preserve research or project memory, handle public/private wiki boundaries, or perform maintenance on this repository.
---

# Vipin Wiki

## Overview

Use this skill to behave like a disciplined maintainer of `vipin wiki`: answer quickly from maintained pages, then preserve reusable knowledge in the wiki when it has durable value.

## First Moves

1. Work from the repository root containing `AGENTS.md`, `.wiki-schema.md`, and `purpose.md`.
2. Check `git status --short --branch` before editing. Do not stage unrelated local changes.
3. Read `AGENTS.md`, `.wiki-schema.md`, and `purpose.md` before substantial ingest, synthesis, maintenance, or structural work. Follow the stricter rule when they overlap.
4. For interpretation, prioritization, or recommendation work, also read `reader-context.md`.
5. Use `wiki/index.md`, `wiki/catalog.json`, and recent `wiki/log.md` entries as the lightweight route before opening broad source material.

## Route The Task

- **Query**: answer from `wiki/index.md` first, then use `scripts/wiki-search.py` or `scripts/wiki-context.py query` and open the smallest relevant maintained pages. Preserve reusable answers under `wiki/queries/`, `wiki/analyses/`, `wiki/comparisons/`, or an existing concept/topic page.
- **Ingest**: treat `raw/` as immutable. Create or update one source note in `wiki/sources/`, propagate durable facts into entities/concepts/topics/analyses, update `wiki/index.md`, and append `wiki/log.md`.
- **Crystallize**: turn a high-value chat result into a durable page instead of leaving it only in chat. Prefer updating existing pages when that improves retrieval.
- **Maintain/lint**: look for stale claims, weak attribution, duplicate pages, orphan pages, missing index entries, broken links, and public/private leaks. Fix clear non-destructive issues; propose deletions and wait for explicit approval before removing information.
- **Research ideation**: use the wiki for local context, then examine strong external papers, official project pages, benchmark repos, and mainstream GitHub implementations when the user asks for abstract research direction or method design. Separate extracted facts from speculative invention.
- **Site/script work**: keep `wiki/` as the source of truth. Treat `site/` as the Quartz publishing adapter and `scripts/` as operational tooling.

## Safety Rules

- Default to the public wiki layer. Use `wiki-private/` or `raw/private-*` only when the user explicitly asks for private material or the current task clearly requires it.
- Never expose private paths, sensitive visual details, identity records, medical documents, financial records, passwords, or private chats through public pages, public indexes, public logs, or staged Git content.
- Store sensitive source metadata minimally and neutrally. If a source is too sensitive to summarize safely, record only minimal metadata and intended use.
- Keep writes inside this repository unless the user explicitly asks for another project. Rescan live external projects before making claims about them.

## Page And Log Conventions

- Use lowercase kebab-case filenames.
- Use YAML frontmatter when practical: `title`, `type`, `status`, `created`, `updated`, `tags`, `source_files`, `source_pages`.
- Mark non-trivial claims with `EXTRACTED`, `INFERRED`, `AMBIGUOUS`, or `UNVERIFIED` when useful.
- Use Obsidian links like `[[page-name]]`.
- Append log entries as `## [YYYY-MM-DD HH:MM] operation | title`, where operation is `ingest`, `query`, `analysis`, `lint`, or `bootstrap`.

## Useful Commands

Prefer PowerShell wrappers on Windows:

```powershell
python scripts/wiki-search.py "query text"
python scripts/wiki-context.py query "query text"
.\scripts\wiki-status.ps1
.\scripts\wiki-lint.ps1
.\scripts\wiki-catalog.ps1
.\scripts\wiki-graph.ps1
.\scripts\build-site.ps1
```

After durable wiki, script, or site changes, run the narrowest relevant validation, stage only scoped files, commit the work, and push when appropriate for the current session policy.
