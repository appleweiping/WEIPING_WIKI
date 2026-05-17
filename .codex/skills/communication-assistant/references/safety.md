# Communication Safety Rules

## Credentials

- Do not search for or store account passwords.
- Use QR login, OAuth, bot tokens, or existing platform sessions.
- Store any token/session material only under ignored runtime paths.
- Mask secrets in all logs and user-facing output.

## Private Content

- Treat private chats and contacts as high sensitivity.
- Do not write raw chat contents to public wiki pages, commit messages, issue trackers, or partner prompts.
- When using Opus/Sonnet for review, redact message bodies and contact identifiers unless the user explicitly approves sharing them.

## Sending

- Default action is local outbox or prefill-only.
- Sending requires explicit approval in the current conversation.
- Before sending, verify:
  - platform
  - target
  - exact text
  - whether media/files are attached
- Never infer approval from a previous general preference.

## Desktop / Browser Automation

- Warn the user before opening or focusing a real chat window.
- Prefer isolated profiles or platform-specific client windows.
- Do not click send/press Enter unless the user explicitly approved sending.
- If a platform presents CAPTCHA, QR login, device trust, or account-risk warnings, stop and ask the user to handle it.
