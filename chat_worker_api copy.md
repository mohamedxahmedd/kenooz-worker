# Chat API — Worker App

All endpoints require a valid JWT token in the `Authorization` header:

```
Authorization: Bearer <token>
```

Base URL: `/api` — prepend your server domain, e.g. `https://yourdomain.com/api/chat/worker/inbox`

---

## Authentication

Worker endpoints are protected by the `auth:worker` middleware.

**Login:** `POST /api/worker/login` → returns `access_token`  
**Refresh:** `POST /api/worker/refresh` → call this when you receive a `401` with `"Token has expired"`  
**Logout:** `POST /api/worker/logout`

### 401 response shape (token invalid or expired)
```json
{ "status": "error", "message": "Token has expired" }
```
Possible messages: `"Token has expired"` · `"Token is invalid"` · `"Authorization token not found"` · `"User not found"`

When you receive a `401`, attempt a token refresh. If the refresh also fails, redirect the user to the login screen.

---

## Chat flow overview

```
1. Check inbox           GET  /chat/worker/inbox
2. Start a chat          POST /chat/worker/start          { client_id }
3. Send a message        POST /message/worker/send        { chat_id, message }
4. Poll messages         GET  /chat/worker/{id}/messages  (marks client msgs as read)
5. Poll inbox            GET  /chat/worker/inbox          (refreshes unread badges)
6. End chat              POST /chat/worker/{id}/end
7. Review history        GET  /chat/worker/history
```

> **Note:** Workers can only start a chat if they already have a `client_id`. Clients are discovered through the orders system — use the client's ID from an order record to initiate contact. Alternatively, chats are usually started by the client first, and the worker responds from their inbox.

---

## Rendering messages — which side is mine?

Use the `from` field on each message object:

| `from` value | Render as |
|---|---|
| `"worker"` | **My message** — right-aligned bubble |
| `"client"` | **Their message** — left-aligned bubble |

---

## Endpoints

### 1. Active chat inbox
Returns all open (not ended) chats assigned to the authenticated worker, sorted by most recently updated.  
Each entry includes: client info + profile photo, the last message, and the unread message count.

> **No pagination** — returns all active chats in a single response.

> **Inbox polling:** poll this endpoint every 5–10 seconds while the app is in the foreground to refresh unread badges and detect new chats started by clients.

```
GET /api/chat/worker/inbox
```

**Response `200`**
```json
[
  {
    "id": 12,
    "worker_id": 3,
    "client_id": 7,
    "status": "started",
    "is_ended": false,
    "rating": null,
    "note": null,
    "is_solved": null,
    "unread_count": 2,
    "latest_message": {
      "id": 85,
      "chat_id": 12,
      "from": "client",
      "to": "worker",
      "message": "Hello, I have a question.",
      "is_read": false,
      "created_at": "2026-05-01T14:01:00.000000Z",
      "updated_at": "2026-05-01T14:01:00.000000Z"
    },
    "client": {
      "id": 7,
      "name": "Sara Mohamed",
      "phone": "0509876543",
      "media": [
        {
          "id": 22,
          "collection_name": "profile",
          "file_name": "avatar.jpg",
          "mime_type": "image/jpeg",
          "original_url": "https://yourdomain.com/storage/22/avatar.jpg",
          "preview_url": ""
        }
      ]
    },
    "created_at": "2026-05-01T14:00:00.000000Z",
    "updated_at": "2026-05-01T14:01:00.000000Z"
  }
]
```

Empty inbox returns `[]`.  
`unread_count` is the number of client messages you haven't fetched yet. Show this as a badge on the conversation row.  
If `media` is `[]`, the client has no profile photo — show a placeholder.

---

### 2. Closed chat history
Returns all ended chats for the authenticated worker, sorted by most recently closed.  
Includes client info, the last message, and the rating left by the client (if any).

> **No pagination** — returns all closed chats in a single response.

```
GET /api/chat/worker/history
```

**Response `200`**
```json
[
  {
    "id": 9,
    "worker_id": 3,
    "client_id": 6,
    "is_ended": true,
    "rating": 4,
    "note": "Quick response.",
    "is_solved": true,
    "latest_message": {
      "id": 80,
      "chat_id": 9,
      "from": "worker",
      "to": "client",
      "message": "Let me know if you need anything else.",
      "is_read": true,
      "created_at": "2026-04-30T10:00:00.000000Z"
    },
    "client": {
      "id": 6,
      "name": "Khalid Nasser",
      "media": [...]
    }
  }
]
```

`rating` / `note` / `is_solved` are `null` if the client never rated the chat.

---

### 3. Start or resume a chat
Creates a new chat with a client. If an active (not ended) chat with that client already exists, it is returned instead — safe to call every time the user opens a conversation.

You need a `client_id` to call this. Client IDs come from the orders system or from the client's profile.

