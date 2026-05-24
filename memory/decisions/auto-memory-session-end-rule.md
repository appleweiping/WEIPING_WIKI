---
title: "强制规则：每次 session 结束前必须自动写 memory"
type: decision
created: 2026-05-24T12:00:00+08:00
updated: 2026-05-24T12:00:00+08:00
agent: opus
tags: [memory, hard-rule, permanent, all-agents, critical, auto-memory]
related: [memory-write-policy.md, realtime-doc-update-rule.md, mandatory-step-update.md]
---

# 强制规则：每次 session 结束前必须自动写 memory

**生效时间**: 2026-05-24，永久有效，所有 agent 必须遵守。

## 规则

**每个 agent 在 session 结束前（停下来之前），必须自动写 memory。不需要用户提醒，不需要用户要求。**

这是硬规则，不是建议。

## 具体要求

### 1. 每步完成后立即写（不要攒到最后）

| 做了什么 | 立即写什么 | 写到哪里 |
|---------|-----------|---------|
| 完成一个功能/模块 | 功能描述 + 关键决策 + 文件路径 | CC memory 或 markdown facts/ |
| 修了一个 bug | 错误信息 + 根因 + 修复方法 | agentmemory lesson_save |
| 做了架构决策 | 决策内容 + 原因 + 影响 | markdown decisions/ |
| 用户表达偏好/规则 | 规则原文 + 适用范围 | markdown preferences/ |
| Session 结束 | 做了什么 + 结论 + 下一步 | markdown sessions/YYYY-MM-DD_slug.md |

### 2. Session 结束前的 checklist（每次都要做）

在停下来之前，必须确认：
- [ ] 今天做的所有重要工作都写进了 CC memory (MEMORY.md + 对应 .md 文件)
- [ ] 今天做的所有重要工作都写进了 shared markdown memory (D:\research\Vipin's Knowledgebase\memory\)
- [ ] 所有修改都已 commit + push 到对应 GitHub repo
- [ ] 如果有新项目/重大更新，INDEX.md 已更新

### 3. 写什么

**写进 CC memory** (C:\Users\admin\.claude\projects\C--Users-admin\memory\):
- 项目状态更新 (project_*.md)
- 新功能/模块完成 (project_*.md)
- 重要决策 (feedback_*.md)

**写进 shared markdown memory** (D:\research\Vipin's Knowledgebase\memory\):
- 科研项目状态 (facts/)
- 架构决策 (decisions/)
- 经验教训 (lessons/)
- 用户偏好 (preferences/)
- Session 总结 (sessions/)

**写进 agentmemory MCP**:
- 经验教训 (memory_lesson_save)
- 重要发现 (memory_save)

### 4. 不写的后果

不写 memory = 下次 session 从零开始，浪费时间，重复工作，用户体验差。
这是对用户的不尊重。

## 为什么这条规则存在

用户在 2026-05-24 明确要求：
> "以上全部做完后，你让所有agent以后都记住，从开始到停下来最后都要自动的写memory并让所有agent都知道。"

这是用户的明确指令，永久生效。
