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

- Stable ID: `codex-user-prompt:bb760ac5f9048f36`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T12:49:07.630Z`
- Semantic hash: `bb760ac5f9048f36486b75ae931d6d8199a02722d02ab824f41f1a281f61f78c`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# 重写 AGENTS.md 为最高优先级开发章程

## Summary
- 仅修改根目录 `AGENTS.md`，不修改 `docs/**`、`templates/**`、`src/**`、`output/**` 或任何运行时代码。
- 将现有规则文档整体重写为可执行的工作协议，面向 Codex、子 agent、执行 agent。
- 文档使用清晰 Markdown，保留用户指定的 13 个章节标题，并把核心原则写入章程：`Never build before the request is clarified, scoped, reviewed, task-packaged, and accepted.`
- 语言默认使用英文正文和英文章节名，因为该文件主要用于约束后续 agent 行为；最终回复用中文总结。

## Key Changes
- `# 1. Project Identity`：定义 Agent GD Studio 是 AI 游戏开发工作室框架，目标是把模糊游戏想法转化为澄清问题、brief、scope、research、design spec、tech spec、task packages、QA reports 和 iteration records，而不是一句话生成完整游戏。
- `# 2. Operating Model`：明确它是虚拟工作室，不是线性流水线；包含多 agent 协作、共享 artifacts、gates、文档所有权、决策权、客户确认、小步执行和每次执行后 QA。
- `# 3. Non-Negotiable Rules`：将 15 条硬规则逐条写成 `Rule / Why this exists / What to do instead` 格式。
- `# 4. Clarification Policy`：列出必须停止并反问的情况，并规定反问必须具体、可回答、优先选择题、每次最多 5-8 个关键问题。
- `# 5. Gate Policy`：定义 Concept、Scope、Game Design、Technical、Implementation Readiness、QA 六个 gate；每个 gate 包含 Purpose、Required artifacts、Blocking conditions、Who can approve、What happens if blocked。
- `# 6. Artifact Discipline`：定义 `project_brief.md`、`scope.md`、`references.md`、`design_spec.md`、`tech_spec.md`、`milestone_plan.md`、`tasks/TASK-xxx.md`、`acceptance_tests.md`、`qa_report.md`、`implementation_report.md`、`decision_log.md`、`context_pack.md` 的用途、创建时机、更新时机、负责人和 Codex 读取方式，并写入原则：`If a decision matters later, it must be written into an artifact.`
- `# 7. Task Package Requirements`：定义 `TASK-xxx.md` 必填字段；任何字段缺失时执行 agent 必须停止，不能开始写代码。
- `# 8. Change Scope Control`：规定只能修改任务包允许文件，额外文件必须先停止说明原因；禁止顺手重构、无关优化、跨系统大改和合并多个 milestone。
- `# 9. Decision Rights`：定义 Requirements Interviewer、Product Scope Agent、Game Director、Technical Director、Acceptance Criteria Agent、QA Agent、Documentation Agent 和客户的阻止或确认权限。
- `# 10. Execution Protocol`：写成 Codex 每次执行任务必须遵守的 13 步流程，从读取 `AGENTS.md` 到读取任务包、检查 gate、最小修改、测试、报告、QA、decision log 和验收说明。
- `# 11. Stop Conditions`：列出必须停止的情况，并规定停止输出必须包含为什么停止、缺少什么、需要谁确认、推荐下一步和可选澄清问题。
- `# 12. Output Style`：规定回应必须简洁、具体、不夸大、不声明未验证完成，并区分已完成、未完成、假设、风险和需要用户确认。
- `# 13. First Response Behavior`：规定客户第一次提出游戏想法时不得写代码，只输出当前理解、不可执行原因、澄清问题、建议 artifact 和禁止立即执行事项。

## Test Plan
- 运行 `rg --files`，确认本轮计划只涉及 `AGENTS.md`。
- 运行 `git diff --name-only`，确认实际变更文件只有 `AGENTS.md`。
- 检查 `AGENTS.md` 是否包含 13 个指定章节标题。
- 检查 `# 3. Non-Negotiable Rules` 中 15 条规则是否全部使用 `Rule / Why this exists / What to do instead` 格式。
- 检查 gate、artifact、task package、scope control、decision rights、execution protocol、stop conditions、first response behavior 是否覆盖用户列出的所有必需项。
- 不运行 formatter、代码生成、构建或测试命令，因为本任务只应修改 Markdown 文档。

## Assumptions
- `AGENTS.md` 将整体替换为强化后的章程，而不是在现有文档上小修小补。
- 不创建 `implementation_report.md`、`dev_log.md` 或任何新 artifact 文件；只在 `AGENTS.md` 中定义它们的规则。
- 本次不更新 `docs/GATES.md`、`docs/ARTIFACTS.md` 或 `templates/**`，即使新章程比现有辅助文档更严格。
- 执行完成后的用户可见回复应只包含：修改了 `AGENTS.md`、它现在包含哪些章节、它如何约束后续 Codex 工作。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
