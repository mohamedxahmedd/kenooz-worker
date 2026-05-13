# Blogs — Worker App Developer Guide

> **Who this is for:** The mobile developer building the Blogs management feature in the **worker app**.
> **What it covers:** Every endpoint, payload, validation rule, error message, image-upload detail, and UI suggestion for the worker side.
> **Base URL:** All API paths are prefixed with your base URL, e.g. `https://yourdomain.com/api/`

---

## Table of Contents

1. [Feature Overview](#1-feature-overview)
2. [Required Headers](#2-required-headers)
3. [Blog Object Shape](#3-blog-object-shape)
4. [Pagination Shape](#4-pagination-shape)
5. [Endpoint 1 — List Blogs](#5-endpoint-1--list-blogs)
6. [Endpoint 2 — Create Blog](#6-endpoint-2--create-blog)
7. [Endpoint 3 — Update Blog](#7-endpoint-3--update-blog)
8. [Endpoint 4 — Delete Blog](#8-endpoint-4--delete-blog)
9. [Image Upload — Multipart/Form-Data](#9-image-upload--multipartform-data)
10. [Validation Rules & Server Error Messages](#10-validation-rules--server-error-messages)
11. [Client-Side Validation Patterns](#11-client-side-validation-patterns)
12. [All HTTP Errors You Must Handle](#12-all-http-errors-you-must-handle)
13. [Suggested UI](#13-suggested-ui)
14. [Endpoint Reference Card](#14-endpoint-reference-card)
15. [Pre-Ship Checklist](#15-pre-ship-checklist)

---

## 1. Feature Overview

A **Blog** is a piece of editorial content (articles, news, guides) that workers can manage and clients can read. The worker app provides full CRUD over blogs.

What a blog has:
- A **title** (required)
- An optional **subtitle**
- **Details** (required — the body text)
- One or more **images** (optional)
- An `is_active` toggle (workers can hide drafts so the client app won't show them)

### What the worker can do

| Action | Endpoint |
|---|---|
| List all blogs (active + inactive) | `GET /api/worker/blogs` |
| Create a blog | `POST /api/worker/blogs` |
| Update a blog | `POST /api/worker/blogs/{id}` |
| Delete a blog | `DELETE /api/worker/blogs/{id}` |

### Blogs are global

There is **one blog list shared across all shops**. Blogs are NOT scoped per shop. Any worker editing a blog edits it for everyone.

### Authentication

All endpoints require the worker JWT issued by `POST /api/worker/login`. Send it as:

```
Authorization: Bearer <worker_access_token>
```

If the token is missing or expired, you'll get `401 Unauthorized` — redirect the user back to login.

---

## 2. Required Headers

### For GET / DELETE / JSON-only POST

```
Accept: application/json
Content-Type: application/json
Authorization: Bearer <worker_access_token>
```

### For POST/UPDATE with image uploads

```
Accept: application/json
Content-Type: multipart/form-data
Authorization: Bearer <worker_access_token>
```

> **Important:** When uploading images, you MUST use `multipart/form-data`, NOT JSON. Most HTTP clients set the `Content-Type` header automatically when you send a multipart request body — let the library handle it.

If you forget `Accept: application/json`, Laravel may return HTML on auth errors instead of JSON, crashing your parser.

---

## 3. Blog Object Shape

All endpoints that return a blog use this exact shape:

```json
{
  "id": 12,
  "title": "كيف تختار سبيكة الذهب",
  "subtitle": "دليل شامل للمبتدئين",
  "details": "نص طويل... قد يحتوي على فقرات متعددة.\n\nسطر جديد هنا.",
  "is_active": 1,
  "images": [
    { "id": 88, "url": "https://yourdomain.com/storage/.../image1.jpg" },
    { "id": 89, "url": "https://yourdomain.com/storage/.../image2.jpg" }
  ],
  "created_at": "2026-04-28T10:00:00.000000Z",
  "updated_at": "2026-04-28T10:00:00.000000Z"
}
```

### Field reference

| Field | Type | Notes |
|---|---|---|
| `id` | int | Use for update/delete URLs |
| `title` | string | 1–255 chars |
| `subtitle` | string \| null | Up to 255 chars; can be null |
| `details` | string | The body text. May contain `\n` line breaks — preserve them when rendering |
| `is_active` | int (`0` or `1`) | Worker sees both. Show a "draft/published" badge per state |
| `images` | array | Always an array. Empty `[]` if no images. Each item has `id` and `url` |
| `created_at` / `updated_at` | ISO 8601 string | Server timestamps |

### Edge cases

- **No images:** `"images": []` (empty array, not null)
- **No subtitle:** `"subtitle": null`
- **Inactive blog:** `is_active: 0` — show a "Draft" or "Hidden" badge

---

## 4. Pagination Shape

The list endpoint returns Laravel paginator output, wrapped under `blogs`:

```json
{
  "status": "success",
  "blogs": {
    "current_page": 1,
    "data": [ /* array of Blog objects (see §3) */ ],
    "first_page_url": "https://.../api/worker/blogs?page=1",
    "from": 1,
    "last_page": 4,
    "last_page_url": "https://.../api/worker/blogs?page=4",
    "next_page_url": "https://.../api/worker/blogs?page=2",
    "path": "https://.../api/worker/blogs",
    "per_page": 15,
    "prev_page_url": null,
    "to": 15,
    "total": 52
  }
}
```

### What you actually need

| Field | Use it for |
|---|---|
| `data` | The array of blog objects to render |
| `next_page_url` | `null` means no more pages. Stop loading |
| `current_page` | Optional, for analytics |
| `total` | Optional, show "52 blogs" header |

### Loading more

To load page 2: `GET /api/worker/blogs?page=2`
To request a different page size: `GET /api/worker/blogs?per_page=20` (default 15)

---

## 5. Endpoint 1 — List Blogs

```
GET /api/worker/blogs
GET /api/worker/blogs?page=2
GET /api/worker/blogs?per_page=20
```

**Headers:**
```
Accept: application/json
Authorization: Bearer <worker_access_token>
```

### Returns

Paginated list of **all blogs — both active and inactive**. The worker needs to see drafts to manage them.

### Response — `200 OK`

```json
{
  "status": "success",
  "blogs": { /* paginator object — see §4 */ }
}
```

### Empty state

If there are no blogs at all:
```json
{
  "status": "success",
  "blogs": { "data": [], "total": 0, "next_page_url": null, /* ... */ }
}
```

Show "لا توجد مدونات. أنشئ واحدة" with an "Add" button.

---

## 6. Endpoint 2 — Create Blog

```
POST /api/worker/blogs
```

**Headers:**
```
Accept: application/json
Content-Type: multipart/form-data
Authorization: Bearer <worker_access_token>
```

### Body — multipart/form-data fields

| Field | Type | Required | Notes |
|---|---|---|---|
| `title` | text | Yes | 1–255 chars |
| `subtitle` | text | No | Up to 255 chars. Omit if not needed |
| `details` | text | Yes | The body |
| `is_active` | text (`"0"` or `"1"`) | No | Defaults to `1`. Send `"0"` to save as a draft |
| `images[]` | file | No | One or more image files. Each ≤ 5 MB. JPEG / PNG / WebP only |

> **Field name `images[]` (with brackets)**: send each file under the same field name. Most HTTP clients handle this when you call something like `request.files.add('images[]', file)` repeatedly.

### Response — `201 Created`

```json
{
  "status": "success",
  "blog": { /* Blog object — see §3 */ }
}
```

### Response — `422 Unprocessable Entity`

Validation failed. Body shape:
```json
{
  "title":   ["يجب إدخال العنوان"],
  "details": ["يجب إدخال التفاصيل"],
  "images.0": ["حجم الصورة يجب ألا يتجاوز 5 ميجابايت"]
}
```

Each key is a field name; each value is an array of error message strings. See §10 for all possible messages.

---

## 7. Endpoint 3 — Update Blog

```
POST /api/worker/blogs/{id}
```

> **Note:** the route uses **`POST`**, not `PUT`/`PATCH`. This is so the request can be `multipart/form-data` with file uploads. Most form-data libraries don't support `PUT` cleanly.

**Headers:**
```
Accept: application/json
Content-Type: multipart/form-data
Authorization: Bearer <worker_access_token>
```

### Body — multipart/form-data fields

All fields are **optional** — send only what you want to change.

| Field | Type | Notes |
|---|---|---|
| `title` | text | Same rules as create. If sent, must be 1–255 chars |
| `subtitle` | text | Same as create |
| `details` | text | If sent, must be non-empty |
| `is_active` | text (`"0"` or `"1"`) | Toggle visibility |
| `images[]` | file | New image files (see below for behavior) |
| `replace_images` | text (`"0"` or `"1"`) | Default `"1"`. See behavior below |

### Image-update behavior

| What you send | What happens |
|---|---|
| No `images[]` field | Existing images are untouched |
| `images[]` + `replace_images=1` (default) | All old images are deleted; new ones replace them |
| `images[]` + `replace_images=0` | New images are appended to the existing ones |

### Response — `200 OK`

```json
{
  "status": "success",
  "blog": { /* updated Blog object */ }
}
```

### Response — `404 Not Found`

```json
{ "status": "error", "message": "المدونة غير موجودة" }
```

### Response — `422 Unprocessable Entity`

Same shape as create (see §6).

---

## 8. Endpoint 4 — Delete Blog

```
DELETE /api/worker/blogs/{id}
```

**Headers:**
```
Accept: application/json
Authorization: Bearer <worker_access_token>
```

No body.

### Response — `200 OK`

```json
{
  "status": "success",
  "message": "تم حذف المدونة"
}
```

### Response — `404 Not Found`

```json
{ "status": "error", "message": "المدونة غير موجودة" }
```

> **Permanent deletion.** This deletes the blog AND all its images. There's no undo. Always show a confirmation dialog first.

---

## 9. Image Upload — Multipart/Form-Data

When creating or updating a blog with images:

### Setup

- Set `Content-Type: multipart/form-data` (most HTTP clients do this automatically when you send a multipart request)
- Send each image file under the field name **`images[]`** (note the brackets)
- Send `title`, `subtitle`, `details`, `is_active`, `replace_images` as **plain string form fields**, NOT as JSON

### Field name conventions

| Form field | Value |
|---|---|
| `title` | `"العنوان..."` |
| `subtitle` | `"العنوان الفرعي..."` (or omit) |
| `details` | `"النص الكامل..."` |
| `is_active` | `"1"` or `"0"` |
| `replace_images` | `"1"` or `"0"` (update only) |
| `images[]` | first file binary |
| `images[]` | second file binary |
| `images[]` | third file binary, etc. |

### Constraints per image

- **Max size:** 5 MB
- **Allowed MIME types:** `image/jpeg`, `image/jpg`, `image/png`, `image/webp`
- **No hard count limit**, but UX-wise keep it under ~10 per blog

### Recommended client-side preprocessing

- **Compress** images before upload (target ~1–2 MB per file even though max is 5 MB) — saves user bandwidth
- **Validate extension and size locally** before starting the upload — see §11
- **Show progress per file** if you're uploading multiple

---

## 10. Validation Rules & Server Error Messages

### Create (`POST /api/worker/blogs`)

| Field | Rule | Returned message |
|---|---|---|
| `title` | required | يجب إدخال العنوان |
| `title` | max 255 | العنوان طويل جداً |
| `subtitle` | max 255 | العنوان الفرعي طويل جداً |
| `details` | required | يجب إدخال التفاصيل |
| `images` | must be an array | تنسيق الصور غير صحيح |
| `images.*` | must be an image file | الملف يجب أن يكون صورة |
| `images.*` | mimes jpeg/jpg/png/webp | صيغة الصورة يجب أن تكون jpeg أو jpg أو png أو webp |
| `images.*` | max 5 MB | حجم الصورة يجب ألا يتجاوز 5 ميجابايت |

### Update (`POST /api/worker/blogs/{id}`)

Same rules, but `title` and `details` are validated only **if sent** (the server uses Laravel's `sometimes|required` rule).

### List (`GET`)

No validation. `?page` and `?per_page` query params are clamped/defaulted server-side.

### Per-field error key on update for image array

When a specific image fails validation, the error key is `images.<index>`:
```json
{
  "images.0": ["حجم الصورة يجب ألا يتجاوز 5 ميجابايت"],
  "images.2": ["الملف يجب أن يكون صورة"]
}
```

So you can show the error on the specific image preview that failed.

---

## 11. Client-Side Validation Patterns

Match the server's rules so the user never sees an unnecessary round-trip:

| Field | Rule | Suggested error message |
|---|---|---|
| `title` | non-empty after trim, ≤ 255 chars | "يجب إدخال العنوان" / "العنوان طويل جداً" |
| `subtitle` | ≤ 255 chars | "العنوان الفرعي طويل جداً" |
| `details` | non-empty after trim | "يجب إدخال التفاصيل" |
| Image file | size ≤ 5 MB (5 × 1024 × 1024 bytes) | "حجم الصورة يجب ألا يتجاوز 5 ميجابايت" |
| Image file | extension `.jpg` / `.jpeg` / `.png` / `.webp` | "صيغة الصورة غير مدعومة" |

> Run these checks **before** showing a loading spinner. Round-trips for "title is empty" feel sloppy.

---

## 12. All HTTP Errors You Must Handle

| HTTP | Body | Cause | UI message |
|---|---|---|---|
| `200` | `{ status: "success", ... }` | Read / update / delete succeeded | (proceed) |
| `201` | `{ status: "success", blog: {...} }` | Create succeeded | "تم إنشاء المدونة بنجاح" |
| `401` | varies | Token expired or missing | Clear local token, redirect to login |
| `404` | `{ status: "error", message: "المدونة غير موجودة" }` | Blog ID not found | Show message, go back |
| `413` | (server-level, no JSON) | Files too large for server config | "حجم الملف كبير جداً" |
| `422` | `{ field: ["..."], ... }` | Validation failed | Show first error message of each field next to its input |
| `500` | varies | Server error | "حدث خطأ في الخادم، حاول مرة أخرى" |
| network failure / timeout | — | Offline | "لا يوجد اتصال بالإنترنت" + retry button |

---

## 13. Suggested UI

### List screen

```
┌──────────────────────────────────────────────────┐
│  ← المدونات                            [+ إضافة]  │
├──────────────────────────────────────────────────┤
│  ┌────────────┐  كيف تختار سبيكة الذهب  [مفعّل]   │
│  │  [image]   │  دليل شامل للمبتدئين              │
│  │            │  منذ يومين                        │
│  │            │            [تعديل]   [حذف]        │
│  └────────────┘                                  │
├──────────────────────────────────────────────────┤
│  ┌────────────┐  مسودة جديدة          [مخفي]      │
│  │ no image   │  —                                │
│  │            │  منذ ساعة                         │
│  │            │            [تعديل]   [حذف]        │
│  └────────────┘                                  │
└──────────────────────────────────────────────────┘
```

Per row:
- Cover image (`images[0]?.url`) or placeholder
- Title
- Subtitle (if not null)
- "مفعّل" / "مخفي" badge based on `is_active`
- Relative date from `created_at`
- Edit and Delete buttons

### Create / Edit form

```
┌──────────────────────────────────────────────────┐
│  ← إنشاء مدونة                                    │
├──────────────────────────────────────────────────┤
│  العنوان *                                        │
│  [_________________________________________]      │
│                                                  │
│  العنوان الفرعي (اختياري)                          │
│  [_________________________________________]      │
│                                                  │
│  التفاصيل *                                       │
│  ┌──────────────────────────────────────────┐    │
│  │                                          │    │
│  │                                          │    │
│  └──────────────────────────────────────────┘    │
│                                                  │
│  الصور (يمكن اختيار أكثر من صورة)                  │
│  [+ إضافة صور]                                    │
│                                                  │
│  ┌────┐ ┌────┐ ┌────┐                            │
│  │ 1  │ │ 2  │ │ 3  │  (preview thumbs with x)   │
│  └────┘ └────┘ └────┘                            │
│                                                  │
│  ☑ تفعيل (مرئي للعملاء)                          │
│                                                  │
│  [          حفظ                ]                  │
└──────────────────────────────────────────────────┘
```

### Behavior

| Behavior | Spec |
|---|---|
| Pull-to-refresh on list | Reset to `page=1`, refetch |
| Infinite scroll | When 80% scrolled, fetch next page if `next_page_url != null` |
| Tap card | Open edit form (or detail screen with edit button) |
| Tap delete | Show confirmation dialog, then call `DELETE` |
| Save (create/update) | Validate locally → show spinner → call API → on success: pop back + refresh list |
| Image picker | Allow multi-select, show thumbnails with remove button |
| Required field error | Highlight the field, show error inline below |
| 401 anywhere | Clear stored token, send to login screen |
| Network error | Toast/snackbar with retry option |

### Edit form pre-population

When opening the edit form for an existing blog:
1. Pre-fill `title`, `subtitle`, `details` text fields
2. Pre-set the `is_active` toggle
3. Show existing images as removable thumbnails (display `images[].url`)
4. The user can add new images to replace or append

When the user taps "Save":
- If the user added new images: send `images[]` plus `replace_images=1` (default) to wipe and replace, OR `replace_images=0` to append
- If the user didn't change images: don't send `images[]` at all

---

## 14. Endpoint Reference Card

| Method | Endpoint | Auth | Purpose |
|---|---|---|---|
| GET | `/api/worker/blogs` | `auth:worker` | List all blogs (paginated) |
| POST | `/api/worker/blogs` | `auth:worker` | Create blog |
| POST | `/api/worker/blogs/{id}` | `auth:worker` | Update blog |
| DELETE | `/api/worker/blogs/{id}` | `auth:worker` | Delete blog |

### Pagination params (list endpoint)

| Param | Default |
|---|---|
| `page` | `1` |
| `per_page` | `15` |

### Worker login (to get the token)

```
POST /api/worker/login
```

Send your existing login payload to receive a JWT in `access_token`. Use that as the Bearer token for all blog endpoints.

---

## 15. Pre-Ship Checklist

### List screen
- [ ] `GET /api/worker/blogs` called with Bearer token + `Accept: application/json`
- [ ] Both active and inactive blogs displayed (with a status badge per row)
- [ ] Pagination wired up (use `next_page_url`)
- [ ] Pull-to-refresh resets to page 1
- [ ] Empty state with "Add Blog" button
- [ ] Each card has Edit + Delete actions

### Create screen
- [ ] All 5 fields available (title, subtitle, details, is_active, images)
- [ ] Title required, max 255 — validated client-side
- [ ] Subtitle optional, max 255 — validated client-side
- [ ] Details required — validated client-side
- [ ] Image picker supports multiple selection
- [ ] Each picked image checked for size ≤ 5 MB and valid extension before upload
- [ ] Submit uses `multipart/form-data`, NOT JSON
- [ ] Image field name is `images[]`
- [ ] On 201 → pop back + refresh list
- [ ] On 422 → display errors next to the relevant fields

### Update screen
- [ ] Pre-populates with existing blog data
- [ ] Existing images shown as removable thumbnails (with URLs from response)
- [ ] User understands "replacing" vs "appending" — UI conveys it clearly
- [ ] `replace_images=1` (default) sent when user wants to overwrite
- [ ] `replace_images=0` sent when user wants to append
- [ ] If user didn't touch images, the `images[]` field is NOT sent
- [ ] On 404 → friendly "not found" message, return to list

### Delete flow
- [ ] Confirmation dialog before calling DELETE
- [ ] Confirmation copy mentions "permanent" or "all images will be deleted"
- [ ] On success → remove from local list and show toast
- [ ] On 404 → show "already deleted" message and refresh list

### Common
- [ ] Bearer token attached to every request
- [ ] On 401 anywhere → clear local token, redirect to login
- [ ] Loading indicators on every async action
- [ ] Network failure handling with retry
- [ ] All Arabic error messages from §10 visible to the user
- [ ] No silent failures — every error path shows something
