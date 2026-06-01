---
title: Local Active Project Roots
type: topic
status: active
created: 2026-06-01
updated: 2026-06-01
tags:
  - topic
  - local-projects
  - active-projects
  - computer-map
source_pages:
  - whole-computer-project-map
  - local-project-roots
source_files:
  - D:/Project/legal-case-automation/README.md
  - D:/Company/Engineering intelligence/README.md
  - D:/Healthcare/Medora/README.md
  - D:/Game_develop/ai-town/README.md
  - D:/frontend/pretext/README.md
---

# Local Active Project Roots

## Scope

This page gives future agents a detailed, public-safe route into currently important non-research local project roots. It complements [[whole-computer-project-map]], which decides how deeply to inspect each drive/root, and [[research-project-workbench]], which remains the route for research experiment projects.

EXTRACTED: The entries below are based on a shallow live inventory plus top-level README/AGENTS/CLAUDE/package evidence inspected on 2026-06-01.

## Active Root Table

| Root | What it is | Read first | Safety boundary |
| --- | --- | --- | --- |
| `D:/Project/legal-case-automation` | Local-first legal material intake and drafting assistant for consumer-rights/civil/admin case organization. | `README.md`, `AGENTS.md`, `pyproject.toml`, `src/`, `tests/`, `docs/`. | Treat client materials, evidence, generated case workspaces, API keys, and legal drafts as sensitive. Do not publish sample/client details. |
| `D:/Company/Engineering intelligence` | Veylora, an AI-native engineering/decision intelligence platform built with Next.js/React/TypeScript. | `README.md`, `CLAUDE.md`, `package.json`, `src/`, `docs/`, `e2e/`. | Private product/company-intelligence project. Do not expose private business data, test results with secrets, or credentials. |
| `D:/Healthcare/Medora` | AI-native personal health record and healthcare workflow system; local-first private-alpha MVP. | `README.md`, `AGENTS.md`, `package.json`, `apps/`, `packages/`, `docs/`, [[medora]]. | High sensitivity. Do not publish health records, local DB contents, uploads, clinician details, measurements, or user records. |
| `D:/Game_develop/ai-town` | Agent Town, a gamified AI workspace currently rebuilding around a Godot client and local FastAPI/backend evidence loops. | `README.md`, `CLAUDE.md`, `godot/`, `backend/`, `docs/`, `tools/`, `screenshots/`. | Game/project evidence is public-safe only at routing level. Do not run launchers or mutate workspace evidence unless explicitly scoped. |
| `D:/frontend/pretext` | Pretext, a TypeScript/JavaScript multiline text measurement and layout library. | `README.md`, `AGENTS.md`, `CLAUDE.md`, `package.json`, `src/`, `benchmarks/`, `corpora/`, `status/`. | Respect upstream/license boundaries and benchmark/corpora provenance. Treat local demos as examples, not canonical claims. |
| `D:/WeipingYan_portfolio/appleweiping.github.io` | Public academic website/profile repository. | `README.md`, `README_ENGLISH.md`, `README_PROJECT_HANDOFF.md`, `assets/`, `images/`, `src/`, [[weipingyan-portfolio]]. | Public profile material is safe; private contact details and unpublished documents need review. |
| `D:/WeipingYan_portfolio/appleweipingappleweiping` | GitHub profile README repository. | `README.md`, `.github/`, `.codex/`, [[weipingyan-portfolio]]. | Public profile route; avoid adding private biographical details without review. |
| `D:/WeipingYan_portfolio/starfield-animation` | Private memory-album/starfield site. | `README.md`, `LICENSE`, `assets/`, `css/`, `js/`, [[weipingyan-portfolio]]. | Sensitive/private memory material. Public wiki should record only routing and safety boundaries. |

## Lightweight / Archive Roots

| Root | Current evidence | Default handling |
| --- | --- | --- |
| `D:/frontend/beauty-love` | Top-level `source/`; no obvious README in the root at inspection time. | Treat as generated/presentation or asset project until a user asks for it. Keep summary-level routing only. |
| `D:/frontend/life-did-not-spare-you` | No obvious top-level README at inspection time; likely related to prior HTML PPT work. | Route through [[html-ppt-agent-workflow]] and inspect only on explicit deck/presentation tasks. |
| `D:/frontend/frontend-design-test` | No obvious top-level README at inspection time. | Treat as local design test/scratch root. Do not elevate unless reused. |
| `D:/CS project/AI foundation models` | Contains `doravmon_extra_package`; no obvious top-level README at inspection time. The root stayed physically at `D:/` during the 2026-06-01 D-root organization pass because Windows denied the directory move. | Coursework/project archive. Inspect only when a course/project question names it; treat as a classified locked exception until a later retry. |
| `D:/Academic_portfolio` | Application/course/archive folders including `umn`, school-application material, exemption/double-degree/course folders. This root is now a compatibility junction to `D:/_Organized/Documents-Private/_RootDirs/Academic_portfolio`. | Sensitive archive. Public wiki records content nature only. |
| `G:/我的云端硬盘` | Cloud-drive root observed under `G:/`. | Cloud/synced material. Keep shallow unless explicitly relevant. |

## Research Boundary

`D:/Research` contains important research roots including Analog/AI4EDA, recommendation, AI4S, DoneBench, local agent projects, and this wiki. Do not use this page to enter experiments. Use [[research-project-workbench]] and the target project's own instructions, and do not modify datasets, checkpoints, logs, result files, or experiment progress during general maintenance.

## Refresh Rules

- Refresh this page when a root gains or loses README/AGENTS/CLAUDE/package evidence, when a root becomes active/inactive, or when a new high-use project appears.
- If a root becomes repeatedly used, promote it to its own entity/topic page.
- If a root contains sensitive material, keep public notes at the routing/purpose/boundary level.
- If a root has no obvious docs, record that fact rather than inventing purpose from folder names.

## Counterpoints And Gaps

- This page does not inspect source code deeply; it is a launch map, not an architecture review.
- Some active work may live under repositories not listed here; future agents should rerun shallow inventory before claiming completeness.
- README status can drift; use live repo instructions before edits.

## Related

- [[whole-computer-project-map]]
- [[local-project-roots]]
- [[research-project-workbench]]
- [[healthcare-projects]]
- [[medora]]
- [[weipingyan-portfolio]]
