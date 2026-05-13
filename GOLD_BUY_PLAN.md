# Gold Buy Feature — Implementation Plan

> **Pattern source:** `gold_double_sell` feature (same clean architecture, same cubits/freezed/retrofit conventions)
> **Drawer index:** `case 5` in `main_layout_screen.dart` (currently a placeholder)
> **Accent color:** `AppColors.goldColor` (same as gold sell)

---

## Phase 1 — Data Layer: Models

All files go in `lib/features/gold_buy/data/models/`.

### 1.1 — Reusable models (import from `gold_double_sell`)

These models already exist and are **shared** — import them, do NOT duplicate:

| Model | Path | Used for |
|---|---|---|
| `GoldCaratModel` | `gold_double_sell/data/models/gold_carat_model.dart` | Carat dropdown + gram_price auto-fill |
| `GoldBoxModel` | `gold_double_sell/data/models/gold_box_model.dart` | Box dropdown |
| `GoldVendorModel` | `gold_double_sell/data/models/gold_vendor_model.dart` | Vendor dropdown |
| `ShopWorkerModel` | `gold_double_sell/data/models/shop_worker_model.dart` | Worker dropdown |
| `PaymentAccountModel` | `gold_double_sell/data/models/payment_account_model.dart` | Account picker |
| `AccountCurrencyModel` | `gold_double_sell/data/models/account_currency_model.dart` | Currency rate fetch |
| `ClientModel` | `gold_double_sell/data/models/client_model.dart` | Client search result |
| `CreateClientRequestModel` | `gold_double_sell/data/models/create_client_request_model.dart` | Create new client |
| `GoldBuyHistoryModel` | `gold_double_sell/data/models/gold_buy_history_model.dart` | Buy history (already exists but needs extension — see 1.4) |
| `GoldBuyItemHistoryModel` | `gold_double_sell/data/models/gold_buy_item_history_model.dart` | Buy item history |

### 1.2 — `gold_buy_preload_data.dart` (NEW)

Plain Dart class holding all 5 parallel-loaded data sets:

```dart
class GoldBuyPreloadData {
  final List<GoldCaratModel> carats;     // GET /worker/gold/rates → carats[]
  final List<GoldBoxModel> boxes;        // GET /worker/gold/boxes
  final List<GoldVendorModel> vendors;   // GET /worker/gold/vendors
  final List<ShopWorkerModel> workers;   // GET /worker/gold/workers
  final List<PaymentAccountModel> accounts; // GET /worker/accounts
}
```

### 1.3 — `gold_buy_request_model.dart` (NEW)

Submit payload model:

```dart
class GoldBuyRequestModel {
  final int workerId;
  final double total;
  final String? notes;
  final int? clientId;      // either client OR vendor
  final int? vendorId;
  final int? sellId;        // optional link to prior gold sell
  final List<Map<String, dynamic>> allAccounts;  // [{account_id, cash, currency_price}]
  final List<Map<String, dynamic>> products;     // [{carat_id, box_id, grams, loss, gram_price, buy_price}]

  Map<String, dynamic> toJson() => { ... };
}
```

### 1.4 — `gold_buy_full_history_model.dart` (NEW — extends existing)

The existing `GoldBuyHistoryModel` only has `id`, `total`, `items`. The API response for `GET /worker/gold/buys` returns much more. Create a **full** history model:

```dart
class GoldBuyFullHistoryModel {
  final int id;
  final double total;
  final String? notes;
  final int? sellId;
  final bool isChanged;
  final String createdAt;
  final HistoryBuyClientRef? client;   // nullable (vendor buys have no client)
  final HistoryBuyWorkerRef worker;
  final HistoryBuyVendorRef? vendor;   // nullable (client buys have no vendor)
  final List<GoldBuyItemHistoryModel> items;
}
```

### 1.5 — `buy_history_refs.dart` (NEW)

Lightweight ref objects for nested JSON (same pattern as `sell_history_refs.dart`):

```dart
class HistoryBuyClientRef {
  final int id;
  final String name;
  final String phone;
}

class HistoryBuyWorkerRef {
  final int id;
  final String name;
}

class HistoryBuyVendorRef {
  final int id;
  final String name;
}
```

