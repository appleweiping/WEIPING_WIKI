---
title: "DoneBench 项目状态 — Experiment Expansion + ARIS Review Loop"
type: fact
created: 2026-05-27T08:03:00+08:00
updated: 2026-05-31T20:42:00+02:00
agent: codex
tags: [DoneBench, benchmark, specification-grounding, research, experiment-expansion, ARIS, critical]
---

# DoneBench 项目状态

位置: `D:\Research\DoneBench`
GitHub: `appleweiping/donebench`
阶段: Experiment expansion + ARIS review loop (CC/Opus family pass@3 已清理补跑；DMXAPI 仅作为旁路诊断面板)

## 项目简介

DoneBench 评估 tool-using agent 能否推断、形式化、压力测试并满足任务完成标准。核心轴: **Specification Grounding**。

贡献: Specification-to-Execution Diagnostic Protocol (4 gates: criterion inference, executable DoneSpec encoding, near-miss robustness, own-spec compliance)

## 当前状态 (2026-05-31)

| 里程碑 | 状态 |
|--------|------|
| M0: Benchmark Harness | DONE |
| M1: topconf-4.1 Dataset (600 tasks) | DONE |
| M2: Full DeepSeek Run (18,000 trials) | DONE |
| M3: AI-Assisted Audit | DONE (all gates clear) |
| M4: Optional Human Calibration | OPTIONAL (0/50) |
| M5: Paper Claim Freeze | MOSTLY DONE |
| M6: Diagnostic Protocol + Paper | DONE (M6.1 + M6.2) |
| Cross-family frontier | DONE |
| cross_family_3trial | DONE + CLEAN + POSTPROCESSED + CLAIM-AUDITED (9000/9000 clean unique; 412 historical provider/access rows moved to sidecar; parse 8991/9000 = 99.9%; scoped pass@3 paper use allowed with caveats) |
| cross_family_new_models | DONE + POSTPROCESSED + CLAIM-AUDITED + MANUSCRIPT-INTEGRATED (4500/4500 clean unique; 0 provider-failure rows in official JSONL; local bad cclaude slots filtered after recharge) |
| DMXAPI free dev panel | RUNNING CLEAN SHARDED (1185/5100 clean rows at 2026-05-31 17:47 Europe/Berlin; dirty first shard quarantined) |
| LaTeX compilation | COMPILES via pdflatex/bibtex/pdflatex/pdflatex; visual inspection passed after hiding PDF link borders |

Latest commits pushed to `origin/main` on 2026-05-31: `9e7b4d9` (`Audit passk claims and refresh artifacts`) preserves the cross-family pass@3 claim audit, refreshed pass@3 paper tables, proxy-route wording, OpenReview/release manifests, and `results/runs/cross_family_3trial/trials.manifest.json`; `c6bac70` (`Update handoff after passk artifact commit`) updates project handoff/status docs so future agents do not repeat the completed commit step. User clarified that the relevant access issue was CC/Opus recharge/provider slots, not DMXAPI.

## 关键文件

- `AGENTS.md`: 多 agent 操作协议
- `reports/agent_handoff.md`: 当前状态和交接
- `reports/next_actions.md`: 下一步行动
- `reports/blockers.md`: 阻塞项
- `configs/experiments.yaml`: 实验配置
- `configs/models.yaml`: 模型配置

## 活跃实验 (2026-05-31)

`cross_family_new_models` 已完成 Claude Sonnet 4.6 / Haiku 4.5 / Opus 4.6:
- Matrix: 3 models x 3 agents x 500 test tasks x 1 trial = 4500 trial rows.
- Current command: `python -m donebench.cli experiment-pipeline cross_family_new_models --output results/runs/cross_family_new_models/trials.jsonl --report-root reports/cross_family_runs --max-workers 16 --resume --skip-provider-limit-rows`
- Current observed progress: 4500/4500 clean unique rows; 0 provider-failure rows in official JSONL.
- Provider-limit/channel/availability/permission rows are appended to `results/runs/cross_family_new_models/trials.provider_limit_rejects.jsonl` and remain eligible for retry. Current reject sidecar count: 337 unique rows.
- The latest CC/Opus issue was provider balance/access, not DMXAPI. After recharge, one inaccessible cclaude slot per Claude route was filtered out of local gitignored `configs/api_keys.yaml`; Opus 4.6 now has 3 working slots and Sonnet/Haiku each have 1 working slot.
- `--max-workers 20` was tested before recharge and bad-slot filtering. w16 completed the run cleanly after the slot filter.
- JSON parse/delimiter/model-output failures are kept in the official JSONL as model behavior evidence.
- Current cells: all 9 model-agent cells are 500/500.
- Postprocess: complete under `reports/cross_family_runs/runs/cross_family_new_models/`; parse gate 4487 parsed / 13 fallback, parse rate 99.71%, 0 quarantined cells.
- ARIS claim audit: `reports/cross_family_runs/runs/cross_family_new_models/claim_audit.md`.
- Manuscript integration: conservative Claude-family refresh paragraphs added to experiments/results/analysis/reproducibility/limitations; Round 2 ARIS cleanup scoped all Claude/Opus claims to proxy-routed model-ID evidence and refreshed release/openreview manifests.
- Paper table artifacts refreshed: `paper/tables/cross_family_new_models_results.csv`, `paper/tables/cross_family_new_models_parse_transparency.csv`, `paper/tables/cross_family_new_models_cost_summary.json`.
- `experiment-pipeline` now skips postprocessing incomplete result matrices by default unless `--allow-incomplete-postprocess` is explicitly passed.
- Claim boundary: conservative Claude-family refresh only. Do not claim official Anthropic API, zero dollar cost, or meaningful Opus task-success superiority. Original Opus 4.7 results are also proxy-routed and must not be labeled official Anthropic-equivalent.

