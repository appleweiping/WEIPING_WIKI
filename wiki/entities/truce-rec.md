---
title: TRUCE-Rec
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
  - D:/Research/TRUCE-Rec/README.md
---

# TRUCE-Rec

## Summary

`TRUCE-Rec` is a research-grade LLM4Rec codebase for uncertainty-aware generative recommendation. Its current route is observation to CURE/TRUCE framework to official baselines to a four-domain same-candidate recommendation system.

## Key Facts

- EXTRACTED: The local root is `D:/Research/TRUCE-Rec`.
- EXTRACTED: Current stage is Gate R1 server-first four-domain controlled experiment buildout.
- EXTRACTED: No paper-result claim is allowed until full official baseline/Ours runs are imported and evaluated by TRUCE.
- EXTRACTED: Phase 6 OursMethod is `Calibrated Uncertainty-Guided Generative Recommendation`.
- EXTRACTED: The project distinguishes smoke/mock, pilot, diagnostic, controlled adapter pilot, official-native controlled baseline, and paper result.
- EXTRACTED: Current four-domain same-candidate artifact slugs include Beauty, Books, Electronics, and Movies lanes with one positive plus 100 negatives.
- INFERRED: Compared with [[uncertainty]], TRUCE-Rec is a broader uncertainty-aware generative recommendation system with stricter evidence labels and server-first four-domain buildout.

## Relationships

- Related to [[uncertainty]] through calibrated uncertainty and same-candidate evaluation.
- Related to [[tgl-rec]] through shared Qwen3-8B / LoRA / same-candidate protocol concerns.

## Open Questions

- Which controlled adapter pilots will become official-native controlled baselines?
- What is the minimum evidence required to promote Ours/TRUCE from protocol-ready to paper-result?
- How should TRUCE-Rec avoid duplicating or blurring the C-CRP story in [[uncertainty]]?

## Related

- [[vipin-research-project-map]]
- [[llm-based-recommendation]]
- [[2026-05-10-research-project-roots]]
