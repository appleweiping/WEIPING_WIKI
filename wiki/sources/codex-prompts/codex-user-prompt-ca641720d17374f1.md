---
title: commit and push
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - automation
source_pages:
  - codex-prompt-corpus
---

# commit and push

## Metadata

- Stable ID: `codex-user-prompt:ca641720d17374f1`
- Source kind: `codex-session-user`
- Category: `automation`
- Timestamp: `2026-05-14T23:06:49.424Z`
- Semantic hash: `ca641720d17374f1d3c20b7c9de8804004677101d4889b7aeffbf53bf0c5b411`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
commit and push

Read the docs folder first, especially:
- docs/PROJECT_BRIEF.md
- docs/ARCHITECTURE.md
- docs/MVP_SCOPE.md
- docs/DATA_MODEL.md
- docs/MEDICAL_SAFETY.md
- docs/STATE_MACHINES.md
- docs/AGENTS.md
- docs/DEVELOPMENT_PLAN.md

Follow the product direction and constraints in the docs.

Important:
- Do not build a toy chat app.
- Do not build a traditional glucose dashboard.
- Do not let UI call the LLM directly.
- Do not generate diagnosis, prescription, medication-change, or insulin-dosing advice.
- All AI outputs must be structured, persisted, source-grounded, and safety-reviewed.
- The health record and timeline are the center of the product.
- Do not claim HIPAA compliance or regulated medical-device readiness.
- This task is private-alpha readiness, not feature expansion.

Task:
Prepare Medora for a small private alpha with 3–10 real users.

The goal is to harden the existing single-user MVP so it can be safely tested by a small group without expanding product scope.

Implement:
1. Basic alpha access and user ownership
 - Add a minimal authentication or alpha access gate suitable for private testing.
 - Ensure each user can only access their own PatientProfile and related records.
 - Keep implementation simple and local-first if no production auth provider is configured.
 - Do not build organization admin, clinician portal, caregiver sharing, or multi-tenant enterprise features.

2. Data export flow
 - Let a user export their health record data in a simple machine-readable format, preferably JSON.
 - Export should include:
 - PatientProfile
 - HealthDocument metadata
 - HealthDocumentExtraction
 - HealthMetric
 - GlucoseReading
 - Medication
 - SymptomEntry
 - TimelineEvent
 - Insight
 - DoctorSummary
 - SourceReference
 - SafetyReview
 - UserFeedback
 - AgentRun metadata and outputJson where appropriate
 - Do not include raw local file contents unless an existing safe local file export path already exists.
 - Include a short README or metadata block in the export explaining that the export is user-owned health record data and not medical advice.

3. Data deletion flow
 - Add a private-alpha data deletion path for the current user.
 - Deletion should support:
 - deleting user-owned PatientProfile data
 - deleting associated documents, timeline events, insights, summaries, safety reviews, source references, extracted facts, metrics, feedback, and agent runs
 - Use soft deletion where existing models support archivedAt/deletedAt.
 - If hard deletion is necessary for dependent records, do it in a safe transaction.
 - Add clear UI copy before deletion.
 - Do not silently delete another user’s data.

4. Privacy and safety notice
 - Add a private-alpha privacy/safety notice page or modal.
 - It should clearly state:
 - This is an alpha product.
 - It helps organize health information and prepare doctor conversations.
 - It is not a doctor, diagnosis system, emergency triage system, prescription system, insulin dosing system, or medical device.
 - Users should review AI-extracted information for accuracy.
 - Users should not change medication or insulin dosing based on the app.
 - Users should seek urgent medical care for severe, sudden, or emergency symptoms.
 - Do not make legal claims that are not implemented.

5. Manual review placeholder for high-risk output
 - Add a simple internal state/path for outputs with safetyStatus:
 - blocked
 - needs_clinician_review
 - failed
 - These outputs must not be displayed as normal user-facing insight or doctor-summary content.
 - The UI can show a safe generic message such as:
 “This output was not shown because it may require medical review or safer wording.”
 - Add a developer/admin-readable local view or script that lists blocked/high-risk outputs for inspection.
 - Do not build a full clinician review portal.

6. Workflow failure monitoring
 - Add lightweight local observability for:
 - failed AgentRun
 - schema validation failure
 - safety blocked
 - safety rewritten
 - missing SourceReference
 - feedback marked unsafe
 - Implement this as scripts, logs, database queries, or simple admin/dev page.
 - Do not add external monitoring vendors unless already present.

7. Onboarding copy
 - Add minimal onboarding copy for first private-alpha users.
 - Explain the core loop:
 - create/check profile
 - paste or upload health information
 - review extracted facts
 - inspect timeline
 - review safety-reviewed insights
 - generate doctor summary
 - give feedback
 - Keep the product positioned as a personal health record and doctor-prep workflow, not an AI doctor.

