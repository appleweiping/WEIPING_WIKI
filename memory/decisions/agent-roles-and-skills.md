---
title: "Agent 角色分工与技能使用规则"
type: decision
created: 2026-05-21T18:50:00+08:00
updated: 2026-05-21T18:50:00+08:00
agent: claude
tags: [roles, ARIS, skills, permanent, all-agents, critical]
related: [research-hard-rules.md, coding-preference.md]
---

## 角色定位（严格执行，不可混乱）

| Agent | 角色 | 定位 |
|-------|------|------|
| **CC / Opus** | 总舵主 | 智商最高，做架构设计、深度推理、复杂代码、全局决策。统筹全局。 |
| **OpenCode / 像素猫** | 均衡执行者 | 代码实现、实验部署、论文写作、流程编排。能力全面，独立完成任务。 |
| **Codex / GPT-5.5** | 审核官+方案师 | cross-model review、给出方案建议、experiment-audit、kill-argument。不做主力编码。 |
| **DeepSeek / 鲸鱼** | 打杂 | 翻译、摘要、分类、批量文本处理。廉价劳动力，不做决策。 |
| **Sonnet** | 快速审查 | diff 扫描、测试建议、quality gate |
| **Haiku** | 预筛选 | lint、格式化、快速分类 |

## 技能使用规则

- **科研项目必须使用 ARIS 全套技能框架步骤**，不可跳步
- ARIS 流程: idea-discovery → research-refine → experiment-plan → experiment-bridge → run-experiment → monitor → result-to-claim → experiment-audit → paper-plan → paper-figure → paper-write → paper-compile → auto-review-loop → citation-audit → paper-claim-audit
- 各 agent 要主动调用自己可用的 skill，不要等用户提醒
- Codex 的 38 个 skill 要积极使用（特别是 research 相关的）
- CC 的 lidang-perspective、mattpocock-skills 要在合适场景主动触发
