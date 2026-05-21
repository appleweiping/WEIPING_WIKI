---
title: "科研项目硬规则 — 多模型协作与质量标准"
type: decision
created: 2026-05-20T00:00:00+08:00
updated: 2026-05-21T10:00:00+08:00
agent: claude
tags: [ARIS, hard-rule, multi-model, collaboration, quality, permanent]
related: [agent-cli-launch-config.md]
---

## 多模型协作分工

- **Codex/GPT-5.5 (xhigh)**: 审查官+协调者。cross-model review、experiment-audit、citation-audit、paper-claim-audit、kill-argument
- **OpenCode/像素猫 (Claude Opus 4.7)**: 主执行者。代码实现、实验部署、论文写作、流程编排
- **Opus (Claude Opus 4.7 via cc.cmd)**: 深度代码审查、复杂推理、架构设计
- **Sonnet (Claude Sonnet 4.6)**: 快速 diff 扫描、测试建议、quality gate
- **Haiku (Claude Haiku 4.5)**: lint、格式化、预筛选
- **DeepSeek/鲸鱼 (V4)**: 廉价劳动力 ONLY。翻译、摘要、分类

## 质量标准

1. 顶会级别 (NeurIPS/ICML/ICLR oral 级别为目标)
2. 禁止 toy 化 (不允许 mock/pilot 作为 paper evidence)
3. 禁止缝合 (禁止 A+B 模块拼接式创新)
4. 强制创新 (必须有 original problem reframing)
5. 效果要好 (Baselines 至少 8 个, 统计显著性 20+ seeds)
6. 持续与顶会论文比较 rigor
7. Evidence discipline (clear labels: diagnostic/pilot/official/paper_result)

## ARIS 全流程

idea-discovery → research-refine → experiment-plan → experiment-bridge → run-experiment → monitor → result-to-claim → experiment-audit → paper-plan → paper-figure → paper-write → paper-compile → auto-review-loop → citation-audit → paper-claim-audit
