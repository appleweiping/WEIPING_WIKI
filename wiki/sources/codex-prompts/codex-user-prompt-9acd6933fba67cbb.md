---
title: 现在基于根目录 AGENTS.md，创建该项目的的制度层文档和模板。
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

# 现在基于根目录 AGENTS.md，创建该项目的的制度层文档和模板。

## Metadata

- Stable ID: `codex-user-prompt:9acd6933fba67cbb`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T12:58:18.139Z`
- Semantic hash: `9acd6933fba67cbbbcad48cac6b540749db59caa931d3e7e2761d2544c5ce9c3`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
现在基于根目录 AGENTS.md，创建该项目的的制度层文档和模板。 

本轮目标：
把 AGENTS.md 中定义的最高规则，拆解成可执行、可复用的 docs 和 templates。
本轮不是实现产品，不是写 UI，不是写 agent runtime，也不是写游戏代码。

本轮允许创建或修改：
- docs/AGENT_STUDIO_ORG.md
- docs/CLIENT_JOURNEY.md
- docs/GATES.md
- docs/ARTIFACTS.md
- docs/DECISION_RIGHTS.md
- docs/WORKFLOW.md
- templates/TASK_TEMPLATE.md
- templates/CLARIFICATION_TEMPLATE.md
- templates/QA_REPORT_TEMPLATE.md
- templates/PROJECT_BRIEF_TEMPLATE.md
- templates/SCOPE_TEMPLATE.md
- templates/MILESTONE_TEMPLATE.md
- templates/IMPLEMENTATION_REPORT_TEMPLATE.md

本轮禁止修改：
- src/**
- output/**
- 任何游戏代码
- 任何 agent runtime 代码
- package.json
- 构建配置
- 测试配置

如果某些目录不存在，可以创建 docs/ 和 templates/。
如果 AGENTS.md 中的信息与本 prompt 冲突，以 AGENTS.md 为准。
如果 AGENTS.md 缺少某个规则，请不要自行脑补成产品代码，只在相关文档中标记为“Needs confirmation”。

请完成以下内容：

# 1. docs/AGENT_STUDIO_ORG.md

定义 Agent GD Studio 的虚拟游戏工作室组织结构。

必须包含以下部门：

## Production Department
- Executive Producer Agent
- Game Director Agent
- Producer / PM Agent

## Product & Requirements Department
- Requirements Interviewer Agent
- Player Advocate Agent
- Product Scope Agent

## Research Department
- Reference Research Agent
- Mechanic Analyst Agent
- Feasibility Research Agent

## Game Design Department
- Core Gameplay Designer Agent
- Systems Designer Agent
- Level / Content Designer Agent
- UX Designer Agent
- Economy / Balance Designer Agent

## Technical Department
- Technical Director Agent
- Gameplay Programmer Agent
- UI Programmer Agent
- Tools Programmer Agent
- Codebase Steward Agent

## Presentation Department
- Art Direction Agent
- UI Visual Designer Agent
- Feedback / Juice Designer Agent
- Audio Designer Agent

## Quality Department
- Acceptance Criteria Agent
- QA Tester Agent
- Gameplay Evaluator Agent
- Regression Guardian Agent

## Knowledge Department
- Documentation Agent
- Memory / Context Agent

每个 agent 必须包含：
- Purpose
- Responsibilities
- Inputs
- Outputs
- Forbidden actions
- Decision rights
- Stop authority
- Owned artifacts

要求：
- 明确哪些 agent 是常驻核心 agent。
- 明确哪些 agent 是按需调用 agent。
- 明确客户不直接面对这些 agent，客户只面对统一的项目助手界面。

# 2. docs/CLIENT_JOURNEY.md

定义客户如何使用 Agent GD Studio。

客户侧必须只有 5 个阶段：

1. Submit Idea
2. Clarify Requirements
3. Confirm Plan
4. Track Development
5. Review & Accept

每个阶段必须写：
- What the customer sees
- What the customer provides
- What the system does internally
- Which agents are involved
- Which artifacts are created or updated
- What blocks the next step
- What the customer must confirm

必须强调：
- 客户不需要理解多 agent 架构。
- 客户不应该直接面对 20+ agent。
- 客户每次只需要做少量明确决策。
- 系统在需求不清时必须主动停止并反问。
- 系统不得用一句模糊想法直接生成完整游戏。

# 3. docs/GATES.md

定义阶段闸门。

必须包含：

## Concept Gate
## Scope Gate
## Game Design Gate
## Technical Gate
## Implementation Readiness Gate
## QA Gate
## Milestone Gate

每个 Gate 必须包含：
- Purpose
- Entry conditions
- Required artifacts
- Review agents
- Approval authority
- Blocking conditions
- Output if passed
- Output if blocked
- Customer confirmation required or not

要求：
- Implementation Readiness Gate 必须明确：没有 TASK-xxx.md 不得开发。
- QA Gate 必须明确：没有测试结果不得声明完成。
- Scope Gate 必须明确：如果需求过大，必须先缩小范围。
- Game Design Gate 必须明确：玩法任务必须先有核心循环、玩家操作、反馈、失败条件、奖励机制。
- Technical Gate 必须明确：涉及架构、数据结构、状态管理、存档、构建流程时必须先通过技术评审。

# 4. docs/ARTIFACTS.md

定义共享产物池。

至少包含以下 artifacts：

- project_brief.md
- scope.md
- references.md
- mechanic_analysis.md
- design_spec.md
- ux_flow.md
- tech_spec.md
- module_contracts.md
- data_schema.md
- milestone_plan.md
- tasks/TASK-xxx.md
- acceptance_tests.md
- qa_report.md
- implementation_report.md
- decision_log.md
- dev_log.md
- context_pack.md
- risk_register.md

每个 artifact 必须包含：
- Purpose
- Owner agent
- Created during which stage
- Updated during which stage
- Required before which gate
- Consumers
- Minimum required sections

必须强调：
If a decision matters later, it must be written into an artifact.

# 5. docs/DECISION_RIGHTS.md

定义决策权和阻塞权。

至少包含：
- 谁能批准项目定位
- 谁能批准 MVP 范围
- 谁能阻止需求不清的任务
- 谁能阻止范围过大的任务
- 谁能阻止偏离核心体验的设计
- 谁能阻止技术风险过高的任务
- 谁能阻止验收标准不清的任务
- 谁能阻止 QA 不通过的任务
- 哪些决策必须由客户确认

请用表格写清楚：
- Decision type
- Primary owner
- Required reviewers
- Customer confirmation required
- Artifact where decision is recorded

# 6. docs/WORKFLOW.md

定义真实工作流，不要写成简单串联流水线。

必须包含这些工作模式：

## Concept Review
参与 agent：
- Executive Producer
- Game Director
- Requirements Interviewer
- Player Advocate
- Reference Research
- Product Scope

产物：
- project_brief.md
- scope.md
- non_goals
- initial risks

## Prototype Planning
参与 agent：
- Game Director
- Core Gameplay Designer
- Systems Designer
- UX Designer
- Technical Director
- Acceptance Criteria
- Product Scope

产物：
- design_spec.md
- milestone_plan.md
- acceptance_tests.md
- risk_register.md

## Technical Design Review
参与 agent：
- Technical Director
- Gameplay Programmer
- UI Programmer
- Tools Programmer
- Codebase Steward
- QA Tester

产物：
- tech_spec.md
- module_contracts.md
- data_schema.md
- test_plan

## Implementation Readiness Review
参与 agent：
- Producer / PM
- Technical Director
- Acceptance Criteria
- QA Tester
- Memory / Context
- Relevant design agents

产物：
- tasks/TASK-xxx.md
- context_pack.md

## Implementation
参与 agent：
- Relevant programmer agent
- Codebase Steward
- Documentation Agent

产物：
- implementation_report.md
- dev_log.md

## QA & Gameplay Evaluation
参与 agent：
- QA Tester
- Gameplay Evaluator
- Regression Guardian
- Player Advocate

产物：
- qa_report.md
- playtest_notes
- known_issues

## Milestone Review
参与 agent：
- Executive Producer
- Game Director
- Producer / PM
- Product Scope
- QA Tester
- Documentation Agent

产物：
- milestone_review.md
- updated roadmap
- updated risk_register.md
- next task candidates

要求：
- 明确哪些工作可以并行。
- 明确哪些工作必须等待 gate 通过。
- 明确每个阶段失败时应该回退到哪里。
- 明确 Codex 不能因为流程复杂就跳过文档和 gate。

# 7. templates/TASK_TEMPLATE.md

创建 Codex 执行任务包模板。

必须包含：

- Task ID
- Title
- Status
- Requested by
- Approved by
- Related gate
- Goal
- Non-goals
- Background context
- Related artifacts
- Allowed files
- Forbidden files
- Dependencies
- Implementation requirements
- Acceptance criteria
- Automated test commands
- Manual test steps
- Risk notes
- Rollback plan
- Completion report format
- QA checklist

要求：
- 模板必须能直接复制成 tasks/TASK-001.md 使用。
- 明确如果任何关键字段缺失，执行 agent 必须停止。

# 8. templates/CLARIFICATION_TEMPLATE.md

创建需求澄清模板。

必须包含：
- Current understanding
- Why this is not executable yet
- Missing information
- Clarifying questions
- Suggested options
- Recommended next artifact
- What will not be done yet

要求：
- 问题优先使用选择题。
- 每轮最多 5-8 个关键问题。
- 问题必须影响后续实现。
- 禁止开放式长问卷。
- 禁止在客户未回答时自行假设关键需求。

# 9. templates/QA_REPORT_TEMPLATE.md

创建 QA 报告模板。

必须包含：
- Task ID
- Build / commit reference
- Test environment
- Engineering test results
- Functional test results
- Gameplay experience results
- Regression results
- Scope compliance
- Known issues
- Must-fix issues
- Nice-to-have improvements
- Final QA decision
- Next recommended action

QA decision 只能是：
- Pass
- Pass with issues
- Blocked
- Failed

# 10. templates/PROJECT_BRIEF_TEMPLATE.md

必须包含：
- Game concept
- One-sentence pitch
- Target player
- Core experience
- Reference games
- What to borrow
- What not to borrow
- Platform
- Input method
- MVP intent
- Non-goals
- Open questions

# 11. templates/SCOPE_TEMPLATE.md

必须包含：
- MVP must have
- Vertical slice should have
- Later version
- Explicitly out of scope
- Risky or unclear
- Customer confirmation required
- Scope change log

# 12. templates/MILESTONE_TEMPLATE.md

必须包含：
- Milestone name
- Goal
- Required artifacts
- Tasks
- Dependencies
- Acceptance criteria
- Risks
- Exit conditions
- Customer review requirement

# 13. templates/IMPLEMENTATION_REPORT_TEMPLATE.md

必须包含：
- Task ID
- Summary of changes
- Files changed
- Tests run
- Results
- Deviations from task package
- Issues encountered
- Follow-up needed
- Ready for QA or not

完成后请只输出：
1. 创建或修改了哪些文件
2. 每个文件的作用
3. 哪些内容仍然需要客户确认
4. 下一步建议，但不要开始下一步
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
