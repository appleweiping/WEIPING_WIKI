---
title: 2026-05-17 Research Project Workbench Audit
type: analysis
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - analysis
  - research
  - project-workbench
  - llm-recommendation
source_pages:
  - 2026-05-17-research-project-roots-deep-review
---

# 2026-05-17 Research Project Workbench Audit

## Question

How should Vipin wiki remember `D:/Research/Uncertainty`, `D:/Research/TRUCE-Rec`, and `D:/Research/TGL-Rec` so future agents can route work smoothly without weakening project-local evidence rules?

## Short Answer

Use Vipin wiki as an upper-level workbench and keep each project repo authoritative for its own claim, server, baseline, and edit rules. The three projects form a shared same-candidate LLM4Rec research cluster, but their contributions are distinct:

- [[uncertainty]]: C-CRP/task-grounded calibrated uncertainty and official baseline evidence.
- [[truce-rec]]: CURE/TRUCE uncertainty-aware generative recommendation and catalog-grounding/fallback policy.
- [[tgl-rec]]: temporal graph-to-language evidence and need-transition modeling.

## Coverage

This audit classified every git-tracked path in the three repos by file role, then inventoried large raw/generated artifacts by metadata only.

| Project | Tracked paths | Text-like tracked | Primary readable surface | Inventory-only surface |
| --- | ---: | ---: | --- | --- |
| [[uncertainty]] | 1,062 | 585 | `AGENTS.md`, `README.md`, `docs/`, `configs/`, `src/`, `scripts/`, `tests/`, `prompts/`, `Paper/` | `data/raw/`, large `data/processed/`, `outputs/`, evidence tarballs |
| [[truce-rec]] | 617 | 612 | `AGENTS.md`, `README.md`, `docs/`, `configs/`, `src/`, `scripts/`, `tests/`, `.codex/skills/` | `data/raw/`, large `outputs/`, `log/`, `log_tensorboard/`, evidence packages |
| [[tgl-rec]] | 588 | 586 | `AGENTS.md`, `README.md`, `docs/`, `configs/`, `src/llm4rec`, `scripts/`, `tests/`, `.codex/skills/` | `outputs/`, `artifacts/`, `runs/`, root `*.tgz`, raw data, PDFs/zips |

## Project Scale And Shape

### Uncertainty / Pony-Rec

- Tracked shape: artifact-pointer 452; config 237; source 236; docs 64; tests 27; paper 24; scripts 19.
- Core modules: `src/uncertainty`, `src/shadow`, `src/methods`, `src/training`, `src/baselines/official_runner`, `src/eval`.
- Current claim gate: do not expand beyond controlled same-schema candidate ranking/reranking reliability unless separate protocols complete.
- Main risk: live evidence tarballs and untracked summaries may tempt overclaiming before canonical manifests/docs agree.

### TRUCE-Rec

- Tracked shape: source 151; config 143; tests 120; docs 100; scripts 75; artifact-pointer 19.
- Core modules: active `src/llm4rec`; older `src/storyflow` still exists and should be inspected before changes.
- Current claim gate: Pony official baseline reuse is paper-facing only through manifest, evidence package, and exact gate status; TRUCE controlled adapters remain diagnostic unless reopened.
- Main risk: treating Ours v2 or legacy controlled-adapter pilots as finished paper results.

### TGL-Rec

- Tracked shape: source 203; tests 149; config 106; docs 60; scripts 58.
- Core modules: active `src/llm4rec`; legacy `src/tglrec` is not the default edit target.
- Current claim gate: Phase 10 is not complete until large observation, Pony baseline migration, TGL ablations, paired statistics, leakage/reproducibility checks, and reviewer gate pass.
- Main risk: branch and historical Phase 9E files can mislead future agents unless Phase 10 docs remain first.

## Artifact Safety

Do not copy these into public wiki:

- raw Amazon/MovieLens datasets;
- generated predictions, raw LLM outputs, and logs;
- `.env` or private server configs;
- model weights, checkpoints, embeddings, arrays, and large evidence archives;
- full PDF or zip contents from reference folders.

Public-safe summaries may include:

- path pattern;
- approximate size;
- purpose;
- tracked/ignored/untracked status when known;
- reportability status from canonical manifests;
- risks and next command source.

## Collaboration Conflict Judgment

No hard conflict was found between Vipin wiki and the three project-local agent rules.

Interpretation:

- Vipin wiki controls durable routing, cross-project memory, public/private safety, and partner-language collaboration norms.
- The target project controls what to read, what to edit, which tests to run, which server commands to issue, and what evidence qualifies as paper-facing.
- Opus/Sonnet/Whale or Codex parallel selves can provide review or exploration when appropriate, but their output remains advisory until Codex verifies it against live files.

## Maintenance Recommendations

- Keep [[research-project-workbench]] as the first route page for these three projects.
- Update the three entity pages whenever a canonical project doc changes baseline status, current phase, or paper claim.
- When downstream projects reuse Pony official evidence, record only manifest state, score-gate status, paths, sizes, and hashes; do not copy evidence archives.
- If ProMax status changes in Pony/Uncertainty, update [[uncertainty]], [[truce-rec]], [[tgl-rec]], and the workbench together to avoid stale cross-project memory.
- Future deep code reviews should happen inside the target project repo after reading its local `AGENTS.md` and skill.

## Counterpoints and Gaps

- This audit did not run scientific tests, reproduce metrics, or validate output files.
- It did not read raw datasets, logs, PDFs, or generated prediction JSONL files fully.
- Artifact counts can drift quickly because experiments generate large ignored/untracked files. Future agents should rerun live inventory before acting on size or status details.

## Related

- [[research-project-workbench]]
- [[2026-05-17-research-project-roots-deep-review]]
- [[2026-05-10-vipin-research-project-map]]
- [[uncertainty]]
- [[truce-rec]]
- [[tgl-rec]]
