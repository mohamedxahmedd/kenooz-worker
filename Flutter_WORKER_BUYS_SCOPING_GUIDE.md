# Worker Buys — Scoping Update Guide

> **Who this is for:** The mobile app developer maintaining the worker app.
> **What it covers:** Recent backend changes that scope buy listings and the worker selector to the **authenticated worker only**. What you need to update in the app, what stays the same, and how to test.
> **Base URL:** All API paths are prefixed with your base URL, e.g. `https://yourdomain.com/api/`

---

## Table of Contents

1. [Summary of the Change](#1-summary-of-the-change)
2. [Why This Changed](#2-why-this-changed)
3. [Affected Endpoints](#3-affected-endpoints)
4. [Endpoint 1 — Gold Buys History](#4-endpoint-1--gold-buys-history)
5. [Endpoint 2 — Silver Buys History](#5-endpoint-2--silver-buys-history)
6. [Workers Dropdown — Already Restricted](#6-workers-dropdown--already-restricted)
7. [What Stays the Same](#7-what-stays-the-same)
8. [UI Changes Required](#8-ui-changes-required)
9. [Testing Checklist](#9-testing-checklist)
10. [FAQ](#10-faq)

---

## 1. Summary of the Change

Two behaviors changed on the worker app's API for the buy flows:

| # | What changed | Effect on the app |
|---|---|---|
| 1 | **Gold + silver buy history endpoints** now return only buys where `worker_id` matches the authenticated worker | The history screens for both gold and silver buys list only buys the logged-in worker recorded — not other workers' buys in the same shop |
| 2 | **Workers dropdown endpoint** (used by buy creation screens) was already restricted in the sells update — now confirmed for buys too | The "select worker" dropdown when creating a gold buy or silver buy will only show the logged-in worker as an option |

**No request payloads changed. No response field shapes changed.** Only the *contents* of the responses are now narrower.

---

## 2. Why This Changed

This change mirrors the per-worker scoping that was applied earlier to the sells history. Each worker is now responsible for and visible only to their own transactions. This:

- Prevents one worker from viewing another worker's purchase history
- Prevents a worker from accidentally (or intentionally) assigning a buy to a different worker via the dropdown
- Aligns the worker app with the principle that workers should only act on their own behalf — applied uniformly across sells AND buys

---

## 3. Affected Endpoints

| Method | Endpoint | Used by screen |
|---|---|---|
| GET | `/api/worker/gold/buys` | Gold Buy history list |
| GET | `/api/worker/silver/buys` | Silver Buy history list |
| GET | `/api/worker/gold/workers` | Worker selector on buy creation screens (already restricted in earlier sells update) |

---

## 4. Endpoint 1 — Gold Buys History

```
GET /api/worker/gold/buys
```

### What changed

Previously: returned all gold buys in the worker's shop.
Now: returns only gold buys **where `worker_id` equals the authenticated worker's ID**.

### Response shape

**Unchanged.** Still:

```json
{
  "status": "success",
  "buys": [
    {
      "id": 201,
      "total": 36250.00,
      "notes": "ذهب عيار 21",
      "sell_id": 101,
      "is_changed": 1,
      "created_at": "2026-04-28T14:32:00Z",

      "client": { "id": 42, "name": "خالد إبراهيم", "phone": "01012345678" },
      "worker": { "id": 2,  "name": "محمد" },
      "vendor": null,

      "gold_buy_items": [
        {
          "id": 501,
          "grams": 10.5,
          "loss":  0.5,
          "gram_price": 3625.00,
          "price": 36250.00,
          "carat": { "id": 2, "carat": "21", "fixed": 0.875, "price": 3675.00 },
          "box":   { "id": 1, "name": "علبة 21" }
        }
      ]
    }
  ]
}
```

The `worker` field on every record will now always be the same (the logged-in worker). You can hide it in the UI if it's redundant.

### What this means for the app

- The history list will likely be **shorter** than before.
- An empty list now means "this worker has no gold buys", not "the shop has no gold buys".
- Update any empty-state copy, e.g. "ليس لديك مشتريات ذهب بعد" (You have no gold buys yet) instead of "لا توجد مشتريات".

---

## 5. Endpoint 2 — Silver Buys History

```
GET /api/worker/silver/buys
```

Identical change to §4, but for silver. Same response shape, same UI update notes.

```json
{
  "status": "success",
  "buys": [
    {
      "id": 88,
      "total": 663.00,
      "notes": "فضة عيار 925",
      "sell_id": 55,
      "is_changed": 1,
      "created_at": "2026-04-28T14:00:00Z",

      "client": { "id": 42, "name": "خالد إبراهيم", "phone": "01012345678" },
      "worker": { "id": 2,  "name": "محمد" },
      "vendor": null,

      "silver_buy_items": [
        {
          "id": 201,
          "grams": 20.0,
          "loss":  0.5,
          "gram_price": 34.00,
          "price": 663.00,
          "carat": { "id": 1, "carat": "925", "fixed": 0.925, "price": 34.00 },
          "box":   { "id": 2, "name": "علبة 925" }
        }
      ]
    }
  ]
}
```

---

## 6. Workers Dropdown — Already Restricted

```
GET /api/worker/gold/workers
```

This endpoint was restricted to "self only" in the **earlier sells-scoping update**. Because the same endpoint is shared across all sell AND buy creation screens, the buy screens already inherit the new behavior.

### Response

```json
[
  { "id": 2, "name": "محمد" }
]
```

A single-entry array containing only the authenticated worker. The "select worker" dropdown on the gold buy and silver buy creation screens should:
- Show only this one option
- Auto-select it on screen load (no extra tap)
- OR be replaced entirely with a read-only label showing the worker's name

If your buy screens already adopted the change for sells, no new work is needed here. This section exists for completeness.

---

## 7. What Stays the Same

The following are **unchanged** — no app-side updates needed:

| Concern | Status |
|---|---|
| Auth headers (`Authorization: Bearer <token>`) | Unchanged |
| Request payloads for buy-creation endpoints (gold / silver) | Unchanged |
| Response field shapes | Unchanged |
| Validation rules / error messages on store endpoints | Unchanged |
| Sell-history endpoints (already scoped per-worker before this update) | Unchanged |
| Daily-not-open / 422 / 500 error handling | Unchanged |
| Sell-linking endpoints (`worker/gold/buy/sell/find/{id}` etc.) | Unchanged |
| On-the-fly carat creation endpoints | Unchanged |
| Login / register / refresh / logout | Unchanged |

---

## 8. UI Changes Required

Required for parity with the new behavior:

- [ ] **Gold buy history screen:** update empty-state copy to reflect "you have no gold buys" instead of "no gold buys in the shop".
- [ ] **Silver buy history screen:** same update for silver.
- [ ] **Gold buy creation screen:** confirm the workers dropdown auto-selects the single returned worker (or is replaced with a read-only label).
- [ ] **Silver buy creation screen:** same confirmation.

Optional polish:

- [ ] Consider removing the `worker` field from history list cards on both buy screens — it will always be the current user, so it's redundant info that takes up space.
- [ ] If your buy creation screen auto-fills the worker on load anyway (using the local user ID from the JWT), you can skip the workers API call entirely on those screens.

---

## 9. Testing Checklist

Sign in as **two different workers** in the same shop and verify:

- [ ] Worker A's gold buy history shows only Worker A's gold buys
- [ ] Worker B's gold buy history shows only Worker B's gold buys
- [ ] Worker A and Worker B never see each other's gold buys
- [ ] Same isolation holds for silver buys
- [ ] Each worker's "select worker" dropdown on buy creation screens contains exactly one entry (themselves)
- [ ] Creating a new gold buy still works end-to-end and saves with the correct `worker_id`
- [ ] Creating a new silver buy still works end-to-end and saves with the correct `worker_id`
- [ ] Empty-state UI is shown when a worker has no buys (test with a fresh worker account)
- [ ] Sell-linking flow (linking a buy to a prior client sell) still works on both gold and silver buy creation screens

---

## 10. FAQ

**Q: Is `worker_id` still required in the request body when creating a buy?**
Yes. The store endpoints (`POST /api/worker/gold/buys/store` and `POST /api/worker/silver/buys/store`) still validate and use `worker_id` from the request payload. The dropdown change only restricts what the UI offers; the backend contract is unchanged. Send the authenticated worker's ID as before.

**Q: Will old app versions break?**
No. The request shapes didn't change, only the response *contents*. Old versions will still parse the responses correctly — they'll just see a smaller history list and a single-entry dropdown. No 422 or 500 errors will result.

**Q: What if the workers endpoint returns an empty array?**
That should never happen for an authenticated worker — the endpoint returns the auth user themselves. If it's empty, treat it as a session/auth error and force re-login.

**Q: Do listings now match between sells and buys?**
Yes. After this update, both listings (sells AND buys) follow the same per-worker scoping pattern — each worker only sees their own activity. The behavior is now consistent across all 5 transaction-history endpoints (`golds/sells/double`, `silvers/sells/double`, `unified/sells`, `gold/buys`, `silver/buys`).

**Q: Does this affect the owner web dashboard?**
No. Only worker mobile API endpoints (`/api/worker/...`) were changed. The owner dashboard endpoints (`/owner/...`) and the backend admin endpoints (`/backend/...`) are completely separate.

**Q: What about the "exchange" scenario where a buy is linked to a prior sell from another worker's client?**
The `sell_id` link is just a reference — it doesn't grant the buy worker access to the original sell record. A buy created by Worker A linked to a sell by Worker B will still appear only in Worker A's buy history. The link is preserved on the buy record but doesn't cross-pollinate visibility.
