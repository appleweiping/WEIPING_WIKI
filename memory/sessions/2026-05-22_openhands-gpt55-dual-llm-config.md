---
title: OpenHands dual LLM config with gpt55
date: 2026-05-22
tags: [openhands, gpt55, llm-config, codex, agentmemory]
status: completed
---

# OpenHands dual LLM config with gpt55

OpenHands config `D:\research\openhands\config.toml` now preserves the default Claude route and adds a named GPT-5.5 route.

## Default route remains

```toml
[llm]
model = "claude-opus-4-7"
base_url = "http://127.0.0.1:8990"
api_key = "***SET***"

[llm.condenser]
model = "claude-haiku-4-5-20251001"
base_url = "http://127.0.0.1:8990"
api_key = "***SET***"
```

## Added route

```toml
[llm.gpt55]
model = "gpt-5.5"
base_url = "http://127.0.0.1:9100/v1"
api_key = "***SET***"
```

The `gpt55` key was copied from Codex local auth (`C:\Users\admin\.codex\auth.json`) without printing the secret.

## Usage

Default Claude-backed OpenHands:

```powershell
openhands
openhands chat -d D:\research
```

GPT-5.5-backed OpenHands:

```powershell
openhands chat -l gpt55 -d D:\research
openhands-chat -l gpt55 -d D:\research
```

Official one-shot mode with GPT-5.5:

```powershell
openhands -t "Task text" -l gpt55 -d D:\research -i 20
```

## Validation

- Rewrote `config.toml` as UTF-8 without BOM after PowerShell initially introduced BOM.
- Offline OpenHands config parse with `llm_config='gpt55'` selected:
  - model: `gpt-5.5`
  - base_url: `http://127.0.0.1:9100/v1`
  - api_key_set: true
- Live smoke succeeded:
  - command used direct `D:\devtools\openhands-chat.py --no-logo -l gpt55 ...`
  - stdout contained `GPT55_READY`
  - logs loaded and set 53 agentmemory MCP tools.
  - evidence files: `D:\devtools\openhands-gpt55-smoke-out.txt`, `D:\devtools\openhands-gpt55-smoke-err.txt`.

Backup of config before edit: `D:\research\openhands\config.toml.bak-20260522-gpt55`.