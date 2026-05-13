# Silver Double Sell — Implementation Plan

> Feature: Trade-in transaction screen where the shop sells silver to a client and optionally buys old silver back, settling a net total in one atomic API call.
>
> **IMPORTANT:** This feature has the **exact same UI structure** as Gold Double Sell. Reuse the same layout, widget patterns, color scheme approach, and UX flow — but adapted for silver (different endpoints, different models, silver carats instead of gold carats, no USD conversion, silver-specific formulas). Think of it as a "silver skin" over the same gold skeleton.

---

## Phase 1 — Data Layer: Models

All models go in `lib/features/silver_double_sell/data/models/`. Every model uses manual `fromJson` with `_parseInt` / `_parseDouble` helpers (same pattern as Gold Double Sell models).

### 1.1 Pre-load response models

| File | Class | Source endpoint | Key fields |
|------|-------|----------------|------------|
| `silver_carat_model.dart` | `SilverCaratModel` | `GET /api/worker/silver/rates` | `id`, `carat` (display string, e.g. "925"), `fixed` (double), `price` (double — gram price for this carat) |
| `silver_kind_model.dart` | `SilverKindModel` | `GET /api/worker/silver/kinds` | `id`, `name` — **Note:** Unlike gold, silver kinds are NOT carat-dependent. Load once at screen open, never re-fetch. |
| `silver_box_model.dart` | `SilverBoxModel` | `GET /api/worker/silver/boxes` | `id`, `name`, `total` (double — current weight in box) |
| `silver_vendor_model.dart` | `SilverVendorModel` | `GET /api/worker/silver/vendors` | `id`, `name`, `caratId`, `currencyId` |
| `shop_worker_model.dart` | — | `GET /api/worker/gold/workers` | Reuse existing `ShopWorkerModel` from gold_double_sell (import, don't duplicate). **Yes, workers endpoint is shared.** |
| `payment_account_model.dart` | — | `GET /api/worker/accounts` | Reuse existing `PaymentAccountModel` from gold_double_sell (import, don't duplicate) |

### 1.2 Lazy-load response models

| File | Class | Source endpoint |
|------|-------|----------------|
| `account_currency_model.dart` | — | `GET /api/worker/accounts/{id}/currency` — Reuse existing `AccountCurrencyModel` from gold_double_sell |

> **Key difference from gold:** There is NO lazy-load for kinds. Silver kinds are loaded once at screen open (not per-carat). So there is NO `SilverKindsCubit` needed.

### 1.3 Client models

| File | Class | Endpoint |
|------|-------|----------|
| `client_model.dart` | — | Reuse existing `ClientModel` from gold_double_sell |
| `create_client_request_model.dart` | — | Reuse existing `CreateClientRequestModel` — fields: `client_name`, `client_phone`, `client_email`, `client_gender` (note `client_` prefix) |

### 1.4 Vendor creation

| File | Class |
|------|-------|
| `create_silver_vendor_request_model.dart` | `CreateSilverVendorRequestModel` — `name`, `carat_id` (references silver_carats.id), `currency_id`, `phone?`, `notes?` |
| `create_silver_vendor_response_model.dart` | `CreateSilverVendorResponseModel` — full vendor object returned by server (`id`, `name`, `type` = "s", `carat_id`, `currency_id`, `shop_id`) |

### 1.5 Product lookup

| File | Class |
|------|-------|
| `silver_product_model.dart` | `SilverProductModel` — `id`, `name`, `grams`, `mc`, `profit`, `gramPrice`, `caratId`, `caratName`, `kindId`, `vendorId`, `isSold`, `media` (list → extract `original_url`) |

> **Key difference from gold:** No `isMcD` (is MC in dollars) field. Silver has no USD conversion for MC. All prices are purely EGP.

### 1.6 Submit request / response

| File | Class | Notes |
|------|-------|-------|
| `silver_double_sell_request_model.dart` | `SilverDoubleSellRequestModel` | Top-level: `client_id`, `worker_id`, `total`, `tax`, `notes`, `all_accounts`, `insideProducts`, `outsideProducts`, `boxProducts`, `buySilverProducts`, `deduction_accounts` — each sub-array is `List<Map<String, dynamic>>` |
| `silver_double_sell_response_model.dart` | `SilverDoubleSellResponseModel` | `status`, `message?` |

### 1.7 Composite pre-load model

| File | Class | Notes |
|------|-------|-------|
| `silver_double_sell_preload_data.dart` | `SilverDoubleSellPreloadData` | Holds all 6 pre-load results in one object: `carats`, `kinds`, `boxes`, `vendors`, `workers`, `accounts` — passed to the UI as the `Success` state data |

> **Key difference from gold:** Only 6 pre-load endpoints (gold has 8). No `currencies` list, no `usdRate`, no `goldRates`. Silver doesn't need USD conversion.

---

## Phase 2 — Data Layer: API Service

**File:** `lib/features/silver_double_sell/data/remote/silver_double_sell_api_service.dart`

Retrofit interface with all 12 endpoints. Use `static const String` for endpoint paths (same pattern as `GoldDoubleSellApiService`).

```
// Pre-load (6 endpoints — called in parallel)
GET  worker/silver/rates                       → response has {"carats": [...]} → List<SilverCaratModel>
GET  worker/silver/kinds                       → List<SilverKindModel> (raw array)
GET  worker/silver/boxes                       → List<SilverBoxModel>
GET  worker/silver/vendors                     → List<SilverVendorModel>
GET  worker/gold/workers                       → List<ShopWorkerModel> (reuse — shared endpoint)
GET  worker/accounts                           → List<PaymentAccountModel> (reuse)

// Lazy-load (1 endpoint)
GET  worker/accounts/{id}/currency             → AccountCurrencyModel (reuse)

// Client (2 endpoints)
GET  worker/clients/search/{term}              → ClientModel (reuse)
POST worker/clients/add                        → ClientModel (reuse)

// Vendor (1 endpoint)
POST worker/silver/vendors/add                 → CreateSilverVendorResponseModel

// Product (1 endpoint)
GET  worker/silver/product/{id}                → SilverProductModel

// Submit (1 endpoint)
POST worker/silvers/sells/double/store         → SilverDoubleSellResponseModel
```

**Note on response shapes:**
- `worker/silver/rates` returns `{"carats":[...]}` (object with nested array)
- `worker/silver/kinds` returns raw array `[...]`
- All others are standard JSON objects or arrays

Also generate: `silver_double_sell_api_service.g.dart`

---

## Phase 3 — Data Layer: Repository

**File:** `lib/features/silver_double_sell/data/repo/silver_double_sell_repo.dart`

### 3.1 `fetchPreloadData()`

Calls all 6 pre-load endpoints via `Future.wait()` in parallel. Returns `ApiResult<SilverDoubleSellPreloadData>`. On any failure, the entire pre-load fails (wrapped in try/catch → `ErrorHandler.handle(e)`).

### 3.2 Individual lazy-load methods

```dart
Future<ApiResult<AccountCurrencyModel>> fetchAccountCurrency(int accountId)
```

> **No `fetchKindsByCarat` needed** — silver kinds are pre-loaded, not lazy-loaded per carat.

### 3.3 Client methods

```dart
Future<ApiResult<ClientModel>> searchClient(String term)
Future<ApiResult<ClientModel>> createClient(CreateClientRequestModel request)
```

### 3.4 Vendor method

```dart
Future<ApiResult<CreateSilverVendorResponseModel>> createVendor(CreateSilverVendorRequestModel request)
```

### 3.5 Product lookup

```dart
Future<ApiResult<SilverProductModel>> fetchProduct(int id)
```

### 3.6 Submit

```dart
Future<ApiResult<SilverDoubleSellResponseModel>> submitDoubleSell(SilverDoubleSellRequestModel request)
```

Each method follows the same pattern:
```dart
try {
  final result = await _apiService.someEndpoint();
  return ApiResult.success(result);
} catch (e) {
  return ApiResult.failure(ErrorHandler.handle(e));
}
```

---

## Phase 4 — Presentation Layer: Cubits

All in `lib/features/silver_double_sell/presentation/cubit/`.

### 4.1 `SilverDoubleSellPreloadCubit` + `SilverDoubleSellPreloadState`

Handles the initial 6-endpoint parallel fetch. State union:
- `initial` → `loading` → `success(SilverDoubleSellPreloadData data)` | `error(List<String> messages)`

```dart
Future<void> fetchPreloadData() async {
  emit(loading);
  final result = await _repo.fetchPreloadData();
  result.when(success: ..., failure: ...);
}
```

### 4.2 `SilverClientSearchCubit` + `SilverClientSearchState`

For searching and creating clients. State union:
- `initial` | `loading` | `found(ClientModel client)` | `notFound` | `created(ClientModel client)` | `error(List<String> messages)`

Methods:
```dart
Future<void> searchClient(String term)
Future<void> createClient(CreateClientRequestModel request)
void clearClient()  // reset to initial
```

### 4.3 `SilverProductLookupCubit` + `SilverProductLookupState`

For barcode/ID lookup. State union:
- `initial` | `loading` | `found(SilverProductModel product)` | `notFound` | `alreadySold` | `error(List<String> messages)`

```dart
Future<void> lookupProduct(int id)
void clearLookup()
```

### 4.4 `SilverDoubleSellSubmitCubit` + `SilverDoubleSellSubmitState`

Handles final submission. State union:
- `initial` | `loading` | `success(SilverDoubleSellResponseModel data)` | `error(List<String> messages)`

```dart
Future<void> submitSell(SilverDoubleSellRequestModel request)
```

### 4.5 `SilverCreateVendorCubit` + `SilverCreateVendorState`

For on-the-fly vendor creation. State union:
- `initial` | `loading` | `success(CreateSilverVendorResponseModel vendor)` | `error(List<String> messages)`

```dart
Future<void> createVendor(CreateSilverVendorRequestModel request)
```

> **Key difference from gold:** Only 5 cubits (gold has 6). There is NO `SilverKindsCubit` because silver kinds are pre-loaded once and not carat-dependent.

### Freezed state files

Each state file follows the project pattern:
```dart
@freezed
class SomeState<T> with _$SomeState<T> {
  const factory SomeState.initial() = _Initial;
  const factory SomeState.loading() = Loading;
  const factory SomeState.success(T data) = Success<T>;
  const factory SomeState.error({required List<String> messages}) = Error;
}
```
Generate `.freezed.dart` for each.

---

## Phase 5 — Presentation Layer: UI

All in `lib/features/silver_double_sell/presentation/ui/`.

> **IMPORTANT:** The UI is **identical in structure** to Gold Double Sell. Same layout, same widget hierarchy, same user flow. The only differences are:
> 1. Silver endpoints instead of gold endpoints
> 2. Silver carats (e.g. "925", "800") instead of gold carats (e.g. "24", "21", "18")
> 3. No USD conversion — all prices are EGP only
> 4. Silver kinds dropdown is always available (not carat-dependent)
> 5. No `isMcD` checkbox on products
> 6. Different accent color: use a silver/grey accent (`Color(0xFF9E9E9E)` or `AppColors.silverColor` if defined) instead of gold accent

### 5.1 Main screen: `silver_double_sell_screen.dart`

`StatefulWidget`. In `initState`, triggers `SilverDoubleSellPreloadCubit.fetchPreloadData()`.

Top-level structure (same as gold):
```
BlocListener<SilverDoubleSellSubmitCubit> (loading overlay, success/error snackbar)
  └─ BlocBuilder<SilverDoubleSellPreloadCubit>
       ├─ loading → shimmer skeleton
       ├─ error → error view with retry
       └─ success → _SilverDoubleSellFormView(preloadData)
```

### 5.2 Form view (the main scrollable body)

`_SilverDoubleSellFormView` is a `StatefulWidget` that manages all local form state: selected client, selected worker, sell items list, buy items list, account entries, notes, tax.

**Sections (top to bottom) — same order as gold:**

1. **Client Section** — phone/email search field → BlocConsumer on `SilverClientSearchCubit` → show found client card or "Create New Client" form
2. **Worker Selector** — dropdown from `preloadData.workers`
3. **Sell Items Section** — expandable card with 3 tabs:
   - **Inside Tab** — product ID input + barcode scan → `SilverProductLookupCubit` → show product card → add to cart
   - **Box Tab** — carat dropdown → kind dropdown (from preloaded list, NOT lazy) → box dropdown → vendor dropdown → weight/loss/mc/profit fields → price auto-calc → add
   - **Outside Tab** — vendor dropdown → carat dropdown → kind dropdown (preloaded) → weight/mc/profit fields → price auto-calc → add
4. **Sell Items Cart** — list of added items with swipe-to-remove, running total
5. **Buy Items Section** (optional, collapsible) — carat dropdown → box dropdown → weight/loss/gram_price fields → buy_price auto-calc → add
6. **Buy Items Cart** — list with running total
7. **Payment Section — Sell Side** (`all_accounts`) — account dropdown → currency rate auto-fill → cash amount → add multiple
8. **Payment Section — Buy Side** (`deduction_accounts`) — always visible (same as gold) → same pattern
9. **Summary Section** — sell total, buy total, net, tax field, final total
10. **Notes** — optional text field
11. **Submit Button** — validates (Phase 12 checklist) → calls `SilverDoubleSellSubmitCubit.submitSell()`

### 5.3 Widget files (in `widgets/` subfolder)

| File | Purpose |
|------|---------|
| `silver_double_sell_client_section.dart` | Client search + create form (same as gold) |
| `silver_double_sell_worker_selector.dart` | Worker dropdown (same as gold) |
| `silver_double_sell_item_tabs.dart` | TabBar: Inside / Box / Outside |
| `silver_double_sell_inside_tab.dart` | Product lookup input + barcode scan + product card |
| `silver_double_sell_box_tab.dart` | Carat → kind (preloaded) → box → vendor → weight/loss form |
| `silver_double_sell_outside_tab.dart` | Vendor → carat → kind (preloaded) → weight form |
| `silver_double_sell_cart_widget.dart` | Reusable list of sell/buy items with totals |
| `silver_double_sell_cart_item_card.dart` | Single item card in the cart (swipe-dismiss) |
| `silver_double_sell_buy_section.dart` | Buy (trade-in) form |
| `silver_double_sell_payment_section.dart` | Account selection + cash + currency rate (reused for both sell and buy payment) |
| `silver_double_sell_summary_widget.dart` | Totals, tax, net, final |
| `silver_double_sell_product_card.dart` | Displays looked-up inside product (name, grams, carat, image, calculated price) |
| `silver_double_sell_create_vendor_sheet.dart` | Bottom sheet for on-the-fly vendor creation |
| `silver_double_sell_create_client_sheet.dart` | Bottom sheet for new client creation |
| `silver_double_sell_bloc_builder.dart` | Top-level BlocListener + BlocBuilder orchestration |
| `silver_double_sell_shimmer.dart` | Shimmer loading skeleton |

---

## Phase 6 — Price Calculation Helpers

**File:** `lib/features/silver_double_sell/data/helpers/silver_price_calculator.dart`

Pure Dart functions (no Flutter dependencies, easily testable):

```dart
class SilverDoubleSellPriceCalculator {
  /// Inside product price
  /// FORMULA: price = (mc + gram_price + profit) × grams
  /// No USD conversion needed (unlike gold)
  static double insidePrice({
    required double mc,
    required double gramPrice,
    required double profit,
    required double grams,
  }) {
    return (mc + gramPrice + profit) * grams;
  }

  /// Outside product price
  /// FORMULA: price = (mc + gram_price + profit) × grams
  /// Identical to inside formula
  static double outsidePrice({
    required double grams,
    required double gramPrice,
    required double mc,
    required double profit,
  }) {
    return (mc + gramPrice + profit) * grams;
  }

  /// Box product price
  /// FORMULA: price = (mc + gram_price + profit) × (grams - loss)
  /// Loss is subtracted from grams BEFORE multiplying
  static double boxPrice({
    required double grams,
    required double loss,
    required double gramPrice,
    required double mc,
    required double profit,
  }) {
    return (mc + gramPrice + profit) * (grams - loss);
  }

  /// Buy (trade-in) price
  /// FORMULA: buy_price = (grams - loss) × gram_price
  /// Default gram_price = carat.price - 50
  static double buyPrice({
    required double grams,
    required double loss,
    required double gramPrice,
  }) {
    return (grams - loss) * gramPrice;
  }

  /// Back-calculate profit when worker overrides price
  /// FORMULA: new_profit = (new_price / grams) - mc - gram_price
  /// Used for inside, outside, and box price overrides
  static double backCalculateProfit({
    required double newPrice,
    required double grams,
    required double mc,
    required double gramPrice,
  }) {
    return (newPrice / grams) - mc - gramPrice;
  }

  /// Final totals
  static ({double sellTotal, double buyTotal, double net, double taxAmount, double finalTotal})
  calculateTotals({
    required List<double> sellPrices,
    required List<double> buyPrices,
    required double taxPercent,
  }) {
    final sellTotal = sellPrices.fold(0.0, (a, b) => a + b);
    final buyTotal = buyPrices.fold(0.0, (a, b) => a + b);
    final net = sellTotal - buyTotal;
    final taxAmount = net * (taxPercent / 100);
    final finalTotal = net + taxAmount;
    return (
      sellTotal: sellTotal,
      buyTotal: buyTotal,
      net: net,
      taxAmount: taxAmount,
      finalTotal: finalTotal,
    );
  }
}
```

> **Key differences from gold price calculator:**
> 1. `insidePrice` has NO `isMcDollar` / `usdRate` parameters — silver MC is always EGP
> 2. `boxPrice` formula is `(mc + gramPrice + profit) × (grams - loss)` — simpler than gold's `((grams - loss) × gramPrice) + (grams × mc) + profit`
> 3. `buyPrice` default gram price = `carat.price - 50` (set in UI, not calculator)

---

## Phase 7 — DI Registration

**File to update:** `lib/core/di/dependency_injection.dart`

Add:
```dart
getIt.registerLazySingleton<SilverDoubleSellApiService>(() => SilverDoubleSellApiService(dio));
getIt.registerLazySingleton<SilverDoubleSellRepo>(() => SilverDoubleSellRepo(getIt()));
```

---

## Phase 8 — Routing

**File to update:** `lib/core/routing/routes.dart`

Add:
```dart
static const String silverDoubleSellScreen = '/silver_double_sell_screen';
```

**File to update:** `lib/core/routing/app_router.dart`

Add case for `Routes.silverDoubleSellScreen`:
```dart
case Routes.silverDoubleSellScreen:
  return CupertinoPageRoute(
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SilverDoubleSellPreloadCubit(getIt())),
        BlocProvider(create: (_) => SilverClientSearchCubit(getIt())),
        BlocProvider(create: (_) => SilverProductLookupCubit(getIt())),
        BlocProvider(create: (_) => SilverDoubleSellSubmitCubit(getIt())),
        BlocProvider(create: (_) => SilverCreateVendorCubit(getIt())),
      ],
      child: const SilverDoubleSellScreen(),
    ),
  );
```

> **Note:** Only 5 BlocProviders (gold has 6). No `SilverKindsCubit` needed.

---

## Phase 9 — Drawer Integration

**File to update:** `lib/features/main_layout/ui/widgets/main_layout_drawer.dart`

The "Silver Mix Sell" drawer item will navigate to this screen.

**File to update:** `lib/features/main_layout/ui/main_layout_screen.dart`

Update the appropriate drawer case for Silver Mix Sell:
```dart
case X: // Silver Mix Sell → Silver Double Sell
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => SilverDoubleSellPreloadCubit(getIt())),
      BlocProvider(create: (_) => SilverClientSearchCubit(getIt())),
      BlocProvider(create: (_) => SilverProductLookupCubit(getIt())),
      BlocProvider(create: (_) => SilverDoubleSellSubmitCubit(getIt())),
      BlocProvider(create: (_) => SilverCreateVendorCubit(getIt())),
    ],
    child: const SilverDoubleSellScreen(),
  );
```

---

## Phase 10 — Complete File Tree

```
lib/features/silver_double_sell/
├── data/
│   ├── helpers/
│   │   └── silver_price_calculator.dart
│   ├── models/
│   │   ├── silver_carat_model.dart
│   │   ├── silver_kind_model.dart
│   │   ├── silver_box_model.dart
│   │   ├── silver_vendor_model.dart
│   │   ├── create_silver_vendor_request_model.dart
│   │   ├── create_silver_vendor_response_model.dart
│   │   ├── silver_product_model.dart
│   │   ├── silver_double_sell_request_model.dart
│   │   ├── silver_double_sell_response_model.dart
│   │   └── silver_double_sell_preload_data.dart
│   ├── remote/
│   │   ├── silver_double_sell_api_service.dart
│   │   └── silver_double_sell_api_service.g.dart
│   ├── services/
│   │   └── barcode_scanner_service.dart          ← reuse from gold (import, don't duplicate)
│   └── repo/
│       └── silver_double_sell_repo.dart
└── presentation/
    ├── cubit/
    │   ├── silver_double_sell_preload_cubit.dart
    │   ├── silver_double_sell_preload_state.dart
    │   ├── silver_double_sell_preload_state.freezed.dart
    │   ├── silver_client_search_cubit.dart
    │   ├── silver_client_search_state.dart
    │   ├── silver_client_search_state.freezed.dart
    │   ├── silver_product_lookup_cubit.dart
    │   ├── silver_product_lookup_state.dart
    │   ├── silver_product_lookup_state.freezed.dart
    │   ├── silver_double_sell_submit_cubit.dart
    │   ├── silver_double_sell_submit_state.dart
    │   ├── silver_double_sell_submit_state.freezed.dart
    │   ├── silver_create_vendor_cubit.dart
    │   ├── silver_create_vendor_state.dart
    │   └── silver_create_vendor_state.freezed.dart
    └── ui/
        ├── silver_double_sell_screen.dart
        └── widgets/
            ├── silver_double_sell_bloc_builder.dart
            ├── silver_double_sell_shimmer.dart
            ├── silver_double_sell_client_section.dart
            ├── silver_double_sell_create_client_sheet.dart
            ├── silver_double_sell_worker_selector.dart
            ├── silver_double_sell_item_tabs.dart
            ├── silver_double_sell_inside_tab.dart
            ├── silver_double_sell_box_tab.dart
            ├── silver_double_sell_outside_tab.dart
            ├── silver_double_sell_product_card.dart
            ├── silver_double_sell_cart_widget.dart
            ├── silver_double_sell_cart_item_card.dart
            ├── silver_double_sell_buy_section.dart
            ├── silver_double_sell_payment_section.dart
            ├── silver_double_sell_summary_widget.dart
            └── silver_double_sell_create_vendor_sheet.dart
```

---

## Phase 11 — Implementation Order

Build in this exact order to avoid forward-reference issues:

| Step | What | Files | Depends on |
|------|------|-------|------------|
| 1 | Models (10 new + reuse 4 from gold) | `data/models/*.dart` | Nothing |
| 2 | Price calculator | `data/helpers/silver_price_calculator.dart` | Nothing |
| 3 | API service + .g.dart | `data/remote/*` | Step 1 |
| 4 | Repository | `data/repo/*` | Steps 1 + 3 |
| 5 | DI registration | `core/di/dependency_injection.dart` | Steps 3 + 4 |
| 6 | Cubit states (5 freezed) | `presentation/cubit/*_state.dart` + `.freezed.dart` | Nothing |
| 7 | Cubits (5) | `presentation/cubit/*_cubit.dart` | Steps 4 + 6 |
| 8 | Shimmer widget | `ui/widgets/silver_double_sell_shimmer.dart` | Nothing |
| 9 | Client section widgets | `ui/widgets/silver_double_sell_client_section.dart`, `_create_client_sheet.dart` | Step 7 |
| 10 | Worker selector widget | `ui/widgets/silver_double_sell_worker_selector.dart` | Step 1 |
| 11 | Product card widget | `ui/widgets/silver_double_sell_product_card.dart` | Step 1 |
| 12 | Inside tab widget | `ui/widgets/silver_double_sell_inside_tab.dart` | Steps 2, 7, 11 |
| 13 | Create vendor sheet | `ui/widgets/silver_double_sell_create_vendor_sheet.dart` | Step 7 |
| 14 | Box tab widget | `ui/widgets/silver_double_sell_box_tab.dart` | Steps 1, 2, 7, 13 |
| 15 | Outside tab widget | `ui/widgets/silver_double_sell_outside_tab.dart` | Steps 1, 2, 7, 13 |
| 16 | Item tabs container | `ui/widgets/silver_double_sell_item_tabs.dart` | Steps 12, 14, 15 |
| 17 | Cart widgets | `ui/widgets/silver_double_sell_cart_widget.dart`, `_cart_item_card.dart` | Step 1 |
| 18 | Buy section widget | `ui/widgets/silver_double_sell_buy_section.dart` | Steps 1, 2 |
| 19 | Payment section widget | `ui/widgets/silver_double_sell_payment_section.dart` | Step 1 |
| 20 | Summary widget | `ui/widgets/silver_double_sell_summary_widget.dart` | Step 2 |
| 21 | Bloc builder orchestrator | `ui/widgets/silver_double_sell_bloc_builder.dart` | Steps 7, 8, 9–20 |
| 22 | Main screen | `ui/silver_double_sell_screen.dart` | Step 21 |
| 23 | Route + drawer wiring | `routes.dart`, `app_router.dart`, `main_layout_screen.dart` | Step 22 |

---

## Phase 12 — Validation Rules (Pre-submit Checklist)

Enforce in `_SilverDoubleSellFormView` before calling `submitCubit.submitSell()`:

1. `client_id` is set (client was searched or created)
2. `worker_id` is set
3. At least one sell item exists (inside OR box OR outside)
4. Every inside item: `id` set, `profit` set, `price > 0`
5. Every box item: `carat_id`, `kind_id`, `box_id`, `vendor_id` set, `grams > 0`, `loss >= 0`, `loss < grams`, `mc >= 0`, `gram_price > 0`, `price > 0`
6. Every outside item: `carat_id`, `kind_id`, `vendor_id` set, `grams > 0`, `mc >= 0`, `gram_price > 0`, `price > 0`
7. Every buy item: `carat_id`, `box_id` set, `grams > 0`, `loss >= 0`, `gram_price > 0`, `buy_price > 0`
8. If buy items exist → `deduction_accounts` is non-empty
9. `all_accounts` is non-empty
10. Every account entry: `account_id` set, `cash > 0`

> **Key difference from gold:** No validation rule for `isMcD` / `usdRate` — silver has no USD conversion.

---

## Phase 13 — Error Handling Strategy

| Scenario | Where handled | UX |
|----------|---------------|-----|
| Pre-load fails | `SilverDoubleSellPreloadCubit` error state | Error view with retry button |
| Client not found (404) | `SilverClientSearchCubit.notFound` state | Show "لا يوجد عميل بهذا الرقم" + offer "إضافة عميل" button |
| Duplicate phone on create (422) | `SilverClientSearchCubit.error` | Show "هذا الرقم مسجل بالفعل" |
| Duplicate email on create (422) | `SilverClientSearchCubit.error` | Show "هذا الايميل مسجل بالفعل" |
| Product not found (404) | `SilverProductLookupCubit.notFound` state | "لا يوجد منتج بهذا الرقم" — clear input |
| Product already sold (422) | `SilverProductLookupCubit.alreadySold` state | "هذا المنتج تم بيعه بالفعل" — clear input |
| Product already in cart | Client-side check | "هذا المنتج موجود بالفعل" |
| Daily ledger not open (422) | `SilverDoubleSellSubmitCubit.error` | Show "لم يتم فتح اليومية لهذا اليوم" |
| No products in cart | Client-side validation blocks submit | "يجب اختيار منتجات للبيع" |
| No payment account | Client-side validation blocks submit | "يجب إضافة طريقة دفع" |
| Payment cash empty | Client-side validation blocks submit | "برجاء ادخال جميع المبالغ" |
| Buy items but no deduction accounts | Client-side validation blocks submit | "يجب تحديد حسابات الخصم لعملية الشراء" |
| Server error (500) | `SilverDoubleSellSubmitCubit.error` | "حدث خطأ أثناء معالجة الطلب" — let worker retry |
| Network error | Exception | "حدث خطأ في الاتصال" |
| Vendor not in list | "Create Vendor" bottom sheet | Uses `SilverCreateVendorCubit` |

---

## Phase 14 — UI/UX Design Notes

> **The UI is the same as Gold Double Sell but in "silver mode".**

### Color palette (reuse existing `AppColors`)
- Primary actions: `AppColors.primaryColor` / `AppColors.darkBrown` (same as gold)
- Sell items: Use a silver/grey accent (`Color(0xFF9E9E9E)`) instead of gold's `AppColors.goldColor`
- Buy items: `AppColors.successColor` / green accent (same as gold)
- Error states: `AppColors.errorColor` (same as gold)
- Success: `AppColors.successColor` (same as gold)

### Layout principles (same as gold)
- All sizing via `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`)
- Theme-aware: check `Theme.of(context).brightness == Brightness.dark` in every widget
- Cards use `GlassmorphismContainer` or standard `Container` with `BoxDecoration`
- Forms use `CustomTextFormField` from `core/widgets/`
- Buttons use `CustomButton` from `core/widgets/`
- Dropdowns styled to match existing app look
- Bottom sheets for creation flows (client, vendor)
- `EasyLoading.show()` / `.dismiss()` for submit loading
- `successSnackBar()` / `failureSnackBar()` for action feedback
- `Shimmer` loading skeleton during pre-load

### Tab design for sell items
- Use `TabBar` + `TabBarView` with 3 tabs: Inside / Box / Outside
- Match the gold double sell tab styling

### Barcode scanner
- Reuse the native `BarcodeScannerService` from `gold_double_sell/data/services/barcode_scanner_service.dart`
- Same MethodChannel (`kenooz/barcode_scanner`) — Google Code Scanner on Android, AVFoundation on iOS
- On scan result → auto-fill product ID field → trigger lookup via `SilverProductLookupCubit`

---

## Phase 15 — Key Architecture Decisions

1. **One repo, one API service** — all 12 endpoints live in one service since they're all part of the same feature flow
2. **5 cubits** — split by responsibility (1 fewer than gold — no kinds cubit needed)
3. **Preload cubit** fetches all 6 endpoints in parallel — the screen won't render until all succeed
4. **No lazy kinds loading** — silver kinds are loaded once at screen open (not per-carat). This simplifies the UI: the kinds dropdown is always populated.
5. **Price calculator is pure Dart** — no cubit, no Flutter dependency, just static methods called directly in widget `setState`
6. **Reuse shared models** — `ShopWorkerModel`, `PaymentAccountModel`, `AccountCurrencyModel`, `ClientModel`, `CreateClientRequestModel` are imported from gold_double_sell, not duplicated
7. **Reuse barcode scanner service** — import from `gold_double_sell/data/services/barcode_scanner_service.dart`
8. **Request payload uses `Map<String, dynamic>`** for product arrays — same as gold
9. **No USD conversion** — all silver prices are in EGP. No `currencies` list, no `usdRate`, no `isMcD` flag. This simplifies the price calculator significantly.

---

## Phase 16 — Key Differences from Gold Double Sell (Quick Reference)

| Aspect | Gold Double Sell | Silver Double Sell |
|--------|-----------------|-------------------|
| Pre-load endpoints | 8 (carats, currencies, usd, rates, workers, boxes, vendors, accounts) | 6 (carats, kinds, boxes, vendors, workers, accounts) |
| Lazy-load endpoints | 2 (kinds per carat, account currency) | 1 (account currency only) |
| Total endpoints | 15 | 12 |
| Cubits | 6 (incl. GoldKindsCubit) | 5 (no kinds cubit) |
| Kinds loading | Lazy — fetched per carat selection | Pre-loaded once — not carat-dependent |
| USD conversion | Yes — `isMcD` flag, USD rate needed | No — all EGP |
| Inside price formula | `(effectiveMc + gramPrice + profit) × grams` where `effectiveMc = isMcD ? mc × usdRate : mc` | `(mc + gramPrice + profit) × grams` — no USD |
| Box price formula | `((grams - loss) × gramPrice) + (grams × mc) + profit` | `(mc + gramPrice + profit) × (grams - loss)` |
| Outside price formula | `(mc + gramPrice + profit) × grams` | Same |
| Buy gram price default | `carat.price - 50` | Same — `carat.price - 50` |
| Submit endpoint | `POST worker/golds/sells/double/store` | `POST worker/silvers/sells/double/store` |
| Product lookup | `GET worker/gold/product/{id}` | `GET worker/silver/product/{id}` |
| Vendor endpoint | `POST worker/vendors/add` | `POST worker/silver/vendors/add` |
| Accent color | Gold (`AppColors.goldColor`) | Silver/grey (`Color(0xFF9E9E9E)`) |

---

## Full Endpoint Reference Card

| # | Method | Endpoint | When to Call | Auth |
|---|--------|----------|-------------|------|
| 1 | GET | `/api/worker/silver/rates` | Screen open | Worker JWT |
| 2 | GET | `/api/worker/silver/kinds` | Screen open | Worker JWT |
| 3 | GET | `/api/worker/silver/boxes` | Screen open | Worker JWT |
| 4 | GET | `/api/worker/silver/vendors` | Screen open | Worker JWT |
| 5 | GET | `/api/worker/gold/workers` | Screen open | Worker JWT |
| 6 | GET | `/api/worker/accounts` | Screen open | Worker JWT |
| 7 | GET | `/api/worker/silver/product/{id}` | On barcode scan | Worker JWT |
| 8 | GET | `/api/worker/clients/search/{term}` | On client search | Worker JWT |
| 9 | GET | `/api/worker/accounts/{id}/currency` | On account select | Worker JWT |
| 10 | POST | `/api/worker/clients/add` | Create new client | Worker JWT |
| 11 | POST | `/api/worker/silver/vendors/add` | Create new vendor | Worker JWT |
| 12 | POST | `/api/worker/silvers/sells/double/store` | Submit order | Worker JWT |

### Quick notes
- Endpoints 1–6: fire in parallel on screen open
- Endpoint 7: called on every barcode scan, never cached
- Endpoint 8: called on every search attempt
- Endpoint 9: called once per account row when account is selected
- Endpoints 10–11: called only when creating new records
- Endpoint 12: called once at the very end

---

## Appendix — Minimal Full Example Payload

```json
{
  "client_id": 12,
  "worker_id": 3,
  "total": 1222.00,
  "tax": 0,
  "notes": "",
  "all_accounts": [
    { "account_id": 1, "cash": 1222.00, "currency_price": 1.0 }
  ],
  "insideProducts": [
    { "id": 42, "profit": 10.00, "price": 324.50 }
  ],
  "outsideProducts": [
    {
      "carat_id": 1, "kind_id": 2, "vendor_id": 3,
      "grams": 8.0, "mc": 12.0, "profit": 8.0,
      "gram_price": 34.0, "price": 432.0
    }
  ],
  "boxProducts": [
    {
      "carat_id": 1, "kind_id": 1, "box_id": 2, "vendor_id": 3,
      "grams": 10.0, "loss": 0.5, "mc": 10.0, "profit": 5.0,
      "gram_price": 34.0, "price": 465.50
    }
  ],
  "buySilverProducts": [],
  "deduction_accounts": []
}
```

---

## Summary

**Total new files: ~40** (10 models, 2 API service files, 1 repo, 10 cubit files (5 states + 5 cubits) + 5 freezed files, 1 screen, 16 widgets, 1 price calculator)

**Reused from gold_double_sell: 5 models** (ShopWorkerModel, PaymentAccountModel, AccountCurrencyModel, ClientModel, CreateClientRequestModel) + BarcodeScannerService

**Files to update: 4** (dependency_injection.dart, routes.dart, app_router.dart, main_layout_screen.dart)

**Endpoints: 12** (6 pre-load, 1 lazy-load, 2 client, 1 vendor, 1 product, 1 submit)

**Cubits: 5** (preload, client search, product lookup, submit, create vendor)