### 1.6 — `gold_buy_response_model.dart` (NEW)

Submit success response:

```dart
class GoldBuyResponseModel {
  final String status;  // "success"
}
```

### 1.7 — `create_carat_request_model.dart` (NEW)

For creating a carat on-the-fly:

```dart
class CreateCaratRequestModel {
  final String carat;    // e.g. "22"
  final double fixed;    // 0–1 purity ratio
  final double price;    // price per gram

  Map<String, dynamic> toJson() => { ... };
}
```

### 1.8 — `sell_find_model.dart` (NEW)

Response from `GET /worker/gold/buy/sell/find/{id}`:

```dart
class SellFindModel {
  final int id;
  final String sellDate;
  final double total;
  final double totalGrams;
}
```

### 1.9 — `client_sells_model.dart` (NEW)

Response from `GET /worker/gold/buy/sell/client/{term}`:

```dart
class ClientSellsModel {
  final int id;
  final String name;
  final String phone;
  final List<SellFindModel> goldSells;
}
```

**Total new model files: 8** (+ their manual `.g.dart` where needed)
**Reused from gold_double_sell: 10 models**

---

## Phase 2 — Data Layer: API Service + Repo

### 2.1 — `gold_buy_api_service.dart` + `.g.dart`

Path: `lib/features/gold_buy/data/remote/`

Retrofit abstract class with all endpoints:

```dart
@RestApi(baseUrl: baseUrl)
abstract class GoldBuyApiService {
  // ── Preload (5 endpoints, same as gold_double_sell) ──
  static const String goldRatesApi       = 'worker/gold/rates';
  static const String boxesApi           = 'worker/gold/boxes';
  static const String vendorsApi         = 'worker/gold/vendors';
  static const String workersApi         = 'worker/gold/workers';
  static const String accountsApi        = 'worker/accounts';

  // ── Dynamic lookups ──
  static const String accountCurrencyApi = 'worker/accounts/{id}/currency';
  static const String searchClientApi    = 'worker/clients/search/{term}';
  static const String createClientApi    = 'worker/clients/add';

  // ── Gold Buy specific ──
  static const String sellFindApi        = 'worker/gold/buy/sell/find/{id}';
  static const String sellClientApi      = 'worker/gold/buy/sell/client/{term}';
  static const String createCaratApi     = 'worker/gold/buy/carat/add';
  static const String storeBuyApi        = 'worker/gold/buys/store';
  static const String buyHistoryApi      = 'worker/gold/buys';

  factory GoldBuyApiService(Dio dio, {String baseUrl}) = _GoldBuyApiService;

  // ── Preload methods ──
  @GET(goldRatesApi)
  Future<Map<String, dynamic>> getGoldRates();
  // NOTE: returns { "carats": [...] } — parse carats array in repo

  @GET(boxesApi)
  Future<List<GoldBoxModel>> getBoxes();

  @GET(vendorsApi)
  Future<List<GoldVendorModel>> getVendors();

  @GET(workersApi)
  Future<List<ShopWorkerModel>> getWorkers();

  @GET(accountsApi)
  Future<List<PaymentAccountModel>> getAccounts();

  // ── Dynamic lookups ──
  @GET(accountCurrencyApi)
  Future<AccountCurrencyModel> getAccountCurrency(@Path('id') int accountId);

  @GET(searchClientApi)
  Future<ClientModel> searchClient(@Path('term') String term);

  @POST(createClientApi)
  Future<ClientModel> createClient(@Body() CreateClientRequestModel request);

  // ── Gold Buy specific ──
  @GET(sellFindApi)
  Future<Map<String, dynamic>> findSellById(@Path('id') int id);

  @GET(sellClientApi)
  Future<Map<String, dynamic>> findSellsByClient(@Path('term') String term);

  @POST(createCaratApi)
  Future<Map<String, dynamic>> createCarat(@Body() CreateCaratRequestModel request);

  @POST(storeBuyApi)
  Future<Map<String, dynamic>> submitGoldBuy(@Body() GoldBuyRequestModel request);

  @GET(buyHistoryApi)
  Future<Map<String, dynamic>> getBuyHistory();
}
```

