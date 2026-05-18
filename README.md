# vipin wiki

A source-backed knowledge system with multi-agent orchestration. Turns research, conversations, and automation into maintained, interlinked Markdown knowledge that compounds over time.

Built for a research workflow spanning LLM-based recommendation systems, uncertainty quantification, analog circuit design, and personal knowledge management. The system is designed to make future answers faster, safer, and better grounded by preserving reusable knowledge rather than letting it decay in chat history.

## Overview

This repository serves four purposes:

1. **Knowledge Graph** — A public Markdown wiki (`wiki/`) with entities, concepts, sources, analyses, queries, and topics, all interlinked and maintained over time.
2. **Research Memory** — Papers, project histories, baseline comparisons, and literature maps that persist across sessions and agents.
3. **Agent Operating Contract** — Authoritative rules (`AGENTS.md`) that govern how AI agents collaborate, write, validate, and commit within this repository.
4. **Multi-Agent Collaboration Hub** — A 5-agent system with real-time orchestration, shared state, and automated quality gates.

## Getting Started

| You are | First step | Then |
|---------|-----------|------|
| The user (Vipin) | Open Codex or Claude Code | Talk naturally. Agents handle orchestration, wiki updates, and commits. |
| A future AI agent | Read `AGENTS.md` in full | Then read `CLAUDE.md`, check `wiki/index.md`, `wiki/catalog.json`, and recent `wiki/log.md` entries. |
| A human reader | Open `wiki/index.md` | Follow links to entities, concepts, sources, and analyses. |
| A maintainer | Run `python scripts/wiki-catalog.py --root .` | Fix any issues, then `git push`. |

## Repository Structure

```
vipin-wiki/
├── AGENTS.md                  # Authoritative operating contract for all agents
├── CLAUDE.md                  # Claude Code (Opus/Sonnet) entry point and role definition
├── purpose.md                 # Research direction alignment
├── .wiki-schema.md            # Confidence taxonomy (EXTRACTED/INFERRED/AMBIGUOUS/UNVERIFIED)
│
├── wiki/                      # Public maintained knowledge graph
│   ├── index.md               # Human-readable catalog of all pages
│   ├── log.md                 # Chronological activity log
│   ├── catalog.json           # Machine-readable catalog (CI-validated)
│   ├── entities/              # People, organizations, products, projects
│   ├── concepts/              # Frameworks, workflows, methods, rules
│   ├── sources/               # One page per ingested source
│   ├── analyses/              # Syntheses, comparisons, memos
│   ├── queries/               # High-value preserved Q&A
│   ├── topics/                # High-frequency corpus hubs
│   ├── timelines/             # Chronological views
│   └── _templates/            # Page templates for consistency
│
├── wiki-private/              # Local-only private knowledge (never in public Git)
│
├── raw/                       # Immutable source materials and manifests
│   ├── inbox/                 # New materials arrive here
│   ├── lidang-public/         # Public corpus for Lidang entity
│   └── codex-prompts-public/  # Ingested Codex prompt corpus
│
├── scripts/                   # Operational utilities
│   ├── wiki-catalog.py        # Rebuild catalog.json (CI uses this)
│   ├── wiki-lint.ps1          # Check links, leaks, orphans, contradictions
│   ├── wiki-search.py         # Full-text search across wiki
│   ├── wiki-status.ps1        # Repository health overview
│   ├── wiki-context.py        # Context extraction for agent handoffs
│   ├── wiki-graph.ps1         # Link graph visualization
│   └── build-site.ps1         # Quartz site build
│
├── site/                      # Quartz publishing adapter
│   ├── sync-content.mjs       # Syncs wiki/ into Quartz content/
│   ├── quartz.config.ts       # Site configuration
│   └── custom.scss            # Custom styling
│
├── .codex/skills/             # 38 installed Codex skills
│   ├── lark-*/                # 11 Lark/Feishu integration skills
│   ├── chrome-automation/     # Browser automation
│   ├── content-creation-publisher/
│   ├── agent-research-aggregator/
│   └── ...
│
├── .claude/                   # Claude Code configuration
│   ├── settings.json          # Agent Teams enabled
│   └── skills/                # Claude Code skills
│       ├── lidang-perspective/ # Distilled thinking framework (nuwa-skill process)
│       ├── mattpocock-skills/  # Engineering workflow skills (tdd, grill-me, diagnose, etc.)
│       └── README-skills-layout.md
│
└── .github/workflows/         # CI/CD
    ├── deploy.yml             # Validate + build Quartz + deploy to GitHub Pages
    └── pages-health.yml       # Daily health check on live site
```

## Multi-Agent Collaboration System

