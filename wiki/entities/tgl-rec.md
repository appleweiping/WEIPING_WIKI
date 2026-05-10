---
title: TGL-Rec
type: entity
status: active
created: 2026-05-10
updated: 2026-05-10
tags:
  - entity
  - project
  - llm-recommendation
  - temporal-graph
source_pages:
  - 2026-05-10-research-project-roots
source_files:
  - D:/Research/TGL-Rec/README.md
---

# TGL-Rec

## Summary

`TGL-Rec` studies temporal graph-to-language retrieval for need-aware sequential recommendation. Its core question is whether LLM recommenders follow temporal need transitions or mostly retrieve semantically similar/popular items.

## Key Facts

- EXTRACTED: The local root is `D:/Research/TGL-Rec`.
- EXTRACTED: Working title: `Beyond Similarity: Time-Aware Graph Translation for LLM-based Sequential Recommendation`.
- EXTRACTED: Current status is Phase 10, focused on four-domain same-candidate protocol and stronger TGL-Rec framework integration.
- EXTRACTED: The method builds temporal directed item graph evidence and translates it into compact natural-language evidence for candidate-grounded reranking.
- EXTRACTED: Need-gated TDIG evidence includes transition probability, PMI, lift, direction asymmetry, recency, drift, contrastive evidence, and semantic-trap penalty.
- EXTRACTED: Current diagnostic data is not final paper evidence; no senior-recommended official reference baseline is reportable yet.
- INFERRED: TGL-Rec is the temporal-transition counterpart to [[truce-rec]] and [[uncertainty]].

## Relationships

- Related to [[llm-based-recommendation]] through LLM reranking and sequential recommendation.
- Related to [[truce-rec]] through shared large same-candidate packages and official-baseline governance.
- Complements [[uncertainty]] by focusing on temporal evidence rather than calibrated confidence alone.

## Open Questions

- Does temporal evidence beat history-only prompting after post-label-mask LoRA diagnostics are rerun?
- Which reference baselines can be faithfully adapted through official code?
- How should semantic-trap diagnostics become a paper-facing claim without overreaching from preliminary protocol data?

## Related

- [[vipin-research-project-map]]
- [[llm-based-recommendation]]
- [[2026-05-10-research-project-roots]]