**Note on return types:** Endpoints returning nested JSON (`Map<String, dynamic>`) are parsed in the repo layer — same pattern as `fetchSellHistory()` in `GoldDoubleSellRepo`.

### 2.2 — `gold_buy_repo.dart`

Path: `lib/features/gold_buy/data/repo/`

Methods (all return `ApiResult<T>`):

```
fetchPreloadData()         → ApiResult<GoldBuyPreloadData>
fetchAccountCurrency(id)   → ApiResult<AccountCurrencyModel>
searchClient(term)         → ApiResult<ClientModel>
createClient(request)      → ApiResult<ClientModel>
findSellById(id)           → ApiResult<SellFindModel>
findSellsByClient(term)    → ApiResult<ClientSellsModel>
createCarat(request)       → ApiResult<GoldCaratModel>
submitGoldBuy(request)     → ApiResult<GoldBuyResponseModel>
fetchBuyHistory()          → ApiResult<List<GoldBuyFullHistoryModel>>
```

`fetchPreloadData()` fires all 5 API calls in parallel (same pattern as `GoldDoubleSellRepo.fetchPreloadData()`), parses the carats from the `getGoldRates()` response's `"carats"` key.

---

## Phase 3 — DI Registration

In `lib/core/di/dependency_injection.dart`, add:

```dart
import '.../gold_buy/data/remote/gold_buy_api_service.dart';
import '.../gold_buy/data/repo/gold_buy_repo.dart';

// Inside setupGetIt():
getIt.registerLazySingleton<GoldBuyApiService>(() => GoldBuyApiService(dio));
getIt.registerLazySingleton<GoldBuyRepo>(() => GoldBuyRepo(getIt()));
```

---

## Phase 4 — Presentation Layer: Cubits + States

All files in `lib/features/gold_buy/presentation/cubit/`.

### 4.1 — `gold_buy_preload_cubit.dart` + `_state.dart` + `.freezed.dart`

Loads all dropdown data on screen init.

**State:** `initial | loading | success(GoldBuyPreloadData) | error(List<String>)`

**Pattern:** Exact copy of `DoubleSellPreloadCubit` but with `GoldBuyRepo` + `GoldBuyPreloadData`.

### 4.2 — `gold_buy_submit_cubit.dart` + `_state.dart` + `.freezed.dart`

Submits the buy order.

**State:** `initial | loading | success(GoldBuyResponseModel) | error(List<String>)`

**Pattern:** Exact copy of `DoubleSellSubmitCubit`.

### 4.3 — `gold_buy_client_search_cubit.dart` + `_state.dart` + `.freezed.dart`

Searches/creates clients (same logic as existing `ClientSearchCubit`).

**State:** `initial | loading | found(ClientModel) | notFound | created(ClientModel) | error(List<String>)`

**Pattern:** Exact copy of `ClientSearchCubit` but with `GoldBuyRepo`.

### 4.4 — `gold_buy_sell_link_cubit.dart` + `_state.dart` + `.freezed.dart`

Handles finding a prior gold sell to link (by order ID or by client phone/email).

**State:** `initial | loading | foundSingle(SellFindModel) | foundClientSells(ClientSellsModel) | notFound | error(List<String>)`

**Methods:**
- `findByOrderId(int id)` → calls `repo.findSellById(id)`
- `findByClient(String term)` → calls `repo.findSellsByClient(term)`
- `clearLink()` → emits initial

### 4.5 — `gold_buy_create_carat_cubit.dart` + `_state.dart` + `.freezed.dart`

Creates a new carat on-the-fly.

**State:** `initial | loading | success(GoldCaratModel) | error(List<String>)`

### 4.6 — `gold_buy_history_cubit.dart` + `_state.dart` + `.freezed.dart`

Fetches buy history list.

**State:** `initial | loading | success(List<GoldBuyFullHistoryModel>) | error(String)`

**Pattern:** Same as `GoldSellHistoryCubit`.

### State naming convention

