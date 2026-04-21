# AGENTS.md

This repository is a personal knowledge base called `vipin wiki`.
Agents working here should behave like disciplined wiki maintainers, not generic chatbots.

## Mission

Your job is to help compile knowledge into a persistent, interlinked markdown wiki that grows over time.

Humans are responsible for:

- choosing and curating sources
- steering emphasis and interpretation
- asking questions

The agent is responsible for:

- reading source materials
- extracting key facts and claims
- updating existing pages
- creating new pages when needed
- maintaining cross-links
- recording work in the index and log

## Repository Structure

- `raw/`
  - Immutable source materials.
  - Never edit files in this directory unless the user explicitly asks for file organization help.
  - New materials typically arrive in `raw/inbox/`.
- `wiki/`
  - The maintained knowledge layer.
  - The agent may create and update markdown files here.
- `AGENTS.md`
  - The operating schema for all future sessions.

## Wiki Structure

- `wiki/home.md`
  - Top-level overview of the knowledge base.
- `wiki/index.md`
  - Content-oriented catalog of the wiki.
- `wiki/log.md`
  - Append-only chronological activity log.
- `wiki/entities/`
  - People, organizations, products, places, projects, etc.
- `wiki/concepts/`
  - Ideas, themes, frameworks, methods.
- `wiki/sources/`
  - One page per ingested source.
- `wiki/analyses/`
  - Syntheses, comparisons, memos, or structured outputs derived from multiple pages.
- `wiki/queries/`
  - High-value question answers worth preserving.
- `wiki/_templates/`
  - Optional page templates for consistency.

## File Naming

- Use lowercase kebab-case file names.
- Prefer stable page names for durable topics:
  - `wiki/entities/vipin.md`
  - `wiki/concepts/llm-wiki.md`
- For time-stamped source and analysis notes, prefix with ISO date:
  - `wiki/sources/2026-04-21-llm-wiki-pattern.md`
  - `wiki/queries/2026-04-21-how-to-ingest-sources.md`

## Page Conventions

Use YAML frontmatter on wiki pages when practical.

Recommended fields:

- `title`
- `type`
- `status`
- `created`
- `updated`
- `tags`
- `source_files`
- `source_pages`

Use Obsidian wiki links freely, especially:

- from source pages to related entities and concepts
- from concept pages to source pages that support them
- from analysis pages to all major supporting pages

## Source Handling Rules

- Treat `raw/` as the source of truth.
- Do not modify raw files during ingest.
- If a user provides source material in chat, it is valid to create a source page that records:
  - origin: `chat`
  - provenance note describing what was provided
- Distinguish clearly between:
  - what the source says
  - what the wiki currently infers
  - what remains uncertain

## Sensitive Materials

- Treat intimate images, medical documents, identity records, financial records, passwords, and private chats as high-sensitivity materials.
- Store such items in clearly named private folders under `raw/` when the user wants them kept in the repository.
- Do not copy sensitive visual details into the wiki unless they are directly relevant to the user's stated purpose.
- Prefer neutral descriptions and explicit provenance.
- If a source is too sensitive to summarize safely, record only minimal metadata and a note about intended use.

## Ingest Workflow

When asked to ingest a source:

1. Read `wiki/index.md` and recent entries in `wiki/log.md`.
2. Read the new source material.
3. Create or update a page in `wiki/sources/`.
4. Update any relevant pages in:
   - `wiki/entities/`
   - `wiki/concepts/`
   - `wiki/analyses/`
5. Add missing cross-links.
6. Update `wiki/index.md`.
7. Append a new entry to `wiki/log.md`.

During ingest, prefer updating existing pages over creating duplicates.

## Query Workflow

When asked a substantive question:

1. Read `wiki/index.md` first.
2. Open the most relevant pages.
3. Synthesize an answer grounded in the maintained wiki.
4. If the answer is valuable long-term, ask whether it should be filed or directly file it when the user's intent is clearly archival.
5. If filed, create a page under `wiki/queries/` or `wiki/analyses/`, then update index and log.

## Lint Workflow

When asked to health-check the wiki, look for:

- contradictions across pages
- stale claims superseded by newer sources
- orphan pages with weak linking
- concepts/entities that are mentioned often but lack dedicated pages
- missing source attribution
- overly large pages that should split
- gaps that suggest useful future sources

Record meaningful lint results in `wiki/analyses/` and add a `lint` entry to the log.

## Writing Style

- Write concise, information-dense markdown.
- Prefer explicit claims over vague summary language.
- Separate facts, interpretations, and open questions.
- Preserve uncertainty.
- Use headings and bullet lists liberally when they improve scanability.
- Avoid fluff.

## Log Format

Use this heading format for each entry in `wiki/log.md`:

`## [YYYY-MM-DD HH:MM] operation | title`

Where `operation` is one of:

- `ingest`
- `query`
- `analysis`
- `lint`
- `bootstrap`

Each entry should include:

- pages created or updated
- source(s) used
- a short note on what changed

## Index Expectations

`wiki/index.md` should remain easy to skim.
Each listed page should include:

- page link
- one-line description
- last updated date when useful

Keep index organization stable unless the wiki's scale clearly requires a redesign.
