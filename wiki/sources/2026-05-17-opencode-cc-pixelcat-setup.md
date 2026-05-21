---
title: OpenCode, Claude Code, and PixelCat Local Setup Session
type: source
status: active
created: 2026-05-17
updated: 2026-05-18
tags:
  - source
  - local-tools
  - coding-agent
  - opencode
  - claude-code
  - pixelcat
source_files: []
source_pages:
  - local-cc-sidecar-agent-workflow
---

# OpenCode, Claude Code, and PixelCat Local Setup Session

## Provenance

Origin: chat session plus local smoke tests on 2026-05-17.

The user wanted OpenCode and Claude Code installed on the D drive, integrated with PixelCat, and made usable from VSCode without treating the setup as a toy collection. A user-provided tutorial page and local chat/video material guided the setup, but private chat/video contents are not copied into this public wiki.

Tutorial references:

- `https://ai.moono.vip/opencode-tutorial.html?v=2`
- `https://ai.moono.vip/claude-install-tutorial.html`

## Extracted Setup Facts

- EXTRACTED: Current OpenCode and Claude Code runtime files live under `D:\devtools\`.
- EXTRACTED: Current convenience entrypoints: `D:\devtools\opencode.cmd` and `D:\devtools\cc.cmd`.
- EXTRACTED: Current setup helper: `D:\devtools\setup-env.ps1`.
- EXTRACTED: Current runtime folders include `D:\devtools\node`, `D:\devtools\npm-global`, and `D:\devtools\npm-global\node_modules\.bin`.
- EXTRACTED: PixelCat local proxy is launched via `D:\devtools\pixelcat-app.exe` and listens on `127.0.0.1:8990`.
- EXTRACTED: The user later clarified, with a PixelCat management-panel screenshot, that the PixelCat panel must be open for the local `cc` family tools to work.
- EXTRACTED: OpenCode was configured to use the PixelCat-compatible local API endpoint and a default Claude Sonnet model.
- EXTRACTED: VSCode had the PixelCat OpenCode extension and Claude Code extension installed.
- EXTRACTED: Earlier setup notes and some old docs used `D:\cc\...`; live checks on 2026-05-18 found `D:\cc` absent and `D:\devtools` active.

## Smoke Tests

- EXTRACTED: `D:\devtools\opencode.cmd --version` returned `1.15.3`.
- EXTRACTED: `D:\devtools\cc.cmd --version` returned `2.1.143 (Claude Code)`.
- EXTRACTED: Earlier OpenCode and `cc` smoke tests returned `OK` while PixelCat upstream credentials were healthy.
- EXTRACTED: `D:\devtools\cc.cmd` successfully ran a read-only `claude-opus-4-7` diff-review partner prompt for the wiki update and reported `NO BLOCKERS`.
- EXTRACTED: During the PixelCat preflight-rule update, `127.0.0.1:8990` was observed listening locally.
- EXTRACTED: On 2026-05-18, `D:\devtools\cc.cmd --version` returned `2.1.143 (Claude Code)` and `D:\devtools\opencode.cmd --version` returned `1.15.3`.
- EXTRACTED: On 2026-05-18, `scripts/Test-LocalCcPartner.ps1` confirmed the `cc` entrypoint and PixelCat port but reported `upstream_credentials_disabled` because a minimal `/v1/messages` probe returned HTTP 502 from PixelCat/ccmax with all upstream credentials disabled (`0/1`).

## PixelCat Binary Refresh 2026-05-18

- EXTRACTED: User downloaded `C:\Users\admin\Downloads\PixelCat-beta-1029da-Windows-x64.zip` at 2026-05-18 12:27.
- EXTRACTED: The zip SHA256 was `BE91861C2CF1DCDDB28DB69559C18EF4EFC59E47B839E889A8371CA9583DEC37`.
- EXTRACTED: The zip contained `pixelcat-app.exe` and `bundle/nsis/PixelCat_2026.5.18_x64-setup.exe`; only `pixelcat-app.exe` was extracted and installed.
- EXTRACTED: Old `D:\devtools\pixelcat-app.exe` SHA256 was `459AD5803C3039A5E19CCBCC67EEEAB4DCCFFA6E0D28263B1E9BAB70BAED1F94`.
- EXTRACTED: Old exe was backed up to `D:\devtools\pixelcat-app.exe.bak-20260518-123304`.
- EXTRACTED: New installed `D:\devtools\pixelcat-app.exe` SHA256 is `912D3FBDBF0E8BD72C2DE78A6C59C3E47C48280254AEAEC61B29001F073C005E`.
- EXTRACTED: After launching the refreshed binary, PixelCat listened on `127.0.0.1:8990`, but `scripts/Test-LocalCcPartner.ps1` still reported `upstream_credentials_disabled` with HTTP 502.
- INFERRED: The binary replacement succeeded and did not break the local executable/port path, but it did not resolve the upstream credential/network failure.

## PixelCat Network Workaround Attempt 2026-05-18

- EXTRACTED: Clash Verge was present at `C:\Program Files\Clash Verge\clash-verge.exe`.
- EXTRACTED: Launching Clash Verge started `verge-mihomo.exe` and a mixed local proxy on `127.0.0.1:7897`.
- EXTRACTED: PixelCat's displayed `地址: http://127.0.0.1:8990` is its local API listening address for clients, not the outbound proxy address.
- EXTRACTED: Clash Verge did not have an active real profile: `profiles.yaml` had `current: null`, with only empty Merge/Script stubs.
- EXTRACTED: Direct and proxied `api.ipify.org` calls returned the same public IP, so the local proxy did not change the exit node.
- EXTRACTED: Temporarily setting PixelCat `proxyUrl` to `http://127.0.0.1:7897` did not change the health-check result.
- EXTRACTED: Attempts to force TUN through Clash config were reverted by the app; no Wintun/Clash virtual adapter appeared.
- EXTRACTED: Temporary PixelCat and Clash config changes were restored after the attempt.
- INFERRED: A real IP/exit-node change still requires a working Clash profile or connected VPN chosen through the relevant UI. The expected chain is `cc.cmd -> PixelCat:8990 -> outbound proxy/TUN -> ccmax`.
- INFERRED: A provider VPN/TUN app is not strictly required if there is a trusted alternative exit, such as a self-owned VPS SSH dynamic proxy, trusted HTTP/SOCKS proxy, mobile hotspot, WARP-style route, or another physical network. The invariant is that `cc.cmd` still calls PixelCat on `127.0.0.1:8990`; only PixelCat's outbound path changes.