Use **public** names for non-initial variants (matching existing working pattern from `gold_kinds_state.dart`):

```dart
const factory SomeState.initial() = _Initial;   // private (only initial)
const factory SomeState.loading() = Loading;     // PUBLIC
const factory SomeState.success(data) = Success; // PUBLIC
const factory SomeState.error(...) = Error;      // PUBLIC
```

**Total: 6 cubits × 3 files each = 18 files**

---

## Phase 5 — Presentation Layer: Gold Buy Form Screen

Path: `lib/features/gold_buy/presentation/ui/`

### 5.1 — `gold_buy_screen.dart` (Main buy form)

The primary screen where the worker fills out a gold buy transaction.

**Structure:** `Scaffold` → `Column` → `_HeaderCard` + `Expanded(SingleChildScrollView)` containing:

1. **`GoldBuyBlocBuilder`** wrapping the form — handles preload states (shimmer/error/success)
2. Inside the success state, the form sections in order:

```
┌─ _HeaderCard (back arrow + "Gold Buy" title) ────────────────┐
│                                                                │
├─ Worker Selector dropdown ─────────────────────────────────────┤
│                                                                │
├─ Source Selector (Client / Vendor toggle) ─────────────────────┤
│  Tab A: Client search + create                                 │
│  Tab B: Vendor dropdown                                        │
│                                                                │
├─ Sell Link section (only if client selected) ──────────────────┤
│  Search by order ID or client phone → select a prior sell      │
│                                                                │
├─ Products section ─────────────────────────────────────────────┤
│  "Add Product" button → bottom sheet:                          │
│    Carat dropdown + Box dropdown                               │
│    Grams + Loss fields                                         │
│    Gram Price (auto: carat.price − 50, editable)               │
│    Buy Price (read-only: (grams−loss) × gram_price)            │
│  Product cards list with delete                                │
│  "Create Carat" link → bottom sheet for new carat              │
│                                                                │
├─ Payment section ──────────────────────────────────────────────┤
│  Add Account → pick account, fetch currency rate, enter cash   │
│  List of payment entries with remove                           │
│                                                                │
├─ Notes text field ─────────────────────────────────────────────┤
│                                                                │
├─ Order Summary widget ─────────────────────────────────────────┤
│  Total buy price | Total paid | Difference                     │
│                                                                │
├─ Submit button ────────────────────────────────────────────────┤
└────────────────────────────────────────────────────────────────┘
```

**`_HeaderCard`:** Same pattern as `gold_sell_history_screen.dart`'s header — menu/back icon + title. The `onMenuTap` parameter is null when pushed from history (shows back arrow).

**`initState`:** Calls `context.read<GoldBuyPreloadCubit>().fetchPreloadData()`.

**Submit flow:**
1. Run client-side validation (see spec §12)
2. Build `GoldBuyRequestModel` from form state
3. Call `context.read<GoldBuySubmitCubit>().submitGoldBuy(request)`
4. `BlocListener` on submit cubit → show success dialog or error snackbar
5. On success → `Navigator.pop(context)` (returns to history, which auto-refreshes)

### 5.2 — Widget files in `ui/widgets/`

| Widget file | Responsibility |
|---|---|
| `gold_buy_bloc_builder.dart` | BlocBuilder on preload cubit → shimmer / error / success form |
| `gold_buy_worker_selector.dart` | Worker dropdown (reuse pattern from `double_sell_worker_selector.dart`) |
| `gold_buy_source_section.dart` | Client/Vendor toggle with two tabs |
| `gold_buy_client_tab.dart` | Client search field + BlocBuilder on client search cubit + create client bottom sheet |
| `gold_buy_vendor_tab.dart` | Simple vendor dropdown from preload data |
| `gold_buy_sell_link_section.dart` | Search sell by ID or client phone + BlocBuilder on sell link cubit |
| `gold_buy_product_section.dart` | Product list + "Add Product" button + "Create Carat" link |
| `gold_buy_product_form_sheet.dart` | Bottom sheet for adding a product (carat, box, grams, loss, gram_price, buy_price) |
| `gold_buy_product_card.dart` | Single product card in the cart (display + delete) |
| `gold_buy_create_carat_sheet.dart` | Bottom sheet for creating a new carat on-the-fly |
| `gold_buy_payment_section.dart` | Payment accounts section (add account, cash input, currency display) |
| `gold_buy_summary_widget.dart` | Live totals: total buy price, total paid, difference |
| `gold_buy_create_client_sheet.dart` | Bottom sheet for creating a new client (name, phone, email, gender) |

