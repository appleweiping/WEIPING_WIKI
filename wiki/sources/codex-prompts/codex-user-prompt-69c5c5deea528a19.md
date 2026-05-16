---
title: 现在基于 AGENTS.md、docs/ 和 templates/，实现 Agent GD Studio 的最小客户旅程原型。
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

# 现在基于 AGENTS.md、docs/ 和 templates/，实现 Agent GD Studio 的最小客户旅程原型。

## Metadata

- Stable ID: `codex-user-prompt:69c5c5deea528a19`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T13:17:12.610Z`
- Semantic hash: `69c5c5deea528a196b7b781e83c43186ab11e67e74a31071e40a91123361727f`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
现在基于 AGENTS.md、docs/ 和 templates/，实现 Agent GD Studio 的最小客户旅程原型。

本轮目标：
做一个本地可运行的最小原型，验证客户从“输入游戏想法”到“生成第一个可执行任务包”的流程。

本轮不是实现完整产品。
本轮不是实现真实多 agent 编排。
本轮不是接入真实 LLM。
本轮不是开发游戏。
本轮不是做复杂 UI。

本轮允许修改或创建：
- src/**
- output/**
- README.md
- package.json
- tsconfig.json
- vite.config.ts 或其他必要的最小运行配置
- tests/** 如果项目已有测试结构

本轮禁止修改：
- AGENTS.md，除非发现明显路径错误
- docs/**，除非发现模板引用路径错误
- templates/**，除非发现模板无法被程序读取
- 任何游戏项目代码
- 任何外部 API 接入
- 任何真实 agent 调度系统

如果你认为必须修改 docs 或 templates，请先在计划中说明原因，只做最小必要修改。

请先检查当前项目结构，然后实现一个最小 CLI 原型。 
如果项目已经是 Web 项目，可以实现简单 Web 页面；如果没有明确前端框架，优先实现 CLI，因为 CLI 更小、更稳定。

# 1. 用户流程

CLI 至少支持以下流程：

1. 用户输入一句游戏想法。
 示例：
 “我想做一个像杀戮尖塔的卡牌游戏，但加入宠物养成。”

2. 系统读取：
 - AGENTS.md
 - docs/GATES.md
 - docs/CLIENT_JOURNEY.md
 - templates/CLARIFICATION_TEMPLATE.md
 - templates/PROJECT_BRIEF_TEMPLATE.md
 - templates/SCOPE_TEMPLATE.md
 - templates/MILESTONE_TEMPLATE.md
 - templates/TASK_TEMPLATE.md

3. 系统判断该想法是否可直接进入开发。
 默认规则：
 - 如果缺少核心循环、MVP 范围、目标平台、输入方式、参考游戏借鉴点、验收标准，则判定为 Not executable。
 - Not executable 时不得生成开发代码。
 - Not executable 时必须生成澄清问题。

4. 系统生成 5-8 个澄清问题。
 问题必须尽量是选择题或范围题。
 问题必须覆盖：
 - 参考游戏具体借鉴点
 - 核心循环
 - MVP 范围
 - 目标平台
 - 输入方式
 - 战斗或主要玩法方式
 - 第一版明确不做什么

5. 用户回答这些问题。

6. 系统根据用户回答生成以下文件：
 - output/project_brief.md
 - output/scope.md
 - output/milestone_plan.md
 - output/tasks/TASK-001.md
 - output/decision_log.md

7. 系统最后输出：
 - 当前项目是否可进入开发
 - 如果不可进入开发，说明缺少什么
 - 如果可进入下一步，说明 TASK-001 是什么
 - 明确提醒：本轮没有生成游戏代码

# 2. 实现要求

请实现确定性逻辑，不要接入 OpenAI API 或其他 LLM。

可以使用简单规则、关键词检测、模板填充、命令行交互来模拟流程。

例如：
- 检测用户是否提到“像/类似/参考”
- 检测是否提到平台：PC、Web、手机、Steam、iOS、Android
- 检测是否提到玩法类型：卡牌、动作、建造、生存、RPG、塔防、解谜等
- 如果缺少某项，就生成对应澄清问题
- 用户回答后，把回答写入对应 artifacts

请优先保证：
- 流程正确
- 输出文件清晰
- 代码简单
- 容易扩展
- 不做过度工程

# 3. 建议文件结构

如果当前项目没有更合适的结构，可以使用：

src/
 cli.ts
 core/
 artifactWriter.ts
 clarification.ts
 executableCheck.ts
 projectBuilder.ts
 taskBuilder.ts
 templateLoader.ts
 types.ts

output/
 tasks/

# 4. 核心模块要求

## executableCheck

输入：
- rawIdea: string
- optionalAnswers?: object

输出：
- executable: boolean
- missing: string[]
- reasons: string[]

判断至少覆盖：
- game_type
- reference_borrowing
- core_loop
- platform
- input_method
- mvp_scope
- non_goals
- acceptance_criteria

## clarification

输入：
- missing: string[]
- rawIdea: string

输出：
- questions: ClarificationQuestion[]

ClarificationQuestion 至少包含：
- id
- question
- type: single_choice | multi_choice | short_text
- options
- why_it_matters

## projectBuilder

输入：
- rawIdea
- answers

输出：
- projectBrief markdown
- scope markdown
- milestonePlan markdown
- decisionLog markdown

## taskBuilder

输入：
- projectBrief
- scope
- milestonePlan
- answers

输出：
- TASK-001 markdown

TASK-001 必须符合 templates/TASK_TEMPLATE.md 的字段结构。

TASK-001 的默认目标应该是：
“Create the smallest playable prototype shell for the confirmed MVP direction.”

但它不能实现游戏代码，只是生成未来给执行 agent 的任务包。

# 5. CLI 体验要求

运行方式可以是：

npm run gd:init

或者：

npm run start

CLI 交互示例：

Agent GD Studio
Describe your game idea:
> 我想做一个像杀戮尖塔的卡牌游戏，但加入宠物养成。

Status: Not executable yet.
Reason:
- Reference game is mentioned but borrowable mechanics are unclear.
- MVP scope is missing.
- Platform is missing.
- Input method is missing.
- Acceptance criteria are missing.

Please answer these questions:

1. When you say “like Slay the Spire”, what should be borrowed?
 A. Turn-based card combat
 B. Map route selection
 C. Relic system
 D. Deck-building progression
 E. Random events

...

After answering, the CLI writes artifacts to output/.

# 6. Tests or verification

如果项目已有测试框架，请添加最小测试覆盖：
- executableCheck detects missing fields
- clarification generates questions for missing fields
- taskBuilder outputs required sections

如果没有测试框架，不要引入复杂测试系统。 
可以添加一个简单脚本：

npm run gd:demo

它使用固定示例输入，自动生成 output/ artifacts，方便验证。

# 7. README 更新

请更新 README.md，加入：

- Agent GD Studio 是什么
- 当前原型能做什么
- 如何运行
- 输出文件在哪里
- 当前限制
- 下一步计划

必须明确写出当前限制：
- 不接入真实 LLM
- 不执行游戏代码开发
- 不是真实多 agent 编排
- 只验证客户旅程和 artifact 生成链路

# 8. 完成后输出

完成后请输出：

1. 你实现了什么
2. 创建或修改了哪些文件
3. 如何运行 demo
4. 生成的 artifacts 在哪里
5. 当前原型有哪些限制
6. 下一步建议

重要：
本轮不要实现游戏代码。
本轮不要接入外部 API。
本轮不要把 mock agent 做成复杂框架。
本轮只验证客户旅程。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
