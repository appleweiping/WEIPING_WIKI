---
title: PLEASE IMPLEMENT THIS PLAN -
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - wiki-ingest
source_pages:
  - codex-prompt-corpus
---

# PLEASE IMPLEMENT THIS PLAN:

## Metadata

- Stable ID: `codex-user-prompt:797e551aa4577a62`
- Source kind: `codex-session-user`
- Category: `wiki-ingest`
- Timestamp: `2026-05-16T14:05:39.255Z`
- Semantic hash: `797e551aa4577a62bb3337f79d2ced41ed55ea1a4b2c4142ed6028209a9c655d`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# 前端项目框架 Corpus 纠偏计划

## Summary
- 把现有 `frontend-frameworks-public` 从“热门 UI 框架列表”重构成“可迁移的前端项目外壳 / 文档站 / 应用框架语料库”。
- 保留 React/Vue/Svelte 等已抓内容，但降级为 `ui-runtime` / `dependency-substrate` 层；把 Quartz 这类“点进去就能知道怎么搭项目”的框架提升为主轴。
- v1 点击体验采用“wiki 分类摘要 + GitHub/官网/demo/docs/release 外链导航”，不做 iframe 或全文镜像，保证稳定、可定时更新、agent 也能快速复用。

## Key Changes
- 更新 [`D:\Research\vipin's knowledgebase\raw\frontend-frameworks-public\registry.json`](D:\Research\vipin's%20knowledgebase\raw\frontend-frameworks-public\registry.json) 的分类模型：
 - 新增主类：`site-framework`、`docs-framework`、`knowledge-site-framework`、`app-framework`、`static-site-generator`、`build-tooling`、`ui-runtime`、`component-system`、`starter-template`。
 - 新增字段：`reuse_profile`、`project_shell_score`、`recommended_use_cases`、`official_demo_url`、`docs_url`、`starter_or_template_paths`、`agent_reuse_notes`。
 - 稳定 ID 保持兼容：`framework:<slug>`、`github:<owner>/<repo>`、`github-release:<owner>/<repo>:<tag>`。
- 扩展首批 registry，主轴覆盖：
 - 文档/知识站：Quartz `jackyzha0/quartz`、Docusaurus `facebook/docusaurus`、VitePress `vuejs/vitepress`、Nextra `shuding/nextra`、Starlight `withastro/starlight`。
 - 内容/站点框架：Astro `withastro/astro`、Next.js `vercel/next.js`、Nuxt `nuxt/nuxt`、SvelteKit `sveltejs/kit`、Remix/React Router `remix-run/react-router`。
 - 工程外壳/构建层：Vite `vitejs/vite`、Nitro canonical `nitrojs/nitro`。
 - 底层 UI/runtime：React、Vue、Angular、Svelte、Solid、Qwik 保留，但页面明确标注“通常不是完整项目外壳”。
- 更新 [`D:\Research\vipin's knowledgebase\scripts\ingest-frontend-frameworks-public.ps1`](D:\Research\vipin's%20knowledgebase\scripts\ingest-frontend-frameworks-public.ps1)：
 - README/release 摘要优先抽取“怎么建项目、目录结构、插件、主题、路由、内容系统、部署、迁移、模板”。
 - repo 页面增加“可复用入口”：官网、GitHub、docs、examples、starter/templates、latest release。
 - 候选发现从“框架关键词”改为“可迁移项目外壳关键词”：`docs`、`site generator`、`starter`、`template`、`theme`、`content`、`markdown`、`ssg`、`app framework`。
- 重写 wiki 导航：
 - [`D:\Research\vipin's knowledgebase\wiki\topics\frontend-frameworks-public.md`](D:\Research\vipin's%20knowledgebase\wiki\topics\frontend-frameworks-public.md) 改成“选型入口”：知识站/文档站/应用外壳/构建工具/底层 runtime 分区。
 - 新增或更新分析页：`frontend-project-shell-taxonomy` 和 `frontend-framework-reuse-map`，重点回答“什么时候把它迁移到我的项目里”。
 - 自动化 prompt 改口径，并继续固定 `model = "gpt-5.5"`、`reasoning_effort = "medium"`。

## Test Plan
- 运行 dry-run：确认新 registry 至少覆盖 Quartz、Docusaurus、VitePress、Nextra、Starlight、Astro、Next、Nuxt、SvelteKit、Remix、Vite、Nitro。
- 真实 ingest 后检查：
 - hub 能从“我要做 wiki/docs/site/app”一路点到框架、repo、docs/demo、release。
 - Quartz 页面明确说明 vipin wiki 当前站点层使用 Quartz v4，且链接到本仓库 site 构建说明。
 - React/Vue 等页面不再被误当作完整项目外壳，而是标成底层 runtime。
- 验证命令：
 - `scripts/wiki-catalog.ps1`
 - `scripts/wiki-lint.ps1`
 - `git diff --check`
 - manifest duplicate stable ID 检查。
- 提交边界：只 stage 前端框架 corpus、wiki index/log/catalog、ingest 脚本和 automation/memory 相关变更；继续忽略 `GetPdf.pdf`。

## Assumptions
- “热门前端框架”默认解释为“可直接启发/迁移到新项目的前端项目框架”，不是单纯 UI runtime 排行榜。
- v1 不嵌入外站交互页面；用稳定外链、摘要、分类、release idea 和 agent reuse notes 支撑点击与复用。
- 现有已提交 corpus 不删除，而是纠偏分层，避免丢失已抓 GitHub/release 证据。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
