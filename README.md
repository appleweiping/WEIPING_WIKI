# vipin wiki

`vipin wiki` is a serious LLM-maintained knowledge base designed for long-term use.

It combines:

- a public markdown wiki for durable, publishable knowledge
- a private local-only layer for sensitive materials
- an operating schema that tells an agent how to ingest, synthesize, lint, graph, and grow the repository over time

## Core Files

- `AGENTS.md`
- `.wiki-schema.md`
- `WORKFLOWS.md`
- `purpose.md`
- `wiki/home.md`
- `wiki/index.md`
- `wiki/log.md`
- `wiki/overview.md`

## Layers

- `raw/`: immutable or externally referenced source materials
- `wiki/`: public knowledge layer
- `wiki-private/`: local-only private knowledge layer
- `scripts/`: operational scripts for routing, validation, cacheing, status, graph generation, and linting

## Supported Workflows

- `init`: initialize or repair the knowledge base structure
- `ingest`: digest one source into the wiki
- `batch-ingest`: register and digest a whole folder or collection
- `query`: answer from curated wiki pages
- `digest`: write higher-order syntheses, comparisons, and reports
- `lint`: check structure, link health, and public/private boundaries
- `status`: summarize repository scale and recent activity
- `graph`: generate a public wiki-link graph
- `delete`: scan references before removing durable pages
- `crystallize`: save valuable conversations back into the wiki

## Useful Commands

```powershell
./scripts/wiki-status.ps1
./scripts/wiki-lint.ps1
./scripts/wiki-graph.ps1
```

```bash
bash scripts/wiki-status.sh
bash scripts/source-registry.sh validate
bash scripts/wiki-compat.sh inspect .
bash scripts/lint-runner.sh .
bash scripts/build-graph-data.sh .
bash scripts/build-graph-html.sh .
```

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

The graph workflow generates:

- `wiki/graph-data.json`
- `wiki/knowledge-graph.html`
- `wiki/knowledge-graph.md`


