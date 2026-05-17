# Publish Workflow

Use this sequence:

1. Validate login:
   - `node dist/cli.js tencent check --account <name>`
2. Prefer a draft run when validating a new content shape:
   - add `--draft`
   - do not combine `--draft` with `--schedule`; video号 may refuse to save scheduled drafts
3. Use absolute paths:
   - `--file /absolute/path/to/video.mp4`
   - `--cover /absolute/path/to/cover.jpg`
4. Map queue data to CLI arguments:
   - `title` -> `--title`
   - `hashtags[]` -> `--tags`
   - `caption` -> `--caption`
   - `cover` -> `--cover`
   - `pinned_comment` -> `--pinned-comment`
   - `publish_at` -> `--schedule`

For real scheduled publishing, omit `--draft`. For safe form-fill validation, use `--draft` without `--schedule`.

Example:

```bash
node dist/cli.js tencent upload \
  --account my_account \
  --file /absolute/path/to/video.mp4 \
  --title "标题" \
  --tags "AI教育,家庭教育" \
  --caption "正文描述" \
  --cover /absolute/path/to/cover.jpg \
  --pinned-comment "发布后补的一条评论" \
  --schedule "2026-05-02 20:30"
```