`dmx_free_dev_panel` 正在作为独立诊断面板运行:
- Matrix: 17 DMXAPI free/zero-price chat/code routes x 3 agents x 100 dev tasks x 1 trial = 5100 trial rows.
- Dirty first attempt under `results/runs/dmx_free_dev_panel_shards/` is quarantined because provider-limit rows were being counted as completed rows.
- Clean run is one shard per model under `results/runs/dmx_free_dev_panel_clean_shards/` using `scripts/run_model_shard.py --max-workers 1 --row-delay-s 30 --skip-provider-limit-rows`.
- Current observed progress: 1185/5100 clean rows; 0 provider-failure rows in main shard outputs; 980 provider/access reject-sidecar rows under the corrected detector.
- The first provider detector version misclassified some parse/delimiter errors as provider failures; those rows were recovered into main shard JSONLs. The corrected detector avoids bare `limit` so `delimiter` no longer matches.
- Claim boundary: diagnostic/model-coverage evidence only; do not use as main SOTA ranking unless a later full test panel and ARIS audit justify it.

`cross_family_3trial` completed and repaired after CC/Opus recharge:
- Scope: GPT-5.5 and Claude Opus 4.7, 3 agents, 500 test tasks, 3 trials = 9000 expected trials.
- Main raw trace is now 9000/9000 clean unique rows with `provider_failure_rows=0`.
- 412 historical provider/access failures were moved out of the paper-facing JSONL into `results/runs/cross_family_3trial/trials.provider_limit_rejects.jsonl` as retry/access evidence, not model behavior.
- Postprocess is complete under `reports/cross_family_runs/runs/cross_family_3trial/`.
- Parse gate: 8991 parsed / 9 fallback, parse rate 99.9%, 0 quarantined cells, `paper_ready_parse_gate=true`.
- Current clean pass@3 consistency: GPT-5.5 direct and plan-first DoneSpec-valid pass@3 100% / task-success 0%; GPT-5.5 spec-first 1.6% DoneSpec-valid / 0.6% task-success; Claude Opus 4.7 spec-first 0.2% / 0.2%.
- Paper text now uses the clean pass@3 values and scopes claims to proxy-routed model IDs; do not present CC/Opus as official Anthropic API evidence.
- 2026-05-31 follow-up ARIS review used GPT-5.5 subagents for primary analysis, skeptical top-conference review, and artifact/repro checking. Fixes applied: pass@3 wording now means at least one success/valid DoneSpec across three repeated attempts; stale `paper/tables/cross_family_3trial_*` snapshots were refreshed from clean artifacts; `reports/cross_family_runs/runs/cross_family_3trial/claim_audit.md`, `reports/claim_to_artifact_map.md`, OpenReview metadata, and paper proxy-route wording were updated.
- The pass@3 audit package was committed and pushed as `9e7b4d9`; no raw JSONL, provider-sidecar, or key file was included in that commit.

## 论文状态

- Paper-facing few-shot ablation values were corrected to match artifacts: GPT-5.5 few-shot near-miss detection 98.6%, self-violation 82.6%.
- `cross_family_3trial` clean pass@3 values are integrated conservatively in the paper and now have a dedicated ARIS claim audit. Do not strengthen pass@k/CI/provider-ranking interpretation beyond the current scoped wording without a new audit.
- `cross_family_new_models` may be presented only as a conservative proxy-routed Claude-family refresh with caveats; DMXAPI panel must not be presented as completed paper evidence yet.
- PDF visual inspection passed after hidden-link rebuild; remaining LaTeX warnings are small overfull/underfull boxes and hyperref bookmark warnings for math headings.
- 目标会议: AAAI-27 (Jul 28) 或 ICLR 2027 (~Sep)

## 下一步

1. Publish manifest-hashed hosted-model raw traces (`results/runs/cross_family_3trial/trials*.jsonl` and `results/runs/cross_family_new_models/trials*.jsonl`) via GitHub release assets or Git LFS before external submission.
2. Continue monitoring `dmx_free_dev_panel` shards only as a diagnostic/model-coverage panel; do not treat it as the primary CC/Opus experiment line.
3. Continue optional provider-family slices only with scoped claims and ARIS audit.
4. Commit+push non-secret artifacts after each completed milestone.
