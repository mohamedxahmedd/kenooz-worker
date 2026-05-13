# Gold Hangings — Worker App Developer Guide

> **Who this is for:** The mobile developer adding the Gold Hangings (متعلقات منتجات الذهب) feature to the worker app.
> **What it covers:** All four endpoints, payloads, validation, errors, and UI suggestions.
> **Base URL:** All API paths are prefixed with your base URL, e.g. `https://yourdomain.com/api/`

---

## Table of Contents

1. [Feature Overview](#1-feature-overview)
2. [Required Headers](#2-required-headers)
3. [Endpoint 1 — List Hanged Golds](#3-endpoint-1--list-hanged-golds)
4. [Endpoint 2 — List Available Golds](#4-endpoint-2--list-available-golds)
5. [Endpoint 3 — Hang One or Many Golds](#5-endpoint-3--hang-one-or-many-golds)
6. [Endpoint 4 — Unhang a Gold](#6-endpoint-4--unhang-a-gold)
7. [Validation Rules & Server Messages](#7-validation-rules--server-messages)
8. [Suggested UI](#8-suggested-ui)
9. [All HTTP Errors You Must Handle](#9-all-http-errors-you-must-handle)
10. [Endpoint Reference Card](#10-endpoint-reference-card)
11. [Pre-Ship Checklist](#11-pre-ship-checklist)

---

## 1. Feature Overview

A worker can **hang** (set aside / reserve) a gold inventory item so that:
- It disappears from the regular gold inventory and from all sell flows
- It cannot be sold (server rejects with a clear error if attempted)
- It cannot be deleted by the owner (server rejects)
- It appears on a dedicated "Hangings" page

A hanged gold can be **unhanged** later — releasing it back to the sellable inventory.

### Worker scope

Per the spec for this app:
- **Workers see ALL hangings in their shop** (not just their own — multiple workers may need to coordinate)
- **Workers can unhang ANY hanged gold** in their shop (not just ones they hanged)
- **Workers can hang one or many golds in a single request** (multi-select supported)
- An optional `hang_note` is stored to explain *why* a gold was hanged

### Authentication

All four endpoints require the worker JWT issued by `POST /api/worker/login`:

```
Authorization: Bearer <worker_access_token>
```

If the token is missing or expired, you'll get `401 Unauthorized` — clear stored credentials and redirect to login.

---

## 2. Required Headers

```
Accept: application/json
Content-Type: application/json   (POST only)
Authorization: Bearer <worker_access_token>
```

If you forget `Accept: application/json`, Laravel may return HTML on auth/validation errors instead of JSON, which will crash your parser.

---

## 3. Endpoint 1 — List Hanged Golds

```
GET /api/worker/golds/hangings
```

Returns all currently hanged gold items in the worker's shop, newest hanging first.

### Response — `200 OK`

```json
{
  "status": "success",
  "hanged": [
    {
      "id": 142,
      "name": "خاتم ذهب",
      "grams": 5.25,
      "mc": 80,
      "is_mc_d": 0,
      "profit": 200,
      "kind":   { "id": 3, "name": "خاتم" },
      "carat":  { "id": 1, "carat": "21", "fixed": 0.875, "price": 3675.00 },
      "vendor": { "id": 7, "name": "مورد الذهب الذهبي" },
      "image":  "https://yourdomain.com/storage/.../142.jpg",
      "hanged_at": "2026-04-29T14:32:00.000000Z",
      "hanged_by": { "id": 2, "name": "محمد" },
      "hang_note": "محجوز لعميل سيرجع الأسبوع القادم"
    }
  ]
}
```

### Field reference

| Field | Type | Notes |
|---|---|---|
| `id` | int | Gold inventory ID |
| `name` | string | Gold piece name |
| `grams` | float | Weight in grams |
| `mc` | float | Manufacturing cost |
| `is_mc_d` | int (`0`/`1`) | `1` if `mc` is in USD, `0` if EGP |
| `profit` | float | Profit margin |
| `kind` | object | `{ id, name }` — the kind/category (e.g., ring, necklace) |
| `carat` | object | `{ id, carat, fixed, price }` |
| `vendor` | object \| null | `{ id, name }` |
| `image` | string \| null | URL to the first image, or null if no images |
| `hanged_at` | ISO 8601 string | When it was hanged |
| `hanged_by` | object \| null | `{ id, name }` of the worker who hanged it (null if hanged by an owner from the web dashboard) |
| `hang_note` | string \| null | Optional reason text |

### Empty case

```json
{ "status": "success", "hanged": [] }
```

Show "لا توجد منتجات معلقة حالياً".

---

## 4. Endpoint 2 — List Available Golds

```
GET /api/worker/golds/hangings/available
```

Returns the picker list — all golds in the shop that **could be hanged** right now: not sold, not lost, not already hanged.

### Response — `200 OK`

```json
{
  "status": "success",
  "available": [
    {
      "id": 156,
      "name": "سلسلة ذهب",
      "grams": 12.40,
      "kind":  { "id": 5, "name": "سلسلة" },
      "carat": { "id": 1, "carat": "21", "fixed": 0.875, "price": 3675.00 },
      "image": "https://yourdomain.com/storage/.../156.jpg"
    }
  ]
}
```

### Field reference

Lighter than the hanged list — only the data needed to render a picker row.

| Field | Type |
|---|---|
| `id` | int |
| `name` | string |
| `grams` | float |
| `kind` | `{ id, name }` |
| `carat` | `{ id, carat, fixed, price }` |
| `image` | string \| null |

### When to call

- When the user opens the "Hang" picker / multi-select screen
- After a successful hang/unhang to refresh the picker

> Workers can also see hanged golds via §3, but the picker should NOT show them — the server filters them out automatically.

---

## 5. Endpoint 3 — Hang One or Many Golds

```
POST /api/worker/golds/hangings/hang
```

Hangs one or more golds in a single transaction. Either all succeed, or none do.

### Request body

```json
{
  "gold_ids": [142, 156, 203],
  "hang_note": "محجوز لعميل خالد إبراهيم"
}
```

### Field reference

| Field | Type | Required | Notes |
|---|---|---|---|
| `gold_ids` | array of int | Yes | At least 1, must be valid gold IDs in `golds` table |
| `hang_note` | string | No | Up to 1000 chars. Same note applied to all golds in this request |

### Response — `200 OK`

```json
{
  "status": "success",
  "message": "تم تعليق 3 منتج بنجاح",
  "count": 3
}
```

### Response — `422 Unprocessable Entity` (validation)

```json
{
  "gold_ids": ["يجب اختيار منتج واحد على الأقل"]
}
```

### Response — `422` (business rule)

The server runs a few extra checks per gold. If any fails, the **entire transaction rolls back** — none of the golds get hanged. Possible messages:

| Scenario | Returned message |
|---|---|
| Gold doesn't exist OR is in another shop | "بعض المنتجات غير موجودة أو لا تخص متجرك" |
| Gold is already sold | "المنتج رقم {id} تم بيعه ولا يمكن تعليقه" |
| Gold is already hanged | "المنتج رقم {id} معلق بالفعل" |

```json
{ "status": "error", "message": "المنتج رقم 142 معلق بالفعل" }
```

### Atomicity

The endpoint uses a DB transaction. If you send 3 IDs and one of them is sold, **none** of them get hanged. The error message names the specific gold so the user can deselect it and retry.

### Audit trail

The hanged record stores:
- `hanged_at` — server timestamp
- `hanged_by` — the authenticated worker's ID (visible as `hanged_by` object on the list endpoint)
- `hang_note` — the note from the request (or null)

---

## 6. Endpoint 4 — Unhang a Gold

```
POST /api/worker/golds/hangings/unhang
```

Releases a single gold back to the sellable inventory. **Any worker in the shop can unhang any gold** — not restricted to the original hanger.

### Request body

```json
{ "gold_id": 142 }
```

### Field reference

| Field | Type | Required |
|---|---|---|
| `gold_id` | int | Yes |

### Response — `200 OK`

```json
{
  "status": "success",
  "message": "تم إلغاء تعليق المنتج بنجاح"
}
```

### Response — `422 Unprocessable Entity`

| Scenario | Returned message |
|---|---|
| `gold_id` missing | "يجب تحديد المنتج" |
| `gold_id` doesn't exist | "المنتج غير موجود" |
| Gold is not currently hanged | "المنتج غير معلق" |

### Response — `404 Not Found`

```json
{ "status": "error", "message": "المنتج غير موجود" }
```

Returned when the gold exists but doesn't belong to the worker's shop.

### Effect

Sets `is_hanged=0`, clears `hanged_at`, `hanged_by`, and `hang_note` to `null`. The gold immediately becomes available for sale again.

---

## 7. Validation Rules & Server Messages

### Hang (`POST /worker/golds/hangings/hang`)

| Field | Rule | Returned message |
|---|---|---|
| `gold_ids` | required | يجب اختيار منتج واحد على الأقل |
| `gold_ids` | must be an array | تنسيق المنتجات غير صحيح |
| `gold_ids` | min 1 | يجب اختيار منتج واحد على الأقل |
| `gold_ids.*` | must be a valid gold ID | (Laravel default — usually means "ID does not exist") |
| `hang_note` | max 1000 | الملاحظة طويلة جداً |

### Unhang (`POST /worker/golds/hangings/unhang`)

| Field | Rule | Returned message |
|---|---|---|
| `gold_id` | required | يجب تحديد المنتج |
| `gold_id` | exists in `golds` | المنتج غير موجود |

---

## 8. Suggested UI

### Hangings list screen

```
┌──────────────────────────────────────────────────┐
│  ← متعلقات منتجات الذهب          [+ تعليق منتج]   │
├──────────────────────────────────────────────────┤
│  ┌────┐  خاتم ذهب                                 │
│  │img │  عيار 21 — 5.25g                           │
│  │    │  علّقه: محمد · 2026-04-29 14:32             │
│  │    │  محجوز لعميل سيرجع الأسبوع القادم          │
│  └────┘                          [إلغاء التعليق]   │
├──────────────────────────────────────────────────┤
│  ┌────┐  سلسلة ذهب                                │
│  │img │  عيار 21 — 12.40g                          │
│  │    │  علّقه: أحمد · 2026-04-28 09:15             │
│  │    │  بدون ملاحظة                              │
│  └────┘                          [إلغاء التعليق]   │
└──────────────────────────────────────────────────┘
```

Per row:
- Image, name, carat + grams
- Hanger name + relative date from `hanged_at`
- Note (or "بدون ملاحظة" placeholder if `hang_note` is null)
- "إلغاء التعليق" button → confirmation dialog → `unhang` call

### Hang picker screen

```
┌──────────────────────────────────────────────────┐
│  ← اختر منتجات للتعليق                            │
│  [بحث: ____________________]   ☐ تحديد الكل      │
├──────────────────────────────────────────────────┤
│  ☐  ┌────┐  #142 خاتم ذهب                         │
│      │img │  خاتم — عيار 21 — 5.25g                │
│      └────┘                                       │
├──────────────────────────────────────────────────┤
│  ☑  ┌────┐  #156 سلسلة ذهب                        │
│      │img │  سلسلة — عيار 21 — 12.40g              │
│      └────┘                                       │
├──────────────────────────────────────────────────┤
│  ملاحظة (اختياري)                                  │
│  ┌──────────────────────────────────────────┐    │
│  │ سبب التعليق...                            │    │
│  └──────────────────────────────────────────┘    │
│                                                  │
│       [          تعليق المنتجات المختارة      ]   │
└──────────────────────────────────────────────────┘
```

- Multi-select with check-all
- Local search/filter on `id` and `name`
- One shared note field that applies to all selected golds
- Submit button disabled until at least one selected
- After 200 success → pop back, refresh hangings list + show success toast

### Behavior

| Behavior | Spec |
|---|---|
| Pull-to-refresh on hangings list | Refetch `GET /worker/golds/hangings` |
| Tap "+ تعليق منتج" | Open picker → fetch `GET /worker/golds/hangings/available` |
| Submit hang | Call `POST /worker/golds/hangings/hang`, on 200 → close picker + refresh list |
| Tap "إلغاء التعليق" | Confirmation dialog → `POST /worker/golds/hangings/unhang` → on 200 refresh list |
| 422 errors | Display the `message` field directly to the user (already in Arabic) |
| 401 anywhere | Clear stored token, redirect to login |
| 404 on unhang | Show toast, refresh list (the gold may have been deleted) |

---

## 9. All HTTP Errors You Must Handle

| HTTP | Body | Cause | UI message |
|---|---|---|---|
| `200` | `{ status: "success", ... }` | Read / hang / unhang succeeded | (proceed) |
| `401` | varies | Token missing or expired | Clear local token, redirect to login |
| `404` | `{ status: "error", message: "المنتج غير موجود" }` | Gold not found OR not in worker's shop | Show toast + refresh list |
| `422` | `{ field: ["..."] }` (validation) | Field-level rule failed | Show first message of each field |
| `422` | `{ status: "error", message: "..." }` (business rule) | Gold sold / already hanged / not hanged / cross-shop | Show the `message` directly |
| `500` | `{ status: "error", message: "حدث خطأ في الخادم" }` | Server error | Show "حدث خطأ في الخادم، حاول مرة أخرى" |
| network failure | — | Offline | "لا يوجد اتصال بالإنترنت" + retry |

---

## 10. Endpoint Reference Card

| Method | Endpoint | Auth | Purpose |
|---|---|---|---|
| GET | `/api/worker/golds/hangings` | `auth:worker` | List all hanged golds in the shop |
| GET | `/api/worker/golds/hangings/available` | `auth:worker` | List sellable golds available to hang |
| POST | `/api/worker/golds/hangings/hang` | `auth:worker` | Hang one or many golds (`gold_ids[]` + optional `hang_note`) |
| POST | `/api/worker/golds/hangings/unhang` | `auth:worker` | Unhang a single gold (`gold_id`) |

### How sells interact

The existing gold sell endpoints (`/api/worker/golds/sells/double/store` and the inside-product fetch on `/api/worker/gold/product/{id}`) **automatically reject** any attempt to sell a hanged gold with:

```json
{ "error": "هذا المنتج معلق ولا يمكن بيعه" }
```

You don't need to add any client-side filter for this — but for a smoother UX, hide hanged golds from the sell-creation barcode/picker if the worker has the hangings list cached.

---

## 11. Pre-Ship Checklist

### Hangings list screen
- [ ] Calls `GET /api/worker/golds/hangings` with Bearer token + `Accept: application/json`
- [ ] Each row shows: image, name, kind, carat, grams, hanger name, date, note
- [ ] "بدون ملاحظة" shown when `hang_note` is null
- [ ] Empty state shown when list is empty
- [ ] Pull-to-refresh works
- [ ] Inline "إلغاء التعليق" with confirmation dialog
- [ ] On unhang success → row disappears or list refreshes

### Picker screen
- [ ] Calls `GET /api/worker/golds/hangings/available` on open
- [ ] Multi-select with check-all
- [ ] Local search filter on `id` and `name`
- [ ] Submit button disabled until ≥1 selected
- [ ] Optional note field (max 1000 chars, validated client-side)
- [ ] Submit sends `gold_ids: [...]` and `hang_note`
- [ ] On 200 → close picker + refresh hangings list + success toast
- [ ] On 422 → show server message directly

### Common
- [ ] All requests use `Authorization: Bearer ...`
- [ ] 401 anywhere → log out
- [ ] All Arabic error messages from §7 displayed clearly
- [ ] No silent failures — every error path shows something
