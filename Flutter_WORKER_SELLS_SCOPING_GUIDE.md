# Worker Sells — Scoping Update Guide

> **Who this is for:** The mobile app developer maintaining the worker app.
> **What it covers:** Recent backend changes that scope sell listings and the worker selector to the **authenticated worker only**. What you need to update in the app, what stays the same, and how to test.
> **Base URL:** All API paths are prefixed with your base URL, e.g. `https://yourdomain.com/api/`

---

## Table of Contents

1. [Summary of the Change](#1-summary-of-the-change)
2. [Why This Changed](#2-why-this-changed)
3. [Affected Endpoints](#3-affected-endpoints)
4. [Endpoint 1 — Workers Dropdown](#4-endpoint-1--workers-dropdown)
5. [Endpoint 2 — Gold Double Sells History](#5-endpoint-2--gold-double-sells-history)
6. [Endpoint 3 — Silver Double Sells History](#6-endpoint-3--silver-double-sells-history)
7. [Endpoint 4 — Unified (Diamond + Stone) Sells History](#7-endpoint-4--unified-diamond--stone-sells-history)
8. [What Stays the Same](#8-what-stays-the-same)
9. [UI Changes Required](#9-ui-changes-required)
10. [Testing Checklist](#10-testing-checklist)
11. [FAQ](#11-faq)

---

## 1. Summary of the Change

Two behaviors changed on the worker app's API:

| # | What changed | Effect on the app |
|---|---|---|
| 1 | **Workers dropdown endpoint** now returns only the authenticated worker | The "select worker" dropdown when creating a new sell will only show the logged-in worker as an option |
| 2 | **All 3 sell-history endpoints** now return only sells where `worker_id` matches the authenticated worker | The history screen lists only sells the logged-in worker recorded — not other workers' sells in the same shop |

**No request payloads changed. No response field shapes changed.** Only the *contents* of the responses are now narrower.

---

## 2. Why This Changed

Each worker is now responsible for and visible only to their own transactions. This:

- Prevents one worker from viewing another worker's sales history
- Prevents a worker from accidentally (or intentionally) assigning a sell to a different worker via the dropdown
- Aligns the worker app with the principle that workers should only act on their own behalf

---

## 3. Affected Endpoints

| Method | Endpoint | Used by screen |
|---|---|---|
| GET | `/api/worker/gold/workers` | Worker selector (used by all 3 sell creation screens AND the 2 buy creation screens) |
| GET | `/api/worker/golds/sells/double` | Gold Double Sell history list |
| GET | `/api/worker/silvers/sells/double` | Silver Double Sell history list |
| GET | `/api/worker/unified/sells` | Unified (Diamond + Stone) Sell history list |

---

## 4. Endpoint 1 — Workers Dropdown

```
GET /api/worker/gold/workers
```

### Before

Returned an array of every worker in the shop:

```json
[
  { "id": 1, "name": "أحمد" },
  { "id": 2, "name": "محمد" },
  { "id": 3, "name": "خالد" },
  { "id": 4, "name": "علي" }
]
```

### After

Returns an array containing **only the authenticated worker**:

```json
[
  { "id": 2, "name": "محمد" }
]
```

> The response shape is unchanged — still a JSON array of `{ id, name }` objects. Only the length is now always `1`.

### What this means in the UI

- The "select worker" dropdown when creating a new sell (or buy) will have only one option: the logged-in worker.
- You can keep the dropdown widget if you want, OR you can replace it with a read-only label showing the worker's name. Both are valid.
- If you keep the dropdown, **auto-select the only entry** when the screen loads — no extra tap required.

### Note about buy screens

This endpoint is also used by the **gold buy** and **silver buy** creation screens. They will also see only the logged-in worker in their dropdowns. This is intentional — workers should only record buys on their own behalf too.

---

## 5. Endpoint 2 — Gold Double Sells History

```
GET /api/worker/golds/sells/double
```

### What changed

Previously: returned all gold double sells in the worker's shop.
Now: returns only gold double sells **where `worker_id` equals the authenticated worker's ID**.

### Response shape

**Unchanged.** Still:

```json
{
  "status": "success",
  "sells": [
    {
      "id": 101,
      "type": "double",
      "total": 12500.00,
      "client": { "id": 42, "name": "خالد", "phone": "01012345678" },
      "worker": { "id": 2, "name": "محمد" },
      "gold_sell_items": [ ... ],
      "gold_buys": [ ... ]
    }
  ]
}
```

The `worker` field on every record will now always be the same (the logged-in worker). You can hide it in the UI if it's redundant.

### What this means for the app

- The history list will likely be **shorter** than before.
- An empty list now means "this worker has no sells", not "the shop has no sells".
- Update any empty-state copy, e.g. "ليس لديك مبيعات بعد" (You have no sells yet) instead of "لا توجد مبيعات".

---

## 6. Endpoint 3 — Silver Double Sells History

```
GET /api/worker/silvers/sells/double
```

Identical change to §5, but for silver. Same response shape, same UI update notes.

---

## 7. Endpoint 4 — Unified (Diamond + Stone) Sells History

```
GET /api/worker/unified/sells
```

### What changed

Previously: returned all unified sells in the worker's shop.
Now: returns only unified sells **where `worker_id` on the diamond record equals the authenticated worker's ID**.

> Technical note: filtering happens on the `diamond_sells` table, which is the entry point for grouping by `unified_sell_id`. Stone records that share the same `unified_sell_id` are inherited correctly because they all belong to the same worker.

### Response shape

**Unchanged.** Still:

```json
{
  "status": "success",
  "sells": [
    {
      "unified_id": "550e8400-e29b-41d4-a716-446655440000",
      "sell_date": "2025-11-20",
      "notes": "...",
      "grand_total": 18500.00,
      "client": { "id": 42, "name": "خالد", "phone": "01012345678" },
      "worker": { "id": 2, "name": "محمد" },
      "diamond_sells": [ ... ],
      "stone_sells":   [ ... ]
    }
  ]
}
```

Same UI update notes as gold/silver: shorter list, update empty-state copy.

---

## 8. What Stays the Same

The following are **unchanged** — no app-side updates needed:

| Concern | Status |
|---|---|
| Auth headers (`Authorization: Bearer <token>`) | Unchanged |
| Request payloads for sell-creation endpoints (gold/silver/unified) | Unchanged |
| Response field shapes | Unchanged |
| Validation rules / error messages on store endpoints | Unchanged |
| Buy listing endpoints (`/worker/gold/buys`, `/worker/silver/buys`) | Unchanged — still return shop-wide |
| Daily-not-open / 422 / 500 error handling | Unchanged |
| Login / register / refresh / logout | Unchanged |

---

## 9. UI Changes Required

Required for parity with the new behavior:

- [ ] **Sell creation screens (gold / silver / unified):** auto-select the single returned worker from the dropdown, or replace the dropdown with a read-only label.
- [ ] **Buy creation screens (gold / silver):** same as above — the workers endpoint affects both flows.
- [ ] **Sell history screens:** update empty-state copy to reflect "you have no sells" instead of "no sells in the shop".

Optional polish:

- [ ] Consider removing the `worker` field from history list cards — it will always be the current user, so it's redundant info that takes up space.
- [ ] If your sell creation screen auto-fills the worker on load anyway (using the local user ID), you can skip the API call entirely on those screens. Just keep it for screens that need the dropdown UI shape.

---

## 10. Testing Checklist

Sign in as **two different workers** in the same shop and verify:

- [ ] Worker A's history lists show only Worker A's sells (across gold / silver / unified)
- [ ] Worker B's history lists show only Worker B's sells
- [ ] Worker A and Worker B never see each other's records
- [ ] Each worker's "select worker" dropdown contains exactly one entry (themselves)
- [ ] Creating a new sell still works end-to-end
- [ ] Submitting a sell still associates it with the correct worker on the backend
- [ ] Empty-state UI is shown when a worker has no sells (test with a fresh worker account)

---

## 11. FAQ

**Q: Is `worker_id` still required in the request body when creating a sell?**
Yes. The store endpoints still validate and use `worker_id` from the request payload. The dropdown change only restricts what the UI offers; the backend contract is unchanged. Send the authenticated worker's ID as before.

**Q: What if the workers endpoint returns an empty array?**
That should never happen for an authenticated worker — the endpoint returns the auth user themselves. If it's empty, treat it as a session/auth error and force re-login.

**Q: Will buy listings (gold/silver) also be filtered by worker?**
Not yet. Currently buy listings still return all buys in the shop. If you want this filtered the same way, ask the backend dev to apply the same filter — it's a one-line change.

**Q: Will old app versions break?**
No. The request shapes didn't change, only the response *contents*. Old versions will still parse the responses correctly — they'll just see a smaller list and a single-entry dropdown. No 422/500 errors will result.

**Q: Does this affect the owner web dashboard?**
No. Only worker mobile API endpoints (`/api/worker/...`) were changed. The owner dashboard endpoints are completely separate.
