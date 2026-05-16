---
title: 请重写并强化根目录的 AGENTS.md。
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

# 请重写并强化根目录的 AGENTS.md。

## Metadata

- Stable ID: `codex-user-prompt:8ef9777c4280712f`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T12:47:24.424Z`
- Semantic hash: `8ef9777c4280712fd85cdddbbb38dcfd78d7b6ff4ad6372910a197a0f69407be`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
请重写并强化根目录的 AGENTS.md。

AGENTS.md 是 Agent GD Studio 项目的最高优先级工作协议。 
它不是普通 README，也不是介绍文档，而是 Codex、子 agent、执行 agent 在本项目中必须遵守的行为规则。

本轮只允许修改：
- AGENTS.md

本轮禁止修改：
- src/**
- docs/**
- templates/**
- output/**
- 任何游戏代码
- 任何运行时实现

目标：
把 AGENTS.md 写成一个可执行的“开发章程”，用于约束后续所有 Codex 工作。

AGENTS.md 必须包含以下章节：

# 1. Project Identity

说明 Agent GD Studio 是什么：

- 它是一个 AI 游戏开发工作室框架。
- 它的目标不是让 AI 根据一句话直接生成完整游戏。
- 它的目标是把模糊游戏想法转化为：
 - 澄清问题
 - 项目简报
 - 范围定义
 - 参考研究
 - 游戏设计规格
 - 技术设计规格
 - 可执行任务包
 - QA 验收报告
 - 迭代记录

必须写清楚核心原则：

> Never build before the request is clarified, scoped, reviewed, task-packaged, and accepted.

# 2. Operating Model

说明 Agent GD Studio 不是线性流水线，而是一个虚拟游戏工作室。

必须包含这些概念：

- 多 agent 协作
- 共享 artifacts
- 阶段 gates
- 文档所有权
- 决策权
- 客户确认
- 小步执行
- 每次执行后 QA

明确说明：

- agent 之间不能只靠聊天传递上下文。
- 重要信息必须写入 artifact 文件。
- Codex 执行任务时，必须读取相关 artifact。
- 没有 artifact 支撑的假设不能直接进入实现。

# 3. Non-Negotiable Rules

列出不可违反的硬规则。

至少包含：

1. 需求不清时，不得写代码。
2. 没有 TASK-xxx.md 任务包，不得写代码。
3. 任务包缺少验收标准，不得写代码。
4. 没有明确允许修改文件，不得写代码。
5. 没有明确禁止修改文件，不得写代码。
6. 不得因为客户说“继续”就跳过 gate。
7. 不得自行扩大任务范围。
8. 不得把原型任务做成完整商业系统。
9. 不得把完整系统压缩成一次性大改。
10. 不得在没有 QA 标准时声明完成。
11. 不得修改与任务无关的文件。
12. 不得用“我认为”补全关键需求。
13. 不得静默处理冲突需求。
14. 不得删除或绕过既有 project artifacts。
15. 不得在没有记录的情况下做重大设计决策。

每条规则都要写成：
- Rule
- Why this exists
- What to do instead

例如：

Rule: Do not write code without a TASK-xxx.md file. 
Why this exists: Prevents broad, unfocused changes. 
What to do instead: Create or request a task package using templates/TASK_TEMPLATE.md.

# 4. Clarification Policy

定义什么时候必须反问客户。

必须说明：如果出现以下情况，Codex 必须停止执行并生成澄清问题：

- 游戏类型不明确
- 核心循环不明确
- 参考游戏只说了名字，没有说明借鉴点
- MVP 范围不明确
- 目标平台不明确
- 输入方式不明确
- 美术风格不明确但任务涉及 UI/视觉
- 联机、存档、关卡、战斗、经济、AI 等系统边界不明确
- 验收标准不明确
- 任务过大，无法安全完成
- 允许修改范围不明确
- 需求之间存在冲突
- 用户要求“一次做完整游戏”

反问必须遵守：

- 优先问选择题
- 每次最多问 5-8 个关键问题
- 问题必须具体
- 问题必须能影响后续实现
- 不问无关偏好
- 不用开放式长问卷吓退客户

# 5. Gate Policy

定义所有阶段 gate。

必须包含：

## Concept Gate
通过前必须有：
- 项目一句话定位
- 目标玩家
- 核心体验
- 参考方向
- 非目标事项

## Scope Gate
通过前必须有：
- MVP 功能列表
- 明确不做事项
- 优先级
- 风险列表

## Game Design Gate
通过前必须有：
- 核心循环
- 玩家操作
- 系统反馈
- 失败条件
- 奖励机制
- 基础 UI 流程

## Technical Gate
通过前必须有：
- 技术栈
- 项目结构
- 模块边界
- 数据格式
- 测试方式
- 构建方式

## Implementation Readiness Gate
通过前必须有：
- TASK-xxx.md
- 允许修改文件
- 禁止修改文件
- 验收标准
- 测试步骤
- 回滚策略

## QA Gate
通过前必须有：
- 实际测试结果
- 功能验收结果
- 是否超范围修改
- 已知问题
- 是否允许进入下一任务

每个 gate 都要说明：
- Purpose
- Required artifacts
- Blocking conditions
- Who can approve
- What happens if blocked

# 6. Artifact Discipline

定义所有重要 artifact。

至少包含：

- project_brief.md
- scope.md
- references.md
- design_spec.md
- tech_spec.md
- milestone_plan.md
- tasks/TASK-xxx.md
- acceptance_tests.md
- qa_report.md
- implementation_report.md
- decision_log.md
- context_pack.md

必须写清楚：

- 每个 artifact 的用途
- 什么时候创建
- 什么时候更新
- 哪些 agent 负责
- 后续 Codex 任务应该如何读取它

必须强调：

> If a decision matters later, it must be written into an artifact.

# 7. Task Package Requirements

定义 TASK-xxx.md 必须包含什么。

至少包含：

- Task ID
- Title
- Goal
- Background context
- Related artifacts
- Allowed files
- Forbidden files
- Implementation requirements
- Acceptance criteria
- Automated test commands
- Manual test steps
- Rollback plan
- Completion report format

必须说明：

如果任何字段缺失，执行 agent 必须停止，不能开始写代码。

# 8. Change Scope Control

定义如何控制 Codex 改动范围。

必须包含：

- 只能修改任务包允许的文件。
- 如果必须修改额外文件，先停止并说明原因。
- 不允许顺手重构。
- 不允许顺手优化无关模块。
- 不允许跨系统大改。
- 不允许把多个 milestone 的内容合并到一次任务。
- 大任务必须拆分。
- 单次任务应该尽量小，能独立测试，能回滚。

# 9. Decision Rights

定义谁有权阻止或批准。

至少包含：

- Requirements Interviewer 可以阻止需求不清的任务。
- Product Scope Agent 可以阻止范围过大的任务。
- Game Director 可以阻止偏离核心体验的设计。
- Technical Director 可以阻止技术风险过高或架构不清的任务。
- Acceptance Criteria Agent 可以阻止验收标准不清的任务。
- QA Agent 可以阻止未通过测试的任务。
- Documentation Agent 可以要求记录重要决策。
- 客户必须确认项目定位、MVP 范围、重大方向变化和验收结果。

# 10. Execution Protocol

定义 Codex 每次执行任务时必须遵守的步骤：

1. 读取 AGENTS.md。
2. 读取当前 TASK-xxx.md。
3. 读取任务中列出的 related artifacts。
4. 检查任务包是否完整。
5. 检查允许修改范围和禁止修改范围。
6. 如果信息不足，停止并输出澄清问题。
7. 如果任务过大，停止并请求拆分。
8. 执行最小必要修改。
9. 运行指定测试。
10. 生成 implementation report。
11. 生成或更新 QA report。
12. 更新 decision_log.md 或 dev_log.md。
13. 明确说明是否通过验收。

# 11. Stop Conditions

定义 Codex 必须停止的情况。

至少包含：

- 没有任务包
- 任务包字段缺失
- 客户需求冲突
- 需要改动禁止文件
- 需要做架构决策但没有 Technical Gate
- 需要做玩法决策但没有 Game Design Gate
- 测试命令缺失
- 项目无法运行且原因不明
- 需求大到无法安全执行
- 发现当前实现会破坏既有核心体验

停止时必须输出：

- 为什么停止
- 缺少什么信息
- 需要谁确认
- 推荐下一步
- 可选的澄清问题

# 12. Output Style

定义 Codex 回应风格。

要求：

- 简洁
- 具体
- 不夸大
- 不声称完成未验证的事情
- 不说“应该可以”
- 必须区分：
 - 已完成
 - 未完成
 - 假设
 - 风险
 - 需要用户确认

# 13. First Response Behavior

定义当客户第一次提出游戏想法时，Codex 应该怎么做。

它不应该写代码，而应该输出：

- 当前理解
- 当前不可执行原因
- 需要澄清的问题
- 建议的下一步 artifact
- 禁止立即执行的事项

请用清晰的 Markdown 写 AGENTS.md。

完成后，只输出：
1. 修改了 AGENTS.md
2. AGENTS.md 现在包含哪些章节
3. 这个文件如何约束后续 Codex 工作
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
