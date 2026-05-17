---
title: Analog Agent
type: entity
status: active
created: 2026-05-10
updated: 2026-05-17
tags:
  - entity
  - project
  - ai4eda
  - analog-design
  - project-workbench
source_pages:
  - 2026-05-10-research-project-roots
  - 2026-05-17-research-project-roots-deep-review
  - 2026-05-17-research-project-workbench-audit
source_files:
  - D:/Research/Agent-AI4EDA/analog-agent/AGENTS.md
  - D:/Research/Agent-AI4EDA/analog-agent/README.md
  - D:/Research/Agent-AI4EDA/analog-agent/docs/configured_truth_user_action_boundary.md
  - D:/Research/Agent-AI4EDA/analog-agent/docs/repo-map.md
  - D:/Research/Agent-AI4EDA/analog-agent/docs/related_work_map.md
  - D:/Research/Agent-AI4EDA/analog-agent/docs/stop_conditions.md
  - D:/Research/Agent-AI4EDA/analog-agent/configs/default.yaml
  - D:/Research/Agent-AI4EDA/analog-agent/configs/benchmarks/multi_task_suite_v1.yaml
  - D:/Research/Agent-AI4EDA/analog-agent/configs/simulator/ngspice.yaml
---

# Analog Agent

## Summary

`analog-agent` is Vipin's AI4EDA layered analog circuit design harness. It treats natural-language specification understanding, strict task compilation, world-model support, planning/search, simulator-backed verification, and memory/reflection as separate system roles rather than a single generative loop.

## Current Contribution

- EXTRACTED: The intended paper-facing claim is a layered analog-agent system grounded in real SPICE verification, with a world-model-guided and planner-mediated loop rather than a one-shot generator.
- EXTRACTED: The safe default claim boundary is a calibrated, surrogate-guided analog sizing loop under explicit SPICE truth boundaries.
- EXTRACTED: The six-layer spine is specification understanding, task formalization, world-model services, planning/optimization, simulation/verification, and memory/reflection.
- EXTRACTED: Frozen runnable vertical slices include `ota2_v1`, `folded_cascode_v1`, `ldo_v1`, and `bandgap_v1`, with `ota2_v1` retained as the primary submission-facing path.
- EXTRACTED: The default comparison stack includes `full_simulation_baseline`, `random_search_baseline`, `bayesopt_baseline`, `cmaes_baseline`, `rl_baseline`, `no_world_model_baseline`, and `full_system`.
- INFERRED: Compared with the LLM4Rec projects, analog-agent shares closed-loop decision and uncertainty discipline but has a physical SPICE/configured-truth evidence gate instead of a same-candidate ranking gate.

## Current Status And Gates

- EXTRACTED: The project is no longer only a front-end scaffold; the first six system layers are present in formal schema-and-service form with API routes, tests, vertical slices, and submission-package utilities.
- EXTRACTED: The README reports the local-only `archive/research/papers/submission_package/` demonstrator-truth package as `external_submission_ready = true` for the frozen `ngspice` path; treat this as target-project status, not as wiki-validated configured-truth or signoff readiness.
- EXTRACTED: Stronger configured-truth / external-PDK / Spectre-oriented claims remain separate upgrades, not current default paper claims.
- EXTRACTED: The repository intentionally does not create or download user-managed PDK roots, external model cards, Docker exposure, or local mount paths automatically.
- EXTRACTED: If the repo reports `demonstrator_only`, `configured_truth_not_ready`, or `configured_truth_candidate_ready`, stronger configured-truth claims must remain withheld until assets are present and validated.

## Canonical Startup Packet

Read before nontrivial work:

1. `README.md`
2. `docs/configured_truth_user_action_boundary.md`
3. `docs/repo-map.md`
4. `docs/related_work_map.md`
5. `docs/stop_conditions.md`
6. `configs/default.yaml`
7. `configs/benchmarks/multi_task_suite_v1.yaml`
8. `configs/simulator/ngspice.yaml`
9. `scripts/run_system_closure_report.py`

For closeout or paper-readiness decisions, also run or inspect:

- `scripts/review_harness_closeout.py`
- `scripts/check_configured_truth_readiness.py`
- `scripts/check_open_pdk_ready.py`
- `scripts/check_native_artifact_rerunability.py`
- `scripts/check_container_runtime.py`

## Module Map

