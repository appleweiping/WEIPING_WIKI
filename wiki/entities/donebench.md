---
title: DoneBench
type: entity
status: active
created: 2026-05-10
updated: 2026-05-10
tags:
  - entity
  - project
  - benchmark
  - agents
source_pages:
  - 2026-05-10-research-project-roots
source_files:
  - D:/Research/DoneBench/README.md
---

# DoneBench

## Summary

`DoneBench` is a benchmark for specification grounding in tool-using agents. It tests whether agents can infer, formalize, stress-test, and satisfy task-completion criteria before executing stateful tasks.

## Key Facts

- EXTRACTED: The local root is `D:/Research/DoneBench`.
- EXTRACTED: The benchmark axis is `Specification Grounding`, not generic agent ability.
- EXTRACTED: Each task includes a user goal, visible tool environment, initial state, policies, gold criteria, executable DoneSpec, near-miss final states, reference trace, and audit metadata.
- EXTRACTED: Primary grading is deterministic through the DoneSpec DSL rather than LLM-as-judge.
- EXTRACTED: The checked-in corpus has 600 tasks: 120 each for calendar, email, spreadsheet/database, CRM/workflow, and file/document operations.
- EXTRACTED: The default split is 100 dev and 500 test tasks.
- EXTRACTED: As of the inspected README status, a DeepSeek tool-plan full run completed 18,000 / 18,000 trials, with optional human calibration still incomplete.
- INFERRED: DoneBench is more mature as a benchmark artifact than many active research-code projects because it has dataset, DSL, reproducibility package, paper scaffold, and audit gates.

## Relationships

- Related to [[personal-knowledge-systems]] as a benchmark for turning vague goals into checkable completion criteria.
- Useful as a reference for agent evaluation discipline across [[analog-agent]] and [[vipin-research-project-map]].

## Open Questions

- Which result rows are final paper-facing rows after the tool-plan executor change?
- How much optional human calibration is needed before submission?
- Which specification-grounding failures should become named error categories in the wiki?

## Related

- [[vipin-research-project-map]]
- [[2026-05-10-research-project-roots]]
