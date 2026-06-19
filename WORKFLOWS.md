# Workflows

`WEIPING_WIKI` / `Weiping Wiki` follows an operating model inspired by the reference `llm-wiki-skill` repository, but adapted to this repository's public/private split.

Historical aliases (`vipin wiki`, `vipinknowledge`, `vipin-wiki`) remain valid when reading old prompts, old slugs, and compatibility automation. New operating docs should prefer `WEIPING_WIKI` and the `weiping-wiki` skill name.

## Commands

- `init`
  Repairs the repo structure, templates, cache helpers, and section entry pages.
- `ingest`
  Processes one source into a source note plus downstream updates.
- `batch-ingest`
  Registers a folder, corpus, or paper set as a collection and writes a research map before deeper per-item ingest.
- `query`
  Answers from `wiki/index.md` and maintained pages first.
- `digest`
  Produces a durable synthesis, comparison, timeline, or memo from multiple maintained pages.
- `search`
  Searches a machine-readable wiki catalog rather than only scanning raw markdown by hand. Optional `--graph` fuses BM25 with 1-hop wiki-link expansion (reciprocal rank fusion); `--semantic` adds best-effort agentmemory vector search with graceful fallback.
- `context`
  Builds layered context packs so future sessions can load just enough repository state.
- `lint`
  Checks broken links, orphan pages, index coverage, and public/private leaks.
- `status`
  Summarizes scale, recent activity, and public/private health without exposing private details.
- `delete`
  Scans references before deleting a durable page so indexes and graphs stay clean.
- `maintain`
  Performs periodic CRUD cleanup: add missing durable pages, update stale ones, merge duplicates, and prepare deletion proposals for genuinely useless or harmful pages.
- `crystallize`
  Saves a high-value chat outcome back into the wiki as a durable page.
- `site`
  Publishes the public `wiki/` layer as a Quartz website without treating generated pages as source material.
- `lifecycle`
  Advisory memory-lifecycle audit (confidence, Ebbinghaus retention decay, supersession). `python scripts/wiki.py lifecycle [--json] [--apply]`. Report-first; `--apply` only stamps optional date fields.
- `graph`
  Query the wiki-link knowledge graph built from the catalog: `python scripts/wiki.py graph <stats|neighbors|path|export>`.
- `scrub`
  Privacy filter-on-ingest: scan a file for secrets/private paths before it becomes a page. `python scripts/wiki.py scrub <file> [--apply]` (`--apply` writes a redacted copy, never overwrites the original).

## Default Query Contract

Questions use a fast-answer-first contract:

1. Load the lightweight route: `wiki/index.md`, `wiki/catalog.json`, and recent log context.
2. Search with `scripts/wiki-search.py` or `scripts/wiki-context.py query` when needed.
3. Open only the top maintained pages needed for a grounded answer.
4. Answer the user before running slower ingest, batch synthesis, graph generation, or broad lint.
5. Crystallize reusable answers after the quick answer, then update `wiki/index.md` and `wiki/log.md`.

This keeps conversations responsive while preserving the compounding wiki behavior.

## Abstract Project / Research Queries

When a request is phrased abstractly, such as "how should this project work", "what architecture should I use", "what research direction is promising", or "how do people usually solve this", treat it as a prior-art and inspiration task.

Use the maintained wiki first for local context, then search broadly across mainstream GitHub repositories, official project pages, benchmark repos, and strong top-conference paper/project pages. Compare several examples rather than anchoring on one. Return synthesized lessons, reusable patterns, and cautions, not copied artifacts.

## Canonical Flow

1. Read `wiki/index.md` and recent `wiki/log.md` entries.
2. Load the reader-specific layer from `reader-context.md` when the task involves interpretation, prioritization, or presentation choices.
3. Use L0/L1/L2/L3 context packs when the session needs scalable navigation instead of reading the entire wiki at once.
4. Route the source through `scripts/source-registry.sh` when relevant.
5. Create or update the source page.
6. Propagate durable changes into entities, concepts, topics, comparisons, and synthesis pages.
7. Update `wiki/index.md`, section homes, and `wiki/log.md`.
8. Produce two outputs when possible:
   the direct answer for the user and the durable wiki updates that keep the knowledge base compounding.
