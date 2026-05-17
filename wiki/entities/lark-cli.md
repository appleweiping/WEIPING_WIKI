---
title: Lark CLI
type: entity
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - entity
  - agent-skills
  - feishu
  - lark
  - cli
source_pages:
  - 2026-05-17-larksuite-cli-feishu-bridge
---

# Lark CLI

## Role In The Wiki

`lark-cli` is the official Lark/Feishu command-line tool from `larksuite/cli`. It is the main runtime for API-based access to Feishu/Lark resources from Codex.

## Current Claims

- EXTRACTED: Official source repository: `https://github.com/larksuite/cli`.
- EXTRACTED: Installed release: `v1.0.32`.
- EXTRACTED: Source commit inspected locally: `14a3213038eaf563fb2c1234fe20c92981cc8ed9`.
- EXTRACTED: The official README describes `lark-cli` as covering Messenger, Docs, Base, Sheets, Slides, Calendar, Mail, Tasks, Meetings, Markdown, Wiki, and more, with 200+ commands and 24+ AI Agent skills.
- EXTRACTED: The Windows AMD64 release zip checksum matched the official release checksum: `8f5fef30ec0485279e1a8b7e949f8ee42df9ada006c7617b0e4fc54177179b9d`.
- EXTRACTED: The local binary returned `lark-cli version 1.0.32`.
- EXTRACTED: `lark-cli doctor` passed CLI version and update checks but failed config because no Feishu/Lark app/auth has been configured yet.

## Local Installation

- Runtime binary: `D:/Research/vipin's knowledgebase/.wiki-tmp/tools/lark-cli/v1.0.32/bin/lark-cli.exe`
- Source mirror: `D:/Research/vipin's knowledgebase/skill/lark-cli/`
- Installed skills: `.codex/skills/lark-*`
- Mirrored skills: `skill/lark-*`

Installed project-discoverable skills include:

- `lark-shared`
- `lark-doc`
- `lark-wiki`
- `lark-drive`
- `lark-base`
- `lark-im`
- `lark-sheets`
- `lark-markdown`
- `lark-slides`
- `lark-calendar`
- `lark-contact`
- `lark-openapi-explorer`
- `lark-skill-maker`

## Usage

Use the D-drive binary directly:

```powershell
$LARK_CLI = "D:\Research\vipin's knowledgebase\.wiki-tmp\tools\lark-cli\v1.0.32\bin\lark-cli.exe"
& $LARK_CLI --version
& $LARK_CLI docs --api-version v2 --help
& $LARK_CLI drive --help
& $LARK_CLI wiki --help
& $LARK_CLI base --help
```

Initial auth flow, to be completed with the user's browser:

```powershell
& $LARK_CLI config init --new
& $LARK_CLI auth login --recommend
& $LARK_CLI auth status
```

For docs v2:

```powershell
& $LARK_CLI docs +fetch --api-version v2 --doc "<doc URL or token>"
& $LARK_CLI docs +create --api-version v2 --content "<title>Test</title><p>Hello</p>"
```

For Drive/Wiki/Base discovery:

```powershell
& $LARK_CLI drive +search --help
& $LARK_CLI wiki +space-list --help
& $LARK_CLI base +record-list --help
```

## Verification Record

- EXTRACTED: `--version`, root `--help`, `docs --api-version v2 --help`, `wiki --help`, `drive --help`, `base --help`, `im --help`, `config init --help`, and `auth login --help` all executed successfully from the D-drive binary.
- EXTRACTED: `auth login --help` confirms a `--no-wait` mode and a resumable `--device-code` flow.
- EXTRACTED: `config init --help` confirms `config init --new` blocks until the user completes browser setup and should be run in the background by an agent.
- AMBIGUOUS: Real document, Wiki, Base, and write tests have not run yet because the CLI is not configured/authenticated.

## Safety Boundary

- Treat OAuth URLs as opaque strings and forward them exactly when generated.
- Prefer personal user OAuth for the user's own Feishu/Lark resources unless a bot/app identity is explicitly requested.
- Do not commit runtime caches, tokens, browser profiles, or app secrets.
- Avoid public wiki copies of private Feishu content.

## Related Pages

- [[feishu-bridge]]
- [[agent-skill-installation-workflow]]
- [[agent-skill-repositories]]