# Invoice API — Worker App

## Authentication

All invoice endpoints are protected by the worker JWT guard.

```
Authorization: Bearer <worker_token>
```

---

## Flow

After a successful sell, the response includes the record ID(s). Use them to request the invoice PDF.

```
POST worker/golds/sells/double/store
        ↓
{ "status": "success", "sell_id": 42, "buy_id": null, "total": 15000 }
        ↓
GET /api/worker/invoice/gold/42
        ↓
Server streams invoice-gold-42.pdf
```

---

## Success response shapes by transaction

| Transaction | Store route | ID fields returned |
|---|---|---|
| Gold sell | `POST worker/golds/sells/double/store` | `sell_id`, `buy_id` (null if no linked purchase), `total` |
| Silver sell | `POST worker/silvers/sells/double/store` | `sell_id`, `invoice_type: "silver"` |
| Diamond + Stone unified sell | `POST worker/unified/sells/store` | `unified_id`, `diamond_sell_id`, `stone_sell_id`, `grand_total` |
| Gold buy | `POST worker/gold/buys/store` | `buy_id`, `invoice_type: "gold_buy"` |
| Silver buy | `POST worker/silver/buys/store` | `buy_id`, `invoice_type: "silver_buy"` |

---

## Invoice endpoints

### Gold sell

```
GET /api/worker/invoice/gold/{id}
```

`id` = `sell_id` from the gold sell response.

**Response:** HTTP 200, `Content-Type: application/pdf`, file `invoice-gold-{id}.pdf`.

---

### Silver sell

```
GET /api/worker/invoice/silver/{id}
```

`id` = `sell_id` from the silver sell response.

---

### Diamond sell

```
GET /api/worker/invoice/diamond/{id}
```

`id` = `diamond_sell_id` from the unified sell response.

> There is no standalone diamond sell worker endpoint — diamonds are always sold through the unified `POST worker/unified/sells/store` route. Use `diamond_sell_id` from that response, not `unified_id`.

---

### Stone sell

```
GET /api/worker/invoice/stone/{id}
```

`id` = `stone_sell_id` from the unified sell response.

> Same as diamond — `stone_sell_id` comes from the unified sell response. Only present when the sell included stone products.

---

### Gold buy / Silver buy

No invoice template exists yet for buy transactions. The buy endpoints return a `buy_id` for future use.

---

## Security

The server checks `shop_id` on every request. A worker cannot fetch an invoice from another shop — returns 404 (not 403) to avoid leaking record existence.

---

## PDF content by type

| Type | Contents |
|---|---|
| `gold` | Sale items (category, carat, weight, amount) + any linked purchase rows shown as negatives, with sales/purchase/net totals |
| `silver` | Same structure as gold, for silver |
| `diamond` | Diamond sell items (product name, clarity, gold weight, diamond weight, amount), USD→EGP conversion note |
| `stone` | Stone sell items (product name, color, clarity, shape, weight, amount) |

---

## Error responses

| Status | Meaning |
|---|---|
| 401 | Missing or invalid worker token |
| 404 | Record not found or belongs to a different shop |
| 500 | PDF generation failed |

Non-2xx responses are JSON:

```json
{ "message": "No query results for model [App\\Models\\Gold_sell]." }
```
