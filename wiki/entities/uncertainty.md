---
title: Uncertainty
type: entity
status: active
created: 2026-05-10
updated: 2026-05-17
tags:
  - entity
  - project
  - llm-recommendation
  - uncertainty
  - pony-rec
source_pages:
  - 2026-05-10-research-project-roots
  - 2026-05-17-research-project-roots-deep-review
  - 2026-05-17-research-project-workbench-audit
source_files:
  - D:/Research/Uncertainty/AGENTS.md
  - D:/Research/Uncertainty/README.md
  - D:/Research/Uncertainty/docs/milestones/README.md
  - D:/Research/Uncertainty/docs/paper_claims_and_status.md
  - D:/Research/Uncertainty/docs/top_conference_review_gate.md
  - D:/Research/Uncertainty/docs/server_runbook.md
  - D:/Research/Uncertainty/docs/baseline_protocol.md
  - D:/Research/Uncertainty/OFFICIAL_EXTERNAL_BASELINE_UPGRADE_PLAN_2026-05-07.md
  - D:/Research/Uncertainty/configs/official_external_baselines.yaml
  - D:/Research/Uncertainty/PROJECT_LINEAGE_AND_FILE_INDEX_2026-05-06.md
---

# Uncertainty

## Summary

`Uncertainty`, also routed as Pony-Rec, is Vipin's main task-grounded calibrated uncertainty project for LLM-based recommendation. Its current defended claim is narrow: calibrated, task-grounded uncertainty improves controlled candidate ranking/reranking reliability under same-schema evaluation.

## Current Contribution

- EXTRACTED: The project spine is observation -> Pony framework -> Light boundary tests -> Shadow task-grounded uncertainty -> same-candidate baseline system -> small-domain to four-domain 100-negative validation -> complete recommender-system roadmap.
- EXTRACTED: The formal defended claim is not full-catalog recommender SOTA, not generative-title recommendation, and not a LoRA distillation claim.
- EXTRACTED: C-CRP is the main task-grounded uncertainty method only after validation-only selection, exact score export, same-schema import, score audit, and paired tests.
- EXTRACTED: SRPD is a trainable framework/ablation line with stricter leakage, teacher-data, weighted-loss, and score-export requirements.
- INFERRED: Pony/Uncertainty is the canonical evidence source for the official same-candidate Qwen3-base baseline suite reused by [[truce-rec]] and [[tgl-rec]].

## Current Status And Gates

- EXTRACTED: Canonical docs place the project between M4 baseline system and M5 four-domain same-candidate validation.
- EXTRACTED: The official external baseline contract requires pinned official or official-code-level implementations, Qwen3-8B declared adaptation, official/default hyperparameters, exact candidate score export, and import through `main_import_same_candidate_baseline_scores.py`.
- EXTRACTED: Completed official baseline families in current downstream manifests include `llm2rec`, `llmesr`, `llmemb`, `rlmrec`, `irllrec`, `elmrec`, and `proex`.
- AMBIGUOUS: The live root contains ProMax evidence tarballs and an untracked `week8_official_external_qwen3base_multik_comparison.md`; downstream TGL memory still treats `promax` as pending until all declared-domain exact-score gates and canonical manifests are updated.
- EXTRACTED: SETRec is blocked/replaced unless a future memory-stable official run passes all gates.

Do not promote any row to paper-facing status from filename alone. Use the conservative order: blocked > partial > style/scaffold > official completed.

## Canonical Startup Packet

Read before nontrivial work:

1. `README.md`
2. `docs/milestones/README.md`
3. `docs/paper_claims_and_status.md`
4. `docs/top_conference_review_gate.md`
5. `docs/server_runbook.md`

For baseline or experiment work, also read:

- `docs/baseline_protocol.md`
- `OFFICIAL_EXTERNAL_BASELINE_UPGRADE_PLAN_2026-05-07.md`
- `configs/official_external_baselines.yaml`
- `PROJECT_LINEAGE_AND_FILE_INDEX_2026-05-06.md`
- `.codex/skills/uncertainty-rec-research/SKILL.md`

