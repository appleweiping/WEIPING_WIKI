---
title: "DoneBench 项目状态 — Paper Writing Phase"
type: fact
created: 2026-05-27T08:03:00+08:00
updated: 2026-05-27T08:03:00+08:00
agent: opus
tags: [DoneBench, benchmark, specification-grounding, research, paper-writing, critical]
---

# DoneBench 项目状态

位置: `D:\Research\DoneBench`
GitHub: `appleweiping/donebench`
阶段: Paper Writing (实验基本完成，论文定稿中)

## 项目简介

DoneBench 评估 tool-using agent 能否推断、形式化、压力测试并满足任务完成标准。核心轴: **Specification Grounding**。

贡献: Specification-to-Execution Diagnostic Protocol (4 gates: criterion inference, executable DoneSpec encoding, near-miss robustness, own-spec compliance)

## 当前状态 (2026-05-27)

| 里程碑 | 状态 |
|--------|------|
| M0: Benchmark Harness | DONE |
| M1: topconf-4.1 Dataset (600 tasks) | DONE |
| M2: Full DeepSeek Run (18,000 trials) | DONE |
| M3: AI-Assisted Audit | DONE (all gates clear) |
| M4: Optional Human Calibration | OPTIONAL (0/50) |
| M5: Paper Claim Freeze | MOSTLY DONE |
| M6: Diagnostic Protocol + Paper | DONE (M6.1 + M6.2) |
| Cross-family experiments | CONFIGURED, NOT RUN |
| LaTeX compilation | NOT DONE (no TeX installed) |

## 关键文件

- `AGENTS.md`: 多 agent 操作协议
- `reports/agent_handoff.md`: 当前状态和交接
- `reports/next_actions.md`: 下一步行动
- `reports/blockers.md`: 阻塞项
- `configs/experiments.yaml`: 实验配置
- `configs/models.yaml`: 模型配置

## 活跃实验 (2026-05-27)

Cross-family frontier RE-RUN 进行中 (修复后):
- 问题已修复: GPT-5.5 temp=1 + proxy路由, Claude retry 5次 + 8s backoff
- Command: `donebench run-matrix --suite cross_family_frontier --output results/runs/cross_family_frontier/trials.jsonl --resume --max-workers 6`
- Env vars: DEEPSEEK_API_KEY, CLAUDE_PROXY_API_KEY (sbbbbbbbbb.xyz key, 同时用于GPT-5.5和Claude)
- 当前: 3486/7500 trials (DeepSeek 3000 完成, GPT+Claude ~4000 待完成)
- 速率限制: proxy 20 req/min, 预计 8-13 小时完成
- 如果中断: 重跑同一命令加 --resume

## 论文状态

- 所有 section 已重写为 NeurIPS 质量 (commit 14961ab)
- MiKTeX 编译为 14 页 PDF
- Cross-family 结果表是 placeholder — 实验完成后填入
- 目标会议: AAAI-27 (Jul 28) 或 ICLR 2027 (~Sep)

## 下一步

1. 等待 cross-family 实验完成
2. 将 cross-family 结果整合到论文表格
3. 生成更新的 figures
4. 确定最终投稿会议并适配格式
5. 最终 polish 和提交准备
