---
name: email-assistant
description: Personal Gmail and Google Workspace email assistant for Vipin. Use when Codex needs to search, read, summarize, translate, triage, draft, update drafts, or user-approved send email for the UMN and vipinapple Gmail accounts. Optimized for API-first low-interruption workflows, Chinese summaries of English email, polished email drafting, multi-account Gmail profiles, and explicit user approval before any send action.
---

# Email Assistant

Use this skill for Vipin's Gmail/Google Workspace email workflows: reading, searching, explaining, summarizing, drafting, and updating Gmail drafts across the `umn` and `vipinapple` account profiles.

## Defaults

- Use Gmail API scripts first. Do not open or control the browser for routine mail reading or drafting.
- Keep normal output in Chinese unless the user asks otherwise.
- Write outgoing professional or UMN mail in polished English unless the thread clearly uses another language.
- Default to draft-only. Never send email unless the user explicitly says to send.
- Use browser automation only for OAuth login, manual user review, or web-only fallback, and only with explicit confirmation before live account actions.
- Do not store email bodies, tokens, cookies, credentials, browser profiles, or private mail content in the public wiki or Git.

## Local Paths

Skill install:

```powershell
D:\Research\vipin's knowledgebase\.codex\skills\email-assistant
```

Source mirror:

```powershell
D:\Research\vipin's knowledgebase\skill\email-assistant
```

OAuth files are local-only and ignored by Git:

```powershell
D:\Research\vipin's knowledgebase\.wiki-tmp\email-assistant\auth\credentials.json
D:\Research\vipin's knowledgebase\.wiki-tmp\email-assistant\auth\tokens.json
```

Override paths only when needed:

```powershell
$env:EMAIL_ASSISTANT_AUTH_DIR = "D:\Research\vipin's knowledgebase\.wiki-tmp\email-assistant\auth"
$env:EMAIL_ASSISTANT_LOG_DIR = "D:\Research\vipin's knowledgebase\.wiki-tmp\email-assistant\logs"
```

## First-Time Setup

From the skill directory:

```powershell
& "D:\cc\node\corepack.cmd" pnpm install
```

Create a Google Cloud OAuth Desktop credential with Gmail API enabled, then save the downloaded `credentials.json` to:

```powershell
.wiki-tmp\email-assistant\auth\credentials.json
```

Authenticate both accounts:

```powershell
& "D:\cc\node\corepack.cmd" pnpm run setup -- --account umn --email "<umn email address>"
& "D:\cc\node\corepack.cmd" pnpm run setup -- --account vipinapple --email "<vipinapple email address>"
node scripts/manage-accounts.js --list
```

If UMN cannot authenticate through Gmail API, mark `umn` as pending and keep `vipinapple` usable. Do not replace v1 with fragile browser-only mail handling.

## Workflow

1. Clarify which account to use when ambiguous: `umn` or `vipinapple`.
2. Search/read the smallest relevant set of messages.
3. Summarize in Chinese:
   - sender
   - what they want
   - deadline or time sensitivity
   - risk or hidden obligation
   - suggested response
4. Draft the reply and show it to the user.
5. Create or update a Gmail draft when requested.
6. Send only after explicit approval, using `--confirm-send YES_SEND`.

## Commands

Run scripts from the skill directory:

```powershell
cd "D:\Research\vipin's knowledgebase\.codex\skills\email-assistant"
```

List accounts:

```powershell
node scripts/manage-accounts.js --list
```

Search unread UMN mail:

```powershell
node scripts/gmail-search.js --account umn --query "is:unread" --limit 10
```

Search likely action items:

```powershell
node scripts/gmail-search.js --account umn --query "(deadline OR due OR bill OR course OR visa OR housing) newer_than:30d" --limit 20
```

Read one message:

```powershell
node scripts/gmail-read.js --account umn --id "<message-id>" --thread
```

Create a draft:

```powershell
node scripts/gmail-drafts.js --account umn --action create --to "person@example.com" --subject "Subject" --body "Draft body"
```

Update a draft:

```powershell
node scripts/gmail-drafts.js --account umn --action update --id "<draft-id>" --to "person@example.com" --subject "Subject" --body "Updated body"
```

Send a direct message only after explicit user approval:

```powershell
node scripts/gmail-send.js --account umn --to "person@example.com" --subject "Subject" --body "Body" --confirm-send YES_SEND
```

Send an approved draft:

```powershell
node scripts/gmail-drafts.js --account umn --action send --id "<draft-id>" --confirm-send YES_SEND
```

## Safety Rules

- Prefer drafts over sends.
- Do not delete messages.
- Do not create filters or forwarding rules unless the user explicitly asks and understands the account-wide effect.
- Do not expose raw email content in wiki pages, logs, commit messages, or partner prompts.
- When calling read-only partners for review, redact sender addresses and message bodies unless the user explicitly approves sharing.
- If OAuth opens a browser, tell the user first because it may need manual account login.

## Useful User Prompts

- "帮我看 UMN 未读邮件，中文讲重点。"
- "把这封英文邮件讲人话。"
- "帮我回这封邮件，先写草稿。"
- "查一下 UMN 有没有 deadline / bill / course / visa 相关邮件。"
- "写好草稿，我确认后再发。"