| Area | Role |
| --- | --- |
| `apps/api_server/` | FastAPI routes for interaction, tasking, world modeling, planning, simulation, memory, experiments, and acceptance checks. |
| `apps/orchestrator/` | Cross-layer job and truth-loop orchestration. |
| `apps/worker_llm/`, `apps/worker_simulator/`, `apps/worker_world_model/`, `apps/worker_memory/` | Thin worker-facing adapters; shared behavior should stay in `libs/`. |
| `libs/schema/` | Typed contracts for specs, tasks, actions, world models, planning, simulation, memory, benchmark evidence, and submission packages. |
| `libs/interaction/`, `libs/tasking/`, `libs/world_model/`, `libs/planner/`, `libs/simulation/`, `libs/memory/` | Core six-layer implementation spine. |
| `libs/eval/`, `libs/vertical_slices/` | Benchmark runners, statistics, baselines, evidence packaging, and frozen OTA/folded-cascode/LDO/bandgap slices. |
| `configs/` | Benchmarks, simulator truth boundary, PDK, LLM roles, world-model settings, and runtime defaults. |
| `templates/` | Frozen netlist/testbench/measurement contracts for canonical verification paths. |
| `scripts/` | Test suite, benchmark, evidence generation, export, readiness, closeout, and review-gate commands. |
| `archive/`, `.artifacts/` | Ignored local outputs and transient simulator/cache artifacts. Inventory only from the wiki. |

## File Inventory Baseline

2026-05-17 live scan:

| Measure | Count / summary |
| --- | --- |
| `git ls-files` | 376 tracked paths |
| `rg --files` | 358 visible searchable paths |
| tracked text-like paths | 359 |
| tracked non-text/artifact marker paths | 17, mostly `.gitkeep` placeholders |
| category counts | source 184; test 82; script 58; config 33; doc 7; template 4; infra 4; other 4 |
| largest local artifacts | ignored `archive/legacy/...` and `.artifacts/simulation/.../tran.json` files around 0.2 MB each; no giant raw/model artifact was visible in this scan |

## File Area Rules

- Safe to edit when working inside analog-agent: `libs/`, thin `apps/` wrappers, configs, templates, tests, scripts, and canonical docs for the requested subsystem.
- Caution: paper/export helpers and closeout scripts affect claim wording and reportability; inspect the relevant review tests before changing them.
- Inventory only: `archive/`, `.artifacts/`, local `.venv`, local PDK/model-card paths, simulator logs, and generated benchmark/submission outputs.
- Do not copy into public wiki: raw simulator logs, private paper drafts, local PDK/model-card contents, `.env`, generated archive outputs, or any proprietary/process-sensitive model data.

## Current Git Reminder

2026-05-17 status:

```text
## main...origin/main
```

Remote:

```text
https://github.com/appleweiping/analog-agent.git
```

The worktree was clean during this wiki audit.

## Future Agent Entry

Recommended local commands from current docs:

```powershell
py -3.12 scripts\run_test_suite.py
.\scripts\run_test_suite.ps1 -UseVenv -RequireApiDeps
py -3.12 scripts\review_harness_closeout.py
py -3.12 scripts\check_configured_truth_readiness.py
py -3.12 scripts\run_system_closure_report.py
```

Acceptance and benchmark entrypoints:

```powershell
py -3.12 scripts\run_ota_acceptance.py
py -3.12 scripts\run_folded_cascode_acceptance.py
py -3.12 scripts\run_ldo_acceptance.py
py -3.12 scripts\run_bandgap_acceptance.py
py -3.12 scripts\run_benchmark.py
```

## Difference From Sibling Projects

- [[uncertainty]], [[truce-rec]], and [[tgl-rec]] are LLM4Rec projects governed by same-candidate evaluation and baseline gates.
- `analog-agent` is an AI4EDA/SPICE harness governed by physical-validity and configured-truth gates.
- It is related to [[protein-optimization-feedback-shift]] through closed-loop uncertainty-aware optimization, but its evidence is simulator-backed analog circuit closure rather than biological sequence feedback.

## Counterpoints and Gaps

- The public repository intentionally abstracts some research-sensitive backend details; do not infer missing internals from README absence alone.
- Demonstrator-truth `external_submission_ready = true` is not the same as configured-truth, external-PDK, Spectre, signoff, layout, PEX, or yield readiness.
- This wiki pass did not run the test suite or inspect generated archive outputs; it preserved metadata-level routing and artifact boundaries.

## Related

- [[research-project-workbench]]
- [[2026-05-17-research-project-roots-deep-review]]
- [[2026-05-17-research-project-workbench-audit]]
- [[vipin-research-project-map]]
