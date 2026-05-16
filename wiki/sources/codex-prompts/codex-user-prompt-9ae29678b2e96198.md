---
title: PLEASE IMPLEMENT THIS PLAN -
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

# PLEASE IMPLEMENT THIS PLAN:

## Metadata

- Stable ID: `codex-user-prompt:9ae29678b2e96198`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T15:00:15.598Z`
- Semantic hash: `9ae29678b2e96198aa09fb527ea6882055b7091f0540db3167a4847f938e1c5e`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

````text
PLEASE IMPLEMENT THIS PLAN:
# 下一步计划：实现最小 Implementation Readiness 审批闭环

## Summary
- 当前项目已经能生成 `TASK-001`，也能用 `gd:review` 检查任务包结构，但 review 仍停在 `Pass with issues`，因为缺少 Technical Director、Acceptance Criteria、QA、Product Scope 的审批记录。
- 下一步建议做 **Domain A：框架仓库开发**，不是制作游戏产品。
- 目标是新增一个确定性的本地命令 `gd:approve`，模拟“实现准备评审”的审批记录，让流程从“任务包草案”推进到“任务包通过 Implementation Readiness Gate”。
- 本轮仍然不写游戏代码、不接 LLM、不做真实 agent runtime。

## Key Changes
- 新增 `src/approve.js` 和对应 core 模块，用于读取 `output/tasks/TASK-001.md` 并生成：
 - `output/implementation_readiness_review.md`
 - 追加更新 `output/decision_log.md`
- 新增命令：
 ```bash
 node src/approve.js --all
 ```
 或 npm 环境：
 ```bash
 npm run gd:approve
 ```
- `gd:approve --all` 记录 4 个最小审批：
 - Product Scope approval
 - Technical Director approval
 - Acceptance Criteria approval
 - QA testability approval
- 更新 `src/core/taskReview.js`：
 - review 时读取 `output/implementation_readiness_review.md`
 - 如果 4 个审批齐全，`gd:review` 从 `Pass with issues / Can enter development: No` 变成 `Pass / Can enter development: Yes`
 - 如果审批缺失，继续保持 blocked/warning，不允许进入开发
- 更新 `README.md` 和 `package.json`：
 - 增加 `gd:approve`
 - 文档说明 `approve` 只是本地确定性审批模拟，不代表真实多 agent 系统

## Test Plan
- 先运行：
 ```bash
 node src/demo.js
 ```
 确认重新生成 artifacts。
- 再运行：
 ```bash
 node src/review.js
 ```
 预期：`Pass with issues`，因为还没审批。
- 再运行：
 ```bash
 node src/approve.js --all
 ```
 预期：生成 `output/implementation_readiness_review.md`，并更新 `output/decision_log.md`。
- 最后运行：
 ```bash
 node src/review.js
 ```
 预期：`Pass`，`Can enter development: Yes`。
- 运行 JS 语法检查：
 ```bash
 node --check src/approve.js
 node --check src/core/*.js
 ```
- 完成后按本项目规则分批 commit，并 push 到 GitHub。

## Assumptions
- 这一步只是在开发 Agent GD Studio 框架本身，属于 `AGENTS.md` 的 Domain A。
- `gd:approve` 是确定性本地模拟，不是真实 agent 审批系统。
- 即使 `TASK-001` 通过 review，也只是表示“未来可以进入开发任务”，本轮仍不实现任何游戏代码。
- 默认把 `output/implementation_readiness_review.md` 作为可追踪 demo artifact 提交到仓库。
````

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
