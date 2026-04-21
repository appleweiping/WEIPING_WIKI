# vipin wiki

`vipin wiki` is a serious LLM-maintained knowledge base designed for long-term use.

It combines:

- a public markdown wiki for durable, publishable knowledge
- a private local-only layer for sensitive materials
- an operating schema that tells an agent how to ingest, synthesize, lint, and grow the repository over time

## Core Files

- [AGENTS.md](D:\Research\vipin's knowledgebase\AGENTS.md)
- [.wiki-schema.md](D:\Research\vipin's knowledgebase\.wiki-schema.md)
- [purpose.md](D:\Research\vipin's knowledgebase\purpose.md)
- [wiki/home.md](D:\Research\vipin's knowledgebase\wiki\home.md)
- [wiki/index.md](D:\Research\vipin's knowledgebase\wiki\index.md)
- [wiki/log.md](D:\Research\vipin's knowledgebase\wiki\log.md)

## Layers

- `raw/`: immutable or externally referenced source materials
- `wiki/`: public knowledge layer
- `wiki-private/`: local-only private knowledge layer
- `scripts/`: operational scripts for status, graph generation, and linting

## Supported Workflows

- `init`: initialize or repair the knowledge base structure
- `ingest`: digest one source into the wiki
- `batch-ingest`: register and digest a whole folder or collection
- `query`: answer from curated wiki pages
- `digest`: write higher-order syntheses, comparisons, and reports
- `lint`: check structure, link health, and public/private boundaries
- `status`: summarize repository scale and recent activity
- `graph`: generate a public wiki-link graph
- `crystallize`: save valuable conversations back into the wiki

## Useful Commands

```powershell
./scripts/wiki-status.ps1
./scripts/wiki-lint.ps1
./scripts/wiki-graph.ps1
```

## Public / Private Safety

Public Git history must not contain:

- `raw/private-*`
- `wiki-private/`
- sensitive source references in public pages

The repository is intentionally structured so that private files stay local while the public wiki can still be versioned on GitHub.


