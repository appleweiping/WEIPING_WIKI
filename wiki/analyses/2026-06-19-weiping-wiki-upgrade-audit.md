---
title: WEIPING_WIKI Upgrade Audit
type: analysis
status: active
created: 2026-06-19
updated: 2026-06-19
confidence: EXTRACTED
tags:
  - weiping-wiki
  - llm-wiki
  - upgrade
  - agentmemory
source_pages:
  - llm-wiki
  - 2026-06-19-llm-wiki-v2-pattern
  - agentmemory-first-agent-collaboration
  - weiping-agentic-project-constellation
source_files:
  - scripts/wiki.py
  - scripts/wiki_core.py
  - .wiki-schema.md
  - AGENTS.md
---

# WEIPING_WIKI Upgrade Audit

## Summary

EXTRACTED: On 2026-06-19, WEIPING_WIKI adopted the substantive modules of the "LLM Wiki v2" pattern ([[2026-06-19-llm-wiki-v2-pattern]]) into the canonical `python scripts/wiki.py` CLI and the wiki knowledge layer. All changes are additive: no page was rewritten or deleted, no project root was moved, and public/private boundaries were preserved.

## Audit: gist modules vs prior state

| v2 module | Prior state | Action taken |
| --- | --- | --- |
| Crystallization | In schema/workflow vocabulary but not implemented in the CLI | Built `wiki.py crystallize` |
| Self-healing lint | `health --fix` flag existed but was a no-op | Implemented non-destructive `--fix` (+ `--dry-run`) |
| Confidence / retention-decay / supersession | Qualitative taxonomy only | Added advisory `wiki.py lifecycle` + optional frontmatter fields |
| Typed graph + traversal | Catalog stored links/backlinks; no CLI graph; relations unparsed | Added `wiki.py graph` + typed-relation parsing |
| Hybrid search | BM25-lite already present | Added `search --graph` (RRF) and `search --semantic` (agentmemory) |
| Quality scoring | Metadata tiers only | Added per-page quality score to `health` |
| Privacy filter-on-ingest | Manual schema rule | Added `wiki.py scrub` |
| Event hooks | CI + cron only | Added `scripts/hooks/session-{start,end}.py` (opt-in) |
| Consolidation tiers / mesh-sync / contradiction-heal / graph query | Provided by agentmemory | Left to agentmemory; documented, not duplicated |

## What shipped

- `scripts/wiki_core.py` (additive): typed-relation parsing into the catalog (`typed_links`, emitted only when non-empty); `build_link_graph`, `graph_neighbors`, `graph_path`, `graph_stats`; `search_catalog_graph` (BM25 + 1-hop RRF, structural hubs excluded); `quality_score`; `retention_score` + `lifecycle_audit`.
- `scripts/wiki.py` (additive): new subcommands `crystallize`, `lifecycle`, `graph`, `scrub`; real `health --fix [--dry-run]` plus a quality distribution; `search --graph` / `--semantic`.
- `scripts/hooks/session-start.py`, `session-end.py`: optional Claude Code hook helpers (read-only).
- Knowledge layer: this analysis, the source note [[2026-06-19-llm-wiki-v2-pattern]], and the updated [[llm-wiki]] concept.
- Docs/adapters updated in the same change: `.wiki-schema.md`, `WORKFLOWS.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `.opencode/OPENCODE.md`, and both `vipin-wiki` SKILL adapters.

## Design constraints honored

- Additive only; stdlib-only (no new dependencies). Semantic search reaches agentmemory over `http://localhost:3111` via `urllib`, with graceful BM25 fallback.
- New frontmatter fields (`confidence`, `last_confirmed`, `superseded_by`) are optional; pages omitting them are handled gracefully.
- `crystallize` writes only under `wiki/` and refuses to overwrite without `--force`; `scrub` never overwrites the original file.
- Constellation links to the [[weiping-agentic-project-constellation|sibling agents]] (WEIPING_LAB, WEIPING_COUNCIL, devtools, AGENT_RESOURCE, AGENTIC_SCIENCE) were not modified.

## Verification

- `wiki.py` and `wiki_core.py` compile; existing `search` / `status` / `health` behavior unchanged.
- Smoke-tested: `graph stats` (1181 nodes / 4846 edges / 0 orphans), `lifecycle --json` (0 stale — the corpus is young), `search --graph` (real content, no hub domination), `crystallize --dry-run`, `health --fix --dry-run` (rebuild stale catalog only), `scrub` (7/7 findings), `search --semantic` (agentmemory reachable).
- Gates: `lint` clean, `catalog` rebuilt, `Test-PrePushSafety.ps1` passing.

## Counterpoints and Gaps

- `lifecycle` is advisory; numeric `confidence` is not yet populated across pages, so confidence-weighted retention is mostly time-only until pages opt in.
- `search --semantic` depends on the local agentmemory service and an inferred REST endpoint; it degrades to BM25 when unavailable.
- Typed-relation counts are currently near-zero because existing pages use unlabeled wiki links; the parser populates as pages adopt relation labels.
- `health --fix` deliberately auto-fixes only catalog freshness and missing frontmatter; orphan/broken-link/counterpoint repairs remain report-only by design (human-gated).

## Sources

- [[llm-wiki]]
- [[2026-06-19-llm-wiki-v2-pattern]]
- [[agentmemory-first-agent-collaboration]]
- [[weiping-agentic-project-constellation]]
- `scripts/wiki.py`
- `scripts/wiki_core.py`
- `.wiki-schema.md`
- `AGENTS.md`
