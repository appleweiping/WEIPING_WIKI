# vipin wiki

`vipin wiki` is a long-term, LLM-maintained knowledge base for research, project memory, and reusable agent workflows.

It is designed to compound: conversations, sources, local project discoveries, public corpora, and operational lessons should become maintained Markdown knowledge instead of disappearing into chat history.

## What This Is

- A public Markdown wiki for durable, publishable knowledge.
- A private local layer for sensitive materials that must not leak into public pages, indexes, logs, commits, or the published site.
- A source-backed research memory system for papers, projects, tools, skills, workflows, and reusable answers.
- An operating environment for Codex-style agents: query first, preserve what matters, validate, commit, and push.
- A Quartz-ready public website source, where `wiki/` remains the source of truth and `site/` is only the publishing adapter.

## What This Is Not

- Not a loose notes folder.
- Not an append-only archive.
- Not a place to mirror private documents or unclear-license source material into public Git history.
- Not a replacement for live rescanning of external projects before editing them.
- Not a generic chatbot transcript dump; high-value exchanges should be crystallized into durable pages.

## Architecture

| Layer | Purpose | Main entry points |
| --- | --- | --- |
| Raw sources | Immutable evidence, source pointers, local captures, and manifests | `raw/` |
| Public wiki | Maintained, publishable knowledge graph | `wiki/home.md`, `wiki/index.md`, `wiki/overview.md`, `wiki/log.md` |
| Private local layer | Sensitive local-only knowledge and materials | kept out of public indexes, logs, and site output |
| Reader context | User-specific priorities for interpretation and synthesis | `reader-context.md`, `purpose.md` |
| Operating contract | Rules for agents, schema, workflows, and contribution history | `AGENTS.md`, `.wiki-schema.md`, `WORKFLOWS.md`, `CONTRIBUTIONS.md` |
| Tooling | Search, catalog, lint, context packing, ingest, status, and site build scripts | `scripts/` |
| Publishing adapter | Quartz website build layer for the public wiki | `site/` |
| Local runtime/cache | Temporary tools and generated operational artifacts | `.wiki-tmp/` |

## Start Here

For humans:

1. Read `purpose.md` for why this wiki exists.
2. Read `wiki/home.md` and `wiki/index.md` for navigation.
3. Read `wiki/log.md` to understand recent maintenance and ingests.
4. Use `scripts/wiki-search.ps1` or `scripts/wiki-search.py` when the index is not enough.

For agents:

1. Read `AGENTS.md`, `.wiki-schema.md`, and `purpose.md`.
2. Check `git status --short --branch` before changing anything.
3. Use `wiki/index.md`, `wiki/catalog.json`, and recent `wiki/log.md` entries as the lightweight route.
4. Open only the smallest relevant maintained pages needed for the task.
5. After durable changes, rebuild catalog, lint, check diff hygiene, commit scoped changes, and push.

## Operating Contract

Default behavior is two-lane:

- Fast answer lane: answer from maintained wiki pages first.
- Durable lane: preserve reusable knowledge in `wiki/`, update index/log/catalog when needed, validate, commit, and push.

Important rules:

- Prefer updating existing pages over creating duplicates.
- Preserve source attribution and uncertainty.
- Separate `EXTRACTED`, `INFERRED`, `AMBIGUOUS`, and `UNVERIFIED` claims when useful.
- Keep public and private material separated.
- Treat local project pages as routing/context; rescan live projects before making current-state claims or edits.
- Install missing narrow dependencies into project-local D-drive/cache locations when practical, then verify them.

## Core Workflows

