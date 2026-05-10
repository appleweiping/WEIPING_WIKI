---
title: D Drive Portfolio and Undergraduate Roots
type: source
status: ingested
created: 2026-05-10
updated: 2026-05-10
tags:
  - source
  - local-projects
  - portfolio
  - coursework
origin: local-filesystem
provenance: Read-only inspection of D-drive portfolio, undergraduate project, and study archives requested by the user.
source_files:
  - D:/Academic_portfolio
  - D:/WeipingYan_portfolio
  - D:/Undergraduate_project_netherlands
  - D:/Undergraduate_study_netherlands
---

# D Drive Portfolio and Undergraduate Roots

## Source Summary

This source records the content nature of several D-drive roots the user wants the wiki to know about for quick answering. It does not copy these folders into the wiki.

## Path Resolution

- EXTRACTED: Requested `D:/academic-portfolio` is absent; likely current equivalent is `D:/Academic_portfolio`.
- EXTRACTED: Requested `D:/weipingyan-portfolio` is absent; likely current equivalent is `D:/WeipingYan_portfolio`.
- EXTRACTED: Requested `D:/undergraducate-project-netherlands` is absent; likely current equivalent is `D:/Undergraduate_project_netherlands`.
- EXTRACTED: Requested `D:/undergraduate-study-netherlands` is absent; likely current equivalent is `D:/Undergraduate_study_netherlands`.

## Content Nature

- EXTRACTED: `D:/Academic_portfolio` is an academic/application document archive, not primarily a software repo.
- EXTRACTED: `D:/WeipingYan_portfolio` contains public portfolio/profile repos and a private memory-album style static site.
- EXTRACTED: `D:/Undergraduate_project_netherlands` is a collection of coursework/project repositories, including Venus Team 28 and other CS/embedded/robotics projects.
- EXTRACTED: `D:/Undergraduate_study_netherlands` is a broad undergraduate study archive with course materials, notes, attachments, and many active/untracked/deleted git changes.

## Sensitive Boundaries

- EXTRACTED: `D:/Academic_portfolio` contains high-sensitivity or personal materials such as application documents, transcripts, passport-related files, resumes, certificates, and logistics paperwork.
- EXTRACTED: `D:/Undergraduate_study_netherlands` contains personal information files and consent-form material, and its git state needs privacy triage before any push.
- EXTRACTED: `D:/WeipingYan_portfolio/starfield-animation` is explicitly private/personal and contains password-gated memory/photo/audio content.
- EXTRACTED: `Venus basestation` docs mention MQTT credentials and explicitly warn not to commit passwords.

## Discovery Heuristics

- INFERRED: Do not rely only on exact folder names. Search D-drive siblings case-insensitively for variants of `academic`, `portfolio`, `weiping`, `yan`, `under`, `grad`, `study`, `netherlands`, and `project`.
- INFERRED: Treat `.git`, `README.md`, `ARCHITECTURE.md`, `pyproject.toml`, `package.json`, `Cargo.toml`, `index.html`, `server.py`, `docs/`, `src/`, and deployment docs as project markers.
- INFERRED: Treat course-code folders such as `2IRR40`, `5EID0`, and `31EMA` as course anchors.
- INFERRED: Before modifying any external project, rescan the target root because names and internal structures may change.
- INFERRED: Avoid opening or summarizing personal PDFs/images/spreadsheets unless explicitly needed.

## Related Pages

- [[local-project-roots]]
- [[weipingyan-portfolio]]
- [[academic-portfolio]]
- [[undergraduate-projects-netherlands]]
- [[undergraduate-study-netherlands]]
