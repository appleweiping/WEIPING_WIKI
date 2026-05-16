---
title: 我们要创建一个名为 Agent gamedevelopmentstudio 的项目。
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

# 我们要创建一个名为 Agent gamedevelopmentstudio 的项目。

## Metadata

- Stable ID: `codex-user-prompt:902ac6d571a1fe84`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T12:29:34.671Z`
- Semantic hash: `902ac6d571a1fe840fbaf9f0494f9289058c694ac8ad4634cae0b7b635fe1df7`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
我们要创建一个名为 Agent gamedevelopmentstudio 的项目。 

它不是一个普通游戏项目，而是一个“AI 游戏开发工作室框架”。目标是让客户输入一个模糊的游戏想法后，系统不要立刻写代码，而是像真实游戏工作室一样，先澄清需求、做参考研究、做策划、做技术评审、生成任务包、执行开发、QA 验收、再进入下一轮。

本轮不要实现完整产品，不要写大量业务代码。你只需要创建项目的基础文档和规则文件。

请创建以下文件：

1. AGENTS.md
 - 这是 Codex 必须遵守的项目总规则。
 - 明确：需求不清时必须反问；没有任务包不得写代码；没有验收标准不得执行；任何执行任务必须限制修改范围。
 - 明确 Agent GD Studio 的工作方式：不是串行流水线，而是虚拟游戏工作室，包含会议、闸门、文档所有权、任务包、验收报告。

2. docs/AGENT_STUDIO_ORG.md
 - 定义 Agent GD Studio 的组织结构。
 - 包含部门：
 - 制作管理层
 - 需求与产品层
 - 研究层
 - 游戏设计层
 - 技术层
 - 美术与表现层
 - 质量层
 - 知识管理层
 - 每个部门列出 agent、职责、输入、输出、禁止事项、决策权。

3. docs/CLIENT_JOURNEY.md
 - 定义客户如何使用这个系统。
 - 客户不要直接面对 20 多个 agent。
 - 客户只看到：
 - 提交想法
 - 需求澄清
 - 方案确认
 - 开发看板
 - 验收迭代
 - 说明每一步客户看到什么、需要确认什么、系统后台做什么。

4. docs/GATES.md
 - 定义阶段闸门：
 - Concept Gate
 - Prototype Gate
 - Technical Gate
 - Implementation Readiness Gate
 - QA Gate
 - Milestone Gate
 - 每个 gate 必须包含：
 - 进入条件
 - 必须产物
 - 审核 agent
 - 阻塞条件
 - 通过后允许进入的阶段。

5. docs/ARTIFACTS.md
 - 定义所有共享产物：
 - project_brief.md
 - scope.md
 - references.md
 - design_spec.md
 - tech_spec.md
 - milestone_plan.md
 - tasks/TASK-xxx.md
 - acceptance_tests.md
 - qa_report.md
 - decision_log.md
 - context_pack.md
 - 每个产物要写清楚 owner agent、用途、何时创建、何时更新。

6. templates/TASK_TEMPLATE.md
 - Codex 执行开发任务时必须使用的任务包模板。
 - 必须包含：
 - 任务目标
 - 背景上下文
 - 相关文档
 - 允许修改文件
 - 禁止修改文件
 - 具体实现要求
 - 验收标准
 - 测试命令
 - 手动测试步骤
 - 回滚策略
 - 完成报告格式

7. templates/CLARIFICATION_TEMPLATE.md
 - 需求不清时的反问模板。
 - 要求问题必须具体、可回答，优先使用选择题和范围问题。
 - 禁止在需求不清时假设客户意图。

8. templates/QA_REPORT_TEMPLATE.md
 - QA 验收报告模板。
 - 分为：
 - 工程结果
 - 功能结果
 - 游戏体验结果
 - 是否超范围修改
 - 是否通过验收
 - 必须修复项
 - 建议优化项

请先只创建这些文档，不要实现 UI，不要实现 agent 运行时，不要接入 Codex subagents，不要写游戏代码。

完成后，请输出：
1. 创建了哪些文件
2. 每个文件的作用
3. 下一步建议实现什么
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