---

## Phase 6 — Presentation Layer: Gold Buy History Screen

Same structure as the existing `GoldSellHistoryScreen`.

### 6.1 — `gold_buy_history_screen.dart`

**`_HeaderCard`:** Menu/back + history icon (gold) + "Gold Buy History" title + "Add New" button.

**`_openNewOrder()`:** Pushes `GoldBuyScreen` wrapped in `MultiBlocProvider` with all 6 cubits:
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => GoldBuyPreloadCubit(getIt())),
    BlocProvider(create: (_) => GoldBuyClientSearchCubit(getIt())),
    BlocProvider(create: (_) => GoldBuySellLinkCubit(getIt())),
    BlocProvider(create: (_) => GoldBuyCreateCaratCubit(getIt())),
    BlocProvider(create: (_) => GoldBuySubmitCubit(getIt())),
  ],
  child: const GoldBuyScreen(),
)
```

Then `.then((_) => refresh history)`.

### 6.2 — History widgets in `ui/widgets/`

| Widget file | Responsibility |
|---|---|
| `gold_buy_history_bloc_builder.dart` | BlocBuilder on history cubit → shimmer / empty+addNew / list / error+retry |
| `gold_buy_history_card.dart` | Single buy record card showing: client/vendor name, date, total, item count, sell_id badge |
| `gold_buy_history_shimmer.dart` | Shimmer loading skeleton |

---

## Phase 7 — Wire into Main Layout

### 7.1 — Update `main_layout_screen.dart`

Replace the `case 5` placeholder:

```dart
// Add imports:
import '.../gold_buy/presentation/cubit/gold_buy_history_cubit.dart';
import '.../gold_buy/presentation/ui/gold_buy_history_screen.dart';

// Replace case 5:
case 5:
  return BlocProvider(
    create: (_) => GoldBuyHistoryCubit(getIt()),
    child: GoldBuyHistoryScreen(onMenuTap: openDrawer),
  );
