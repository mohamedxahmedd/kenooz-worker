# Gold Double Sell — Implementation Plan

> Feature: Trade-in transaction screen where the shop sells gold to a client and optionally buys old gold back, settling a net total in one atomic API call.

---

## Phase 1 — Data Layer: Models

All models go in `lib/features/gold_double_sell/data/models/`. Every model uses manual `fromJson` with `_parseInt` / `_parseDouble` helpers (same pattern as `CaratModel`, `OrderModel`).

### 1.1 Pre-load response models

| File | Class | Source endpoint | Key fields |
|------|-------|----------------|------------|
| `gold_carat_model.dart` | `GoldCaratModel` | `GET /api/carats/all` | `id`, `carat` (display string), `fixed` (double), `price` (double) |
| `currency_model.dart` | `CurrencyModel` | `GET /api/currency/all` | `id`, `name`, `code`, `price` (EGP rate) |
| `usd_rate_model.dart` | — | `GET /api/worker/gold/usd` | Reuse existing `UsdRateModel` from home feature (import, don't duplicate) |
| `gold_rate_model.dart` | — | `GET /api/worker/gold/rates` | Reuse existing `GoldRatesModel` / `CaratModel` from home (same shape) |
| `shop_worker_model.dart` | `ShopWorkerModel` | `GET /api/worker/gold/workers` | `id`, `name` |
| `gold_box_model.dart` | `GoldBoxModel` | `GET /api/worker/gold/boxes` | `id`, `name`, `total` (string → double) |
| `gold_vendor_model.dart` | `GoldVendorModel` | `GET /api/worker/gold/vendors` | `id`, `name`, `caratId`, `currencyId`, `gold` (double), `cash` (double) |
| `payment_account_model.dart` | `PaymentAccountModel` | `GET /api/worker/accounts` | `id`, `name`, `balance`, `currencyId`, `methodId`, nested `currency` object → extract `code` and `price` |

### 1.2 Lazy-load response models

| File | Class | Source endpoint |
|------|-------|----------------|
| `gold_kind_model.dart` | `GoldKindModel` | `GET /api/worker/gold/kinds/{carat_id}` — fields: `id`, `name` |
| `account_currency_model.dart` | `AccountCurrencyModel` | `GET /api/worker/accounts/{id}/currency` — fields: `id`, `code`, `price` |

### 1.3 Client models

| File | Class | Endpoint |
|------|-------|----------|
| `client_model.dart` | `ClientModel` | Search and create responses — `id`, `name`, `email`, `phone`, `gender`, `points` |
| `create_client_request_model.dart` | `CreateClientRequestModel` | `POST /api/worker/clients/add` — `client_name`, `client_phone`, `client_email`, `client_gender` (note `client_` prefix) |

### 1.4 Vendor creation

| File | Class |
|------|-------|
| `create_vendor_request_model.dart` | `CreateVendorRequestModel` — `name`, `carat_id`, `currency_id`, `phone?`, `notes?` |
| `create_vendor_response_model.dart` | `CreateVendorResponseModel` — full vendor object returned by server |

### 1.5 Product lookup

| File | Class |
|------|-------|
| `gold_product_model.dart` | `GoldProductModel` — `id`, `shopId`, `kindId`, `caratId`, `vendorId`, `name`, `grams`, `profit`, `mc`, `isMcD` (int→bool), `isSold`, `gramPrice`, `caratName`, `carat` (nested `GoldCaratModel`), `media` (list → extract `original_url`) |

### 1.6 Submit request / response

| File | Class | Notes |
|------|-------|-------|
| `double_sell_request_model.dart` | `DoubleSellRequestModel` | Top-level: `client_id`, `worker_id`, `total`, `tax`, `notes`, `all_accounts`, `insideProducts`, `outsideProducts`, `boxProducts`, `buyGoldProducts`, `deduction_accounts` — each sub-array is `List<Map<String, dynamic>>` |
| `double_sell_response_model.dart` | `DoubleSellResponseModel` | `status`, `sell_id`, `buy_id` (nullable), `total` |

### 1.7 Composite pre-load model

| File | Class | Notes |
|------|-------|-------|
| `double_sell_preload_data.dart` | `DoubleSellPreloadData` | Holds all 8 pre-load results in one object: `carats`, `currencies`, `usdRate`, `goldRates`, `workers`, `boxes`, `vendors`, `accounts` — passed to the UI as the `Success` state data |

---

## Phase 2 — Data Layer: API Service

**File:** `lib/features/gold_double_sell/data/remote/gold_double_sell_api_service.dart`

Retrofit interface with all 15 endpoints. Use `static const String` for endpoint paths (same pattern as `HomeApiService`).

```
// Pre-load (8 endpoints — called in parallel)
GET  carats/all                              → List<GoldCaratModel>
GET  currency/all                            → List<CurrencyModel>
GET  worker/gold/usd                         → UsdRateModel (reuse)
GET  worker/gold/rates                       → GoldRatesModel (reuse)
GET  worker/gold/workers                     → List<ShopWorkerModel>
GET  worker/gold/boxes                       → List<GoldBoxModel>
GET  worker/gold/vendors                     → List<GoldVendorModel>
GET  worker/accounts                         → List<PaymentAccountModel>

// Lazy-load (2 endpoints)
GET  worker/gold/kinds/{carat_id}            → List<GoldKindModel>
GET  worker/accounts/{id}/currency           → AccountCurrencyModel

// Client (2 endpoints)
GET  worker/clients/search/{term}            → ClientModel
POST worker/clients/add                      → ClientModel

// Vendor (1 endpoint)
POST worker/vendors/add                      → CreateVendorResponseModel

// Product (1 endpoint)
GET  worker/gold/product/{id}                → GoldProductModel

// Submit (1 endpoint)
POST worker/golds/sells/double/store         → DoubleSellResponseModel
```

**Important:** The `carats/all` and `currency/all` endpoints are public (no auth needed). All `worker/*` endpoints require Bearer token (already handled by `DioFactory.addDioHeaders()`).

**Note on response shapes:** `carats/all` and `currency/all` return raw JSON arrays `[...]`, while `worker/gold/rates` returns `{"carats":[...]}`. Handle in the `.g.dart` accordingly (use `_dio.fetch<List<dynamic>>` for raw arrays, `_dio.fetch<Map<String, dynamic>>` for objects).

Also generate: `gold_double_sell_api_service.g.dart`

---

## Phase 3 — Data Layer: Repository

**File:** `lib/features/gold_double_sell/data/repo/gold_double_sell_repo.dart`

### 3.1 `fetchPreloadData()`

Calls all 8 pre-load endpoints via `Future.wait()` in parallel. Returns `ApiResult<DoubleSellPreloadData>`. On any failure, the entire pre-load fails (wrapped in try/catch → `ErrorHandler.handle(e)`).

### 3.2 Individual lazy-load methods

```dart
Future<ApiResult<List<GoldKindModel>>> fetchKindsByCarat(int caratId)
Future<ApiResult<AccountCurrencyModel>> fetchAccountCurrency(int accountId)
```

### 3.3 Client methods

```dart
Future<ApiResult<ClientModel>> searchClient(String term)
Future<ApiResult<ClientModel>> createClient(CreateClientRequestModel request)
```

### 3.4 Vendor method

```dart
Future<ApiResult<CreateVendorResponseModel>> createVendor(CreateVendorRequestModel request)
```

### 3.5 Product lookup

```dart
Future<ApiResult<GoldProductModel>> fetchProduct(int id)
```

### 3.6 Submit

```dart
Future<ApiResult<DoubleSellResponseModel>> submitDoubleSell(DoubleSellRequestModel request)
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

All in `lib/features/gold_double_sell/presentation/cubit/`.

### 4.1 `DoubleSellPreloadCubit` + `DoubleSellPreloadState`

Handles the initial 8-endpoint parallel fetch. State union:
- `initial` → `loading` → `success(DoubleSellPreloadData data)` | `error(List<String> messages)`

```dart
Future<void> fetchPreloadData() async {
  emit(loading);
  final result = await _repo.fetchPreloadData();
  result.when(success: ..., failure: ...);
}
```

### 4.2 `ClientSearchCubit` + `ClientSearchState`

For searching and creating clients. State union:
- `initial` | `loading` | `found(ClientModel client)` | `notFound` | `created(ClientModel client)` | `error(List<String> messages)`

Methods:
```dart
Future<void> searchClient(String term)
Future<void> createClient(CreateClientRequestModel request)
void clearClient()  // reset to initial
```

### 4.3 `ProductLookupCubit` + `ProductLookupState`

For barcode/ID lookup. State union:
- `initial` | `loading` | `found(GoldProductModel product)` | `notFound` | `alreadySold` | `error(List<String> messages)`

```dart
Future<void> lookupProduct(int id)
void clearLookup()
```

### 4.4 `GoldKindsCubit` + `GoldKindsState`

Lazy-loads kinds when a carat is selected. State union:
- `initial` | `loading` | `success(List<GoldKindModel> kinds)` | `error(List<String> messages)`

```dart
Future<void> fetchKinds(int caratId)
```

### 4.5 `DoubleSellSubmitCubit` + `DoubleSellSubmitState`

Handles final submission. State union:
- `initial` | `loading` | `success(DoubleSellResponseModel data)` | `error(List<String> messages)`

```dart
Future<void> submitSell(DoubleSellRequestModel request)
```

### 4.6 `CreateVendorCubit` + `CreateVendorState`

For on-the-fly vendor creation. State union:
- `initial` | `loading` | `success(CreateVendorResponseModel vendor)` | `error(List<String> messages)`

```dart
Future<void> createVendor(CreateVendorRequestModel request)
```

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

All in `lib/features/gold_double_sell/presentation/ui/`.

### 5.1 Main screen: `gold_double_sell_screen.dart`

`StatefulWidget`. In `initState`, triggers `DoubleSellPreloadCubit.fetchPreloadData()`.

Top-level structure:
```
BlocListener<DoubleSellSubmitCubit> (loading overlay, success/error snackbar)
  └─ BlocBuilder<DoubleSellPreloadCubit>
       ├─ loading → shimmer skeleton
       ├─ error → error view with retry
       └─ success → _DoubleSellFormView(preloadData)
```

### 5.2 Form view (the main scrollable body)

`_DoubleSellFormView` is a `StatefulWidget` that manages all local form state: selected client, selected worker, sell items list, buy items list, account entries, notes, tax.

**Sections (top to bottom):**

1. **Client Section** — phone/email search field → BlocConsumer on `ClientSearchCubit` → show found client card or "Create New Client" form
2. **Worker Selector** — dropdown from `preloadData.workers`
3. **Sell Items Section** — expandable card with 3 tabs:
   - **Inside Tab** — product ID input → `ProductLookupCubit` → show product card → add to cart
   - **Box Tab** — carat dropdown → lazy kinds → box dropdown → vendor dropdown → weight/loss/mc/profit fields → price auto-calc → add
   - **Outside Tab** — vendor dropdown → carat dropdown → lazy kinds → weight/mc/profit fields → price auto-calc → add
4. **Sell Items Cart** — list of added items with swipe-to-remove, running total
5. **Buy Items Section** (optional, collapsible) — carat dropdown → box dropdown → weight/loss/gram_price fields → buy_price auto-calc → add
6. **Buy Items Cart** — list with running total
7. **Payment Section — Sell Side** (`all_accounts`) — account dropdown → currency rate auto-fill → cash amount → add multiple
8. **Payment Section — Buy Side** (`deduction_accounts`) — only visible if buy items exist → same pattern
9. **Summary Section** — sell total, buy total, net, tax field, final total
10. **Notes** — optional text field
11. **Submit Button** — validates (§12 checklist) → calls `DoubleSellSubmitCubit.submitSell()`

### 5.3 Widget files (in `widgets/` subfolder)

| File | Purpose |
|------|---------|
| `double_sell_client_section.dart` | Client search + create form |
| `double_sell_worker_selector.dart` | Worker dropdown |
| `double_sell_item_tabs.dart` | TabBar: Inside / Box / Outside |
| `double_sell_inside_tab.dart` | Product lookup input + product card |
| `double_sell_box_tab.dart` | Carat → kind → box → vendor → weight form |
| `double_sell_outside_tab.dart` | Vendor → carat → kind → weight form |
| `double_sell_cart_widget.dart` | Reusable list of sell/buy items with totals |
| `double_sell_cart_item_card.dart` | Single item card in the cart (swipe-dismiss) |
| `double_sell_buy_section.dart` | Buy (trade-in) form |
| `double_sell_payment_section.dart` | Account selection + cash + currency rate (reused for both sell and buy payment) |
| `double_sell_summary_widget.dart` | Totals, tax, net, final |
| `double_sell_product_card.dart` | Displays looked-up inside product (name, grams, carat, image, calculated price) |
| `double_sell_create_vendor_sheet.dart` | Bottom sheet for on-the-fly vendor creation |
| `double_sell_create_client_sheet.dart` | Bottom sheet for new client creation |
| `double_sell_bloc_builder.dart` | Top-level BlocListener + BlocBuilder orchestration |
| `double_sell_shimmer.dart` | Shimmer loading skeleton |

---

## Phase 6 — Price Calculation Helpers

**File:** `lib/features/gold_double_sell/data/helpers/price_calculator.dart`

Pure Dart functions (no Flutter dependencies, easily testable):

```dart
class DoubleSellPriceCalculator {
  /// Inside product price (§7.1)
  static double insidePrice({
    required double mc,
    required double gramPrice,
    required double profit,
    required double grams,
    required bool isMcDollar,
    required double usdRate,
  }) {
    final effectiveMc = isMcDollar ? mc * usdRate : mc;
    return (effectiveMc + gramPrice + profit) * grams;
  }

  /// Box product price (§7.2)
  static double boxPrice({
    required double grams,
    required double loss,
    required double gramPrice,
    required double mc,
    required double profit,
  }) {
    return ((grams - loss) * gramPrice) + (grams * mc) + profit;
  }

  /// Outside product price (§7.3)
  static double outsidePrice({
    required double grams,
    required double gramPrice,
    required double mc,
    required double profit,
  }) {
    return (mc + gramPrice + profit) * grams;
  }

  /// Buy (trade-in) price (§7.4)
  static double buyPrice({
    required double grams,
    required double loss,
    required double gramPrice,
  }) {
    return (grams - loss) * gramPrice;
  }

  /// Final totals (§7.5)
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
    return (sellTotal: sellTotal, buyTotal: buyTotal, net: net, taxAmount: taxAmount, finalTotal: finalTotal);
  }
}
```

---

## Phase 7 — DI Registration

**File to update:** `lib/core/di/dependency_injection.dart`

Add:
```dart
getIt.registerLazySingleton<GoldDoubleSellApiService>(() => GoldDoubleSellApiService(dio));
getIt.registerLazySingleton<GoldDoubleSellRepo>(() => GoldDoubleSellRepo(getIt()));
```

---

## Phase 8 — Routing

**File to update:** `lib/core/routing/routes.dart`

Add:
```dart
static const String goldDoubleSellScreen = '/gold_double_sell_screen';
```

**File to update:** `lib/core/routing/app_router.dart`

Add case for `Routes.goldDoubleSellScreen`:
```dart
case Routes.goldDoubleSellScreen:
  return CupertinoPageRoute(
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DoubleSellPreloadCubit(getIt())),
        BlocProvider(create: (_) => ClientSearchCubit(getIt())),
        BlocProvider(create: (_) => ProductLookupCubit(getIt())),
        BlocProvider(create: (_) => GoldKindsCubit(getIt())),
        BlocProvider(create: (_) => DoubleSellSubmitCubit(getIt())),
        BlocProvider(create: (_) => CreateVendorCubit(getIt())),
      ],
      child: const GoldDoubleSellScreen(),
    ),
  );
