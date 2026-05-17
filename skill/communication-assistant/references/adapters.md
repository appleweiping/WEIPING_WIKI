# Communication Adapter Notes

This skill is an aggregate router. Prefer the narrowest adapter that can safely do the requested work.

## Email

- Use `$email-assistant` for Gmail/Google Workspace.
- It already has draft semantics, account profiles, OAuth storage, and send confirmation gates.
- Use this skill's outbox only for cross-channel planning or when the user wants a single queue across platforms.

## Feishu / Lark

- Use `lark-im` for structured IM send/search operations when available.
- Use `feishu-bridge` when a Feishu URL or web-only task needs routing.
- Browser fallback should be explicit and should not submit live actions without approval.

## WeChat

Candidate adapters:

- `wechat-cli`: local read/search/export for WeChat data. Useful for "帮我查微信历史/未读", if configured and permitted by the local OS.
- `wxauto`: Windows desktop WeChat UI automation. Useful for opening a chat and prefilling text in the input box.
- `WeClaw` / `Claude-to-IM`: bridge-style options for agent chat through WeChat. Useful if the user wants to chat with Codex from WeChat, not mainly to manage personal chats.

Rules:

- Do not store a WeChat password.
- Prefer QR login or existing desktop client login.
- For personal replies, default to outbox or prefill-only.
- Mark WeChat read/search as pending if local WeChat data access is blocked.

## WhatsApp

Candidate adapters:

- `whatsapp-web.js`: local WhatsApp Web automation with QR session.
- WAHA-style HTTP adapter: useful if a local WhatsApp HTTP service is already running.
- OpenClaw/Warelay: heavier gateway choices when the user wants long-running multi-channel infrastructure.

Rules:

- Prefer isolated browser/session storage under `.wiki-tmp/communication-assistant/sessions/whatsapp/`.
- Do not store a WhatsApp password.
- Do not send from WhatsApp Web without explicit approval.
- Reading chats may require opening WhatsApp Web, which can change browser/window focus.

## QQ

Candidate adapters:

- Official QQ Bot / OpenClaw QQ channel: preferred for bot-style communication, approvals, and structured message handling.
- NapCat/OneBot: advanced protocol-side option; only use after explicit risk acceptance.

Rules:

- Do not treat QQ number/password login as a default path.
- Prefer official bot tokens or QR/session based flows.
- For personal QQ client operations, default to outbox-only until a stable adapter is verified.
- Do not use group/private send actions without explicit target confirmation and send approval.
