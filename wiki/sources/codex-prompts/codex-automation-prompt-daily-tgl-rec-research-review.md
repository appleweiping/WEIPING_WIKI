---
title: Repository -
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

# Repository:

## Metadata

- Stable ID: `codex-automation-prompt:daily-tgl-rec-research-review`
- Source kind: `codex-automation`
- Category: `research-workflow`
- Timestamp: `2026-04-30T01:07:24.317890+00:00`
- Semantic hash: `20b6cb084cc8dbbebe950b4efd21afd0d4f54fc800431c458c6a5584f66ff91f`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Repository:
https://github.com/appleweiping/TGL-Rec.git

Read AGENTS.md, PROJECT_CHARTER.md, ROADMAP.md, TASKS.md, EXPERIMENTS.md, BASELINES.md, PAPER_OUTLINE.md if present, CODEX_PROMPTS.md, recent git diff/logs, reports/, and recent runs/ summaries if present.

Use reviewer and repro_auditor. Do not edit implementation files unless explicitly asked.

Important communication rule:
Repository-facing comments may be in English, but the final user-facing review summary should be written in Chinese.

Goal:
Perform a strict daily top-tier conference readiness review of the TGL-Rec project.

Review focus:
1. Is the project still aligned with the central thesis:
 LLM/sequential recommenders may rely more on item similarity/popularity than true temporal next-need transitions?
2. Are diagnostics strong enough to support the paper observation?
3. Are temporal splits and graph construction free of future leakage?
4. Are metrics correct and consistently applied?
5. Are baselines fair, strong, and using the same split/candidate protocol?
6. Are claims stronger than current evidence?
7. Is the work moving beyond toy/MVP stage toward real datasets and publishable experiments?
8. Are ablations sufficient to isolate:
 - time,
 - graph,
 - language evidence,
 - gate,
 - retrieval,
 - dynamic/inductive update if used?
9. Are run artifacts reproducible?
10. Are there missing tests that could hide serious bugs?

Output format in Chinese:
1. Blocking issues.
2. Major risks.
3. Leakage/reproducibility concerns.
4. Missing experiments or tests.
5. Recommended next tasks for research_worker.
6. Verdict:
 - on track,
 - needs correction,
 - blocked,
 - or not yet publishable.


Write the review to:
- reports/reviews/YYYY-MM-DD.md
- reports/reviews/latest.md

The review should be in Chinese and include:
1. Blocking issues.
2. Major risks.
3. Leakage/reproducibility concerns.
4. Missing experiments or tests.
5. Recommended next tasks for research_worker.
6. Verdict: on track / needs correction / blocked / not yet publishable.
Constraints:

- Do not edit implementation files unless explicitly asked.This is a review-only automation. Do not edit implementation code, configs, datasets, experiment outputs, or task implementation files. You may create or update Markdown review reports under reports/reviews/.
- Be strict.
- Do not praise vague progress.
- Do not ask the user trivial questions.
- Do not make code changes.
- Only request user intervention for GPU/server/API key/licensed dataset/destructive git operation.
- If there is nothing serious to report, still provide a short status and the next highest-value task.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