## Module Map

| Area | Role |
| --- | --- |
| `src/uncertainty`, `src/shadow`, `src/methods`, `src/training` | C-CRP, Shadow, SRPD, uncertainty and training logic. |
| `src/baselines/official_runner`, root `main_train_score_*_upstream_adapter.py`, root `main_run_*_official_same_candidate_adapter.py` | Official baseline adaptation and score export. |
| `src/eval`, `main_import_same_candidate_baseline_scores.py`, comparison/stat-test scripts | Same-candidate import, metrics, comparison, and paired tests. |
| `configs/official_external_baselines.yaml`, `configs/srpd/`, `configs/lora/`, `configs/week8_*` | Experiment and evidence contracts. |
| `docs/milestones/`, `docs/server_runbook.md`, `docs/top_conference_review_gate.md` | Canonical claim, server, and reviewer routing. |
| `outputs/`, root `*_official_qwen3base*_evidence_*.tar.gz` | Evidence artifacts. Inventory only from the wiki. |

## File Inventory Baseline

2026-05-17 live scan:

| Measure | Count / summary |
| --- | --- |
| `git ls-files` | 1,062 tracked paths |
| `rg --files` | 1,063 visible searchable paths |
| tracked text-like paths | 585 |
| tracked non-text/artifact marker paths | 477, mostly `.gitkeep` markers under artifact directories |
| category counts | artifact-pointer 452; config 237; source 236; doc 64; test 27; paper 24; script 19; other 3 |
| largest local artifacts | Amazon raw JSONL/GZ files up to about 21.6 GB, MovieLens processed JSONL up to about 4.8 GB, official evidence tarballs up to about 397 MB |

## File Area Rules

- Safe to edit when working inside this project: source, configs, tests, canonical docs, and scripts directly tied to the requested change.
- Caution: root legacy markdown and Week8 handoffs are historical unless current docs route to them.
- Inventory only: `data/raw/`, large `data/processed/`, `outputs/`, `tmp_outputs/`, `outputs_backup_old/`, evidence tarballs, logs, and generated score/prediction artifacts.
- Do not copy into public wiki: raw datasets, raw logs, model weights/checkpoints, server credentials, `.env`, or full evidence archive contents.

## Current Git Reminder

2026-05-17 status:

```text
## main...origin/main
?? week8_official_external_qwen3base_multik_comparison.md
```

Do not stage or commit the untracked comparison file unless the user explicitly asks to work in Pony/Uncertainty and the file is audited.

## Future Agent Entry

Common commands from project docs:

```bash
git status --short --branch
python main_project_readiness_check.py
python main_audit_official_fairness_policy.py
python main_audit_official_external_repos.py
python main_import_same_candidate_baseline_scores.py --help
```

For storage-heavy official baselines, use a one method-domain production loop: run, verify unblocked provenance and exact score coverage, import metrics, package a light evidence artifact, confirm local copy, then clean only documented intermediates.

## Difference From Sibling Projects

- [[truce-rec]] uses Pony official evidence as a baseline source but contributes a CURE/TRUCE uncertainty-aware generative recommendation framework.
- [[tgl-rec]] uses Pony official evidence as a baseline source but contributes temporal graph-to-language evidence and need-transition modeling.
- Pony/Uncertainty owns the official external baseline evidence lane and the C-CRP/task-grounded uncertainty claim.

## Counterpoints and Gaps

- Live evidence files can be newer than docs. Do not infer paper status from tarball presence.
- This wiki pass did not inspect raw dataset contents or generated logs line by line.
- The exact current ProMax status should be resolved inside Pony's canonical baseline docs/manifests before downstream projects treat it as completed.

## Related

- [[research-project-workbench]]
- [[2026-05-17-research-project-roots-deep-review]]
- [[2026-05-17-research-project-workbench-audit]]
- [[truce-rec]]
- [[tgl-rec]]
- [[llm-based-recommendation]]