Scope:
Only modify or add files in these areas:
- apps/web/app/
- apps/web/features/
- apps/web/src/server/
- apps/web/components/
- apps/web/lib/
- apps/web/scripts/
- packages/db/prisma/
- packages/db/services/
- packages/db/repositories/
- packages/db/scripts/
- packages/core/domain/
- packages/core/services/
- packages/ai/observability/
- packages/ai/scripts/
- package.json only for new validation scripts
- README.md or package READMEs only to document private-alpha commands and flows

Do not modify core AI workflow behavior unless needed for safety visibility or ownership checks.
Do not add new medical reasoning workflows.
Do not add chat.
Do not add CGM integrations.
Do not add OCR.
Do not add caregiver sharing.
Do not add clinician portal.
Do not add payments.
Do not add production compliance claims.
Do not bypass safety review.
Do not expose blocked unsafe outputs.

Deliverables:
1. Alpha access / ownership
 - Minimal auth or alpha gate.
 - Server-side helper to resolve current user and current patient profile.
 - Ownership checks for profile, inbox, timeline, insights, doctor summary, feedback, export, and deletion operations.
 - Validation proving cross-user access is rejected or impossible.

2. Export
 - Server action or route for exporting the current user’s health record.
 - Export service that gathers all user-owned health record objects.
 - JSON export format with version, generatedAt, patientProfile, records, AI audit records, safety reviews, source references, and feedback.
 - UI button or private-alpha settings page entry.

3. Deletion
 - Server action or route for deleting current user data.
 - Transactional deletion or soft-deletion service.
 - Confirmation UI.
 - Validation script proving records are deleted or marked deleted only for the current user.

4. Privacy and safety notice
 - Page or modal visible in onboarding/settings.
 - Copy aligned with docs/MEDICAL_SAFETY.md.
 - No diagnosis, treatment, medication-change, insulin-dosing, emergency-triage, or HIPAA claims.

5. High-risk output handling
 - Ensure blocked / needs_clinician_review / failed safety outputs are not rendered as normal insights or ready summaries.
 - Add developer-readable blocked-output inspection script or simple internal page.
 - Include AgentRun id, workflowName, safetyStatus, flags, reasons, and createdAt.

6. Observability
 - Add script such as:
 - npm run alpha:healthcheck
 - npm run alpha:blocked-outputs
 - npm run alpha:workflow-failures
 - These scripts should summarize:
 - failed AgentRuns
 - blocked SafetyReviews
 - rewritten SafetyReviews
 - unsafe UserFeedback
 - missing SourceReferences for active insights or ready doctor summaries
 - doctor summaries missing safety review
 - active insights missing safety review

7. Onboarding
 - Add simple onboarding or getting-started copy.
 - It should guide users through the MVP loop without implying medical advice.

Validation:
Run and pass:
- npm install
- npm run db:generate
- npm run db:migrate
- npm run db:seed
- npm run typecheck
- npm run db:validate-ingestion
- npm run ai:validate-workflow
- npm run ai:validate-initial-workflows
- npm run ai:validate-provider-config
- npm run web:validate-data
- existing single-user E2E validation script
- existing eval script
- existing safety regression validation script
- existing feedback validation script
- new alpha readiness validation script
- new export validation script
- new deletion validation script
- new blocked-output / workflow-failure healthcheck scripts

The new alpha readiness validation must assert at minimum:
- A current user can only access their own PatientProfile.
- A current user can only list their own documents, timeline events, insights, doctor summaries, feedback, safety reviews, source references, and agent runs.
- Export includes the required health record and AI audit objects.
- Export does not include another user’s data.
- Deletion only affects the current user’s data.
- Deleted or archived data is no longer shown in normal UI.
- Active insights have SafetyReview.
- Ready doctor summaries have SafetyReview.
- Active insights and ready doctor summaries have SourceReference.
- Blocked safety outputs are not displayed as active insights.
- Blocked safety outputs are not displayed as ready doctor summaries.
- Unsafe feedback is persisted and visible in the alpha healthcheck.
- Privacy/safety notice exists and does not make unsupported compliance or medical claims.

Manual validation:
1. Start the app locally after seeding.
2. Complete onboarding or view the private-alpha notice.
3. Create or open the demo patient profile.
4. Submit a glucose-related note through /inbox.
5. Confirm /timeline, /insights, /doctor-summary, and /profile still work.
6. Submit feedback on an insight and a doctor summary.
7. Export the health record and inspect the JSON.
8. Run the alpha healthcheck script.
9. Trigger or seed a blocked safety output and confirm it is not displayed as normal user-facing content.
10. Delete the current user’s data.
11. Confirm normal UI no longer shows deleted records.
12. Confirm no diagnosis, prescription, medication-change, insulin-dosing, emergency-downplaying, or unsupported HIPAA/compliance claims appear anywhere.

Expected final state:
Medora should be private-alpha ready in a narrow, honest sense:
- small-user access is gated
- user data ownership is enforced
- users can export their data
- users can delete their data
- safety and privacy copy is visible
- high-risk outputs are blocked from normal display
- workflow failures and unsafe feedback can be inspected
- the existing health-record-first E2E MVP remains intact
- the product still does not behave like a chat app, glucose dashboard, AI doctor, or regulated medical device.

commit and push
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
