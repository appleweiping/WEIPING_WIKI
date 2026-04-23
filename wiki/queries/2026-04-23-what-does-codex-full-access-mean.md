---
title: What Does Codex Full Access Mean
type: query
status: active
created: 2026-04-23
updated: 2026-04-23
tags:
  - query
  - codex
  - permissions
  - safety
source_files:
  - chat
---

# What Does Codex Full Access Mean

## Question

What does `Codex full access` mean, why is it warned about, and what boundary should apply in practice?

## Short Answer

`Full access` means the agent may be able to read, write, and run commands across a much wider part of the local machine than the current project.

The warning exists because broader permissions increase the impact of mistakes.

Vipin's rule for this repository is:

- do **not** modify files outside the current project unless the user explicitly asks for it
- if touching another project may help, confirm first before making changes

## Why The Warning Exists

The issue is not that the agent will automatically start editing random files.

The issue is that once permissions are wider:

- the reachable file scope is larger
- a mistaken path or overly broad command can affect more than the intended project
- installs, Git actions, and filesystem writes can have broader consequences

So the warning is about risk surface, not about a promise that the agent will misbehave.

## Practical Interpretation

In normal operation, the agent should still follow user intent and task scope.

Broader access should be used only to complete requested work more effectively, not to opportunistically edit unrelated files.

## Repository Rule

For `vipin wiki`, the durable rule is:

- default write scope = current project or explicitly named repository
- project-external edits require either:
  - explicit user instruction, or
  - confirmation first

This keeps broad local access from becoming broad editing authority.

## Counterpoints and Gaps

- broad access can still be useful for multi-repository work when the user clearly asks for it
- the main remaining risk is ambiguous wording from the user, which is why cross-project changes should stay explicit

## Related

- [[2026-04-22-how-to-reduce-github-submit-prompts]]
- [[queries-home]]
- [[index]]
- [[log]]
