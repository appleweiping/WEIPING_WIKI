---
title: LLM Wiki v2 Pattern
type: source
status: active
created: 2026-06-19
updated: 2026-06-19
confidence: EXTRACTED
tags:
  - source
  - knowledge-base
  - llm
  - agentmemory
origin: web
provenance: "Public gist by Rohit Ghumare (rohitg00), titled 'LLM Wiki v2', at gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2. A design-pattern essay (single markdown file, no executable code) that extends Andrej Karpathy's original LLM Wiki idea with production lessons from the agentmemory engine. Only a summary and transferable mechanisms are recorded here; the full text is not mirrored (unclear-license public webpage)."
source_pages:
  - llm-wiki
  - 2026-04-21-llm-wiki-pattern
---

# LLM Wiki v2 Pattern

## Source Summary

EXTRACTED: The source argues that Karpathy's core LLM-Wiki insight — "stop re-deriving, start compiling" — is correct, and that the bottleneck (bookkeeping) is what LLMs remove. It then adds the machinery needed to keep such a wiki healthy *at scale*, drawn from running the pattern across many sessions while building [agentmemory](https://github.com/rohitg00/agentmemory).

## Proposed Modules (what the source adds beyond v1)

EXTRACTED, each item as stated by the source:

- **Memory lifecycle.** Every fact should carry a confidence score (source count, recency, contradictions); confidence decays with time (Ebbinghaus curve) and strengthens with reinforcement. New claims should explicitly **supersede** old ones (linked, timestamped, old version preserved but marked stale). Unused facts should **fade** (retention curve), not be deleted. Raw observations should promote through **consolidation tiers**: working → episodic → semantic → procedural.
- **Knowledge graph.** Ingest should extract typed **entities** (people, projects, libraries, concepts, files, decisions) and **typed relationships** ("uses", "depends on", "contradicts", "caused", "fixed", "supersedes"). Queries should walk the graph, not only keyword-match.
- **Hybrid search.** Combine BM25 (keyword), vector (semantic), and graph traversal, fused with reciprocal rank fusion. Keep `index.md` as a human catalog but stop relying on it as the primary search past ~100–200 pages.
- **Event-driven automation.** Fire hooks on new source, session start, session end, query, memory write, and on a schedule — so the bookkeeping that makes people abandon wikis is automated while humans stay on curation/direction.
- **Quality and self-correction.** Score every written page; a **self-healing lint** should auto-fix what it safely can (orphans, stale claims, broken cross-references); contradictions should be **resolved**, not just flagged.
- **Multi-agent collaboration.** Mesh sync of parallel agents' observations (last-write-wins + timestamp resolution), shared-vs-private scoping, and lightweight work coordination.
- **Privacy and governance.** Filter sensitive data on ingest, keep an audit trail of every operation, and make bulk operations governed and reversible.
- **Crystallization.** Distill a completed chain of work (a research/debug/analysis thread) into a structured digest that becomes a first-class page, with extracted lessons strengthening the base.
- **Output formats beyond markdown.** Tables, timelines, dependency graphs, slide decks, structured exports — chosen by audience and question.
- **Schema is the product.** The schema/instruction file (`AGENTS.md` / `CLAUDE.md`) encodes entity/relation types, ingest rules, page-creation policy, quality standards, contradiction handling, consolidation schedule, and privacy scoping; it is co-evolved and transferable.

## Relevance To This Repository

EXTRACTED: WEIPING_WIKI is already an implementation of the v1 LLM-Wiki pattern (see [[llm-wiki]], [[2026-04-21-llm-wiki-pattern]]). Several v2 modules were already present in embryo (a confidence taxonomy in `.wiki-schema.md`, an `entities/` layer, a `distill` command, `log.md` as an audit trail) or covered by the active [[agentmemory-first-agent-collaboration|agentmemory]] layer (consolidation tiers, mesh-sync, contradiction-heal, graph query).

INFERRED: The transferable, missing pieces for the local `wiki.py` CLI were: a real `crystallize` command, a working self-healing `health --fix`, an advisory memory-lifecycle audit (confidence/retention-decay/supersession), wiki-link graph traversal in the unified CLI, graph/semantic search fusion, a content-quality score, and an ingest privacy-scrub. These were adopted on 2026-06-19; see [[2026-06-19-weiping-wiki-upgrade-audit]].

## Related Pages

- [[llm-wiki]]
- [[2026-04-21-llm-wiki-pattern]]
- [[2026-04-22-karpathy-llm-wiki-zh-compilation]]
- [[agentmemory-first-agent-collaboration]]
- [[2026-06-19-weiping-wiki-upgrade-audit]]
