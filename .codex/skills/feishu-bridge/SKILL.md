---
name: feishu-bridge
description: Route Feishu/Lark content access for Codex. Use when the user asks to read, summarize, extract, search, create, update, or fill Feishu/Lark links, documents, wikis, Drive files, Base/bitable tables, Sheets, messages, forms, or pages; when Chinese prompts mention 飞书、飞书文档、飞书知识库、飞书多维表格、飞书表单、飞书链接、Lark, or lark-cli; or when deciding whether to use official Lark/Feishu API commands or Chrome automation for logged-in web pages.
---

# Feishu Bridge

Use this as the router for Feishu/Lark work. Prefer official `lark-cli` API access whenever a task can be expressed as Docs/Wiki/Drive/Base/Sheets/IM/Calendar/etc. Use `chrome-automation` only for web-only flows such as opening arbitrary shared links, pages that require the user's live browser login state, or filling interactive forms.

## Local Runtime

Use the verified D-drive binary first:

```powershell
$LARK_CLI = "D:\Research\vipin's knowledgebase\.wiki-tmp\tools\lark-cli\v1.0.32\bin\lark-cli.exe"
& $LARK_CLI --version
```

Installed version: `lark-cli 1.0.32`, from `larksuite/cli` release `v1.0.32`.

## Routing

1. Read `lark-shared/SKILL.md` before configuring, logging in, switching identities, or handling scope errors.
2. If the user gives a Feishu/Lark document or asks to read/summarize/update a doc, use `lark-doc`. For docs v2 commands, always pass `--api-version v2`.
3. If the user asks about a knowledge base / wiki node, use `lark-wiki`.
4. If the user asks to search, upload, download, find a file, manage comments, or discover cloud objects, use `lark-drive` first.
5. If a document contains an embedded spreadsheet or bitable, extract the token and switch to `lark-sheets` or `lark-base` rather than stopping at the embedded tag.
6. If the user asks to read/write a multi-dimensional table / 多维表格 / bitable, use `lark-base`.
7. If the user asks to send, reply, search, or inspect messages, use `lark-im`, and dry-run risky sends before execution.
8. If the user gives a web link that cannot be cleanly handled by token/API, or asks to fill fields/buttons on a Feishu page/form, use `chrome-automation` with the D-drive `agent-browser` runtime.

## Authentication

Assume personal user OAuth by default. Use bot identity only when the user explicitly asks for bot/app behavior.

Typical setup:

```powershell
& $LARK_CLI config init --new
& $LARK_CLI auth login --recommend
& $LARK_CLI auth status
```

When `config init` or `auth login` emits a verification URL, forward the raw URL exactly as returned. Do not re-encode or rewrite it. If OAuth is not completed in the current session, report API read/write tests as blocked by user authorization rather than claiming success.

## Safety

- Do not expose app secrets, access tokens, or private document content in public wiki pages.
- For public wiki records, preserve only neutral metadata, capability notes, and smoke-test status unless the user explicitly permits more detail.
- Use `--dry-run` before high-risk writes when available.
- Confirm intent before deleting, bulk editing, sending messages, changing permissions, or modifying important business data.

## Smoke Test Checklist

- `lark-cli --version` works from the D-drive path.
- Domain help works, for example `docs --api-version v2 --help`, `wiki --help`, `base --help`, and `drive --help`.
- OAuth/config status is checked.
- Read/write tests are performed only against user-approved Feishu resources.
- Browser-fill tests use `chrome-automation` on a test page or explicitly approved Feishu form.
- Record verified and blocked capabilities in `vipin wiki` after setup or meaningful changes.
