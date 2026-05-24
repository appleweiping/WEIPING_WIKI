---
title: OpenHands Local GUI 升级与本机启动
date: 2026-05-22
tags: [openhands, local-gui, docker, llm-profiles, infrastructure, session]
---

## Summary
- OpenHands 主仓库已从 `15716df79` 升级到 `3515cb085`。
- 本机已成功构建并启动官方 Local GUI / Web UI（Docker 路线）。
- GUI 设置已写入 `D:\devtools\openhands\home\settings.json`。
- 已预置双模型配置：`claude-opus-4-7` 与 `gpt55`，默认激活 `claude-opus-4-7`。
- `http://127.0.0.1:3000/api/v1/settings` 返回 200，`llm_api_key_set=true`，`llm_profiles` 正常加载。

## Key Findings
- 官方当前产品拆分为三条线：主仓库提供 Local GUI/Web UI；官方 CLI 已拆到 `OpenHands-CLI` 独立仓库；Cloud GUI 为托管版。
- 当前机器最稳的新版本地运行方式是 Docker Local GUI，而不是 Windows 原生 `make run`。
- `C:\Users\admin\.openhands` 实际是指向 `D:\devtools\openhands\home` 的 junction，因此相关持久化配置需要按 D 盘规则管理。

## Current Limitation
- 当前 Local GUI 尚未接入 `agentmemory` MCP。
- 原因：现有 `agentmemory` 接法依赖 Windows 本机 stdio bridge（Node + standalone.mjs），容器化 OpenHands 不能直接调用该 Windows 路径。
- 后续若要打通 memory，推荐路线是：
  1. 将 `agentmemory` 暴露为 OpenHands 可直连的远程 MCP（HTTP/SSE）；或
  2. 改为 WSL / 原生主机模式运行新版 OpenHands，再复用本机 stdio MCP。
