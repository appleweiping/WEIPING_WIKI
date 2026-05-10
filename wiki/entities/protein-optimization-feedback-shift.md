---
title: Protein Optimization Feedback Shift
type: entity
status: active
created: 2026-05-10
updated: 2026-05-10
tags:
  - entity
  - project
  - ai4s
  - protein-optimization
  - uncertainty
source_pages:
  - 2026-05-10-research-project-roots
source_files:
  - D:/Research/UncertaintyProtein-AI4S/README.md
---

# Protein Optimization Feedback Shift

## Summary

`protein-optimization-feedback-shift` is Vipin's AI4S project on uncertainty-aware closed-loop protein sequence optimization under feedback distribution shift. Its thesis is that calibration and decision quality can separate once the optimization loop changes its own candidate distribution.

Exact local project-name entry: [[uncertaintyprotein-ai4s]].

## Key Facts

- EXTRACTED: The local root is `D:/Research/UncertaintyProtein-AI4S`.
- EXTRACTED: The executable codebase is `D:/Research/UncertaintyProtein-AI4S/protein_bo_conformal`.
- EXTRACTED: The project asks when calibration stops tracking decision quality, when weighted conformal acts as recovery under shift, and when proposal/batch policy explains observed UQ effects.
- EXTRACTED: The main panel has 12 tasks: 3 FLIP, 3 FLIP2, and 6 ProteinGym tasks.
- EXTRACTED: The appendix robustness panel has 10 tasks.
- EXTRACTED: Strong supported conclusions include that greedy is a strong baseline, raw UCB is not universally better, improved coverage does not automatically imply improved decisions, and weighted conformal is condition-dependent.
- EXTRACTED: The project is in final paper-preparation mode, with the remaining major task described as `essay/`-level LaTeX manuscript assembly and final server-side asset refresh.

## Relationships

- Related to [[analog-agent]] through closed-loop optimization and simulator/oracle-backed decision loops.
- Related to [[uncertainty]] through calibration, decision quality, and uncertainty semantics.
- Adds the AI4S branch of Vipin's research map.

## Open Questions

- Which figures/tables need final server refresh before writing?
- How should weighted conformal be framed so it is not overstated as a universal optimization improvement?
- Which local data/provenance details should remain out of the public wiki?

## Related

- [[uncertaintyprotein-ai4s]]
- [[vipin-research-project-map]]
- [[2026-05-10-research-project-roots]]
