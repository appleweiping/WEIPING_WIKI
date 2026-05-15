---
title: Medora
type: entity
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - entity
  - project
  - healthcare
  - ai
  - local-project
source_pages:
  - 2026-05-15-d-drive-healthcare-and-skill-roots
---

# Medora

## Role In The Wiki

Medora is Vipin's local healthcare project under `D:/Healthcare/Medora`. It should be treated as a high-sensitivity project root because it concerns personal health records and healthcare workflows.

## Current Claims

- EXTRACTED: The repository defines Medora as an AI-native personal health record and healthcare workflow system.
- EXTRACTED: Its first product vertical is glucose, diabetes, and metabolic health.
- EXTRACTED: The current status is a local-first private-alpha MVP for a small, closely monitored test group.
- EXTRACTED: The app surfaces include profile, inbox, timeline, insights, doctor summary, settings, onboarding, privacy/safety, and alpha access.
- EXTRACTED: The architecture uses a Next.js web app, Prisma-backed data model, TypeScript packages, workflow-based AI layer, provider abstraction, Zod validation, safety guard, persistence, and validation scripts.
- EXTRACTED: The docs explicitly rule out diagnosis, prescription, medication or insulin dose adjustment, emergency triage, production security readiness, HIPAA compliance claims, and regulated medical-device claims.
- INFERRED: Medora is best treated as a healthcare workflow and longitudinal record project, not a chat-with-PDF app or a traditional glucose dashboard clone.

## Local Routing

- Local root: `D:/Healthcare/Medora`.
- Git remote: `https://github.com/appleweiping/Medora.git`.
- Branch at inspection: `main`.
- Major folders:
  - `apps/web` - Next.js app.
  - `packages/ai` - AI workflow/provider/safety layer.
  - `packages/core` - domain and workflow state logic.
  - `packages/db` - Prisma/database services and local storage.
  - `packages/shared` - shared package.
  - `docs` - project brief, architecture, data model, MVP scope, medical safety, and development plan.

## Safety Boundary

- Do not copy local health records, uploaded documents, SQLite database rows, generated local-storage contents, patient details, medication details, clinician contact details, or logs into the public wiki.
- For actual medical decisions, treat the wiki as project memory only. It is not medical advice.
- Use [[healthcare-projects]] for routing and safety reminders before opening deeper files.

## Related Pages

- [[healthcare-projects]]
- [[2026-05-15-d-drive-healthcare-and-skill-roots]]
