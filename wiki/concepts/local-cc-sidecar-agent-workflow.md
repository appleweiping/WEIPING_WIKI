---
title: Local CC Partner Agent Workflow
type: concept
status: active
created: 2026-05-17
updated: 2026-05-18
tags:
  - agent-workflow
  - coding
  - multi-agent
  - claude-code
source_pages:
  - AGENTS.md
  - 2026-05-17-opencode-cc-pixelcat-setup.md
---

# Local CC Partner Agent Workflow

## Purpose

This workflow turns the local `cc` / Claude Code runtime into a strict threshold-based multi-agent coding system.

Codex acts as the supervisor and only writer. Opus and Sonnet act as read-only partners with bounded prompts. This follows a common supervisor/handoff pattern: one coordinator owns the task state and repository mutations, while specialist partners provide scoped review, scanning, or reasoning.

## Runtime

- EXTRACTED: Current Claude Code entrypoint: `D:\devtools\cc.cmd`.
- EXTRACTED: Current Node/npm runtime and global packages live under `D:\devtools\`, not the C drive.
- EXTRACTED: PixelCat provides the local model proxy on `127.0.0.1:8990`.
- EXTRACTED: PixelCat management panel executable: `D:\devtools\pixelcat-app.exe`.
- EXTRACTED: Verified Claude Code version: `2.1.143`.

OpenCode is installed and recorded in [[2026-05-17-opencode-cc-pixelcat-setup]], but it is not part of this multi-agent coding workflow.

## PixelCat Preflight

PixelCat is the required control plane for the local `cc` family setup. Before calling `D:\devtools\cc.cmd`, Codex should make sure the PixelCat proxy and upstream credential pool are available.

Preferred check from the `vipin wiki` root:

```powershell
.\scripts\Test-LocalCcPartner.ps1
```

The check verifies the `cc` entrypoint, the PixelCat port, and a minimal Anthropic-compatible `/v1/messages` request. A listening port alone is insufficient because PixelCat can be open while its upstream credential pool is disabled.

Check the local proxy:

```powershell
Get-NetTCPConnection -LocalAddress 127.0.0.1 -LocalPort 8990 -ErrorAction SilentlyContinue
```

If nothing is listening, launch the visible management panel:

```powershell
Start-Process -FilePath "D:\devtools\pixelcat-app.exe"
```

Then wait briefly and re-check `127.0.0.1:8990`. If the proxy still does not come up, record the limitation and either retry later or continue Codex-only when the missing partner does not materially change the risk profile.

If the port is listening but the API probe returns HTTP 502 with a message like "all upstream credentials are disabled" or `0/1`, the local Claude Code installation is not the broken part. The fix is to repair PixelCat's upstream account/network state in the panel, try TUN mode or another IP/exit node, and rerun the health check. Do not keep retrying `cc`, changing prompts, or treating this as a model-name issue.

Changing IP does not require changing the `cc` base URL. Keep `cc.cmd` pointed at PixelCat's local API on `127.0.0.1:8990`; if a different exit is needed, route PixelCat's outbound traffic through a trusted process-level proxy, SSH dynamic tunnel, WARP-style route, mobile hotspot, or another real network exit. A local proxy port such as `127.0.0.1:7897` is not a replacement for `8990`; it is only useful if it is a working outbound proxy and the public exit IP actually changes.

Do not ask the user to remember how to open PixelCat unless the executable is missing or startup fails repeatedly.

## Role Contract

| Agent | Model | Role | Writes files | Commits/pushes |
| --- | --- | --- | --- | --- |
| Codex Coordinator | current Codex session | Owns task framing, repo inspection, implementation, integration, validation, staging, commits, pushes, and wiki memory. | yes | yes |
| Opus Reviewer | `claude-opus-4-7` | Deep code review, complex reasoning, architecture critique, hard debugging, security/privacy review, high-risk design calls, high-risk final review. | no | no |
| Sonnet Scanner | `claude-sonnet-4-6` | Quick diff scans, test suggestions, documentation reading, low-risk second-pass checks. | no | no |

Codex must not treat partner output as authority. It is advisory evidence that Codex verifies against the live repository before acting.

## Quick Routing Reference

`AGENTS.md` remains the authoritative routing layer. Do not create a separate routing script or skill merely to restate these rules unless the user explicitly asks for an implementation project.

| Trigger | Partner | Runtime | Notes |
| --- | --- | --- | --- |
| User explicitly asks for Opus | Opus | `D:\devtools\cc.cmd` with `claude-opus-4-7` | Send a full context pack and keep the call read-only. |
| User explicitly asks for Sonnet | Sonnet | `D:\devtools\cc.cmd` with `claude-sonnet-4-6` | Use for quick scans, docs, and lower-risk second looks. |
| User explicitly asks for DeepSeek / `鲸鱼` | DeepSeek Pro by default | configured DeepSeek route when available | Do not search for a local binary unless the user asks for a CLI route. For local files, Codex gathers a compact read-only snapshot first. |
| Architecture, cross-module, security/privacy, hard debugging, high-risk final review | Opus | `D:\devtools\cc.cmd` | Opus wins when Sonnet and Opus triggers both match. |
| Low-risk diff scan, test-gap suggestion, documentation summary | Sonnet | `D:\devtools\cc.cmd` | Escalate to Opus if Sonnet reports uncertainty, blockers, or architectural/security risk. |
| Partner unavailable or context cannot be safely shared | Codex parallel selves / `分身` with limitation stated | current Codex session plus bounded Codex subagents when useful | Fill the CC-family collaboration slots with Codex-owned equivalents, keep scopes explicit, and state the limitation when missing CC review materially changes risk. |

## Forced Thresholds

Invoke `claude-opus-4-7` when the task includes any of:

- architecture decisions or more than two plausible implementation approaches
- cross-module, multi-file, or shared-interface changes
- API, schema, data migration, auth, security, privacy, or permission behavior
- refactors where behavior preservation matters
- debugging that resists the first Codex pass
- final review for high-risk diffs before commit or push

Invoke `claude-sonnet-4-6` when the task includes any of:

- quick scan of a low-risk diff
- test-gap or regression-risk suggestions
- documentation, README, or usage-note reading
- summarizing unfamiliar code before Codex edits
- routine second set of eyes on a small change

If Opus and Sonnet triggers both match, Opus wins. For example, a small diff touching auth, permissions, privacy, schema, or shared APIs is an Opus task, not a Sonnet-only task.

Lightweight exemptions are allowed only when the change is small and not a policy, workflow, security, privacy, data, or behavior change:

- spelling or wording fixes
- one-line comments
- tiny wiki/log/catalog corrections that do not alter operating rules
- pure formatting inspection with no behavioral impact
- user explicitly asks not to call a partner

Escalate Sonnet to Opus when Sonnet reports uncertainty, a possible blocker, security/privacy risk, cross-module reasoning, architecture tradeoffs, or a recommendation that Codex cannot verify quickly.

## Handoff Prompt Contract

Every partner call must use non-interactive `-p` and include these fields:

```text
AUTHORIZATION: User-authorized local read-only review.
ROLE: Opus Reviewer | Sonnet Scanner
MODEL: claude-opus-4-7 | claude-sonnet-4-6
REPO: <absolute repository path>
SCOPE: <specific files, diff, command output, or question boundary>
QUESTION: <one bounded question or task>
CONSTRAINTS: Read-only. Do not edit files. Do not run destructive commands. Do not stage, commit, push, or handle credentials/live accounts.
OUTPUT FORMAT: <findings list | yes/no + rationale | plan outline | test suggestions>
ESCALATION SIGNALS: Say "ESCALATE TO OPUS" or "BLOCKER" when the issue exceeds this role's scope.
```

Avoid open-ended prompts such as "review everything." Scope the handoff to a specific concern.

For long or multi-line context packs, prefer piping the prompt through stdin instead of passing the entire prompt as a PowerShell argument:

```powershell
$prompt = @'
AUTHORIZATION: User-authorized local read-only review.
ROLE: Opus Reviewer
MODEL: claude-opus-4-7
REPO: D:\Research\SomeRepo
SCOPE: Current diff plus relevant repository instructions.
QUESTION: Review this scoped change for blockers.
CONSTRAINTS: Read-only. Do not edit files. Do not run destructive commands. Do not stage, commit, push, or handle credentials/live accounts.
OUTPUT FORMAT: Findings first. If no blockers, say NO BLOCKERS and list residual risks.
ESCALATION SIGNALS: Say BLOCKER for any issue that should stop commit.
'@
$prompt | D:\devtools\cc.cmd -p --model claude-opus-4-7 --output-format text
```

If the output is only a generic readiness/greeting line or does not answer the scoped question, treat the handoff as failed or unusable. Do not count that as a real partner review.

## Command Templates

Sonnet quick scan:

```powershell
D:\devtools\cc.cmd -p "AUTHORIZATION: User-authorized local read-only review.
ROLE: Sonnet Scanner
MODEL: claude-sonnet-4-6
REPO: D:\Research\SomeRepo
SCOPE: Current git diff only.
QUESTION: Quickly list likely regressions, missing tests, and unclear docs. Do not redesign the solution.
CONSTRAINTS: Read-only. Do not edit files. Do not run destructive commands. Do not stage, commit, push, or handle credentials/live accounts.
OUTPUT FORMAT: Bullet list. If no issues, say NO QUICK-SCAN ISSUES.
ESCALATION SIGNALS: Say ESCALATE TO OPUS for architecture, cross-module, security/privacy, or possible blocker concerns." --model claude-sonnet-4-6 --output-format text
```

Opus deep review:

```powershell
D:\devtools\cc.cmd -p "AUTHORIZATION: User-authorized local read-only review.
ROLE: Opus Reviewer
MODEL: claude-opus-4-7
REPO: D:\Research\SomeRepo
SCOPE: Current git diff and relevant repository instructions.
QUESTION: Perform a deep blocker review for architecture, correctness, security/privacy, and missing tests.
CONSTRAINTS: Read-only. Do not edit files. Do not run destructive commands. Do not stage, commit, push, or handle credentials/live accounts.
OUTPUT FORMAT: Findings first, ordered by severity. If no blockers, say NO BLOCKERS and list residual risks.
ESCALATION SIGNALS: Say BLOCKER for any issue that should stop commit." --model claude-opus-4-7 --output-format text
```

Smoke test:

```powershell
D:\devtools\cc.cmd -p "Reply only OK" --model claude-opus-4-7 --output-format text
```

## Coordinator Verification

Before Codex adopts a partner recommendation:

- re-read the files, diff, or command output the partner referenced
- decide whether the claim is accurate, stale, or overbroad
- run the relevant tests, lint, build, or wiki validation when available
- stage only scoped files
- record durable workflow changes in the wiki when the user asked future agents to remember them

The commit rationale must be Codex-verified. "A partner said so" is never sufficient.

## Context Packing Rule

When using Opus, Sonnet, or DeepSeek for a hard coding task, do not send a toy prompt. Include:

- the actual goal
- the decisions already fixed
- the files or artifacts in scope
- the question the partner must answer
- the output shape you want back

If the task is software or project work, give the partner enough of the real conversation and repository context to understand what changed and why before asking for judgment.

## Safety Gates

- Opus and Sonnet are read-only partners by default.
- Do not expose tokens, passwords, cookies, OAuth material, private chats, or sensitive personal data in prompts.
- Do not delegate destructive commands, production changes, real account actions, payment actions, or credential handling.
- User approval is still required for destructive operations or cross-repository edits, regardless of partner output.
- If `cc` fails, hangs, returns unusable output, or the PixelCat panel/proxy is not running, fill the CC-family collaboration slots with Codex parallel selves / `分身` and record the limitation when it materially affects risk or validation.
- If the preflight reports `upstream_credentials_disabled`, fall back immediately to Codex parallel selves / `分身` for the Opus/Sonnet/Haiku slots and record that the CC family is blocked by PixelCat upstream credential/network state. Do not spend the user's time on prompt retries.
- The limitation is material when the task would normally trigger Opus: architecture, security/privacy, cross-module changes, hard debugging, or high-risk final review.
- When PixelCat is not running, try the PixelCat preflight launch procedure before falling back.

## Verified Status

- EXTRACTED: `D:\devtools\cc.cmd --version` returned `2.1.143 (Claude Code)`.
- EXTRACTED: The PixelCat proxy was observed listening on `127.0.0.1:8990`.
- EXTRACTED: The user confirmed that the PixelCat management panel must be open for the local `cc` family tools to work.
- EXTRACTED: Earlier `D:\devtools\cc.cmd -p "Reply only OK" --model claude-sonnet-4-6 --output-format text` and Opus smoke tests returned `OK` when PixelCat's upstream credentials were healthy.
- EXTRACTED: `D:\devtools\cc.cmd` successfully ran a read-only `claude-opus-4-7` diff-review partner prompt for a wiki update and reported `NO BLOCKERS`.
- EXTRACTED: On 2026-05-18, piping a long context pack through stdin to `D:\devtools\cc.cmd -p --model claude-opus-4-7 --output-format text` successfully produced a scoped Opus architecture review.
- EXTRACTED: In the same session, passing a long prompt directly as a PowerShell argument returned only a generic readiness line; future agents should treat that shape of output as a failed handoff, not as partner input.
- EXTRACTED: On 2026-05-18 11:51 +02:00, `scripts/Test-LocalCcPartner.ps1` found `D:\devtools\cc.cmd` version `2.1.143`, PixelCat listening on `127.0.0.1:8990`, and the `/v1/messages` probe failing with HTTP 502 because PixelCat reported all upstream credentials disabled (`0/1`).

## Counterpoints And Gaps

- AMBIGUOUS: Model availability depends on the currently running PixelCat panel/proxy configuration.
- INFERRED: The strict threshold rule is most useful for non-trivial coding tasks; forcing partner calls for tiny edits would add latency without meaningful safety gains.
- UNVERIFIED: Long-running implementation by partner agents remains out of scope until a separate write-scope protocol is designed and tested.

## Related Pages

- [[2026-05-17-opencode-cc-pixelcat-setup]]
- [[agent-collaboration-tone-and-model-roles]]
- [[durable-agent-rule-memory]]
- [[agent-skill-installation-workflow]]
- [[model-collaboration-context-and-reference-intake]]
