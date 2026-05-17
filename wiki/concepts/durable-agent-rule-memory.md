---
title: Durable Agent Rule Memory
type: concept
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - wiki-workflow
  - agent-memory
  - operating-rules
source_pages:
  - AGENTS.md
---

# Durable Agent Rule Memory

## Rule

When the user says future agents should remember a reusable rule, the agent must persist it into the durable operating layer instead of relying on chat history.

## Required Workflow

1. Decide whether the instruction is reusable, operational, and safe to preserve.
2. Update `AGENTS.md` when the rule affects future agent behavior.
3. Update or create the relevant wiki concept/workflow page for maintained context.
4. Update `wiki/index.md` when a new public rule page is created.
5. Append `wiki/log.md` with the rule change and source.
6. Regenerate `wiki/catalog.json` when wiki content changes.
7. Run relevant validation, stage scoped files, commit, and push.

## Placement Guidance

- Use `AGENTS.md` for mandatory future-agent behavior.
- Use a concept/workflow page for explanation, examples, caveats, and related links.
- Use a source page when the rule came from a significant external source or installed skill.
- Prefer updating an existing page when the rule clearly belongs to an established workflow.

## Anti-Pattern

Do not answer "noted" or "I will remember" without writing the rule into a durable file when the user explicitly asks future agents to remember it.

## Counterpoints And Gaps

- AMBIGUOUS: Not every preference belongs in `AGENTS.md`; small stylistic preferences may be better captured in an existing workflow page or not preserved if they are not reusable.
- INFERRED: The durable layer should avoid overfitting to one-off frustration. Preserve rules that improve future execution, safety, validation, or user preference alignment.

## Related Pages

- [[agent-skill-installation-workflow]]
- [[readme-maintenance-workflow]]
