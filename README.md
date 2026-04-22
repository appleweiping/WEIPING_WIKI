# vipin wiki

`vipin wiki` is a serious LLM-maintained knowledge base designed for long-term use.

It combines:

- a public markdown wiki for durable, publishable knowledge
- a private local-only layer for sensitive materials
- a reader-specific context layer that shapes how knowledge is selected and synthesized
- an operating schema that tells an agent how to ingest, synthesize, lint, search, and grow the repository over time

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
```

```bash
bash scripts/wiki-status.sh
bash scripts/source-registry.sh validate
bash scripts/wiki-compat.sh inspect .
bash scripts/lint-runner.sh .
python scripts/wiki-catalog.py --root .
bash scripts/wiki-search.py "llm recommendation" --root .
bash scripts/wiki-context.py l0 --root .
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


