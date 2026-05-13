# Invoice API — Worker App

## Authentication

All invoice endpoints are protected by the worker JWT guard.

```
Authorization: Bearer <worker_token>
```

---

## How it works

After any successful sell or buy, the server returns the record ID(s) in the response. Pass that ID to the matching invoice endpoint to download the PDF.

```
POST /api/worker/golds/sells/double/store
        ↓
{ "status": "success", "sell_id": 42, "buy_id": null, "total": 15000 }
        ↓
GET /api/worker/invoice/gold/42
        ↓
HTTP 200  Content-Type: application/pdf  →  invoice-gold-42.pdf
```

---

## Step 1 — Read the IDs from the store response

Every sell and buy endpoint now returns the record ID(s) you need.

| Transaction | Store endpoint | ID fields in success response |
|---|---|---|
| Gold sell | `POST /api/worker/golds/sells/double/store` | `sell_id`, `buy_id` (null if no linked purchase), `total` |
| Silver sell | `POST /api/worker/silvers/sells/double/store` | `sell_id`, `invoice_type: "silver"` |
| Diamond + Stone unified sell | `POST /api/worker/unified/sells/store` | `unified_id`, `diamond_sell_id`, `stone_sell_id`, `grand_total` |
| Gold buy | `POST /api/worker/gold/buys/store` | `buy_id`, `invoice_type: "gold_buy"` |
| Silver buy | `POST /api/worker/silver/buys/store` | `buy_id`, `invoice_type: "silver_buy"` |

> `unified_id` (e.g. `UNI-1746123-abc`) is an internal correlation string. Do not use it as an invoice endpoint parameter — use `diamond_sell_id` or `stone_sell_id` instead.

---

## Step 2 — Request the invoice PDF

### Gold sell invoice

```
GET /api/worker/invoice/gold/{id}
```

`id` = `sell_id` from the gold sell response.

**Success:** HTTP 200, `Content-Type: application/pdf`, filename `invoice-gold-{id}.pdf`

---

### Silver sell invoice

```
GET /api/worker/invoice/silver/{id}
```

`id` = `sell_id` from the silver sell response.

---

### Diamond sell invoice

```
GET /api/worker/invoice/diamond/{id}
```

`id` = `diamond_sell_id` from the unified sell response.

> Diamonds are always sold through the unified endpoint (`POST /api/worker/unified/sells/store`). There is no standalone diamond sell route for workers.

---

### Stone sell invoice

```
GET /api/worker/invoice/stone/{id}
```

`id` = `stone_sell_id` from the unified sell response. Only request this if `stone_sell_id` is present in the response (i.e. the sell included stone products).

---

### Gold buy invoice

```
GET /api/worker/invoice/gold_buy/{id}
```

`id` = `buy_id` from the gold buy response.

---

### Silver buy invoice

```
GET /api/worker/invoice/silver_buy/{id}
```

`id` = `buy_id` from the silver buy response.

---

## All invoice endpoints at a glance

| Invoice type | Endpoint | ID source |
|---|---|---|
| Gold sell | `GET /api/worker/invoice/gold/{id}` | `sell_id` |
| Silver sell | `GET /api/worker/invoice/silver/{id}` | `sell_id` |
| Diamond sell | `GET /api/worker/invoice/diamond/{id}` | `diamond_sell_id` |
| Stone sell | `GET /api/worker/invoice/stone/{id}` | `stone_sell_id` |
| Gold buy | `GET /api/worker/invoice/gold_buy/{id}` | `buy_id` |
| Silver buy | `GET /api/worker/invoice/silver_buy/{id}` | `buy_id` |

---

## PDF content by invoice type

| Type | Columns |
|---|---|
| Gold sell | Category, Carat, Weight, Amount — sale rows + any linked purchase rows (shown as negatives), Sales Total / Purchases Total / Net Total |
| Silver sell | Same structure as gold sell |
| Diamond sell | Product Name, Clarity, Gold Weight, Diamond Weight, Amount — with USD→EGP conversion note |
| Stone sell | Product Name, Color, Clarity, Shape, Weight, Amount |
| Gold buy | Carat, Gross Weight, Loss, Net Weight, Gram Price, Amount |
| Silver buy | Same structure as gold buy |

---

## Security

The server enforces shop ownership on every invoice request. A worker can only download invoices that belong to their shop. Returns 404 (not 403) if the record doesn't exist or belongs to another shop.

---

## Error responses

All errors are JSON.

| Status | Meaning |
|---|---|
| 401 | Missing or invalid worker token |
| 404 | Record not found, or belongs to a different shop |
| 500 | PDF generation failed on the server |

```json
{ "message": "No query results for model [App\\Models\\Gold_sell]." }
```
