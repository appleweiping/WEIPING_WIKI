---
title: 2026-05-17 WeChat Video Channel Publish Skill
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - agent-skills
  - publishing
  - video
source_files:
  - "D:/Research/vipin's knowledgebase/skill/wechat-video-channel-publish/SKILL.md"
  - "D:/Research/vipin's knowledgebase/.codex/skills/wechat-video-channel-publish/SKILL.md"
source_pages:
  - https://github.com/JamesWuHK/wechat-video-channel-publish-skill
---

# 2026-05-17 WeChat Video Channel Publish Skill

## Provenance

- Source: user correction that the workflow should search for a skill spanning video creation to direct WeChat Channels upload.
- Upstream repository: `https://github.com/JamesWuHK/wechat-video-channel-publish-skill`.
- Upstream HEAD at install: `67ebe674a5d633f9209b5de3059c4e37eb2afd64`.
- Local probe path: `.wiki-tmp/wechat-video-channel-publish-skill-probe/`.
- Source mirror: `skill/wechat-video-channel-publish/`.
- Installed skill: `.codex/skills/wechat-video-channel-publish/`.

## What The Skill Does

- EXTRACTED: Provides a Playwright CLI for WeChat Channels / 视频号.
- EXTRACTED: Supports QR login, cookie validation, video upload, title, tags, long caption, cover image, scheduled publishing, draft save, and best-effort pinned comment.
- EXTRACTED: Commands include:
  - `node dist/cli.js tencent login --account <name>`
  - `node dist/cli.js tencent check --account <name>`
  - `node dist/cli.js tencent upload --account <name> --file <video> --title <title> ...`

## Validation

- EXTRACTED: Node/npm on the ordinary PATH were unavailable or broken.
- EXTRACTED: A narrow Node.js runtime was downloaded under `D:/video creation/tools/nodejs/`.
- EXTRACTED: Downloaded Node zip SHA256: `3C624E9FBE07E3217552EC52A0F84E2BDC2E6FFA7348F3FDFB9FBF8F42E23FCF`.
- EXTRACTED: `npm install` completed in the installed skill directory.
- EXTRACTED: `npm run build` succeeded after replacing the Unix `cp` build step with a cross-platform Node `copyFileSync` command.
- EXTRACTED: CLI help and `tencent upload --help` ran successfully.
- UNVERIFIED: Live login, cookie check, draft upload, scheduled publish, cover selection, and pinned-comment posting were not executed.

## Safety Notes

- `upload` is a live-account action.
- `--draft` is safer than publish but still uploads media and may create a draft.
- `scripts/tencent_delete_scheduled.ts` can delete scheduled/listed posts and should not be used for smoke tests.
- Any debug artifacts, cookies, `.env` files, screenshots, and account-specific paths must stay out of public git content.

## Related

- [[wechat-video-channel-publish-skill]]