9. Run lint, catalog rebuild, or optional graph generation when the change is structural.
10. Commit scoped changes and push to GitHub by default after durable wiki, script, or site updates.

## Q&A Preservation Rule

Substantive question/answer exchanges should normally be preserved without needing a separate reminder from the user.

Preferred routing:

- direct reusable answer -> `wiki/queries/`
- multi-source memo -> `wiki/analyses/`
- tradeoff answer -> `wiki/comparisons/`
- durable subject improvement -> update `wiki/concepts/` or `wiki/topics/`

Chat is the transient surface.
The wiki is the durable memory.

## Context Layers

- `L0`
  Reader context, purpose, overview, and recent log headings.
- `L1`
  Stable navigation documents such as `wiki/index.md`.
- `L2`
  Full-text search results and candidate pages relevant to a specific question.
- `L3`
  Full page contents loaded only when a task truly needs them.

## Harness-Style Architecture Rules

- Keep content, retrieval, ingest, validation, and publishing as separate stages.
- Use shared parser/index code for catalog, search, context, status, and lint.
- Prefer narrow, observable commands over one large opaque script.
- Treat validation outputs as gates before commits and pushes.
- Use multi-agent collaboration by default for large content, architecture, and website tasks when the environment supports it.
- If a required dependency is truly missing, fetch the narrowest needed tool into `.wiki-tmp/` or another project-local cache and continue after verification.

## Active Maintenance / CRUD

The wiki should be maintained actively when evidence supports it. Do not preserve garbage content just because it already exists, but do preserve useful old information.

Periodic maintenance should:

- create missing durable homes for repeated topics, sources, or project concepts
- update pages whose claims, status, or framing have drifted
- merge pages that split one idea without adding retrieval value
- archive or annotate useful old information instead of deleting it
- identify stale, misleading, unsafe, superseded, or low-signal pages that may be garbage
- ask the user for explicit approval before deleting any information
- after approved deletion or merge, clean backlinks, section homes, `wiki/index.md`, and site-facing references
- log the maintenance and commit scoped changes after lint/catalog validation

Deletion proposals must state what would be removed, why it is not useful, what useful context is preserved elsewhere, and what references will be cleaned. For ambiguous cases, prefer a short deprecation note, archive marker, or merge target.

## Site Publishing

- `site/` contains the Quartz publishing adapter.
- `wiki/` remains the canonical public content source.
- `raw/`, `wiki-private/`, `raw/private-*`, generated graph assets, and non-Markdown files are not part of the first public site build.
- Local build: `./scripts/build-site.ps1` on Windows or `bash scripts/build-site.sh` where Bash/npm are available.
- GitHub Pages build: `.github/workflows/deploy.yml`.

## Public / Private Policy

- Public wiki pages live under `wiki/`.
- Sensitive local-only pages live under `wiki-private/`.
- Sensitive raw sources live under `raw/private-*`.
- Public scripts may report private counts or presence, but must not emit sensitive paths or content into public markdown.

## Cross-Project Edit Policy

- default to editing only the current repository or the repository the user explicitly named
- if a task appears to require touching another project, pause and confirm unless the user already asked for that cross-project work
- do not treat broad local filesystem access as standing permission to modify unrelated files
- when in doubt, keep changes local and ask before expanding scope

## Divergence Check

For claims that matter, the system should preserve the best counterarguments instead of only reinforcing the dominant line of evidence.

Preferred practice:

- concept, topic, comparison, analysis, and synthesis pages should include a `## Counterpoints and Gaps` section when the subject is debatable or incomplete
- if a topic is becoming one-sided, the agent should explicitly look for missing objections, limitations, or contrary data
- absence of contrary evidence is not itself confirmation

## Durable Destinations

- `wiki/sources/` for source records
- `wiki/entities/` for people, orgs, projects, products
- `wiki/concepts/` for ideas and methods
- `wiki/topics/` for durable subject clusters
- `wiki/comparisons/` for side-by-side evaluations
- `wiki/analyses/` for multi-source memos and maps
- `wiki/queries/` for saved answers
- `wiki/synthesis/` for long-running synthesis pages
- `wiki/synthesis/sessions/` for dated synthesis increments
- `wiki/timelines/` for chronological views
