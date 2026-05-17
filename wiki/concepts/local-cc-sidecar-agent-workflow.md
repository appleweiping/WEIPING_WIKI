---
title: Local CC Sidecar Agent Workflow
type: concept
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - agent-workflow
  - coding
  - multi-agent
  - claude-code
source_pages:
  - AGENTS.md
  - 2026-05-17-opencode-cc-pixelcat-setup.md
---

# Local CC Sidecar Agent Workflow

## Purpose

This workflow turns the local `cc` / Claude Code runtime into a strict threshold-based multi-agent coding system.

Codex acts as the supervisor and only writer. The sidecar models act as read-only specialists with bounded prompts. This follows a common supervisor/handoff pattern: one coordinator owns the task state and repository mutations, while specialist agents provide scoped review, scanning, or reasoning.

## Runtime

- EXTRACTED: Claude Code entrypoint: `D:\cc\cc.cmd`.
- EXTRACTED: Node/npm runtime and global packages live under `D:\cc\`, not the C drive.
- EXTRACTED: PixelCat provides the local model proxy on `127.0.0.1:8990`.
- EXTRACTED: PixelCat management panel executable: `D:\cc\pixelcat-app.exe`.
- EXTRACTED: Verified Claude Code version: `2.1.143`.

OpenCode is installed and recorded in [[2026-05-17-opencode-cc-pixelcat-setup]], but it is not part of this multi-agent coding workflow.

## PixelCat Preflight

PixelCat is the required control plane for the local `cc` family setup. Before calling `D:\cc\cc.cmd`, Codex should make sure the PixelCat proxy is available.

Check the local proxy:

```powershell
Get-NetTCPConnection -LocalAddress 127.0.0.1 -LocalPort 8990 -ErrorAction SilentlyContinue
```

If nothing is listening, launch the visible management panel:

```powershell
Start-Process -FilePath "D:\cc\pixelcat-app.exe"
```

Then wait briefly and re-check `127.0.0.1:8990`. If the proxy still does not come up, record the limitation and either retry later or continue Codex-only when the missing sidecar does not materially change the risk profile.

Do not ask the user to remember how to open PixelCat unless the executable is missing or startup fails repeatedly.

## Role Contract

| Agent | Model | Role | Writes files | Commits/pushes |
| --- | --- | --- | --- | --- |
| Codex Coordinator | current Codex session | Owns task framing, repo inspection, implementation, integration, validation, staging, commits, pushes, and wiki memory. | yes | yes |
| Opus Reviewer | `claude-opus-4-7` | Deep code review, complex reasoning, architecture critique, hard debugging, security/privacy review, high-risk design calls, high-risk final review. | no | no |
| Sonnet Scanner | `claude-sonnet-4-6` | Quick diff scans, test suggestions, documentation reading, low-risk second-pass checks. | no | no |

Codex must not treat sidecar output as authority. It is advisory evidence that Codex verifies against the live repository before acting.

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
- user explicitly asks not to call a sidecar

Escalate Sonnet to Opus when Sonnet reports uncertainty, a possible blocker, security/privacy risk, cross-module reasoning, architecture tradeoffs, or a recommendation that Codex cannot verify quickly.

## Handoff Prompt Contract

Every sidecar call must use non-interactive `-p` and include these fields:

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

## Command Templates

Sonnet quick scan:

```powershell
D:\cc\cc.cmd -p "AUTHORIZATION: User-authorized local read-only review.
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
D:\cc\cc.cmd -p "AUTHORIZATION: User-authorized local read-only review.
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
D:\cc\cc.cmd -p "Reply only OK" --model claude-opus-4-7 --output-format text
```

## Coordinator Verification

Before Codex adopts a sidecar recommendation:

- re-read the files, diff, or command output the sidecar referenced
- decide whether the claim is accurate, stale, or overbroad
- run the relevant tests, lint, build, or wiki validation when available
- stage only scoped files
- record durable workflow changes in the wiki when the user asked future agents to remember them

The commit rationale must be Codex-verified. "Sidecar said so" is never sufficient.

## Safety Gates

- Sidecars are read-only by default.
- Do not expose tokens, passwords, cookies, OAuth material, private chats, or sensitive personal data in prompts.
- Do not delegate destructive commands, production changes, real account actions, payment actions, or credential handling.
- User approval is still required for destructive operations or cross-repository edits, regardless of sidecar output.
- If `cc` fails, hangs, returns unusable output, or the PixelCat panel/proxy is not running, fall back to Codex-only work and record the limitation when it materially affects risk or validation.
- When PixelCat is not running, try the PixelCat preflight launch procedure before falling back.

## Verified Status

- EXTRACTED: `D:\cc\cc.cmd --version` returned `2.1.143 (Claude Code)`.
- EXTRACTED: The PixelCat proxy was observed listening on `127.0.0.1:8990`.
- EXTRACTED: The user confirmed that the PixelCat management panel must be open for the local `cc` family tools to work.
- EXTRACTED: `D:\cc\cc.cmd -p "Reply only OK" --model claude-sonnet-4-6 --output-format text` returned `OK`.
- EXTRACTED: `D:\cc\cc.cmd -p "Reply only OK" --model claude-opus-4-7 --output-format text` returned `OK`.
- EXTRACTED: `D:\cc\cc.cmd` successfully ran a read-only `claude-opus-4-7` diff-review sidecar prompt for a wiki update and reported `NO BLOCKERS`.

## Counterpoints And Gaps

- AMBIGUOUS: Model availability depends on the currently running PixelCat panel/proxy configuration.
- INFERRED: The strict threshold rule is most useful for non-trivial coding tasks; forcing sidecars for tiny edits would add latency without meaningful safety gains.
- UNVERIFIED: Long-running implementation by sidecar agents remains out of scope until a separate write-scope protocol is designed and tested.

## Related Pages

- [[2026-05-17-opencode-cc-pixelcat-setup]]
- [[durable-agent-rule-memory]]
- [[agent-skill-installation-workflow]]
