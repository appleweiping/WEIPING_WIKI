---
title: Email Assistant Skill
type: entity
status: active
created: 2026-05-17
updated: 2026-05-18
tags:
  - entity
  - agent-skills
  - email
  - gmail
  - google-workspace
source_pages:
  - 2026-05-17-email-assistant-skill
---

# Email Assistant Skill

## Role In The Wiki

`email-assistant` is a project-local Codex skill for low-interruption Gmail / Google Workspace email workflows across Vipin's `umn` and `vipinapple` account profiles.

## Current Claims

- EXTRACTED: The skill is installed under `.codex/skills/email-assistant/`.
- EXTRACTED: The source mirror is under `skill/email-assistant/`.
- EXTRACTED: It is derived from `benchflow-ai/skillsbench`'s `gmail-skill`, with local safety and workflow changes.
- EXTRACTED: It uses Gmail API scripts first rather than browser control for normal reading, searching, and drafting.
- EXTRACTED: OAuth credentials and tokens default to `.wiki-tmp/email-assistant/auth/`, which is ignored by Git.
- EXTRACTED: The installed scripts support account IDs `umn` and `vipinapple` through `--account`.
- EXTRACTED: Direct sends require `--confirm-send YES_SEND`.
- EXTRACTED: Sending a draft also requires `--confirm-send YES_SEND`.
- EXTRACTED: Draft deletion requires `--confirm-delete YES_DELETE`.
- EXTRACTED: Label/message modification requires `--confirm-modify YES_MODIFY`.
- EXTRACTED: Removed upstream scripts for filters, forwarding, migration, and paywall cleanup to reduce account-wide side effects.

## Usage

Use this skill for prompts such as:

```text
帮我看 UMN 未读邮件，中文讲重点。
把这封英文邮件讲人话。
帮我回这封邮件，先写草稿。
查一下 UMN 有没有 deadline / bill / course / visa 相关邮件。
写好草稿，我确认后再发。
```

Expected workflow:

1. Choose `umn` or `vipinapple`.
2. Search/read only the smallest relevant mail set.
3. Summarize in Chinese: sender, request, deadline, risk, and suggested response.
4. Draft or update a Gmail draft.
5. Send only after explicit user approval.

## Local Commands

```powershell
cd "D:\Research\vipin's knowledgebase\.codex\skills\email-assistant"
& "D:\devtools\node\corepack.cmd" pnpm install
& "D:\devtools\node\corepack.cmd" pnpm run setup -- --account umn --email "<umn email address>"
& "D:\devtools\node\corepack.cmd" pnpm run setup -- --account vipinapple --email "<personal email address>"
node scripts/manage-accounts.js --list
```

## Safety Boundary

- Do not commit credentials, tokens, browser profiles, cookies, or email bodies.
- Do not copy raw private email content into public wiki pages or partner prompts.
- Prefer drafts over sends.
- Browser automation is only a fallback for OAuth login, manual review, or web-only workflows.
- If UMN blocks Gmail API authentication, mark `umn` as pending and keep `vipinapple` working instead of replacing v1 with a fragile browser-only flow.

## Verification Record

- EXTRACTED: Dependencies installed locally with `D:\devtools\node\corepack.cmd pnpm install` after the D-drive tool runtime moved from `D:\cc` to `D:\devtools`.
- EXTRACTED: `quick_validate.py` passed after installing PyYAML into `.wiki-tmp/python`.
- EXTRACTED: `node --check` passed for all installed JavaScript scripts.
- EXTRACTED: `manage-accounts --list` reports no configured accounts cleanly when OAuth tokens are absent.
- EXTRACTED: OAuth setup reports the `.wiki-tmp/email-assistant/auth/credentials.json` path when credentials are absent.
- EXTRACTED: Direct send and draft-send smoke tests fail closed without `--confirm-send YES_SEND`.
- EXTRACTED: Label modification fails closed without `--confirm-modify YES_MODIFY`.
- AMBIGUOUS: Live Gmail search/read/draft creation still requires the user to complete OAuth for each account.

## Related Pages

- [[2026-05-17-email-assistant-skill]]
- [[agent-skill-installation-workflow]]
- [[chrome-automation]]
