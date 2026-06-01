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

> [!WARNING]
> Historical Agent Hub references on this page are deprecated. Current partner coordination uses agentmemory signals/actions, git state, and explicit context packs.

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

If an external run aborts with text like `exceeded retry limit, last status: 429 Too Many Requests`, treat it as an upstream rate-limit/retry-exhaustion condition. It is not evidence that `cc` should be pointed at a proxy port instead of PixelCat's local API.

## Fix Path

For `upstream_credentials_disabled`:

1. Open the PixelCat panel at the visible app, not Codex.
2. Fix account/credential availability in PixelCat or ccmax.
3. Try TUN mode, a PixelCat process-level proxy, or another IP/exit node if the panel suggests a network/IP issue.
4. Rerun `.\scripts\Test-LocalCcPartner.ps1`.
5. Only after `api_ok`, retry Opus/Sonnet/Haiku partner calls.

## No-TUN IP Change Options

INFERRED: It is possible to change PixelCat's upstream exit IP without using the provider's virtual VPN/TUN app, but only if there is a real trusted exit node available. A local config change alone cannot create a new public IP.

Recommended routing shape:

```text
cc.cmd -> PixelCat local API on 127.0.0.1:8990 -> trusted outbound proxy / SSH tunnel / hotspot / WARP -> ccmax
```

Do not replace the `cc`/PixelCat local API address with a proxy port such as `127.0.0.1:7897`. The `8990` port is where `cc.cmd` talks to PixelCat. Ports such as `7897`, `7898`, or other local proxy ports are only candidates for PixelCat's outbound `proxyUrl` or for a system-level route.

Practical non-TUN choices:

- Self-owned VPS SSH dynamic forwarding: start a local SOCKS proxy such as `ssh -N -D 127.0.0.1:7898 user@vps-host`, then configure PixelCat's outbound proxy to the local SOCKS endpoint if PixelCat supports SOCKS. If PixelCat only accepts HTTP proxies, put a local HTTP-to-SOCKS bridge in front of it.
- Trusted HTTP/SOCKS proxy: configure PixelCat's outbound proxy URL to that proxy, then verify the public IP changes before retrying `cc`.
- Different physical network: switch to a mobile hotspot, another Wi-Fi, or another router exit and rerun the health check.
- WARP or similar outbound route: acceptable if it provides a changed exit path, but it may still install a network adapter; treat it as an exit-node option, not as changing the `cc` base URL.

Verification order:

1. Confirm the proxy itself changes public IP with a command such as `curl.exe --proxy http://127.0.0.1:PORT https://api.ipify.org`.
2. Configure PixelCat outbound proxy only after the proxy exit differs from the direct exit.
3. Restart PixelCat if required.
4. Run `.\scripts\Test-LocalCcPartner.ps1`.

Safety note: avoid random free proxies for this path. Even when HTTPS protects upstream content, the proxy still sees timing, destination, and account-adjacent traffic patterns, and a malicious proxy can cause confusing failures.

## 2026-05-18 Binary Refresh Result

EXTRACTED: Replacing `D:\devtools\pixelcat-app.exe` with the 2026-05-18 `PixelCat-beta-1029da-Windows-x64.zip` binary succeeded and kept the port path alive.

EXTRACTED: The post-refresh health check still returned `upstream_credentials_disabled` with HTTP 502.

INFERRED: When this exact status persists after a binary refresh, the remaining blocker is upstream credential/account/network state rather than the local PixelCat executable.

## 2026-05-18 TUN / Exit-Node Attempt Result

EXTRACTED: Clash Verge was installed and could launch `verge-mihomo.exe` with a local mixed proxy on `127.0.0.1:7897`, but `profiles.yaml` had `current: null` and only empty Merge/Script profile stubs.

EXTRACTED: PixelCat's panel still showing `地址: http://127.0.0.1:8990` is expected. That field is PixelCat's local API listening endpoint for `cc.cmd` and OpenCode, not the upstream proxy/exit-node setting.

EXTRACTED: Direct IP and proxied IP were both `217.149.131.41`; the local proxy did not provide a different exit node.

EXTRACTED: Temporarily setting PixelCat `proxyUrl` to `http://127.0.0.1:7897` and restarting PixelCat did not change the health-check result: `upstream_credentials_disabled` with HTTP 502.

EXTRACTED: Attempts to force Clash Verge TUN through config files were overwritten back to disabled by the app, no Wintun/Clash virtual adapter appeared, and no TUN startup log was observed.

EXTRACTED: The temporary PixelCat proxy setting and Clash TUN config change were restored after testing.

INFERRED: The panel suggestion still makes sense, but this machine currently lacks an active Clash profile / real exit node. The next practical fix requires the user to select or add a working proxy/VPN profile in Clash/VPN UI, or connect a real VPN, then rerun `.\scripts\Test-LocalCcPartner.ps1`.

INFERRED: The desired routing shape is `cc.cmd -> PixelCat on 127.0.0.1:8990 -> optional outbound proxy/TUN such as 127.0.0.1:7897 -> ccmax`. Seeing `8990` in the PixelCat panel does not prove that the outbound proxy is unused; the proof is whether `proxyUrl` is set, TUN is actually active, and the public exit IP changes.

## Agent Behavior

Future agents should not keep retrying `cc.cmd` when the health check reports `upstream_credentials_disabled`. They should state the limitation and fill the Opus/Sonnet/Haiku collaboration slots with Codex parallel selves / `分身` by default when the task still benefits from parallel review or bounded exploration. DeepSeek Pro remains useful for translation, summarization, classification, and bulk drafts when appropriate and available, but it is not the automatic replacement for every CC-family role.

Historical note: Agent Hub was later retired. The current equivalent guard is the PixelCat/CC preflight plus agentmemory-based coordination; do not revive Agent Hub daemon dispatch for this runbook.

## Related

- [[local-cc-sidecar-agent-workflow]]
- [[agent-hub-mcp-server]]
- [[2026-05-17-opencode-cc-pixelcat-setup]]
