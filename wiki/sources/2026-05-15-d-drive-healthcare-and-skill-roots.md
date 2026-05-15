---
title: D Drive Healthcare And Skill Roots
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - source
  - local-projects
  - healthcare
  - agent-skills
source_files:
  - D:/Healthcare/Medora
  - D:/Skill/anbeime-skill
  - D:/Skill/colleague-skill
  - D:/Skill/darwin-skill
  - D:/Skill/mattpocock-skills
  - D:/Skill/nuwa-skill
source_pages:
  - medora
  - healthcare-projects
  - agent-skill-repositories
---

# D Drive Healthcare And Skill Roots

## Provenance

- Source: user request in chat on 2026-05-15 to ingest the D-drive `Healthcare` and `Skill` roots.
- Inspection mode: read-only local filesystem and git metadata survey.
- Scope: public-safe content-nature inventory, not a copy of the source folders.
- Related routing topic: [[local-project-roots]].

## Source Scope

This source records the current shape of `D:/Healthcare` and `D:/Skill` so future sessions can route quickly to the right local project or repository. It intentionally avoids storing private health records, local database contents, credentials, or generated logs.

## Healthcare Root

- EXTRACTED: `D:/Healthcare` currently contains one project root, `D:/Healthcare/Medora`.
- EXTRACTED: `D:/Healthcare/Medora` is a git repository on branch `main`, tracking `https://github.com/appleweiping/Medora.git`, with a clean working tree at inspection time.
- EXTRACTED: The root package is `medora` version `0.1.0`, marked private.
- EXTRACTED: The repository is a TypeScript/Next.js monorepo with `apps/web` and packages including `@medora/ai`, `@medora/core`, `@medora/db`, and `@medora/shared`.
- EXTRACTED: The README defines [[medora]] as an AI-native personal health record and healthcare workflow system.
- EXTRACTED: The first product vertical is glucose, diabetes, and metabolic health.
- EXTRACTED: The current status is a local-first private-alpha MVP for a small, closely monitored test group.
- EXTRACTED: The project includes a Next.js web app, Prisma-backed data model, workflow-based AI layer, provider abstraction, deterministic mock provider, OpenAI provider boundary, rule-based medical safety guard, private-alpha controls, and validation scripts.
- EXTRACTED: The documentation states that Medora does not claim production security readiness, HIPAA compliance, regulated medical-device readiness, emergency-triage capability, prescription authority, diagnosis capability, or insulin-dosing capability.
- INFERRED: Local storage folders, SQLite databases, logs, and uploaded health artifacts under this root should be treated as high-sensitivity even if some current files are synthetic or test data.

## Skill Root

- EXTRACTED: `D:/Skill` currently contains five git repositories:
  - [[anbeime-skill]] at `D:/Skill/anbeime-skill`
  - [[colleague-skill]] at `D:/Skill/colleague-skill`
  - [[darwin-skill]] at `D:/Skill/darwin-skill`
  - [[mattpocock-skills]] at `D:/Skill/mattpocock-skills`
  - [[nuwa-skill]] at `D:/Skill/nuwa-skill`
- EXTRACTED: All five inspected skill repositories had clean working trees at inspection time.
- EXTRACTED: `anbeime-skill` tracks `https://github.com/appleweiping/skill.git` on branch `main`; it is a skill-store / skill-library project with crawler, data management, scheduling, API integration, web pages, and many collected `SKILL.md` files.
- EXTRACTED: `colleague-skill` tracks `https://github.com/appleweiping/colleague-skill.git` on branch `dot-skill`; it describes `dot-skill`, a meta-skill for distilling colleagues, relationships, public figures, or characters into reusable skills.
- EXTRACTED: `darwin-skill` tracks `https://github.com/appleweiping/darwin-skill.git` on branch `master`; it is an autonomous skill optimizer inspired by Karpathy's `autoresearch`.
- EXTRACTED: `mattpocock-skills` tracks `https://github.com/appleweiping/skills.git` on branch `main`; it is a collection of small composable engineering/productivity skills for coding agents.
- EXTRACTED: `nuwa-skill` tracks `https://github.com/appleweiping/nuwa-skill.git` on branch `main`; it creates person-perspective skills by researching, extracting, and validating how a person thinks.

## Safety And Routing Notes

- Healthcare project details should stay public-safe unless the user explicitly asks for private handling.
- Do not store personal medical records, local database contents, uploaded artifacts, health measurements, patient names, or clinician contact details in the public wiki.
- Before editing any external root, rescan the live repository and run `git status --short --branch` inside that root.
- Treat generated logs, local databases, and cache/storage folders as non-source operational artifacts unless the user explicitly asks to debug them.

## Counterpoints And Gaps

- This is a shallow routing ingest. It does not inspect all documents, all code paths, or all generated data.
- The Medora health-data safety assessment is conservative because healthcare data can become sensitive even when filenames look generic.
- The skill repositories are summarized at repository level; individual skill quality and installability were not validated.
- Folder names and branches can change, so future current-state claims require a live rescan.

## Related Pages

- [[medora]]
- [[healthcare-projects]]
- [[agent-skill-repositories]]
- [[local-project-roots]]
