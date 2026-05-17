# Communication Outbox

The outbox is the chat-platform equivalent of email drafts. It stores proposed replies before any platform action.

## Status Values

- `drafted`: written locally only.
- `prefilled`: placed into a chat input box or platform draft field, not sent.
- `sent`: sent after explicit approval.
- `canceled`: intentionally abandoned.

## JSON Fields

Each item is stored as one JSON file in `.wiki-tmp/communication-assistant/outbox/`.

```json
{
  "id": "20260517-214300-wechat-abc12345",
  "platform": "wechat",
  "target": "Alice",
  "targetId": "",
  "message": "好的，我晚点回复你。",
  "context": "reply to unread message about dinner",
  "status": "drafted",
  "createdAt": "2026-05-17T19:43:00.000Z",
  "updatedAt": "2026-05-17T19:43:00.000Z"
}
```

## Privacy

- The outbox is intentionally under `.wiki-tmp/` and must not be committed.
- Keep context summaries short and neutral.
- Do not copy large private chat transcripts into outbox items.
- If a message is sensitive, store only a minimal reminder and keep the full content in the active conversation.