Five AI agents collaborate through the Agent Hub MCP server (`D:\devtools\agent-hub\`), a custom-built orchestration layer with 20 tools, a real-time daemon, and shared persistent state.

### Agent Roles

| Agent | Model | Role | Primary Use Cases |
|-------|-------|------|-------------------|
| **Opus** | Claude 4.7 | Architect + primary coder | Complex multi-file refactors, architecture design, security review, long-context analysis (1M tokens), agentic multi-hour tasks |
| **GPT-5.5** | GPT-5.5 | Coordinator + fast executor | Task decomposition, parallel subagent orchestration, short CLI tasks, math/algorithms, wiki maintenance |
| **Sonnet** | Claude 4.6 | Reviewer + verifier | Code review second pass, test gap analysis, documentation generation, routine "second set of eyes" checks |
| **Haiku** | Claude 4.5 | Speedster + pre-screener | Lint checks, formatting validation, quick classification, high-frequency small tasks, pre-screening before deeper review |
| **DeepSeek Pro** | DeepSeek V4 | Bulk worker | Translation, summarization, classification, batch text processing, Chinese content generation, cost-sensitive tasks |

### Orchestration Capabilities

**Real-time dispatch**: A background daemon (port 9800) polls agent mailboxes every 2 seconds. When an urgent message arrives, the daemon automatically invokes the recipient agent without human intervention.

**Auto-retry cascade**: If the primary agent fails a task, the daemon automatically retries with the next agent in the chain: Opus → Sonnet → DeepSeek. This ensures tasks complete even when individual agents are unavailable.

**Quality gate**: A multi-layer automated code review pipeline. Haiku performs fast lint (~2 seconds), then Sonnet performs deeper correctness/security review (~10 seconds). Code must pass all checks before delivery.

**Pipeline with human gates**: Sequential multi-step workflows where critical steps pause for human confirmation. Non-critical steps execute automatically. The user receives an urgent notification when confirmation is needed.

**Spec-driven parallel dispatch**: For complex tasks, one agent writes a specification that defines subtasks with assigned agents, file boundaries, and dependencies. All agents receive their portion simultaneously and work in parallel.

**Warm context**: The daemon scans project state every 5 minutes (branch, dirty files, recent commits, active files) and writes it to shared state. Any agent can read current project status instantly without rescanning the repository.

**Performance metrics**: Every dispatch, completion, failure, and retry is logged to `D:\devtools\agent-hub\state\metrics.json`. Agents can query `hub_metrics` to see per-agent success rates and identify reliability patterns.

### Infrastructure

All infrastructure starts automatically on Windows boot (via `shell:startup`):
- **PixelCat** (`D:\devtools\pixelcat-app.exe`) — Local API proxy on port 8990, holds Anthropic API key
- **Agent Hub Daemon** (`D:\devtools\agent-hub\daemon.mjs`) — HTTP server on port 9800, handles dispatch/retry/pipeline/warm-context

The user only needs to open one chat window (Codex or Claude Code). Everything else is automatic.

Health check for the Claude Code partner path:

```powershell
.\scripts\Test-LocalCcPartner.ps1
```

`upstream_credentials_disabled` means PixelCat is running but ccmax/PixelCat has disabled every upstream credential currently available. Fix the PixelCat panel's account/network state, try TUN, a PixelCat outbound proxy, or another IP/exit node, then rerun the check before invoking Opus, Sonnet, or Haiku. Keep Claude Code pointed at PixelCat's local API on `127.0.0.1:8990`; proxy ports such as `7897` are outbound exits only.

When the CC family is unavailable, keep the collaboration shape by assigning the Opus/Sonnet/Haiku slots to Codex parallel selves / `分身` by default, and note the missing CC review when it materially increases risk.

### 20 MCP Tools

| Category | Tools |
|----------|-------|
| Messaging | `hub_send_message`, `hub_read_messages`, `hub_mark_read`, `hub_notify` |
| Shared State | `hub_set_context`, `hub_get_context`, `hub_list_context`, `hub_agent_status` |
| Collaboration | `hub_create_thread`, `hub_thread_history`, `hub_dispatch_spec` |
| Routing | `hub_route_task` |
| Pipeline | `hub_pipeline`, `hub_pipeline_status` |
| Metrics | `hub_metrics` |
| Direct Invocation | `hub_invoke_sonnet`, `hub_invoke_haiku`, `hub_invoke_gpt55` |
| Quality | `hub_quality_gate` |
| External | `deepseek_chat` |

## Knowledge Workflows

| Workflow | When to use | What it produces |
|----------|-------------|-----------------|
| **Query** | User asks a substantive question | Grounded answer from maintained context, plus a durable wiki page when the answer is reusable |
| **Ingest** | A source should become maintained knowledge | Source page plus linked entity, concept, topic, or analysis updates |
| **Batch ingest** | A repo set, paper set, person corpus, or folder needs structure | Collection note, manifests, dedup rules, and topic maps |
| **Crystallize** | A chat produced something worth reusing | Query, concept, analysis, comparison, topic, or workflow page |
| **Maintain** | Wiki has drift, duplication, stale claims, or weak links | Non-destructive cleanup, merge/rewrite, and a log entry |
| **Automation** | A scheduled/local workflow changes wiki artifacts | Validated scoped commit and push of real changes |
| **Site publish** | Public wiki needs deploying | Quartz build from `wiki/` through `site/` to GitHub Pages |

Cron automations are high-intelligence by default: use `gpt-5.5` with `high` reasoning. Do not downgrade scheduled work to low or medium reasoning.

## Commands

### PowerShell (primary on Windows)

```powershell
.\scripts\wiki-catalog.ps1          # Rebuild catalog.json
.\scripts\wiki-lint.ps1             # Check links, leaks, orphans, contradictions
.\scripts\wiki-search.ps1 "query"   # Full-text search across wiki
.\scripts\wiki-status.ps1           # Repository health overview
.\scripts\wiki-context.ps1 l0       # Extract context for agent handoffs
.\scripts\wiki-graph.ps1            # Link graph visualization
.\scripts\build-site.ps1            # Build Quartz site locally
.\scripts\Test-LocalCcPartner.ps1    # Check PixelCat + Claude Code partner availability
```

### Python/Bash (cross-platform, used in CI)

```bash
python scripts/wiki-catalog.py --root .       # Rebuild catalog (CI gate)
python scripts/wiki-search.py "query" --root . # Full-text search
python scripts/wiki-context.py l0 --root .     # Context extraction
bash scripts/wiki-status.sh                    # Repository health
bash scripts/build-site.sh                     # Quartz build
```

## Quality Discipline

### Confidence Taxonomy

All substantive claims in wiki pages use the confidence taxonomy from `.wiki-schema.md`:
- **EXTRACTED** — directly stated in the source
- **INFERRED** — logically derived from source material
- **AMBIGUOUS** — multiple interpretations possible
- **UNVERIFIED** — plausible but not confirmed

### Public/Private Boundary

Public pages (`wiki/`) may include: neutral metadata, public URLs, source summaries, stable IDs, hashes, workflow notes, and non-sensitive project memory.

Public pages must never include: secrets, tokens, private document contents, sensitive personal identifiers, private chats, or high-sensitivity materials. The `wiki-private/` layer exists for sensitive content and is excluded from Git, site builds, and public indexes.

### Commit Discipline

- Stage only files that belong to the current task
- Catalog must be fresh before push (CI validates this)
- No append-only accumulation — merge, rewrite, or propose deletion when content becomes stale
- No empty commits for false dirty states
- Infrastructure changes must update all documentation files in the same commit

## CI/CD

| Workflow | Trigger | Steps |
|----------|---------|-------|
| **Deploy Quartz site** | Push to `wiki/**` or `site/**` on main | Validate catalog → lint gates → checkout Quartz → build → verify artifact → check public/private boundary → deploy to GitHub Pages → verify live site |
| **Pages health check** | Daily at 04:17 UTC + manual dispatch | Verify live site serves Quartz wiki home (not README or raw Markdown) |

Published site: [appleweiping.github.io/vipin-wiki](https://appleweiping.github.io/vipin-wiki/)

## Research Directions

- Large language models and their application to recommendation systems
- Uncertainty quantification in LLM-based recommendation
- Analog circuit design with AI (AI4EDA)
- Paper digestion, literature mapping, and synthesis
- Personal knowledge management and agent workflow optimization

## For AI Agents

Read `AGENTS.md` first. It is the single authoritative operating contract and defines:

- Mission, operating priority, and two-lane workflow (answer first, crystallize second)
- Collaboration tone and partner naming conventions
- Context packing rules for agent handoffs
- Wiki structure, page conventions, and file naming
- Source handling, sensitivity rules, and ingest workflow
- Multi-agent collaboration model with Agent Hub (roles, thresholds, dispatch patterns)
- Local CC partner policy (PixelCat preflight, prompt contract, escalation rules)
- Pipeline examples and quality gate patterns
- Commit policy, lint workflow, and validation gates
- Research ideation policy
- Durable rule memory and auto-update documentation rule

**Mandatory rule**: Any change to agent-hub code, skills, MCP config, startup scripts, or agent roles must update all affected documentation files (`CLAUDE.md`, `AGENTS.md`, `README.md`, `.claude/skills/README-skills-layout.md`, `D:\devtools\agent-hub\README.md`) in the same turn. The user should never need to remind agents to keep docs current.
