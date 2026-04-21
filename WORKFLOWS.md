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
- `lint`
  Checks broken links, orphan pages, index coverage, and public/private leaks.
- `status`
  Summarizes scale, recent activity, and public/private health without exposing private details.
- `graph`
  Generates machine-readable and human-readable graph outputs for public pages.
- `delete`
  Scans references before deleting a durable page so indexes and graphs stay clean.
- `crystallize`
  Saves a high-value chat outcome back into the wiki as a durable page.

## Canonical Flow

1. Read `wiki/index.md` and recent `wiki/log.md` entries.
2. Route the source through `scripts/source-registry.sh` when relevant.
3. Create or update the source page.
4. Propagate durable changes into entities, concepts, topics, comparisons, and synthesis pages.
5. Update `wiki/index.md`, section homes, and `wiki/log.md`.
6. Run lint or graph generation when the change is structural.

## Public / Private Policy

- Public wiki pages live under `wiki/`.
- Sensitive local-only pages live under `wiki-private/`.
- Sensitive raw sources live under `raw/private-*`.
- Public scripts may report private counts or presence, but must not emit sensitive paths or content into public markdown.

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
