# WeChat Video Channel Publish Skill

`wechat-video-channel-publish-skill` 是一个面向 Codex / Claude Code / 通用本地 Agent 的最小可复用仓库，用于：

- 微信视频号扫码登录
- cookie 校验
- 视频上传
- 定时发布
- 草稿保存（best effort，平台 UI 可能拒绝某些状态）
- 标题、话题、正文长描述
- 封面设置
- 发布后补评论（best effort）

## 快速开始

```bash
npm install
npx playwright install chromium
npm run build
```

登录：

```bash
node dist/cli.js tencent login --account my_account
```

校验登录态：

```bash
node dist/cli.js tencent check --account my_account
```

上传视频：

```bash
node dist/cli.js tencent upload \
  --account my_account \
  --file /absolute/path/to/video.mp4 \
  --title "标题" \
  --tags "标签1,标签2" \
  --caption "正文描述" \
  --cover /absolute/path/to/cover.jpg \
  --pinned-comment "发布后补的一条评论" \
  --schedule "2026-05-02 20:30"
```

保存草稿：

```bash
node dist/cli.js tencent upload \
  --account my_account \
  --file /absolute/path/to/video.mp4 \
  --title "标题" \
  --draft
```

注意：视频号当前页面对“保存草稿”状态比较敏感，尤其不要把 `--draft` 和 `--schedule` 当成同一个动作。真实定时发布请不要加 `--draft`；草稿验证请先不加 `--schedule`。如果平台拒绝保存，CLI 会输出按钮/弹窗诊断而不是无限等待。

## 隐私说明

- cookie 默认保存在 `~/.social-publish-skills/cookies/tencent/`
- 不要把 cookie JSON、`.env`、本地导出的截图、调试日志提交到仓库
- 本仓库默认 `.gitignore` 已排除常见敏感文件

## Skill

核心 skill 文档见：

- `SKILL.md`

附加参考见：

- `references/runtime-requirements.md`
- `references/publish-workflow.md`
- `references/privacy-checklist.md`