| Workflow | Use when | Durable output |
| --- | --- | --- |
| `query` | The user asks a substantive question | A fast grounded answer, plus a saved query/analysis if reusable |
| `ingest` | One source or chat-provided source should become wiki knowledge | Source note plus relevant entity/concept/topic updates |
| `batch-ingest` | A folder, corpus, person, repo set, or paper set needs structured capture | Collection source note, manifests, maps, and dedupe rules |
| `crystallize` | A valuable chat result should not remain only in chat | Query, analysis, concept, topic, or workflow page |
| `maintain` | The wiki has drift, stale claims, duplicates, weak links, or outdated README/docs | Non-destructive CRUD maintenance plus log entry |
| `lint` | Structure, links, index coverage, or public/private boundaries need checking | Lint report and fixes when safe |
| `site` | The public wiki needs publishing | Quartz build through `site/`, without treating generated output as source truth |
| `automation` | Local crawls or scheduled ingests update manifests/wiki pages | Validated, scoped commit and push of real automation outputs |

## Common Commands

PowerShell, preferred on this Windows workspace:

```powershell
.\scripts\wiki-status.ps1
.\scripts\wiki-catalog.ps1
.\scripts\wiki-lint.ps1
.\scripts\wiki-search.ps1 "llm recommendation"
.\scripts\wiki-context.ps1 l0
.\scripts\build-site.ps1
```

Python/Bash alternatives:

```bash
python scripts/wiki-catalog.py --root .
python scripts/wiki-search.py "llm recommendation" --root .
python scripts/wiki-context.py l0 --root .
bash scripts/wiki-status.sh
bash scripts/source-registry.sh validate
bash scripts/wiki-compat.sh inspect .
bash scripts/build-site.sh
```

## Quality Gates

Run the narrowest relevant validation before committing. For typical wiki maintenance:

```powershell
.\scripts\wiki-catalog.ps1
.\scripts\wiki-lint.ps1
git diff --check
```

Expected standards:

- No broken wiki links.
- No missing index entries for durable public pages.
- No public/private boundary leaks.
- No unrelated files staged.
- No generated cache/tool/browser-profile artifacts committed.
- No meaningless commits for false dirty states with no real content diff.

## Commit And Automation Discipline

After durable wiki, script, site, README, or automation-output changes:

1. Inspect `git status --short --branch`.
2. Inspect relevant diffs, not just filenames.
3. Rebuild catalog when wiki content changed.
4. Run lint and `git diff --check`.
5. Stage only scoped files.
6. Commit with a clear message.
7. Push to GitHub by default.

Automation outputs are official maintenance when they produce real changes. If a crawl or scheduled workflow updates raw manifests, source pages, analysis pages, catalog, index, or log, validate and commit those scoped outputs. If files are only falsely marked dirty because of line endings or index metadata, refresh/normalize the state and report that there was no substantive diff to commit.

## Public And Private Safety

Public Git history and public wiki pages must not contain sensitive content.

Use public pages for:

- neutral metadata;
- source summaries;
- public URLs;
- stable IDs and hashes;
- workflow notes;
- non-sensitive project memory;
- public-safe analyses and queries.

Do not publish:

- secrets, tokens, credentials, or app keys;
- private document contents;
- sensitive personal identifiers;
- private chats or high-sensitivity materials;
- unclear-license full PDFs, long webpage text, or source-code mirrors unless explicitly permitted and appropriate.

When in doubt, record minimal metadata and ask before expanding public detail.

## Important Maintained Pages

- `wiki/index.md` - main public catalog.
- `wiki/overview.md` - structural overview of the wiki.
- `wiki/log.md` - chronological maintenance and ingest log.
- `wiki/concepts/readme-maintenance-workflow.md` - README refresh rule.
- `wiki/analyses/public-corpus-ingest-workflow.md` - public corpus and automation discipline.
- `wiki/concepts/agent-skill-installation-workflow.md` - skill installation as usable-tool workflow.
- `wiki/concepts/feishu-material-access-workflow.md` - Feishu/Lark API-first, browser-fallback workflow.

## README Maintenance

This README is a living engineering entry point. Refresh it when:

- wiki structure changes materially;
- automation rules or commit discipline changes;
- major workflows or local tooling are added;
- validation expectations change;
- new agents would otherwise start from stale guidance.

README refreshes should stay concise, public-safe, and linked to maintained wiki pages rather than duplicating the full index. After refreshing, validate, commit, and push the scoped change.