## Operational Meaning

INFERRED: The installation is usable as a local coding-agent runtime, not just a manually opened terminal tool, when PixelCat's upstream credentials are healthy. Future Codex sessions should call `D:\devtools\cc.cmd` directly for partner planning, review, debugging, and verification when the task merits multi-agent collaboration.

On 2026-05-17, the workflow was upgraded from a flexible sidecar rule into a strict three-role arrangement:

- Codex Coordinator: supervisor, integrator, file edits, validation, commits, pushes, and wiki memory.
- Opus Reviewer: `claude-opus-4-7` for deep code review, complex reasoning, architecture, hard debugging, and high-risk final audits.
- Sonnet Scanner: `claude-sonnet-4-6` for quick diff scans, test suggestions, documentation reading, and routine low-risk checks.

OpenCode remains an installed and smoke-tested tool. As of 2026-05-18, it has been promoted to a full CC-family fusion partner in the multi-agent collaboration system (see `AGENTS.md` § OpenCode Partner Policy).

The strict-role update was validated with real sidecar calls:

- EXTRACTED: `claude-sonnet-4-6` performed a read-only quick scan of the policy diff, found no credential or public/private leaks, and suggested tightening PixelCat dependency notes, lightweight exemption boundaries, and prompt authorization wording.
- EXTRACTED: `claude-opus-4-7` performed a read-only blocker review of the policy diff and reported `NO BLOCKERS`, with low-risk suggestions about role wording drift, Opus/Sonnet trigger precedence, and sidecar failure handling.

See [[local-cc-sidecar-agent-workflow]] for the reusable workflow.

## Additional API Endpoints (Non-PixelCat)

### Codex GPT-5.5 Direct Line (added 2026-05-20)

- Base URL: `https://ssvip.moono.vip/v1`
- API Key: configured locally only; do not publish the secret value.
- Use case: Direct OpenAI-compatible endpoint for GPT-5.5 (Codex). Bypasses PixelCat. Use when PixelCat quota is exhausted or for heavy Codex workloads.
- Compatible with: OpenCode custom provider, litellm, any OpenAI-compatible client.
- Note: This is a separate billing line from PixelCat/ccmax.

## Safety Notes

- Do not publish local auth tokens or provider secrets in wiki pages.
- Do not copy private chat/video contents into public wiki pages.
- Keep runtime packages, caches, and downloaded toolchains out of Git unless they are deliberate source files.
- If the PixelCat panel/proxy is not running, `cc` and OpenCode may fail even when the entrypoints exist.
- Future agents should try to launch `D:\devtools\pixelcat-app.exe` and re-check `127.0.0.1:8990` before reporting that `cc` is unavailable.
- A listening PixelCat port is not sufficient. Future agents should run `scripts/Test-LocalCcPartner.ps1` or make an equivalent minimal `/v1/messages` probe before counting Opus, Sonnet, or Haiku as available.
- If PixelCat returns HTTP 502 with all upstream credentials disabled (`0/1`), the local fix is not prompt editing or model-name changes. Repair PixelCat account/network state in the panel, try TUN mode or another IP/exit node, then rerun the health check.
- The hardcoded D-drive path and local proxy port are operational notes, not portable configuration; update the workflow if the local runtime moves.
- Do not publish screenshot-visible account details, API keys, balances, quota, or usage data from the PixelCat panel in public wiki pages.
