# CLAUDE.md

Read `AGENTS.md` first. It is the authoritative operating guide for this repository.

This repository is `WEIPING_WIKI` / `Weiping Wiki`, a maintained personal knowledge base. Historical aliases include `vipin wiki`, `vipinknowledge`, and `vipin-wiki`; preserve them as compatibility context for old paths, prompts, and automations. Preserve public/private boundaries, update wiki pages deliberately, and treat active agent memory as `agentmemory` state unless the user explicitly asks for historical markdown `memory/` files.

For whole-computer maintenance, project routing, or local file-organization work, use the `weiping-wiki` skill when available; `vipin-wiki` remains a historical alias and may still be the physical folder name in older installs. Read `wiki/concepts/whole-computer-project-map.md` first; use `wiki/concepts/d-drive-project-map.md` and `wiki/concepts/weiping-agentic-project-constellation.md` for D-drive infrastructure detail so private runtime cleanup, public exports, agentic method repos, and research workbenches do not get mixed. For physical C:/D:/G: file organization, use the shared `workstation-maintenance` skill from `D:\agent-resources\skills\vipin\workstation-maintenance`; it owns dry-run manifests, full-plan, exact-batch, and D-root organization non-moving preflights, approval packets, batch-approved moves, move-with-junction D-root organization, and rollback manifests. Broad user approval can cover all currently passing low-risk batches. The continuous maintenance system is documented at `wiki/concepts/weiping-wiki-maintenance-system.md`; recurring Codex maintenance should use `gpt-5.5` with `xhigh` reasoning when supported.

When Claude Code is invoked by Codex as Opus or Sonnet, act as a read-only partner: inspect, reason, review, and report findings. Do not edit files, stage, commit, push, run destructive commands, or handle credentials/live accounts.

When the user starts Claude Code directly and explicitly grants write scope, follow that user request while still obeying `AGENTS.md`, `.wiki-schema.md`, and `purpose.md`.

## Active Memory And Coordination

Use `agentmemory` automatically and proactively:

1. On session start or when past context matters, search or recall relevant memories.
2. For collaboration, use agentmemory signals rather than Agent Hub queues.
3. After important work, save decisions, findings, lessons, configurations, and next steps with agentmemory.
4. Do not store secrets, API keys, private chats, credentials, or sensitive account state in memory.

Markdown `memory/` files in this repo are historical/superseded unless the task explicitly targets them. Stable public-safe knowledge should be crystallized into `wiki/`.

## Implicit Skill Use

Do not wait for the user to name a skill. Before non-trivial work:

1. Classify the task intent.
2. Check project skills and `D:\agent-resources\SKILL-INDEX.md`.
3. Read the matched `SKILL.md`.
4. Follow that skill's workflow before improvising.

Research tasks must use the matching ARIS skill when one exists. README, architecture, skill, audit, browser, frontend, document, and infrastructure tasks should route to the relevant installed skills by description.

Do not move files during broad workstation cleanup unless a `workstation-maintenance` manifest and type-grouped age-gated move plan exist and the user has approved the batch ID or broadly approved all currently passing low-risk batches. For immediate D-root directory cleanup, use the drive-root plan/invoke scripts and keep old paths working through junctions. `D:\Research` resolved paths are a hard no-move boundary.

For recurring `WEIPING_WIKI` upkeep, the canonical report command is:

```powershell
python scripts/wiki.py maintain --scope whole-computer --json
```

Review the report, update only curated scoped files, validate, and preserve unrelated dirty work.

### LLM Wiki v2 commands

The unified CLI also provides these additive, public-safe commands: `crystallize` (turn a high-value outcome into a routed durable page), `lifecycle` (advisory confidence / Ebbinghaus retention-decay / supersession audit), `graph` (wiki-link traversal: `stats|neighbors|path|export`), `scrub` (pre-ingest secret/private-path scan), `health --fix [--dry-run]` (non-destructive self-heal), and `search --graph` / `--semantic`. See `wiki/concepts/llm-wiki.md` and `wiki/analyses/2026-06-19-weiping-wiki-upgrade-audit.md`.

For major maintenance-skill redesigns, UUPF from `D:\AGENTIC_SCIENCE\uupf\UniversalUpgradeForge.zip` may be used in offline mode as audit/planning input. Raw UUPF reports are not proof and should stay ignored unless curated into public-safe notes.

## Multi-Agent Roles

| Agent | Role | Notes |
| --- | --- | --- |
| Codex | Coordinator, fast executor, integrator, commit/push owner | Uses agentmemory and git state to coordinate. |
| Opus | Deep reasoning, architecture, high-risk review | Read-only when invoked by Codex. |
| Sonnet | Quick second look, test gaps, docs review | Read-only when invoked by Codex. |
| Haiku | Fast classification/lint-style checks | Use only for lightweight checks. |
| OpenCode | Independent CC-family entry point | May write when the user starts OpenCode directly. |
| DeepSeek Pro / `鲸鱼` | Bulk text, translation, summarization, low-cost drafts | Advisory unless explicitly scoped otherwise. |

Agent Hub is retired. Do not call old Agent Hub MCP tools or expect `D:\devtools\agent-hub` to be active. Use agentmemory signals/actions and git state for coordination.

## CC Partner Preflight

Before relying on Opus, Sonnet, or Haiku through `D:\devtools\cc.cmd`, run the local partner health check when available:

```powershell
.\scripts\Test-LocalCcPartner.ps1
```

If PixelCat reports disabled upstream credentials or returns unusable output, state the limitation and continue with Codex-owned review or another available partner when that is acceptable.

## Server Access

Remote GPU server access and research experiment operations are out of scope unless the user explicitly asks. Do not change research experiment progress, datasets, checkpoints, baselines, or server state while maintaining this wiki/infrastructure layer.

## Documentation Rule

When agent memory, skill routing, MCP config, startup scripts, agent roles, or multi-agent infrastructure changes, update the relevant docs in the same scoped change:

- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `.opencode/OPENCODE.md`
- `.claude/skills/README-skills-layout.md`
- relevant `wiki/` pages, `wiki/index.md`, and `wiki/log.md`
