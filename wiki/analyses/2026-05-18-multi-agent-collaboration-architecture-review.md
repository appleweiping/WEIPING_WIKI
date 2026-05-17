---
title: Multi-Agent Collaboration Architecture Review
type: analysis
status: active
created: 2026-05-18
updated: 2026-05-18
tags:
  - agent-workflow
  - collaboration
  - deepseek
  - claude-code
  - operating-rules
source_pages:
  - AGENTS.md
  - local-cc-sidecar-agent-workflow
  - model-collaboration-context-and-reference-intake
  - agent-collaboration-tone-and-model-roles
---

# Multi-Agent Collaboration Architecture Review

## Context

The user asked Codex to judge a Claude Code review of `vipin wiki`'s multi-agent collaboration setup. The concern was not only whether Opus, Sonnet, and DeepSeek / `鲸鱼` are mentioned, but whether future agents will actually give partners enough context to make their work useful.

Codex inspected the live repository, treated the earlier Claude Code output as advisory, then ran a scoped Opus read-only review with a full context pack.

## Decision Summary

| Suggestion | Decision | Rationale |
| --- | --- | --- |
| Add a DeepSeek CLI/API wrapper and autonomous thresholds | DEFER | The durable intent rule now exists, but a runtime adapter is a separate implementation project and the user paused skill/adapter work for now. |
| Bridge Codex and Claude Code skill folders by index or symlink | REJECT FOR NOW | `.claude/skills` already has a documented D-drive layout, and blindly linking Codex skills into Claude Code would mix runtimes with different trigger semantics. |
| Add a unified `route-to-agent.ps1` router | PARTIAL NOW | A script is premature. The useful immediate fix is a quick routing reference in the maintained CC partner workflow. |
| Add Claude Code role awareness | ADOPT PROJECT-LOCAL | A root `CLAUDE.md` can safely point direct Claude Code sessions to `AGENTS.md` and distinguish Codex-invoked read-only partner calls from user-granted write sessions. Global C-drive config remains out of scope. |
| Treat PixelCat as a single point of failure | ALREADY MOSTLY ADOPTED | PixelCat preflight and fallback rules already exist. The gap is clarifying when fallback to Codex-only materially affects risk. |

## Adopted Changes

- `AGENTS.md` keeps DeepSeek / `鲸鱼` as explicit delegation intent and fixes the dropped indentation for DeepSeek unavailability and `监视`.
- `AGENTS.md` now requires `cc` calls to carry a real context pack, not only the formal contract fields.
- `AGENTS.md` and [[local-cc-sidecar-agent-workflow]] now say long `cc` prompts should be piped through stdin and that generic readiness output is a failed handoff.
- [[local-cc-sidecar-agent-workflow]] now has a quick routing reference across Opus, Sonnet, DeepSeek / `鲸鱼`, and Codex-only fallback.
- `CLAUDE.md` now gives direct Claude Code sessions a project-local entry point without duplicating the full operating rules.
- [[model-collaboration-context-and-reference-intake]] now records that a partner answer must be verified as actually responsive before Codex treats it as evidence.

## Deferred Work

- DeepSeek API/CLI wrapper: useful later, but should be a separate adapter project with credentials, preflight, output schema, safety boundaries, and smoke tests.
- Programmatic router script: only worth building when there are more runtime paths or repeated routing failures that natural-language rules cannot handle.
- Global `C:\Users\admin\.claude\CLAUDE.md`: cross-project configuration and should be changed only on explicit request.
- Skill-folder bridging: defer unless a specific Claude Code skill needs to be installed or adapted; do not symlink whole Codex skill packs blindly.

## Practical Lesson

The critical failure mode is fake collaboration: a partner is named, but receives too little context, receives the wrong context, or never actually receives the prompt. Future agents should verify both halves of the handoff:

- the prompt included enough conversation, file, decision, and output-format context
- the returned answer actually addressed the scoped question

## Related Pages

- [[local-cc-sidecar-agent-workflow]]
- [[model-collaboration-context-and-reference-intake]]
- [[agent-collaboration-tone-and-model-roles]]
- [[durable-agent-rule-memory]]
