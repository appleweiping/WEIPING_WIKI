---
title: 2026-05-17 Research Project Roots Deep Review
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - research
  - project-roots
  - llm-recommendation
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
  - D:/Research/TRUCE-Rec/AGENTS.md
  - D:/Research/TRUCE-Rec/README.md
  - D:/Research/TRUCE-Rec/docs/PROJECT_MEMORY.md
  - D:/Research/TRUCE-Rec/docs/RESEARCH_IDEA.md
  - D:/Research/TRUCE-Rec/docs/submission_roadmap.md
  - D:/Research/TRUCE-Rec/docs/top_conference_review_plan.md
  - D:/Research/TRUCE-Rec/docs/qwen3_lora_controlled_baselines.md
  - D:/Research/TRUCE-Rec/docs/server_execution_matrix.md
  - D:/Research/TRUCE-Rec/docs/server_next_commands.md
  - D:/Research/TGL-Rec/AGENTS.md
  - D:/Research/TGL-Rec/README.md
  - D:/Research/TGL-Rec/docs/codex_project_memory.md
  - D:/Research/TGL-Rec/docs/phase10_master_plan.md
  - D:/Research/TGL-Rec/docs/server_runbook.md
  - D:/Research/TGL-Rec/docs/codex_handoff_phase9e.md
---

# 2026-05-17 Research Project Roots Deep Review

## Provenance

Origin: local read-only review requested by the user on 2026-05-17.

Roots inspected:

- `D:/Research/Uncertainty`
- `D:/Research/TRUCE-Rec`
- `D:/Research/TGL-Rec`

Commands used included:

```powershell
git status --short --branch
git remote -v
git ls-files
rg --files
Get-ChildItem -Recurse -File
```

No files in the three project repositories were modified.

## Coverage Strategy

- EXTRACTED: All git-tracked paths were classified by category: source, config, test, doc, script, prompt, paper, artifact pointer, or other metadata.
- EXTRACTED: Large raw data, generated outputs, logs, `.tar.gz`, `.tgz`, and model/checkpoint-like artifacts were inventoried by path pattern and size rather than copied or read line by line.
- EXTRACTED: Public wiki pages record source paths, summaries, and safety boundaries only. They do not mirror raw data, logs, private `.env` contents, model weights, or evidence archive contents.

## Git And Remote State

| Project | Branch/status | Remote |
| --- | --- | --- |
| [[uncertainty]] | `main...origin/main`; untracked `week8_official_external_qwen3base_multik_comparison.md` | `https://github.com/appleweiping/Pony-Rec.git` |
| [[truce-rec]] | `main...origin/main`; untracked `log/`, `log_tensorboard/` | `https://github.com/appleweiping/TRUCE-Rec.git` |
| [[tgl-rec]] | `codex/phase9e-lora-rerank-eval...origin/codex/phase9e-lora-rerank-eval`; clean | `https://github.com/appleweiping/TGL-Rec.git` |

## File Inventory Summary

| Project | Tracked paths | `rg --files` | Text-like tracked | Main category distribution |
| --- | ---: | ---: | ---: | --- |
| [[uncertainty]] | 1,062 | 1,063 | 585 | artifact-pointer 452; config 237; source 236; doc 64; test 27; paper 24; script 19 |
| [[truce-rec]] | 617 | 622 | 612 | source 151; config 143; test 120; doc 100; script 75; artifact-pointer 19; prompt 7 |
| [[tgl-rec]] | 588 | 575 | 586 | source 203; test 149; config 106; doc 60; script 58; prompt 6; artifact-pointer 4 |

## Artifact Inventory Summary

| Project | Largest artifact patterns | Public wiki treatment |
| --- | --- | --- |
| [[uncertainty]] | Amazon raw JSONL/GZ files up to about 21.6 GB; processed MovieLens JSONL up to about 4.8 GB; official evidence tarballs up to about 397 MB | Record path patterns, sizes, and status only. Do not copy raw data or evidence archive contents. |
| [[truce-rec]] | Amazon Video Games raw JSONL about 2.6 GB; observation inputs and examples up to about 790 MB; Pony evidence tarballs up to about 379 MB; controlled-baseline score plans about 253-255 MB | Record manifest/evidence status only. Do not copy `.env`, logs, raw outputs, or evidence package contents. |
| [[tgl-rec]] | `TGL-Rec-phase9e-lora-results.tgz` about 2.8 GB; raw Video Games JSONL about 2.6 GB; predictions JSONL about 1.4-1.7 GB each | Record as generated/protocol artifacts. Do not copy full predictions, PDFs, archives, model artifacts, or private configs. |

## Extracted Project Baselines

### Uncertainty / Pony-Rec

- EXTRACTED: Defended claim is task-grounded calibrated uncertainty improving controlled candidate ranking/reranking reliability under same-schema evaluation.
- EXTRACTED: Canonical first-read docs are `README.md`, `docs/milestones/README.md`, `docs/paper_claims_and_status.md`, `docs/top_conference_review_gate.md`, and `docs/server_runbook.md`.
- EXTRACTED: Official baselines require pinned official or official-code-level implementations, Qwen3-8B declared adaptation, exact same-candidate score export, and importer gates.

### TRUCE-Rec

- EXTRACTED: Strategic spine is generative recommendation observation -> CURE/TRUCE framework -> Qwen3-8B-LoRA Ours adapter and ablations -> official baseline families -> shared same-candidate evaluator -> four-domain experiments.
- EXTRACTED: Current paper-facing external baseline route is Pony official evidence import, not legacy controlled-adapter reruns.
- EXTRACTED: Evidence labels distinguish smoke/mock, diagnostic, controlled adapter pilot, official native controlled, and paper result.

### TGL-Rec

- EXTRACTED: Active direction is Phase 10: observation to original framework to full recommender system.
- EXTRACTED: Active framework is `src/llm4rec`; `src/tglrec` is legacy/compatibility tooling unless explicitly targeted.
- EXTRACTED: Active baseline plan reuses Pony official baselines, with `promax` pending and `setrec` blocked/replaced in current TGL memory.

## Collaboration Rule Interpretation

- INFERRED: Vipin wiki and project-local `AGENTS.md` files are compatible if treated as layers.
- INFERRED: Vipin wiki owns durable routing and partner-language memory; target projects own local edit, claim, baseline, server, and evidence rules.
- INFERRED: Opus, Sonnet, DeepSeek/Whale, and Codex parallel selves can be used as read-only or bounded collaborators when the environment permits, but Codex remains responsible for integration, verification, commits, and pushes in Vipin wiki.

## Counterpoints and Gaps

- This source note is a public-safe metadata record, not a complete raw-file mirror.
- Some live artifacts, especially untracked summaries or fresh tarballs, may be newer than canonical docs. Future agents should resolve such drift inside the target repo before changing paper-facing status.
- The review did not run project tests or validate scientific metrics; it created a wiki workbench and routing memory.

## Links

- [[research-project-workbench]]
- [[2026-05-17-research-project-workbench-audit]]
- [[uncertainty]]
- [[truce-rec]]
- [[tgl-rec]]
