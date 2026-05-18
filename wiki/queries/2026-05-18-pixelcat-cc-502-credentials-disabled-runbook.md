---
title: PixelCat CC 502 Credentials Disabled Runbook
type: query
status: active
created: 2026-05-18
updated: 2026-05-18
tags:
  - query
  - local-tools
  - pixelcat
  - claude-code
  - multi-agent
source_pages:
  - local-cc-sidecar-agent-workflow
  - agent-hub-mcp-server
  - 2026-05-17-opencode-cc-pixelcat-setup
---

# PixelCat CC 502 Credentials Disabled Runbook

## Short Answer

EXTRACTED: On 2026-05-18, PixelCat was running on `127.0.0.1:8990`, `D:\devtools\cc.cmd --version` returned `2.1.143 (Claude Code)`, but a minimal `/v1/messages` probe returned HTTP 502 because PixelCat/ccmax reported that all upstream credentials were disabled (`0/1`).

INFERRED: This is a PixelCat upstream credential/network problem, not a Claude Code installation problem, not a bad prompt, and not primarily a model-name problem.

## Fast Diagnosis

Run from the `vipin wiki` root:

```powershell
.\scripts\Test-LocalCcPartner.ps1
```

Interpretation:

- `api_ok`: Opus/Sonnet/Haiku through `D:\devtools\cc.cmd` can be used.
- `pixelcat_not_listening`: open PixelCat or rerun with `-LaunchIfMissing`.
- `upstream_credentials_disabled`: PixelCat is open, but the upstream credential pool is disabled.
- `local_auth_failed`: check the local PixelCat API key / `ANTHROPIC_AUTH_TOKEN` configuration.
- `rate_limited`: wait or reduce concurrent CC-family calls.

## Fix Path

For `upstream_credentials_disabled`:

1. Open the PixelCat panel at the visible app, not Codex.
2. Fix account/credential availability in PixelCat or ccmax.
3. Try TUN mode or another IP/exit node if the panel suggests a network/IP issue.
4. Rerun `.\scripts\Test-LocalCcPartner.ps1`.
5. Only after `api_ok`, retry Opus/Sonnet/Haiku partner calls.

## Agent Behavior

Future agents should not keep retrying `cc.cmd` when the health check reports `upstream_credentials_disabled`. They should state the limitation, continue Codex-only when risk is acceptable, or use non-CC partners such as DeepSeek Pro when appropriate and available.

Agent Hub has been patched so direct Sonnet/Haiku invocation and daemon Claude-family dispatch run a PixelCat upstream probe before waiting on `cc.cmd`.

## Related

- [[local-cc-sidecar-agent-workflow]]
- [[agent-hub-mcp-server]]
- [[2026-05-17-opencode-cc-pixelcat-setup]]
