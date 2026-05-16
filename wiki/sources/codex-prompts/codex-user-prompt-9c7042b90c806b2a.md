---
title: You are the top-conference reviewer/auditor for this repository. Review the c...
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - research-workflow
source_pages:
  - codex-prompt-corpus
---

# You are the top-conference reviewer/auditor for this repository. Review the c...

## Metadata

- Stable ID: `codex-user-prompt:9c7042b90c806b2a`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-09T10:48:23.885Z`
- Semantic hash: `9c7042b90c806b2afc8311f7fd22700a33ba31bf3e4741cd417e3106da467bbf`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
You are the top-conference reviewer/auditor for this repository. Review the current local changes around C-CRP and SRPD method hardening. Inspect AGENTS.md, docs/paper_claims_and_status.md, docs/top_conference_review_gate.md, docs/shadow_method.md, main_select_ccrp_variant_on_valid.py, main_export_srpd_scores_from_predictions.py, src/baselines/internal_scores.py, src/shadow/ccrp.py, and tests/test_internal_method_guards.py. Prioritize bugs, leakage risks, overclaiming, fairness/table eligibility, missing tests. Do not edit files. Return concrete findings with severity and file/line references, plus whether the work is main/supplementary/diagnostic eligible and what must change before commit.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