```

---

## Phase 8 — Manual Freezed + Retrofit Generated Files

Since the project does NOT use `build_runner`, all `.freezed.dart` and `.g.dart` files must be **hand-written**.

### Freezed files to create (6 state files × 1 each = 6):
- `gold_buy_preload_state.freezed.dart`
- `gold_buy_submit_state.freezed.dart`
- `gold_buy_client_search_state.freezed.dart`
- `gold_buy_sell_link_state.freezed.dart`
- `gold_buy_create_carat_state.freezed.dart`
- `gold_buy_history_state.freezed.dart`

**Pattern:** Copy from `gold_kinds_state.freezed.dart` and adapt class names + data types. Use `const` constructors for all impl classes (critical — missing `const` on `_Success` caused errors in the sell features).

### Retrofit generated file:
- `gold_buy_api_service.g.dart`

**Pattern:** Copy from `gold_double_sell_api_service.g.dart` and adapt method names, return types, and endpoint paths.

---

## Implementation Order (Recommended)

| Step | What | Files |
|---|---|---|
| **1** | Models (new ones only) | 8 model files |
| **2** | API Service + `.g.dart` | 2 files |
| **3** | Repository | 1 file |
| **4** | DI registration | Edit 1 file |
| **5** | History cubit + state + freezed | 3 files |
| **6** | History screen + widgets | 4 files (screen + bloc_builder + card + shimmer) |
| **7** | Wire history into main_layout | Edit 1 file |
| **8** | **TEST** — History loads from API, "Add New" opens placeholder | — |
| **9** | Remaining 5 cubits + states + freezed | 15 files |
| **10** | Buy form screen + all 13 widgets | 14 files |
| **11** | **TEST** — Full buy flow end-to-end | — |
| **12** | Error sweep — verify all imports, const constructors, state naming | — |

---

## File Tree (Final)

```
lib/features/gold_buy/
├── data/
│   ├── models/
│   │   ├── gold_buy_preload_data.dart
│   │   ├── gold_buy_request_model.dart
│   │   ├── gold_buy_response_model.dart
│   │   ├── gold_buy_full_history_model.dart
│   │   ├── buy_history_refs.dart
│   │   ├── create_carat_request_model.dart
│   │   ├── sell_find_model.dart
│   │   └── client_sells_model.dart
│   ├── remote/
│   │   ├── gold_buy_api_service.dart
│   │   └── gold_buy_api_service.g.dart
│   └── repo/
│       └── gold_buy_repo.dart
└── presentation/
    ├── cubit/
    │   ├── gold_buy_preload_cubit.dart
    │   ├── gold_buy_preload_state.dart
    │   ├── gold_buy_preload_state.freezed.dart
    │   ├── gold_buy_submit_cubit.dart
    │   ├── gold_buy_submit_state.dart
    │   ├── gold_buy_submit_state.freezed.dart
    │   ├── gold_buy_client_search_cubit.dart
    │   ├── gold_buy_client_search_state.dart
    │   ├── gold_buy_client_search_state.freezed.dart
    │   ├── gold_buy_sell_link_cubit.dart
    │   ├── gold_buy_sell_link_state.dart
    │   ├── gold_buy_sell_link_state.freezed.dart
    │   ├── gold_buy_create_carat_cubit.dart
    │   ├── gold_buy_create_carat_state.dart
    │   ├── gold_buy_create_carat_state.freezed.dart
    │   ├── gold_buy_history_cubit.dart
    │   ├── gold_buy_history_state.dart
    │   └── gold_buy_history_state.freezed.dart
    └── ui/
        ├── gold_buy_screen.dart
        ├── gold_buy_history_screen.dart
        └── widgets/
            ├── gold_buy_bloc_builder.dart
            ├── gold_buy_worker_selector.dart
            ├── gold_buy_source_section.dart
            ├── gold_buy_client_tab.dart
            ├── gold_buy_vendor_tab.dart
            ├── gold_buy_sell_link_section.dart
            ├── gold_buy_product_section.dart
            ├── gold_buy_product_form_sheet.dart
            ├── gold_buy_product_card.dart
            ├── gold_buy_create_carat_sheet.dart
            ├── gold_buy_payment_section.dart
            ├── gold_buy_summary_widget.dart
            ├── gold_buy_create_client_sheet.dart
            ├── gold_buy_history_bloc_builder.dart
            ├── gold_buy_history_card.dart
            └── gold_buy_history_shimmer.dart
```

**Total: ~48 new files** (8 models + 2 remote + 1 repo + 18 cubit/state/freezed + 2 screens + 16 widgets + 1 DI edit)

---

## Key Formulas (Quick Reference)

```
gram_price_default = carat.price − 50
net_grams          = grams − loss
buy_price          = net_grams × gram_price
total_buy_price    = Σ product.buy_price
egp_per_account    = cash × currency_price
total_paid         = Σ egp_per_account
difference         = total_buy_price − total_paid
```

---

## Critical Gotchas (Learned from Gold Sell Implementation)

1. **Always import `api_result.dart`** in every cubit that uses `result.when()` — it's an extension method
2. **Use `const` constructors** in all freezed impl classes (especially `_Success` with List fields)
3. **Use public names** for non-initial state variants (`Loading`, `Success`, `Error`) — not `_Loading`, `_Success`, `_Error`
4. **`GET /worker/gold/rates`** returns `{ "carats": [...] }` not a plain array — parse in repo
5. **`GET /worker/gold/buys`** returns `{ "status": "success", "buys": [...] }` — parse `buys` key in repo
6. **Currency rate** is fetched when account is added (not at submit time) and stored with the account entry
7. **Client/Vendor mutual exclusion** — selecting one clears the other; `sell_id` is only valid with a client
8. **`sell_id` can be null** — it's optional even for client buys
