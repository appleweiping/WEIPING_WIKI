# vipin wiki

`vipin wiki` is a serious LLM-maintained knowledge base designed for long-term use.

It combines:

- a public markdown wiki for durable, publishable knowledge
- a private local-only layer for sensitive materials
- a reader-specific context layer that shapes how knowledge is selected and synthesized
- an operating schema that tells an agent how to ingest, synthesize, lint, search, and grow the repository over time
- a Quartz publishing adapter that turns the public wiki into a browsable website

## Core Files

- `AGENTS.md`
- `.wiki-schema.md`
- `WORKFLOWS.md`
- `reader-context.md`
- `CONTRIBUTIONS.md`
- `purpose.md`
- `wiki/home.md`
- `wiki/index.md`
- `wiki/log.md`
- `wiki/overview.md`

## Layers

- `raw/`: immutable or externally referenced source materials
- `wiki/`: public knowledge layer
- `wiki-private/`: local-only private knowledge layer
- `reader-context.md`: reader-specific personalization layer
- `scripts/`: operational scripts for routing, validation, cacheing, search, context packing, status, and linting
- `site/`: public website publishing adapter for Quartz

## Operating Contract

For normal questions, the agent should answer quickly from the maintained wiki first, then preserve reusable knowledge after the answer.

- Fast answer lane: `wiki/index.md` -> `wiki/catalog.json` -> top relevant maintained pages.
- Durable ingest lane: update or create wiki pages, rebuild catalog, lint, update log/index, commit, and push.
- Large tasks: use multi-agent collaboration by default when available, with clear exploration, implementation, and verification roles.
- Missing dependencies: download the narrowest required tool into `.wiki-tmp/` when needed, verify it, and keep generated artifacts out of Git.
- Local projects: wiki pages record content nature and routing hints, while actual edits or current-state answers require live rescanning because paths and internals may change.

## Supported Workflows

- `init`: initialize or repair the knowledge base structure
- `ingest`: digest one source into the wiki
- `batch-ingest`: register and digest a whole folder or collection
- `query`: answer from curated wiki pages
- `digest`: write higher-order syntheses, comparisons, and reports
- `lint`: check structure, link health, and public/private boundaries
- `search`: search the machine-readable catalog instead of relying only on the handwritten index
- `context`: assemble L0/L1/L2/L3 context packs for future agent sessions
- `status`: summarize repository scale and recent activity
- `delete`: scan references before removing durable pages
- `crystallize`: save valuable conversations back into the wiki

## Useful Commands

```powershell
./scripts/wiki-status.ps1
./scripts/wiki-lint.ps1
./scripts/wiki-catalog.ps1
./scripts/wiki-search.ps1 "llm recommendation"
./scripts/wiki-context.ps1 l0
./scripts/build-site.ps1
```

```bash
bash scripts/wiki-status.sh
bash scripts/source-registry.sh validate
bash scripts/wiki-compat.sh inspect .
bash scripts/lint-runner.sh .
python scripts/wiki-catalog.py --root .
python scripts/wiki-search.py "llm recommendation" --root .
python scripts/wiki-context.py l0 --root .
bash scripts/build-site.sh
```

## Validation Rule

For non-trivial ingest, synthesis, and comparison work:

- the agent should preserve explicit source attribution
- the agent should preserve counterarguments and data gaps when a topic is contested
- the human remains the final validator for important claims

## Public / Private Safety

Public Git history must not contain:

- `raw/private-*`
- `wiki-private/`
- sensitive source references in public pages

The repository is intentionally structured so that private files stay local while the public wiki can still be versioned on GitHub.

## Section Layout

- `wiki/sources/` for source notes
- `wiki/entities/` for people, organizations, projects, and products
- `wiki/concepts/` for ideas and methods
- `wiki/topics/` for durable subject clusters
- `wiki/comparisons/` for side-by-side evaluations
- `wiki/analyses/` for maps, memos, and synthesis outputs
- `wiki/queries/` for saved answers
- `wiki/synthesis/` and `wiki/synthesis/sessions/` for long-running synthesis work
- `wiki/catalog.json` for machine-readable search and context assembly

## Optional Artifacts

- `wiki/graph-data.json` and `wiki/knowledge-graph.html` can still be generated, but graph output is secondary to ingest quality, search quality, and durable retrieval.
- The public website is built from `wiki/` through `site/` and GitHub Pages. It intentionally excludes private wiki layers and raw source folders.


