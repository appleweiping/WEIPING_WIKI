# Privacy Checklist

Before pushing to a public repository, verify:

- No cookie JSON files are present
- No `.env` files are present
- No access tokens, API keys, or session values are hardcoded
- No user-specific screenshots or debug HTML dumps are present
- No local-only absolute paths remain in committed templates unless clearly placeholder text
- `.gitignore` excludes:
  - `node_modules/`
  - `dist/`
  - `cookies/`
  - `.env*`
  - logs
  - screenshots
  - temp exports

Run an additional secrets scan before publishing.
