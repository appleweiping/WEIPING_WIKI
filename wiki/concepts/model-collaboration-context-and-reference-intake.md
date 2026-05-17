---
title: Model Collaboration Context And Reference Intake
type: concept
status: active
created: 2026-05-18
updated: 2026-05-18
tags:
  - agent-workflow
  - collaboration
  - research
  - reference-intake
source_pages:
  - AGENTS.md
  - 2026-05-18-user-rule-update-chat
---

# Model Collaboration Context And Reference Intake

## Rule

When Codex delegates work to another model or searches external sources, the input must be rich enough to let that model or source act with real understanding. No fake delegation, no skim-only toy version.

## Partner Delegation Context

- EXTRACTED: If a user explicitly asks for Opus, Sonnet, or DeepSeek / `鲸鱼`, Codex should treat that as an actual delegation request rather than a prompt to search for a local binary or answer entirely inside Codex.
- EXTRACTED: Complex software or project work should be given to the partner with the full relevant conversation context, not a thin sentence fragment.
- EXTRACTED: The partner prompt should clearly say what is happening, what has already been checked, what files or artifacts matter, and what output format is expected.
- EXTRACTED: Codex should not imply that a partner saw context it did not actually receive.
- EXTRACTED: If the partner is unavailable or the context is insufficient, Codex should state that plainly instead of pretending the delegation happened.

## External Reference Intake

- EXTRACTED: When searching the web for software, project, or workflow references, the default should be to read the whole relevant file, repo section, or documentation set that is being used as evidence.
- EXTRACTED: Do not reduce a substantial external reference into a toy summary unless the user explicitly wants a lightweight sketch.
- EXTRACTED: For project/software tasks, use external references to understand the full pattern before adapting only the parts that fit this repository.
- EXTRACTED: For research ideation, broad external reading is required, but the result must still be original and not a collage of copied parts.
- INFERRED: If a source is large, "read the whole thing" can mean the whole relevant file set or the complete relevant section, not necessarily every file in a huge repository tree.

## Practical Guidance

- Give partner models the minimum context needed to be accurate, but not so little that they have to guess the situation.
- When delegating, include the current goal, the decision already made, the boundary of the task, and the exact result you want back.
- When researching references, prefer primary or canonical material and read deeply enough to understand the operating pattern, constraints, and failure modes.
- If a task is inherently a creative or research synthesis problem, use external sources as evidence and inspiration, not as a template to paste together.

## Counterpoints And Gaps

- AMBIGUOUS: "Read the whole thing" is a judgment call for very large repositories or documentation trees.
- INFERRED: Some quick confirmation tasks legitimately only need a small excerpt, but that should be the exception and should be stated as such.
- INFERRED: The bigger risk for this workspace is under-reading and under-contexting, not over-reading.

## Related Pages

- [[agent-collaboration-tone-and-model-roles]]
- [[local-cc-sidecar-agent-workflow]]
- [[research-ideation-policy]]
- [[agent-skill-installation-workflow]]
