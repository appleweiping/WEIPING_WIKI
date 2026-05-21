---
title: "Agent Resources 技能与工具索引"
type: workflow
created: 2026-05-21T19:00:00+08:00
updated: 2026-05-21T19:00:00+08:00
agent: claude
tags: [skills, resources, tools, all-agents, permanent, infrastructure]
related: [agent-roles-and-skills.md, agent-cli-launch-config.md]
---

## 资源总目录

所有 agent 共享的技能、工具、参考资料位于 `D:\agent-resources\`。不要重复造轮子 — 先查这里。

## 技能集合 (D:\agent-resources\skills\)

| 集合 | 路径 | 用途 |
|------|------|------|
| **vipin** | skills/vipin/ | 个人定制技能（飞书、邮件、前端、论文编排、通信） |
| **anthropics** | skills/anthropics/ | Anthropic 官方技能（claude-api、mcp-builder、webapp-testing、pdf/docx/pptx） |
| **obra-superpowers** | skills/obra-superpowers/ | 高级工作流（brainstorming、parallel-agents、code-review、TDD、systematic-debugging） |
| **composio** | skills/composio/ | 1000+ SaaS 自动化连接器（按需查找） |
| **standalone** | skills/standalone/ | 独立技能（mattpocock、nuwa-skill、deepseek-mcp） |
| **context-engineering-kit** | skills/context-engineering-kit/ | 上下文工程（DDD、TDD、review、reflexion、kaizen） |
| **trailofbits** | skills/trailofbits/ | 安全审计技能 |

## 常用 Slash Commands (D:\agent-resources\slash-commands\)

| 命令 | 用途 |
|------|------|
| `create-pr` | 创建 PR 的标准流程 |
| `create-prd` | 生成产品需求文档 |
| `fix-github-issue` | 修复 GitHub issue 的标准流程 |
| `pr-review` | PR 审查流程 |
| `commit` | 标准 commit 流程 |
| `context-prime` | 上下文预加载 |
| `optimize` | 代码优化流程 |
| `testing_plan_integration` | 测试计划集成 |
| `todo` | 任务管理 |

## 参考仓库 (D:\agent-resources\repos\)

| 仓库 | 用途 |
|------|------|
| **awesome-claude-code** | Claude Code 最佳实践和技巧集合 |
| **awesome-claude-skills-composio** | Composio 技能集合 |
| **awesome-ai-agents** | AI agent 架构参考 |
| **context-engineering-kit** | 上下文工程方法论 |
| **obra-superpowers** | 高级 agent 工作流模式 |
| **claude-memory-kit** | 记忆系统参考实现 |
| **OpenHands** | OpenHands agent 框架源码 |
| **Auto-claude-code-research-in-sleep** | 自动化研究流程参考 |

## 参考文档 (D:\agent-resources\references\)

| 目录 | 内容 |
|------|------|
| **official-documentation/** | Claude Code 官方文档 |
| **claude.md-files/** | 优秀 CLAUDE.md 示例集合 |
| **slash-commands/** | Slash command 编写指南 |
| **workflows-knowledge-guides/** | 工作流知识指南 |

## 使用规则

1. **做任务前先查**: 如果任务涉及 PR、测试、调试、论文、自动化 — 先看 agent-resources 有没有现成技能
2. **不要重复造轮子**: obra-superpowers 里有 systematic-debugging、TDD、parallel-agents 等高质量工作流
3. **按需安装**: 不需要全部加载，找到合适的 skill 后按项目需要引用
4. **Vipin 技能优先**: `skills/vipin/` 是定制过的，优先使用
5. **科研用 ARIS**: 科研项目严格使用 ARIS 技能（.claude/skills/aris/ 和 .codex/skills/aris-*）
