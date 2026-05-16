---
title: PLEASE IMPLEMENT THIS PLAN -
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

# PLEASE IMPLEMENT THIS PLAN:

## Metadata

- Stable ID: `codex-user-prompt:7ab57db4cc0ce8cc`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-11T12:02:34.629Z`
- Semantic hash: `7ab57db4cc0ce8ccce1c753d4a8eb8e6a4457f523e1d31ed4866c8d32fd319f4`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# 本地大重构与服务器就绪计划 v2

## Summary

保留你贴出的完整计划作为基础，并做三处硬修正：

- Backbone 固定为 **Qwen3 8B**，不再写 Qwen3.5/Qwen3 摇摆表述。
- Baseline 不再使用“至少 3 个 PLM/LLM4Protein 已跑”这种最低门槛；改为 **调研到的 2025/2026 相关顶会/强论文 PLM/LLM4Protein/protein-design baseline 全量纳入，能跑全跑，不能跑必须写 blocker report**。
- Server 执行边界固定：agent 只能准备本地项目、命令、预算、校验和整理脚本；用户在服务器跑命令并返还终端结果和输出目录；agent 在本地整理结果。

明确新 idea：**ObsShift-BO** 
用 DeepSeek/API 与本地 Qwen3 8B 观察器发现低样本蛋白优化中的可复现决策失败模式，把 accepted pain-point ledger 蒸馏成 Qwen3 8B LoRA/SFT 本地观察器，再把这些痛点转化为可被现代 baseline 证伪的 shift-aware proposal、risk、batch 策略。

Harness engineering 只作为项目执行方式，不作为论文贡献。

## Key Changes

### 1. 仓库清理与架构重排

- 建立三层结构：
 - kernel：保留 data、representation、models、uq、acquisition、proposal、loop、evaluation。
 - protocols：observation、finetune、baseline、low_n_audit、method、server。
 - paper/claim layer：只保留 claim/evidence/reviewer/milestone，不再反向定义代码。
- 分层归档旧内容：
 - `config/experiment/day*`, `*_main5`, `*_smoke`, 旧 v2/v3 文档迁入 `archive/legacy_experiments/`。
 - 保留 `paper_main_configs.yaml` 作为兼容索引，但新增 semantic protocol aliases。
 - 删除或本地归档旧 zip、旧 version 本地目录、临时 YAML/SVG、重复草稿、无执行内容 placeholder configs。
- 测试迁移：
 - 从锁文档句子改成锁协议 schema、runner 输出、server command readiness。

### 2. Observation -> LoRA/SFT -> Method 主线

- Observation tiers 固定：
 - Smoke：`1 synthetic task x 8 records x 2 observers`
 - Pilot：`4 real tasks x 32 records x 2 observers`
 - Main：`12 main tasks x 64 records x DeepSeek+Qwen3 8B = 1536 records`
 - Appendix：`10 tasks x 32 records x DeepSeek+Qwen3 8B = 640 records`
- DeepSeek/API 与 Qwen3 8B runner 必须支持：
 - `--workers`
 - retry/backoff/rate-limit handling
 - deterministic record ids
 - JSONL outputs
 - accepted/rejected/needs-review pain-point ledger
- LoRA/SFT path：
 - accepted observations -> instruction JSONL
 - Qwen3 8B LoRA observer
 - speculative observations 不进入训练数据
 - full finetune 仅作为全 baseline 同设置 appendix，不进入默认主比较
- Method freeze rule：
 - 每个 ObsShift-BO 组件必须有 pain-point row。
 - 没有 pain-point 对应的组件删除。
 - 禁止拼接式 A+B+C 作为贡献。

### 3. Modern Baseline Framework

- Baseline 不再是“至少 8 个”作为完成门槛，而是两层：
 - baseline family 覆盖必须完整；
 - 2025/2026 调研到的相关顶会/强论文 baseline 全量进入 registry。
- 必须覆盖 family：
 - random/mutation library
 - greedy supervised surrogate
 - GP/RF/TPE BO
 - deep ensemble BO
 - conformal/weighted conformal internal controls
 - zero-shot PLM
 - PLM embedding + small head
 - active/few-shot protein optimization
 - LLM-directed evolution
 - foundation/generative PLM
 - structure-aware / structure-conditioned design
 - multimodal protein models
- 每个 baseline registry entry 状态只能是：
 - runnable
 - runnable_with_official_api
 - blocked_weights
 - blocked_license
 - blocked_hardware
 - blocked_missing_official_code
 - diagnostic_only_with_reason
- Fairness policy 固定：
 - official implementation
 - adapt only dataset I/O
 - use **Qwen3 8B** shared backbone where applicable
 - unified LoRA
 - baseline official/default/reported optimal hyperparameters
 - our method tuned with documented validation/search budget
- Experimental setting 固定写法：
 - “We use the official implementation of each baseline, adapt only the input/output interface to our benchmark protocol, use Qwen3 8B as the shared LLM backbone where applicable, and keep the baseline’s official default or reported hyperparameters under the LoRA setting unless otherwise stated.”

### 4. Server-Ready Deliverables

- 生成 server run bundle：
 - `server/run_all_observation.ps1`
 - `server/run_lora_observer.ps1`
 - `server/run_low_n_audit.ps1`
 - `server/run_modern_baselines.ps1`
 - `server/run_obsshift_bo.ps1`
 - `server/collect_results.ps1`
- 每个 server command 运行前必须生成：
 - `cost_time_estimate.md`
 - estimated API tokens/cost
 - estimated GPU hours
 - estimated wall time
 - expected outputs
- 执行边界：
 - agent 看不到服务器项目。
 - agent 只准备本地命令、脚本、预算、校验器、整理器。
 - 用户在服务器跑命令并返还 terminal output 和结果目录。
 - agent 在本地 ingest、validate、summarize。
- 每个 runner 输出：
 - `run_manifest.json`
 - `config_snapshot.yaml`
 - `metrics.json/csv`
 - `failure_report.md`
 - `next_action.json`
- 本地 dry-run 必须全部通过后才能上服务器。

## Test Plan

- Unit/schema tests：
 - protocol manifests load
 - full baseline registry has source/status/reason/command
 - observation records schema valid
 - accepted-only LoRA data conversion valid
 - server job matrix emits all runnable and blocked jobs
 - cost/time estimator emits budget files
- Dry-run tests：
 - DeepSeek dry-run parallel
 - Qwen3 8B dry-run parallel
 - LoRA dry-run
 - small-model training smoke
 - baseline job generation
 - result-ingestion sample manifest validation
- Integration tests：
 - one synthetic smoke end-to-end
 - one real dataset pilot end-to-end if local data exists
- Full validation before commit：
 - `py -3.12 -m unittest discover -s tests -p "test_*.py"`
 - dry-run server command generation
 - git status clean except ignored outputs

## Milestones And Stopping Criteria

- M1 local rebuild complete：旧实验归档，semantic protocols 接管，所有 local dry-run 通过。
- M2 observation complete：DeepSeek + Qwen3 8B live main-panel observations 完成，accepted/rejected ledger 固化。
- M3 LoRA observer complete：accepted observations converted，Qwen3 8B LoRA observer 成功或明确硬件/模型访问阻塞。
- M4 baseline registry complete：2025/2026 相关顶会/强论文 baseline 全量调研、全量入 registry。
- M5 baseline execution complete：registry 中所有 runnable baseline 已跑；所有 blocked baseline 有正式 blocker report。
- M6 method complete：ObsShift-BO 每个组件都有 pain-point row 和 falsifying baseline。
- M7 writing-ready：12-task main + 10-task appendix，10 seeds where feasible，CI/paired tests/effect sizes/corrected p-values 完成，reviewer agent 审核通过。

只有 M7 满足时，才能说“实验阶段基本结束，可以进入写作”。

## Assumptions

- 使用“分层归档”而不是硬删除可复现实验。
- 主比较默认统一 LoRA，不混用 full finetune。
- 实际 backbone 固定为 **Qwen3 8B**。
- API 成本不限制，但每次运行必须提供成本预算和时间预算。
- Agent 不直接访问服务器；用户负责服务器运行并返还结果。
- Harness engineering 不进入论文 novelty，只进入执行、审计、复现与停止规则。
- 下一次切出执行模式后，按主题分批实现、测试、commit、push。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