```

---

## Phase 9 — Drawer Integration

**File to update:** `lib/features/main_layout/ui/widgets/main_layout_drawer.dart`

The "Gold Mix Sell" drawer item (currently index 2) will navigate to this screen instead of showing a placeholder.

**File to update:** `lib/features/main_layout/ui/main_layout_screen.dart`

Update `_buildDrawerFeatureScreen` case 2 (Gold Mix Sell):
```dart
case 2: // Gold Mix Sell → Gold Double Sell
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => DoubleSellPreloadCubit(getIt())),
      BlocProvider(create: (_) => ClientSearchCubit(getIt())),
      BlocProvider(create: (_) => ProductLookupCubit(getIt())),
      BlocProvider(create: (_) => GoldKindsCubit(getIt())),
      BlocProvider(create: (_) => DoubleSellSubmitCubit(getIt())),
      BlocProvider(create: (_) => CreateVendorCubit(getIt())),
    ],
    child: const GoldDoubleSellScreen(),
  );
```

---

## Phase 10 — Complete File Tree

```
lib/features/gold_double_sell/
├── data/
│   ├── helpers/
│   │   └── price_calculator.dart
│   ├── models/
│   │   ├── gold_carat_model.dart
│   │   ├── currency_model.dart
│   │   ├── shop_worker_model.dart
│   │   ├── gold_box_model.dart
│   │   ├── gold_vendor_model.dart
│   │   ├── payment_account_model.dart
│   │   ├── gold_kind_model.dart
│   │   ├── account_currency_model.dart
│   │   ├── client_model.dart
│   │   ├── create_client_request_model.dart
│   │   ├── create_vendor_request_model.dart
│   │   ├── create_vendor_response_model.dart
│   │   ├── gold_product_model.dart
│   │   ├── double_sell_request_model.dart
│   │   ├── double_sell_response_model.dart
│   │   └── double_sell_preload_data.dart
│   ├── remote/
│   │   ├── gold_double_sell_api_service.dart
│   │   └── gold_double_sell_api_service.g.dart
│   └── repo/
│       └── gold_double_sell_repo.dart
└── presentation/
    ├── cubit/
    │   ├── double_sell_preload_cubit.dart
    │   ├── double_sell_preload_state.dart
    │   ├── double_sell_preload_state.freezed.dart
    │   ├── client_search_cubit.dart
    │   ├── client_search_state.dart
    │   ├── client_search_state.freezed.dart
    │   ├── product_lookup_cubit.dart
    │   ├── product_lookup_state.dart
    │   ├── product_lookup_state.freezed.dart
    │   ├── gold_kinds_cubit.dart
    │   ├── gold_kinds_state.dart
    │   ├── gold_kinds_state.freezed.dart
    │   ├── double_sell_submit_cubit.dart
    │   ├── double_sell_submit_state.dart
    │   ├── double_sell_submit_state.freezed.dart
    │   ├── create_vendor_cubit.dart
    │   ├── create_vendor_state.dart
    │   └── create_vendor_state.freezed.dart
    └── ui/
        ├── gold_double_sell_screen.dart
        └── widgets/
            ├── double_sell_bloc_builder.dart
            ├── double_sell_shimmer.dart
            ├── double_sell_client_section.dart
            ├── double_sell_create_client_sheet.dart
            ├── double_sell_worker_selector.dart
            ├── double_sell_item_tabs.dart
            ├── double_sell_inside_tab.dart
            ├── double_sell_box_tab.dart
            ├── double_sell_outside_tab.dart
            ├── double_sell_product_card.dart
            ├── double_sell_cart_widget.dart
            ├── double_sell_cart_item_card.dart
            ├── double_sell_buy_section.dart
            ├── double_sell_payment_section.dart
            ├── double_sell_summary_widget.dart
            └── double_sell_create_vendor_sheet.dart
