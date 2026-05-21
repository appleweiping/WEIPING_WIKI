---
title: "GPT Image 2 图像生成 API 配置"
type: fact
created: 2026-05-21T19:30:00+08:00
updated: 2026-05-21T19:30:00+08:00
agent: claude
tags: [gpt-image-2, api, image-generation, all-agents, infrastructure]
related: [agent-cli-launch-config.md]
---

## 使用方式

所有 agent 通过 Agent Hub 调用图像生成：

**MCP 工具**: `hub_generate_image`
- prompt: 图像描述（详细）
- size: "1024x1024" | "1536x1024" | "1024x1536"
- quality: "low" | "medium" | "high"
- n: 生成数量 (1-4)

**HTTP API** (直接调用):
```
POST http://localhost:9800/generate-image
{"prompt": "...", "size": "1024x1024", "quality": "high", "n": 1}
```

## 配置

- Model: gpt-image-2
- Base URL: https://api.sbbbbbbbbb.xyz/v1
- 返回格式: base64 PNG

## 用途

- 论文 figure 生成
- 图表、示意图
- 项目插图
- 任何需要视觉内容的场景
