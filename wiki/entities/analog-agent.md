---
title: Analog Agent
type: entity
status: active
created: 2026-05-10
updated: 2026-05-10
tags:
  - entity
  - project
  - ai4eda
  - analog-design
source_pages:
  - 2026-05-10-research-project-roots
source_files:
  - D:/Research/Agent-AI4EDA/analog-agent/README.md
---

# Analog Agent

## Summary

`analog-agent` is Vipin's mature AI4EDA research codebase for layered analog circuit design agents. Its paper-facing thesis is that a structured analog-design agent can reduce real SPICE simulation cost while preserving or improving feasible-design discovery under physical-validity constraints.

## Key Facts

- EXTRACTED: The local root is `D:/Research/Agent-AI4EDA/analog-agent`.
- EXTRACTED: The system is organized around natural-language specification understanding, strict intermediate representations, model-based planning, simulator-backed verification, and traceable evaluation.
- EXTRACTED: The six-layer spine is specification understanding, task formalization, world-model services, planning/optimization, simulation/verification, and memory/reflection.
- EXTRACTED: The stable benchmark slices include `ota2_v1`, `folded_cascode_v1`, `ldo_v1`, and `bandgap_v1`.
- EXTRACTED: The default benchmark comparison stack includes full simulation, random search, Bayesian optimization, CMA-ES, RL baseline, no-world-model baseline, and full system.
- INFERRED: Among the AI4EDA folders, this is the current mainline project; `analog-uaas` and `Analog-RAPID` are useful lineage/predecessor or side-idea roots.

## Relationships

- Extends [[personal-knowledge-systems]] only operationally: its own README also treats traceable system boundaries as central.
- Related to [[protein-optimization-feedback-shift]] through the shared theme of uncertainty-aware closed-loop optimization.
- Related to [[uncertainty]] through calibration and decision-relevant uncertainty, but in an analog-circuit/SPICE setting rather than recommendation.

## Open Questions

- Which local paper draft is the authoritative current manuscript: `paper/agent for analog circuits.md`, `paper/version 3/deep-research-report.md`, or the submission-package workspace?
- Which results are demonstrator-truth only versus configured-truth / external-PDK / Spectre evidence?
- Which analog-agent claims should be public wiki material and which should stay local until manuscript decisions are settled?

## Related

- [[vipin-research-project-map]]
- [[2026-05-10-research-project-roots]]
