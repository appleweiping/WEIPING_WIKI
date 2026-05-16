---
title: 2026-05-16 Venus Team Project GitHub Archive
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - undergraduate
  - venus-project
  - github
  - gitlab
source_files:
  - D:/Undergraduate_project_netherlands/Venus basestation
  - D:/Undergraduate_project_netherlands/venus-team-28-gitlab
source_pages:
  - 2026-04-22-computer-software-ui-role-plan-for-5eid0
  - 2026-05-08-how-to-integrate-venus-basestation-with-team-gitlab
---

# 2026-05-16 Venus Team Project GitHub Archive

## Provenance

- Source: user request in chat to make `Venus basestation` show the complete Team 28 project context instead of only Vipin's computer software/UI module.
- GitHub archive: `https://github.com/appleweiping/venus-basestation`
- Team GitLab source at migration: `git@gitlab.tue.nl:d.gyftakis/venus-team-28.git`
- Local Team GitLab checkout at migration: `D:/Undergraduate_project_netherlands/venus-team-28-gitlab`
- Local GitLab `main` snapshot HEAD at migration: `44b08fde294700048a4f286c706800f2b92e306a`
- Local archive destination: `D:/Undergraduate_project_netherlands/Venus basestation`

## What Changed

- EXTRACTED: The public GitHub repository was reorganized as a full project archive with the shared team project and Vipin's own UI module separated.
- EXTRACTED: `team-project/` stores a source-focused snapshot of the Team 28 GitLab `main` branch.
- EXTRACTED: `team-project/module-branches/` stores source-focused snapshots of the GitLab module branches for communication, algorithm/navigation, embedded software, and mapping.
- EXTRACTED: `user-interface-module/` stores Vipin's original Python base-station/UI project with its docs, examples, tests, tools, and package files.
- EXTRACTED: `README.md` now describes the repository as a complete Venus Team 28 project archive rather than a standalone UI-only repo.

## Exclusions And Public-Safety Boundary

- EXTRACTED: Git internals, personal `sftp.json`, virtual environments, caches, generated runtime outputs, and generated Doxygen HTML were excluded from the public archive.
- EXTRACTED: The repository keeps the team context and UI module separate so the public page shows both the full project structure and Vipin's specific contribution.
- INFERRED: The GitLab repository remains the collaborative course source of truth; the GitHub repository is a public portfolio/archive mirror.
- INFERRED: Future updates should avoid committing credentials, private keys, real MQTT passwords, personal deployment configs, or bulky generated artifacts.

## Validation

- EXTRACTED: The UI module tests were run from `user-interface-module/` with `PYTHONPATH=src`.
- EXTRACTED: The project-local virtual environment was created under `user-interface-module/.venv` because the global Python environment lacked `pytest`.
- EXTRACTED: Validation result: `28 passed in 0.21s`.

## Related

- [[undergraduate-projects-netherlands]]
- [[2026-04-22-computer-software-ui-role-plan-for-5eid0]]
- [[2026-05-08-how-to-integrate-venus-basestation-with-team-gitlab]]
