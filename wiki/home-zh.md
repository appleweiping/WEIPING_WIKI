---
title: Vipin Wiki 中文
type: overview
status: active
created: 2026-05-10
updated: 2026-05-10
tags:
  - wiki
  - overview
  - zh
cssclasses:
  - dashboard
---

# Vipin Wiki

这是一个面向快速回答、慢速沉淀、科研构思和项目记忆的知识工作台。

**语言:** [English](../) · 中文 · [日本語](../ja/)

> [!tip] 从这里开始
> 按 `Ctrl+K` 或 `/` 搜索整个公开 wiki。用右侧 graph 和 backlinks 进入相关页面，不需要从目录一页页翻。

## 工作入口

| 通道 | 适合做什么 | 入口 |
| --- | --- | --- |
| 快速回答 | 先从维护好的页面回答，再决定是否慢速 ingest。 | [[index|Catalog]], [[queries-home]], [[local-project-roots]] |
| 科研 | 重新框定项目，检查证据边界，寻找更强机制。 | [[research-projects]], [[research-ideation-policy]], [[2026-05-10-vipin-research-project-map]] |
| 项目定位 | 按内容性质定位本地项目根目录，不把文件夹复制进 wiki。 | [[local-project-roots]], [[weipingyan-portfolio]], [[undergraduate-projects-netherlands]] |
| 持久沉淀 | 把可复用知识保存回 wiki。 | [[overview]], [[log]], [[synthesis-home]] |

## 活跃科研地图

- [[uncertainty]] - 面向 LLM 推荐的任务驱动校准不确定性。
- [[truce-rec]] - 带严格证据门控的不确定性感知生成式推荐。
- [[tgl-rec]] - 聚焦下一需求转移的 temporal graph-to-language 推荐。
- [[analog-agent]] - 面向 AI4EDA 的分层模拟电路设计 agent。
- [[donebench]] - 面向工具使用 agent 的 specification grounding benchmark。
- [[uncertaintyprotein-ai4s]] - 反馈分布偏移下的 AI4S 蛋白优化项目。
- [[protein-optimization-feedback-shift]] - 闭环蛋白序列优化中的不确定性概念页。

## 常用入口

| 我想要... | 打开 |
| --- | --- |
| 查看全部公开页面 | [[index|Catalog]] |
| 继续查看已保存问答 | [[queries-home]] |
| 浏览主题集群 | [[topics-home]] |
| 看权衡和对比 | [[comparisons-home]] |
| 读长期综合页面 | [[synthesis-home]] |
| 查看最近维护记录 | [[log]] |
| 理解仓库结构 | [[overview]] |

## 最近沉淀的回答

- [[2026-05-08-which-umn-meal-plan-to-choose]]
- [[2026-05-08-how-to-choose-umn-apartment-vs-residence-hall-for-private-bedroom]]
- [[2026-05-08-how-to-integrate-venus-basestation-with-team-gitlab]]
- [[2026-05-05-how-to-solve-oauth-rt-rbac-security-quiz]]
- [[2026-05-05-how-to-understand-quantization-and-bit-rate]]

## 当前问题

- 不确定性如何真正改善决策，而不只是改善校准指标？
- 哪个科研项目应该激进重构，而不是继续局部打磨？
- 哪些顶会项目、开源系统或 benchmark 值得吸收经验？
- 哪些重复出现的课程/项目问题应该变成稳定 topic 页面？
- 哪些公开页面是有用但过时的，哪些低价值页面应该提出删除方案？

## 操作规则

- 先快答，再慢速沉淀。
- 公开 `wiki/` 是网站来源；private/raw 层不进入公开构建。
- 对外部本地项目做当前状态判断前，先重新扫描。
- 当项目或科研问题比较抽象/general 时，向外看主流 GitHub 项目、顶会论文项目和 benchmark，吸收经验但不抄袭。
- 删除任何信息前必须先征得用户明确同意；有用的旧信息优先标注、归档或合并。

## 网站机制

公开网站由 Quartz 从维护好的 Markdown wiki 构建。它保留 wikilinks、搜索、backlinks、tags 和 graph navigation，同时排除原始私有材料。