```
POST /api/chat/worker/start
Content-Type: application/json

{
  "client_id": 7
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `client_id` | integer | yes | Must exist in the clients table |

**Response `201`** — new chat was created  
**Response `200`** — an existing active chat was returned

```json
{
  "id": 14,
  "worker_id": 3,
  "client_id": 7,
  "status": "started",
  "is_ended": false,
  "rating": null,
  "note": null,
  "is_solved": null,
  "messages": [],
  "created_at": "2026-05-01T15:00:00.000000Z",
  "updated_at": "2026-05-01T15:00:00.000000Z"
}
```

Save the returned `id` as `chat_id` — you'll need it for sending messages and fetching the conversation.

**Errors**

| Code | Meaning |
|---|---|
| `422` | `client_id` is missing or does not exist |

---

### 4. Get messages in a chat
Returns the full chat object with all messages in chronological order (oldest first).

**Side-effect:** every client message in this chat is automatically marked as `is_read: true`. The next inbox poll will show `unread_count: 0` for this chat.

> **Disable the message input** when `is_ended: true` — no messages can be sent in a closed chat.

> **Message polling:** while a conversation is open on screen, poll this endpoint every 5 seconds to display new incoming messages.

```
GET /api/chat/worker/{id}/messages
```

| Param | In | Type | Notes |
|---|---|---|---|
| `id` | URL path | integer | The chat ID |

**Response `200`**
```json
{
  "id": 12,
  "client_id": 7,
  "worker_id": 3,
  "status": "started",
  "is_ended": false,
  "rating": null,
  "note": null,
  "is_solved": null,
  "messages": [
    {
      "id": 85,
      "chat_id": 12,
      "from": "client",
      "to": "worker",
      "message": "Hello, I have a question.",
      "is_read": true,
      "created_at": "2026-05-01T14:01:00.000000Z",
      "updated_at": "2026-05-01T14:01:00.000000Z"
    },
    {
      "id": 86,
      "chat_id": 12,
      "from": "worker",
      "to": "client",
      "message": "Sure, how can I help?",
      "is_read": true,
      "created_at": "2026-05-01T14:02:00.000000Z",
      "updated_at": "2026-05-01T14:02:00.000000Z"
    }
  ],
  "created_at": "2026-05-01T14:00:00.000000Z",
  "updated_at": "2026-05-01T14:02:00.000000Z"
}
```

**Errors**

| Code | Meaning |
|---|---|
| `404` | Chat not found, or it does not belong to you |

---

### 5. Send a message
Send a text message. The chat must be active (`is_ended: false`). Only call this when `is_ended` is false — the server will reject messages in a closed chat.

```
POST /api/message/worker/send
Content-Type: application/json

{
  "chat_id": 12,
  "message": "Your order has been shipped."
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `chat_id` | integer | yes | Must be an active chat that belongs to you |
| `message` | string | yes | Max 5000 characters |

**Response `201`**
```json
{
  "id": 90,
  "chat_id": 12,
  "from": "worker",
  "to": "client",
  "message": "Your order has been shipped.",
  "is_read": false,
  "created_at": "2026-05-01T14:10:00.000000Z",
  "updated_at": "2026-05-01T14:10:00.000000Z"
}
```

Append this response object directly to your local message list so the user sees their message instantly without waiting for the next poll.

**Errors**

| Code | Meaning |
|---|---|
| `404` | Active chat not found, or it does not belong to you, or the chat is already ended |
| `422` | Validation failed |

---

### 6. End a chat
Close an active chat. After this, no more messages can be sent by either side. The client will be prompted to rate the chat.

```
POST /api/chat/worker/{id}/end
```

| Param | In | Type | Notes |
|---|---|---|---|
| `id` | URL path | integer | The chat ID |

**Response `200`**
```json
{ "message": "Chat ended" }
```

After success, update the local chat state: set `is_ended = true` and disable the message input.

**Errors**

| Code | Meaning |
|---|---|
| `404` | Chat not found, or it does not belong to you |
| `422` | Chat is already ended |

---

## Polling strategy

There is no push/WebSocket. Use two separate polling loops:

| Loop | Endpoint | Interval | Purpose |
|---|---|---|---|
| Inbox poller | `GET /chat/worker/inbox` | every 10s | Refresh unread badges and detect new client-initiated chats |
| Message poller | `GET /chat/worker/{id}/messages` | every 5s | Show new messages while a chat is open |

Stop the message poller when the user navigates away from a conversation. Stop both pollers when the app goes to the background.

---

## Chat lifecycle diagram

```
         Client                              Worker
           │                                   │
   POST /chat/client/start              POST /chat/worker/start
           │                                   │
           └──────────────┬────────────────────┘
                          │
                  ┌───────▼────────┐
                  │  is_ended=false │  ← active chat
                  └───────┬────────┘
                          │
          POST /message/*/send  (either side, repeat)
                          │
                  ┌───────▼────────┐
                  │  messages grow  │
                  └───────┬────────┘
                          │
          POST /chat/*/{id}/end  (either side)
                          │
                  ┌───────▼────────┐
                  │  is_ended=true  │  ← closed chat
                  └───────┬────────┘
                          │
          POST /chat/client/{id}/rate  (client only, optional)
                          │
                  ┌───────▼────────┐
                  │  rating stored  │
                  └────────────────┘
```

---

## Error response shape

All non-validation errors:
```json
{ "error": "Human-readable message" }
```

Validation errors `422`:
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "client_id": ["The client id field is required."]
  }
}
```

Auth errors `401`:
```json
{ "status": "error", "message": "Token has expired" }
```