```

---

## Phase 11 — Implementation Order

Build in this exact order to avoid forward-reference issues:

| Step | What | Files | Depends on |
|------|------|-------|------------|
| 1 | Models (all 16) | `data/models/*.dart` | Nothing |
| 2 | Price calculator | `data/helpers/price_calculator.dart` | Nothing |
| 3 | API service + .g.dart | `data/remote/*` | Step 1 |
| 4 | Repository | `data/repo/*` | Steps 1 + 3 |
| 5 | DI registration | `core/di/dependency_injection.dart` | Steps 3 + 4 |
| 6 | Cubit states (6 freezed) | `presentation/cubit/*_state.dart` + `.freezed.dart` | Nothing |
| 7 | Cubits (6) | `presentation/cubit/*_cubit.dart` | Steps 4 + 6 |
| 8 | Shimmer widget | `ui/widgets/double_sell_shimmer.dart` | Nothing |
| 9 | Client section widgets | `ui/widgets/double_sell_client_section.dart`, `_create_client_sheet.dart` | Step 7 |
| 10 | Worker selector widget | `ui/widgets/double_sell_worker_selector.dart` | Step 1 |
| 11 | Product card widget | `ui/widgets/double_sell_product_card.dart` | Step 1 |
| 12 | Inside tab widget | `ui/widgets/double_sell_inside_tab.dart` | Steps 2, 7, 11 |
| 13 | Create vendor sheet | `ui/widgets/double_sell_create_vendor_sheet.dart` | Step 7 |
| 14 | Box tab widget | `ui/widgets/double_sell_box_tab.dart` | Steps 1, 2, 7, 13 |
| 15 | Outside tab widget | `ui/widgets/double_sell_outside_tab.dart` | Steps 1, 2, 7, 13 |
| 16 | Item tabs container | `ui/widgets/double_sell_item_tabs.dart` | Steps 12, 14, 15 |
| 17 | Cart widgets | `ui/widgets/double_sell_cart_widget.dart`, `_cart_item_card.dart` | Step 1 |
| 18 | Buy section widget | `ui/widgets/double_sell_buy_section.dart` | Steps 1, 2 |
| 19 | Payment section widget | `ui/widgets/double_sell_payment_section.dart` | Step 1 |
| 20 | Summary widget | `ui/widgets/double_sell_summary_widget.dart` | Step 2 |
| 21 | Bloc builder orchestrator | `ui/widgets/double_sell_bloc_builder.dart` | Steps 7, 8, 9–20 |
| 22 | Main screen | `ui/gold_double_sell_screen.dart` | Step 21 |
| 23 | Route + drawer wiring | `routes.dart`, `app_router.dart`, `main_layout_screen.dart` | Step 22 |

---

## Phase 12 — Validation Rules (Pre-submit Checklist)

Enforce in `_DoubleSellFormView` before calling `submitCubit.submitSell()`:

1. `client_id` is set (client was searched or created)
2. `worker_id` is set
3. At least one sell item exists (inside OR box OR outside)
4. Every inside item: `id` set, `profit` set, `price > 0`
5. Every box item: `carat_id`, `kind_id`, `box_id`, `vendor_id` set, `grams > 0`, `loss >= 0`, `mc >= 0`, `gram_price > 0`, `price > 0`
6. Every outside item: `carat_id`, `kind_id`, `vendor_id` set, `grams > 0`, `mc >= 0`, `gram_price > 0`, `price > 0`
7. Every buy item: `carat_id`, `box_id` set, `grams > 0`, `loss >= 0`, `gram_price > 0`, `buy_price > 0`
8. If buy items exist → `deduction_accounts` is non-empty
9. `all_accounts` is non-empty
10. If any inside product has `is_mc_d == 1` → `usdRate > 0`
11. `total > 0`

---

## Phase 13 — Error Handling Strategy

| Scenario | Where handled | UX |
|----------|---------------|-----|
| Pre-load fails | `DoubleSellPreloadCubit` error state | Error view with retry button |
| Client not found (404) | `ClientSearchCubit.notFound` state | Show "Not found" + offer "Create Client" button |
| Duplicate phone on create (422) | `ClientSearchCubit.error` | Show error message from `errors.client_phone` |
| Product not found (404) | `ProductLookupCubit.notFound` state | "Product not found" — clear input |
| Product already sold (422) | `ProductLookupCubit.alreadySold` state | "هذا المنتج تم بيعه مسبقاً" — clear input |
| Daily ledger not open (422) | `DoubleSellSubmitCubit.error` | Show Arabic error: "لم يتم فتح اليومية لهذا اليوم" |
| No products in cart (422) | Client-side validation blocks submit | "أضف منتج واحد على الأقل" |
| Buy items but no deduction accounts (422) | Client-side validation blocks submit | "أضف حساب خصم للشراء" |
| `is_mc_d == 1` but no USD rate | Client-side validation blocks submit | "سعر الدولار غير متاح" |
| Server error (500) | `DoubleSellSubmitCubit.error` | Show error, full rollback on server — let worker retry |
| Vendor not in list | "Create Vendor" bottom sheet | Uses `CreateVendorCubit` |

---

## Phase 14 — UI/UX Design Notes

### Color palette (reuse existing `AppColors`)
- Primary actions: `AppColors.primaryColor` / `AppColors.darkBrown`
- Sell items: `AppColors.goldColor` accent
- Buy items: `Color(0xFF4CAF50)` green accent (trade-in receives value)
- Error states: `AppColors.errorColor`
- Success: `AppColors.successColor`

### Layout principles
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
- `RefreshIndicator` not needed here (form screen, not list)

### Tab design for sell items
- Use `TabBar` + `TabBarView` with 3 tabs: Inside / Box / Outside
- Match the orders screen tab styling: `AppColors.primaryColor` indicator, `AppColors.textGreyColor` unselected

---

## Phase 15 — Key Architecture Decisions

1. **One repo, one API service** — all 15 endpoints live in one service since they're all part of the same feature flow
2. **6 cubits** — split by responsibility to avoid a mega-cubit. The form's local state (cart items, selected worker, tax, notes) lives in `StatefulWidget` state, not in cubits
3. **Preload cubit** fetches all 8 endpoints in parallel — the screen won't render until all succeed
4. **Lazy kinds loading** — `GoldKindsCubit` is called on carat selection, not pre-loaded
5. **Price calculator is pure Dart** — no cubit, no Flutter dependency, just static methods called directly in widget `setState`
6. **Reuse home models** — `UsdRateModel` and `GoldRatesModel`/`CaratModel` are imported from the home feature, not duplicated
7. **Request payload uses `Map<String, dynamic>`** for product arrays — simpler than creating 4 separate typed classes for each product type's payload

---

## Summary

**Total new files: ~50** (16 models, 2 API service files, 1 repo, 12 cubit files (6 states + 6 cubits) + 6 freezed files, 1 screen, 15 widgets, 1 price calculator)

**Files to update: 4** (dependency_injection.dart, routes.dart, app_router.dart, main_layout_screen.dart)

**Endpoints: 15** (8 pre-load, 2 lazy-load, 2 client, 1 vendor, 1 product, 1 submit)

**Cubits: 6** (preload, client search, product lookup, gold kinds, submit, create vendor)
