# Google Cloud OAuth Setup

Use this only for Vipin's personal `email-assistant` skill. Store secrets in the repo-local ignored auth directory, not inside the skill source.

## Auth Directory

Default credentials path:

```powershell
D:\Research\vipin's knowledgebase\.wiki-tmp\email-assistant\auth\credentials.json
```

Default token path, created by OAuth:

```powershell
D:\Research\vipin's knowledgebase\.wiki-tmp\email-assistant\auth\tokens.json
```

Both paths are ignored by Git through `.wiki-tmp/`.

## Google Cloud Steps

1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a project, for example `Vipin Email Assistant`.
3. Enable the Gmail API.
4. Configure the OAuth consent screen.
5. Add the Gmail account as a test user if the app is in testing mode.
6. Add these Gmail scopes:
   - `https://www.googleapis.com/auth/gmail.modify`
   - `https://www.googleapis.com/auth/gmail.compose`
   - `https://www.googleapis.com/auth/gmail.send`
7. Create an OAuth Client ID with application type `Desktop app`.
8. Download the JSON file and save it as:

```powershell
D:\Research\vipin's knowledgebase\.wiki-tmp\email-assistant\auth\credentials.json
```

## Local Setup

From the installed skill directory:

```powershell
cd "D:\Research\vipin's knowledgebase\.codex\skills\email-assistant"
& "D:\cc\node\corepack.cmd" pnpm install
& "D:\cc\node\corepack.cmd" pnpm run setup -- --account umn --email "<umn email address>"
& "D:\cc\node\corepack.cmd" pnpm run setup -- --account vipinapple --email "<personal email address>"
node scripts/manage-accounts.js --list
```

The OAuth setup opens a browser. Complete account selection and consent manually.

## Safety Notes

- Do not commit `credentials.json`, `tokens.json`, browser profiles, cookies, or email bodies.
- The default workflow creates drafts rather than sending.
- Direct sends require `--confirm-send YES_SEND`.
- If UMN blocks Gmail API auth, leave `umn` pending and keep `vipinapple` working.
