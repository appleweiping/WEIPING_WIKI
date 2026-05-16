---
title: PLEASE IMPLEMENT THIS PLAN -
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - coding-agent-workflow
source_pages:
  - codex-prompt-corpus
---

# PLEASE IMPLEMENT THIS PLAN:

## Metadata

- Stable ID: `codex-user-prompt:3fba5dbbca4ddf63`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-11T16:53:43.263Z`
- Semantic hash: `3fba5dbbca4ddf63375c7f03c3f7e038d6887643736ba734b7581eb669420cf9`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# Modern External Baseline + Harness Closure Plan

## Summary
- Treat this as a harness-engineering upgrade, not a paper novelty claim: encode rules, protocols, reviewer checks, and stopping criteria so future agents cannot drift.
- Implement the first-wave baseline suite as **exactly eight modern external baselines**. Internal `random/greedy/UQ/conformal/classical controls` remain required controls, but they do **not** count toward the eight.
- Do all local work now: protocol schemas, adapter entrypoints, blocker reports, server commands, validation/scoring, tests, docs cleanup, and readiness ledgers. Live API/model/server execution stays explicitly blocked until the user runs it.

## Key Changes
- Add `protocols/baseline/first_wave_external.yaml` with these eight locked IDs:
 `esm3_generate_filter`, `metl_biophysical_plm`, `prospero_active_learning`, `glid2e_policy_finetune`, `dima_latent_diffusion`, `dplm_2_multimodal`, `activation_steering_plm`, `cfpgen_functional_generation`.
- Keep sources grounded in official references: [OpenAI harness engineering](https://openai.com/index/harness-engineering/), [MLHarness](https://arxiv.org/abs/2111.05231), [OpenML benchmark suites](https://docs.openml.org/benchmark/), [ProteinGym](https://pubmed.ncbi.nlm.nih.gov/38106144/), [ESM](https://github.com/evolutionaryscale/esm), [METL](https://github.com/gitter-lab/metl-pretrained), [ProSpero](https://arxiv.org/abs/2505.22494), [GLID2E](https://openreview.net/pdf/8553f9f59ec7fdbd313ad74fdfa2519220d295f5.pdf), [DiMA](https://github.com/MeshchaninovViacheslav/DiMA), [DPLM-2](https://arxiv.org/abs/2410.13782), [Steering PLMs](https://proceedings.mlr.press/v267/huang25ba.html), and [CFP-Gen](https://github.com/yinjunbo/cfpgen).
- Add a strict baseline protocol input exporter: observed set, candidate pool, split manifest, oracle manifest, allowed-feedback manifest, budget, seed, and validity-filter metadata.
- Extend job generation to accept `--baseline-set`; generating first-wave jobs must produce exactly eight external jobs and a separate internal-control bundle.
- Remove the current server placeholder behavior: `server/run_modern_baselines.ps1` must fail clearly when real protocol input is missing unless an explicit smoke flag is passed.
- Harden existing adapter skeletons and add missing adapter directories for `activation_steering_plm` and `cfpgen_functional_generation`. Each adapter must emit either real contract artifacts or a formal blocker report, never fake scientific success.
- Add post-adapter validation/scoring: validate `candidates.csv`, `scores.csv`, `selected_sequences.csv`, `run_manifest.json`, `adapter_manifest.json`, then apply the shared oracle and emit `oracle_scores.csv`, `baseline_metrics.json`, and `validation_report.json`.
- Add observer-ledger adjudication before LoRA/SFT: DeepSeek and Qwen observations only become `accepted` after agreement or explicit quantitative support.
- Add low-N matrix preparation for budgets `16/32/64/128`, with server job generation but local smoke-only execution.
- Update `AGENTS.md`, readiness docs, and checklist language so future complex tasks default to multi-agent planning, final reports include next-step plans, and completion means reviewer-risk closure rather than endless experiments.

## Test Plan
- Add unit tests for the first-wave baseline set, adapter output schema, no-placeholder server behavior, baseline scoring validation, observation adjudication, low-N matrix generation, and harness governance.
- Run targeted tests first:
 `py -3.12 -m unittest protein_bo_conformal.tests.test_observation_and_modern_baselines`
- Then run full suite:
 `cd protein_bo_conformal && py -3.12 -m unittest discover -s tests -p "test_*.py"`
- Acceptance requires: exactly eight external baseline jobs, all eight produce real/blocker artifacts locally, missing server inputs fail, internal controls remain separate, and docs state the project is not writing-ready until live observations/baselines/low-N audits are returned and validated.

## Assumptions
- The eight baseline suite is modern-external only; local controls are still run but not counted.
- No API calls, model downloads, server filesystem assumptions, or live external execution happen locally.
- Official-code adapters prefer blocker reports over unofficial reimplementation when source, weights, license, or hardware are unresolved.
- After implementation succeeds, changes should be staged, committed, and pushed when credentials allow, with separate commits for governance/docs, protocol/adapter work, and tests.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
