---
name: memory-review
description: |
  Sonnet 在做 review 时自动检查并补写遗漏的 memory。
  作为最后防线，确保所有重要事件都被记录。
trigger: |
  当 Sonnet 被要求 review PR、review code、或 review 实验结果时自动触发。
  也可以手动调用: /memory-review
---

# Memory Review Skill (Sonnet 兜底补写)

## 目的

其他 agent 可能忘记写 memory。Sonnet 在做 review 时，额外检查本次变更涉及的重要事件是否已记录，如果没有则补写。

## 执行步骤

### Phase 1: 收集未记录事件

1. 查看本次 review 涉及的变更（git diff, PR description, 或用户描述）
2. 调用 `memory_smart_search` 搜索相关主题，看是否已有记录
3. 识别以下未记录的事件：
   - 实验结果（有 report.json 但没有对应 memory）
   - Bug 修复（有 fix commit 但没有 lesson）
   - 配置变更（有 diff 但没有 fact 记录）
   - 决策（代码里选了 A 不选 B，但没有 decision 记录）

### Phase 2: 补写

对每个未记录事件：

1. **实验结果** → `memory_save(type=workflow, content=结果摘要)`
2. **Bug/踩坑** → `memory_lesson_save(content=问题+根因+修复)`
3. **决策** → 写 markdown 到 `D:\research\Vipin's Knowledgebase\memory\decisions\`
4. **状态变更** → 更新对应 `facts/` 文件

### Phase 3: 报告

输出审计结果：
```
[MEMORY-AUDIT] Reviewed: <变更描述>
[MEMORY-AUDIT] Found N unrecorded items:
  1. <item> → wrote to <location>
  2. <item> → wrote to <location>
[MEMORY-AUDIT] All items recorded.
```

## 判断标准

**需要补写的：**
- 实验跑完了但 memory 里没有结果数字
- 代码改了重要配置但没记录旧值→新值
- 遇到了报错并修复了但没有 lesson
- 做了架构/方法选择但没有 decision

**不需要补写的：**
- 纯格式化/lint 修改
- 已经在 memory 里有记录的
- 信息完全在 git commit message 里且不需要跨 session 记忆的

## 注意事项

- 补写时标注 `agent: sonnet-review` 以区分来源
- 不要重复写已有的 memory（先搜再写）
- 保持简洁，一个事件一条 memory，不要合并
