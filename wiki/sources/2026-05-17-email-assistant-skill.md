---
title: 2026-05-17 Email Assistant Skill
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - agent-skills
  - email
  - gmail
  - google-workspace
source_files:
  - "D:/Research/vipin's knowledgebase/skill/email-assistant/SKILL.md"
  - "D:/Research/vipin's knowledgebase/.codex/skills/email-assistant/SKILL.md"
source_pages:
  - https://github.com/benchflow-ai/skillsbench/tree/main/tasks_excluded/scheduling-email-assistant/environment/skills/gmail-skill
  - https://github.com/glebis/claude-skills/tree/main/gmail
  - https://github.com/openai/skills
  - https://developers.google.com/gmail/api
---

# 2026-05-17 Email Assistant Skill

## Provenance

- Source: user request to install or create a dedicated email-reading/writing skill for two Gmail/Google Workspace accounts: UMN and `vipinapple`.
- Upstream comparison:
  - EXTRACTED: `openai/skills` is a popular skill repository but did not expose a direct user Gmail/Outlook mail skill during this session's search.
  - EXTRACTED: `benchflow-ai/skillsbench` contained the strongest Gmail base skill, with search, read, send, draft, label, and multi-account scripts.
  - EXTRACTED: `glebis/claude-skills` contained a simpler Gmail search/fetch skill.
- Selected base: `benchflow-ai/skillsbench` Gmail skill.
- Upstream HEAD inspected locally: `30d31e972211c2287e63257a5f5c05eba5d74bba`.
- Local source mirror: `skill/email-assistant/`.
- Installed skill: `.codex/skills/email-assistant/`.

## Local Adaptation

- EXTRACTED: Renamed the installed skill to `email-assistant`.
- EXTRACTED: Added Codex-facing `SKILL.md` instructions for Vipin's personal email workflow.
- EXTRACTED: Added `agents/openai.yaml` UI metadata.
- EXTRACTED: Reworked auth path resolution so credentials and tokens default to `.wiki-tmp/email-assistant/auth/`, not the skill source tree.
- EXTRACTED: Added `.wiki-tmp/email-assistant/logs/` action logging with body/token redaction.
- EXTRACTED: Removed high-side-effect upstream scripts for filters, forwarding, token migration, and paywall cleanup.
- EXTRACTED: Added an `email-message.js` helper shared by direct sends and draft creation/update.
- EXTRACTED: Updated setup docs to use local `D:\cc\node\corepack.cmd pnpm` because `npm` was not available on PATH during installation.

## Safety And Approval Model

- EXTRACTED: Default workflow is draft-only.
- EXTRACTED: `gmail-send.js` refuses to send without `--confirm-send YES_SEND`.
- EXTRACTED: `gmail-drafts.js --action send` refuses to send without `--confirm-send YES_SEND`.
- EXTRACTED: `gmail-drafts.js --action delete` refuses to delete without `--confirm-delete YES_DELETE`.
- EXTRACTED: `gmail-labels.js` refuses create/add/remove actions without `--confirm-modify YES_MODIFY`.
- EXTRACTED: Browser automation is documented as fallback only for OAuth login, manual review, or web-only workflows.
- INFERRED: This design matches the user's preference: agent reads and drafts quietly, user reviews, then explicitly approves sending.

## Verification

- EXTRACTED: `pnpm install` completed under `.codex/skills/email-assistant/`; `node_modules/` remains ignored and is not intended for Git.
- EXTRACTED: `quick_validate.py .codex/skills/email-assistant` passed after installing PyYAML locally under `.wiki-tmp/python`.
- EXTRACTED: `node --check` passed for all installed JavaScript scripts.
- EXTRACTED: `node scripts/manage-accounts.js --list` handled no configured accounts cleanly.
- EXTRACTED: `node scripts/auth/setup-oauth.js --account umn --email test@example.com` failed safely when `credentials.json` was absent and printed the `.wiki-tmp/email-assistant/auth/credentials.json` path.
- EXTRACTED: `node scripts/gmail-send.js --to user@example.com --subject Test --body Body` failed safely without `--confirm-send YES_SEND`.
- EXTRACTED: `node scripts/gmail-drafts.js --action send --id draft123` failed safely without `--confirm-send YES_SEND`.
- EXTRACTED: `node scripts/gmail-search.js --account umn --query "is:unread" --limit 1` failed safely because OAuth accounts are not configured yet.
- EXTRACTED: `node scripts/gmail-labels.js --account umn --action create --name TestLabel` failed safely without `--confirm-modify YES_MODIFY`.
- EXTRACTED: Opus performed a read-only privacy/security review and reported no blocker; its main maintenance suggestion was to remove duplicated email-message construction, which was addressed.

## Limitations

- AMBIGUOUS: Live Gmail read/search/draft tests are pending user OAuth for `umn` and `vipinapple`.
- AMBIGUOUS: UMN may or may not permit Gmail API OAuth through the user's account; if it fails, future agents should record `umn` as pending rather than silently switching to browser-only automation.
- INFERRED: Concurrent token refresh could race if multiple mail scripts run at once, but this is low-risk for a personal single-user workflow.

## Related

- [[email-assistant-skill]]
- [[agent-skill-installation-workflow]]
- [[chrome-automation]]
