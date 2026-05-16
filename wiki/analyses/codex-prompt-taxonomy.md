---
title: Codex Prompt Taxonomy
type: analysis
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - analysis
  - codex-prompts
source_pages:
  - codex-prompt-corpus
---

# Codex Prompt Taxonomy

## Category Map

| Category | Count | What It Captures |
| --- | ---: | --- |
| automation | 14 | Long-running scheduled tasks, commit rules, validation gates, and scoped update behavior. |
| coding-agent-workflow | 108 | Repository implementation tasks, testing, Git hygiene, and agent execution constraints. |
| general-high-quality-prompt | 6 | Selected prompts that pass quality filters but do not fit a narrower bucket. |
| personal-rules | 1 | User preferences and durable operating rules future agents should remember. |
| prompt-engineering-pattern | 8 | Reusable prompt structures, role design, and instruction scaffolds. |
| research-workflow | 173 | Research direction, experiments, baselines, reviewer gates, and non-toy project standards. |
| wiki-ingest | 43 | Source capture, manifest design, stable IDs, semantic hashes, and wiki maintenance rules. |

## Reusable Patterns

- EXTRACTED: Strong prompts usually define role, source boundaries, filtering rules, validation commands, commit policy, and explicit non-goals.
- EXTRACTED: Automation prompts should specify scoped staging paths and no-noisy-commit behavior.
- INFERRED: The highest-value prompts are those that encode judgment, acceptance criteria, and future-agent memory rather than one-off commands.

## Noise Boundaries

- Do not preserve short chat fragments, copied code blobs, traceback/log dumps, garbled text, secrets, or private material as public prompt pages.
- Keep rejected candidate metadata in raw manifest/inbox for audit without creating public full-text pages.

## Sources

- EXTRACTED: Counts and categories come from `raw/codex-prompts-public/manifest.json`.
- EXTRACTED: The selected prompt pages link back to [[codex-prompt-corpus]].

## Counterpoints and Gaps

- AMBIGUOUS: Prompt quality is partly judgment-based; future runs should prefer false negatives over public exposure of noisy or sensitive prompts.
- INFERRED: This taxonomy should stay compact even as the underlying prompt pages grow.

## Related

- [[codex-prompt-corpus]]
