# Runtime Requirements

- Node.js `>= 20`
- Playwright Chromium available locally
- A real desktop session for 微信扫码登录
- A writable cookie directory outside the repository

Recommended setup:

```bash
npm install
npx playwright install chromium
npm run build
```

Common environment variables:

- `SOCIAL_PUBLISH_HEADLESS=0`
- `SOCIAL_PUBLISH_CHROME_PATH=/path/to/Chrome`
- `SOCIAL_PUBLISH_DATA_DIR=/custom/data/dir`
- `SOCIAL_PUBLISH_LOGIN_STDIN=1`
