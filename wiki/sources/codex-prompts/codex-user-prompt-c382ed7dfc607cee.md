---
title: 本地大重构与服务器就绪计划
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

# 本地大重构与服务器就绪计划

## Metadata

- Stable ID: `codex-user-prompt:c382ed7dfc607cee`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-11T12:01:40.780Z`
- Semantic hash: `c382ed7dfc607cee35a71b99390eecea2c044095580835c7b06486ad27bdc3f3`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
# 本地大重构与服务器就绪计划

## Summary

明确的新 idea：**ObsShift-BO** 
用 DeepSeek/API 与本地 Qwen3-8B 观察器发现低样本蛋白优化中的可复现决策失败模式，把 accepted pain-point ledger 蒸馏成 LoRA/SFT 本地观察器，再把这些痛点转化为可被现代 baseline 证伪的 shift-aware proposal、risk、batch 策略。 
Harness engineering 只作为项目执行方式，不作为论文贡献。

默认决策已锁定：

- 清理策略：分层归档，不硬删可复现核心。
- LLM 公平策略：统一 LoRA，统一 Qwen3.5/Qwen3 8B backbone where applicable，baseline 用官方默认/报告超参。
- 复杂任务：默认多 agent，至少 reviewer agent + implementation agent + integration owner。
- 提交策略：按主题分批 commit，验证通过后 push GitHub。

## Key Changes

### 1. 仓库清理与架构重排

- 新建清晰三层结构：
 - `kernel/` 或保留现有核心包：data、representation、models、uq、acquisition、proposal、loop、evaluation。
 - `protocols/`：observation、finetune、baseline、low_n_audit、method、server。
 - `paper/claim layer`：只保留 claim/evidence/reviewer/milestone，不再反向定义代码。
- 分层归档旧内容：
 - `config/experiment/day*`, `*_main5`, `*_smoke`, 旧 v2/v3 文档迁入 `archive/legacy_experiments/`。
 - 保留 `paper_main_configs.yaml` 作为兼容索引，但新增 semantic protocol aliases。
 - 删除或本地归档明显无用文件：旧 zip、旧 version 本地目录、临时 YAML/SVG、重复草稿。
- 测试从“锁文档句子”迁移到“锁协议 schema、runner 输出、server command 可执行性”。

### 2. Observation -> LoRA/SFT -> Method 主线

- Observation tiers 固定：
 - Smoke：`1 synthetic task x 8 records x 2 observers`
 - Pilot：`4 real tasks x 32 records x 2 observers`
 - Main：`12 main tasks x 64 records x DeepSeek+Qwen = 1536 records`
 - Appendix：`10 tasks x 32 records x 2 observers = 640 records`
- DeepSeek/API 与 Qwen3-8B runner 都必须支持：
 - `--workers`
 - rate-limit/retry
 - deterministic record ids
 - JSONL outputs
 - rejected/accepted pain-point ledger
- LoRA/SFT path：
 - accepted observations -> instruction JSONL
 - Qwen3-8B LoRA observer
 - no full finetune in main setting unless all comparable LLM baselines also full finetune
- Method freeze rule：
 - 每个 ObsShift-BO 组件必须有 pain-point row。
 - 没有 pain-point 对应的组件删除，不允许拼接式 A+B+C。

### 3. Modern Baseline Framework

- Baseline 至少 8 个 family，不再把 acquisition variants 当 8 个 baseline。
- 必须覆盖：
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
 - structure-conditioned design where fair
- 参考项目仅作设计基准，不抄袭/缝合：
 - [ProSpero](https://arxiv.org/abs/2505.22494)
 - [Large Language Model is Secretly a Protein Sequence Optimizer](https://arxiv.org/abs/2501.09274)
 - [DPLM-2](https://proceedings.iclr.cc/paper_files/paper/2025/hash/57c30b677add9aa78e1745f0643104d0-Abstract-Conference.html)
 - [ESM3](https://www.nature.com/nature-index/article/10.1126/science.ads0018)
 - [Evo 2](https://www.nature.com/articles/s41586-026-10176-5)
 - [ProteinGym](https://papers.nips.cc/paper_files/paper/2023/hash/cac723e5ff29f65e3fcbb0739ae91bee-Abstract-Datasets_and_Benchmarks.html)
 - [FLIP/FLIP2](https://flip.protein.properties/)
- Fairness policy：
 - official implementation
 - adapt only dataset I/O
 - use Qwen3.5/Qwen3 8B shared backbone where applicable
 - unified LoRA
 - baseline official/default hyperparameters
 - our method tuned with documented validation budget

### 4. Server-Ready Deliverables

- 生成一个 server run bundle：
 - `server/run_all_observation.ps1`
 - `server/run_lora_observer.ps1`
 - `server/run_low_n_audit.ps1`
 - `server/run_modern_baselines.ps1`
 - `server/run_obsshift_bo.ps1`
- 每个命令只需要设置环境变量和路径即可运行。
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
 - baseline registry >= 8 families
 - observation records schema valid
 - LoRA data conversion valid
 - server job matrix emits commands
- Dry-run tests：
 - DeepSeek dry-run parallel
 - Qwen dry-run parallel
 - LoRA dry-run
 - small-model training smoke
 - baseline job generation
- Integration tests：
 - one synthetic smoke end-to-end
 - one real dataset pilot end-to-end if local data exists
- Full validation before commit:
 - `py -3.12 -m unittest discover -s tests -p "test_*.py"`
 - dry-run server command generation
 - git status clean except intended outputs ignored

## Milestones And Stopping Criteria

- M1 local rebuild complete：旧实验归档，semantic protocols 接管，所有 local dry-run 通过。
- M2 observation complete：DeepSeek + Qwen live main-panel observations 完成，accepted/rejected ledger 固化。
- M3 LoRA observer complete：accepted observations converted，Qwen observer LoRA 成功或明确硬件阻塞。
- M4 baseline complete：至少 8 baseline families 可运行或正式标记 unavailable with reason，其中至少 3 个 PLM/LLM4Protein 已跑。
- M5 method complete：ObsShift-BO 每个组件都有 pain-point 与 falsifying baseline。
- M6 writing-ready：12-task main + 10-task appendix，10 seeds where feasible，CI/paired tests/effect sizes/corrected p-values 完成。

只有 M6 满足时，才能说“实验阶段基本结束，可以进入写作”。

## Assumptions

- 使用“分层归档”而不是硬删除可复现实验。
- 主比较默认统一 LoRA，不混用 full finetune。
- Qwen3.5 8B 和 Qwen3 8B 作为同类 backbone policy；实际服务器可用哪个，就在 config 中锁定哪个。
- Harness engineering 不进入论文 novelty，只进入执行、审计、复现与停止规则。
- 下一次切出执行模式后，按上述顺序分批实现、测试、commit、push。
这些你也别忘了要有，我刚才的说明只是让你在这个基础上改
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
