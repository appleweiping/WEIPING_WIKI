# Contributions

This file records external ideas that materially influenced the design of `vipin wiki`.

## Karpathy LLM Wiki

- Source: [karpathy / llm-wiki.md](https://gist.github.com/karpathy)
- Adopted ideas:
  - raw / wiki / schema three-layer model
  - ingest / query / lint as core operations
  - persistent markdown as a compounding knowledge artifact instead of query-time-only RAG

## Community Extensions Adopted Here

- Personalization as a first-class layer
  - inspired by the "source + reader profile + template" idea in the user-provided commentary
  - implemented here as [reader-context.md](/D:/Research/vipin's knowledgebase/reader-context.md)
- Layered context budgets
  - inspired by the L0/L1/L2/L3 progressive disclosure idea in the user-provided commentary
  - implemented here via `scripts/wiki-context.py`
- Dual-output workflow
  - inspired by the "user output plus wiki update" rule in the user-provided commentary
  - documented in `WORKFLOWS.md` and `.wiki-schema.md`
- Divergence check / counterarguments
  - inspired by the "counterarguments and data gaps" suggestion in the user-provided commentary
  - enforced by templates and lint rules
- Source-type-aware ingest
  - strengthened by community commentary about classifying sources before extraction
  - implemented via `scripts/source-registry.tsv`
- Structured search and machine-readable catalog
  - inspired by comments about scale limits of plain index-only navigation
  - implemented via `scripts/wiki-catalog.py` and `scripts/wiki-search.py`

## Related Repositories Reviewed

- [sdyckjq-lab/llm-wiki-skill](https://github.com/sdyckjq-lab/llm-wiki-skill)
- [Astro-Han/karpathy-llm-wiki](https://github.com/Astro-Han/karpathy-llm-wiki)

## Design Principle

This repository is not trying to mirror any one public repo exactly.

Instead, it selectively absorbs ideas that improve:

- knowledge quality
- maintenance discipline
- public/private safety
- long-term usability in a real personal knowledge base
