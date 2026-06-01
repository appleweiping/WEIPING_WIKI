---
title: "Hard rule: do not use local 8990 proxy for experiments"
date: 2026-05-28
tags: [infrastructure, experiments, api, proxy, hard-rule, all-agents, critical]
---

# Hard Rule: Do Not Use Local 8990 Proxy for Experiments

`127.0.0.1:8990` is the local Claude Code proxy. It must not be used for DoneBench or other experiment API calls.

For Claude/CC-related experiment calls, use only a user-approved remote OpenAI-compatible proxy endpoint and key. Do not store raw API keys in memory or logs.

On 2026-05-28, Codex killed local experiment caller processes spawned from Claude Code, including DoneBench `run-matrix`, ad hoc `litellm.completion` tests, and `run_claude_local.py`. The local 8990 proxy service itself was intentionally left running because it belongs to the CC local environment.

DoneBench project guard added on 2026-05-28:

- `D:\Research\DoneBench\configs\models.yaml` keeps `claude_opus_4_7_local` visible but disabled.
- `D:\Research\DoneBench\scripts\run_claude_local.py` is now a fail-fast guard that exits before any API call.
- `D:\Research\DoneBench\AGENTS.md` now tells future agents not to route DoneBench API-backed runs through the local Claude Code proxy.

Correction: do not put this rule in the global provider adapter, because that is too broad for normal API experiments. The guard should stay at the explicit local-proxy script/config/process level.
