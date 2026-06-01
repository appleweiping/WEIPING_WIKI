---
title: WeChat Video Channel Publish Skill
type: entity
status: active
created: 2026-05-17
updated: 2026-06-01
tags:
  - entity
  - agent-skills
  - publishing
  - video
source_pages:
  - 2026-05-17-wechat-video-channel-publish-skill
---

# WeChat Video Channel Publish Skill

## Role In The Wiki

`wechat-video-channel-publish` is the local skill for WeChat Channels / 视频号 publishing. Use it when the task is about login, cookie checks, video upload, video title/tags/caption, cover image, scheduled publishing, or draft upload for 视频号.

It is distinct from [[content-creation-publisher]] and `baoyu-post-to-wechat`, which focus on WeChat Official Account article/image-text publishing.

## Current Claims

- EXTRACTED: Upstream repository: `https://github.com/JamesWuHK/wechat-video-channel-publish-skill`.
- EXTRACTED: Upstream HEAD at install: `67ebe674a5d633f9209b5de3059c4e37eb2afd64`.
- EXTRACTED: Source mirror: `skill/wechat-video-channel-publish/`.
- EXTRACTED: Installed skill: `.codex/skills/wechat-video-channel-publish/`.
- EXTRACTED: Runtime requires Node.js `>=20`, Playwright, and a real desktop session for first-time WeChat QR login.
- EXTRACTED: The CLI supports `tencent login`, `tencent check`, and `tencent upload`.
- INFERRED: This is the right publishing bridge for generated short videos targeting 视频号.

## Local Runtime Notes

- A project-local Node runtime was installed under `D:/video creation/tools/nodejs/node-v22.21.1-win-x64/`.
- After the 2026-06-01 D-root organization pass, `D:/video creation` is a compatibility junction to `D:/_Organized/Media/_RootDirs/video creation`; keep using the old path for existing scripts unless deliberately updating path references.
- `npm install` and `npm run build` were validated in `.codex/skills/wechat-video-channel-publish/`.
- The upstream build command used Unix `cp`; the local installed and mirrored `package.json` were patched to use a cross-platform Node `copyFileSync` build step.
- Smoke tests completed:
  - dependency install
  - TypeScript build
  - CLI help
  - `tencent upload --help`

## Safety Boundaries

- Do not run `tencent upload` without explicit user confirmation.
- Even `--draft` uploads media to a live WeChat Channels account and may save a draft.
- Do not combine `--draft` with `--schedule`.
- Do not commit cookies, `.env*`, screenshots, debug JSON/HTML, account logs, or generated private publishing artifacts.
- Cookie data defaults outside the repository under a `.social-publish-skills` data directory unless overridden.

## Related

- [[2026-05-17-wechat-video-channel-publish-skill]]
- [[content-creation-publisher]]
