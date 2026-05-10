---
title: Uncertainty
type: entity
status: active
created: 2026-05-10
updated: 2026-05-10
tags:
  - entity
  - project
  - llm-recommendation
  - uncertainty
source_pages:
  - 2026-05-10-research-project-roots
source_files:
  - D:/Research/Uncertainty/README.md
  - D:/Research/Uncertainty/docs/paper_claims_and_status.md
---

# Uncertainty

## Summary

`Uncertainty` is Vipin's current main project for task-grounded uncertainty in LLM-based recommendation. The defended claim is that calibrated, task-grounded uncertainty can improve controlled candidate ranking/reranking reliability under same-schema evaluation.

## Key Facts

- EXTRACTED: The local root is `D:/Research/Uncertainty`.
- EXTRACTED: The primary claim is not full-catalog recommender SOTA, generative-title recommendation, or LoRA distillation.
- EXTRACTED: The main method line is C-CRP, a calibrated candidate relevance posterior with uncertainty decomposed into boundary ambiguity, calibration gap, and evidence insufficiency.
- EXTRACTED: The risk-adjusted score is `p_cal * (1 - U)^eta`.
- EXTRACTED: Main evidence requires same-schema candidate ranking/reranking, exact score exports, calibration metadata, candidate protocol audits, and paired statistical tests.
- EXTRACTED: Official external rows need `implementation_status=official_completed`, provenance, exact score coverage, finite scores, and import through the same candidate-score gate.
- INFERRED: `D:/Research/Uncertainty-LLM4Rec` is a predecessor/archive relative to this newer governed root.

## Relationships

- Specializes [[llm-based-recommendation]] around calibrated uncertainty and decision-time reranking.
- Shares same-candidate protocol concerns with [[truce-rec]] and [[tgl-rec]].
- Provides the strongest local bridge between uncertainty research and recommender-systems paper evidence.

## Open Questions

- Which official external baselines are fully main-table eligible right now versus completed locally but not yet reflected in canonical docs?
- How should C-CRP, SRPD, and Shadow-series artifacts be separated in the paper narrative?
- Which server/local path mismatches are harmless environment differences versus missing evidence?

## Related

- [[vipin-research-project-map]]
- [[llm-based-recommendation]]
- [[2026-05-10-research-project-roots]]
