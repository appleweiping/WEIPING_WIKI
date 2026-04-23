# Workflows

`vipin wiki` follows an operating model inspired by the reference `llm-wiki-skill` repository, but adapted to this repository's public/private split.

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
  Searches a machine-readable wiki catalog rather than only scanning raw markdown by hand.
- `context`
  Builds layered context packs so future sessions can load just enough repository state.
- `lint`
  Checks broken links, orphan pages, index coverage, and public/private leaks.
- `status`
  Summarizes scale, recent activity, and public/private health without exposing private details.
- `delete`
  Scans references before deleting a durable page so indexes and graphs stay clean.
- `crystallize`
  Saves a high-value chat outcome back into the wiki as a durable page.

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
  Search results and candidate pages relevant to a specific question.
- `L3`
  Full page contents loaded only when a task truly needs them.

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
