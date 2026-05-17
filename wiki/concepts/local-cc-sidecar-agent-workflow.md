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

The local `cc` / Claude Code setup is a sidecar agent system for coding work. It lets Codex call a stronger or differently tuned coding agent directly from the terminal layer, instead of requiring the user to open Claude Code manually.

## Local Runtime

- EXTRACTED: Claude Code entrypoint: `D:\cc\cc.cmd`.
- EXTRACTED: OpenCode entrypoint: `D:\cc\opencode.cmd`.
- EXTRACTED: Node/npm runtime and global packages live under `D:\cc\`, not the C drive.
- EXTRACTED: PixelCat provides the local model proxy on `127.0.0.1:8990`.
- EXTRACTED: Verified Claude Code version: `2.1.143`.
- EXTRACTED: Verified OpenCode version: `1.15.3`.

Do not publish local auth tokens, account details, or private chat/video material in the wiki.

## When To Use

Use `cc` as a sidecar for:

- complex implementation planning
- architecture review
- risky refactors
- hard debugging
- independent read-only code review
- final diff audit before commit
- second-opinion test strategy

Do not use it for trivial edits where the extra orchestration would slow the task down.

## Model Choice

- Prefer `claude-opus-4-7` for hard reasoning, design review, debugging, and high-stakes reviewer passes.
- Use `claude-sonnet-4-6` or another faster configured model for routine checks when speed matters more than depth.

## Standard Invocation

```powershell
D:\cc\cc.cmd -p "Read the repository instructions first. Act as a read-only reviewer. Inspect the current git diff and list only bugs, regressions, and missing tests. Do not edit files." --model claude-opus-4-7 --output-format text
```

For planning:

```powershell
D:\cc\cc.cmd -p "In D:\Research\SomeRepo, read AGENTS.md and the smallest relevant files. Produce a concise implementation plan for <task>. Do not edit files." --model claude-opus-4-7 --output-format text
```

For a smoke test:

```powershell
D:\cc\cc.cmd -p "Reply only OK" --model claude-opus-4-7 --output-format text
```

## Coordination Rules

- Codex remains the coordinator and final integrator.
- Treat `cc` output as advisory, not automatically correct.
- Verify claims against the live repository before editing or committing.
- Keep sidecar prompts bounded: one role, one repository, one expected output.
- Prefer read-only sidecar prompts unless the user explicitly asks for multi-agent implementation.
- Do not ask the sidecar to run destructive commands, handle credentials, or operate live accounts without explicit user approval.
- If multiple agents are used, keep write scopes disjoint and stage only the final scoped changes.

## Verified Status

- EXTRACTED: `D:\cc\cc.cmd --version` returned `2.1.143 (Claude Code)`.
- EXTRACTED: `D:\cc\opencode.cmd --version` returned `1.15.3`.
- EXTRACTED: `D:\cc\cc.cmd -p "Reply only OK" --model claude-opus-4-7 --output-format text` returned `OK`.
- EXTRACTED: The PixelCat proxy was observed listening on `127.0.0.1:8990`.

## Counterpoints And Gaps

- AMBIGUOUS: Model availability depends on the currently running PixelCat panel/proxy configuration.
- INFERRED: The sidecar is most valuable as an independent reviewer or planner; Codex should still own final repo state because it has the active conversation and commit obligations.
- UNVERIFIED: Long-running multi-agent implementation through `cc` has not yet been stress-tested in this repository; start with bounded read-only sidecar tasks and expand after successful real coding runs.

## Related Pages

- [[2026-05-17-opencode-cc-pixelcat-setup]]
- [[durable-agent-rule-memory]]
- [[agent-skill-installation-workflow]]
