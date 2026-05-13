# Diamond & Stone Unified Sell — Implementation Plan

> **Feature folder:** `lib/features/diamond_sell/`
> **Accent color:** `const Color(0xFF64B5F6)` (diamond blue)
> **Cubits:** 4 (no kinds cubit, no vendor cubit)
> **UI pattern:** Matches gold/silver double sell — same architecture, same widget style

---

## 1. Architecture Overview

```
lib/features/diamond_sell/
├── data/
│   ├── models/
│   │   ├── diamond_product_model.dart           + .g.dart
│   │   ├── stone_product_model.dart             + .g.dart
│   │   ├── diamond_sell_preload_data.dart
│   │   ├── diamond_sell_request_model.dart
│   │   └── diamond_sell_result_model.dart
│   ├── remote/
│   │   ├── diamond_sell_api_service.dart         (Retrofit)
│   │   └── diamond_sell_api_service.g.dart       (manual)
│   └── repo/
│       └── diamond_sell_repo.dart
├── presentation/
│   ├── cubit/
│   │   ├── diamond_sell_preload_cubit.dart
│   │   ├── diamond_sell_preload_state.dart       + .freezed.dart
│   │   ├── diamond_client_search_cubit.dart
│   │   ├── diamond_client_search_state.dart      + .freezed.dart
│   │   ├── diamond_product_lookup_cubit.dart
│   │   ├── diamond_product_lookup_state.dart     + .freezed.dart
│   │   ├── diamond_sell_submit_cubit.dart
│   │   └── diamond_sell_submit_state.dart        + .freezed.dart
│   └── ui/
│       ├── diamond_sell_screen.dart
│       └── widgets/
│           ├── diamond_sell_bloc_builder.dart
│           ├── diamond_sell_shimmer.dart
│           ├── diamond_sell_client_section.dart
│           ├── diamond_sell_product_scanner.dart
│           ├── diamond_sell_product_card.dart
│           └── diamond_sell_summary_widget.dart
```

**Total new files: ~32** (models, .g.dart, cubits, states, .freezed.dart, widgets, screen)

---

## 2. Key Differences from Gold / Silver

| Aspect | Gold | Silver | Diamond |
|--------|------|--------|---------|
| Preload data | 8 parallel calls (carats, currencies, usd, rates, workers, boxes, vendors, accounts) | 4 calls (rates, workers, boxes, vendors, accounts) | **2 calls** (usd rate + accounts) |
| Product types | Single (gold product) | Single (silver product) | **Two** (diamond + stone) in one cart |
| Tabs | Inside / Box / Outside | Inside / Box / Outside | **None** — scan by ID + type toggle |
| USD conversion | Yes (`isMcDollar`, `usdRate`) | No | **Yes** — all prices stored USD, submit EGP |
| Product lookup | `GET worker/gold/product/{id}` | `GET worker/silvers/product/{id}` | `GET worker/unified/product/{type}/{id}` — type = `diamond` or `stone` |
| Submit endpoint | `POST worker/golds/sells/double/store` | `POST worker/silvers/sells/double/store` | `POST worker/unified/sells/store` |
| Request shape | `insideProducts`, `outsideProducts`, `boxProducts`, `buyGoldProducts` arrays | `buySilverProducts` | Single `products[]` array with `type` field per item |
| Price field in request | Computed per tab type | Computed per tab type | Diamond: `product_price`, Stone: `price` — **CRITICAL: not interchangeable** |
| Response | `sellId`, `buyId`, `total` | `status`, `message` | `unified_id`, `diamond_sell_id`, `stone_sell_id`, `grand_total` |
| Worker selector | Yes (picked from worker list) | Yes | **No** — `worker_id` from stored auth |
| Vendor creation | Yes | Yes | **No** |
| Buy section | Yes (buy gold back) | Yes (buy silver back) | **No** |
| Tax field | Yes | Yes | **No** |
| Kinds / Carats | Yes (lazy-loaded per carat) | Yes (preloaded) | **No** — not applicable |
| Product images | No (media ignored in gold) | No | **Yes** — show `media[].original_url` in product card |
| Notes field | Yes | Yes | **Yes** (optional) |
| Cubits count | 6 | 5 | **4** |

---

## 3. Reused Gold Widgets (import directly, NO diamond copies)

These widgets from `gold_double_sell` are generic enough to reuse as-is:

| Widget | Import from | Used for |
|--------|-------------|----------|
| `DoubleSellCreateClientSheet` | `gold_double_sell/presentation/ui/widgets/double_sell_create_client_sheet.dart` | Bottom sheet to create a new client |
| `DoubleSellPaymentSection` | `gold_double_sell/presentation/ui/widgets/double_sell_payment_section.dart` | Payment accounts entry UI |
| `DoubleSellPaymentEntry` | Same file as above | Payment data model for request building |
| `DoubleSellCartWidget` | `gold_double_sell/presentation/ui/widgets/double_sell_cart_widget.dart` | Cart list container with total |
| `DoubleSellCartItemCard` | `gold_double_sell/presentation/ui/widgets/double_sell_cart_item_card.dart` | Individual cart item row |
| `DoubleSellCartItemModel` | Same file as above | Cart item data model (key, type, title, subtitle, grams, price, payload) |

---

## 4. Reused Gold Models (import directly)

| Model | Import from |
|-------|-------------|
| `PaymentAccountModel` | `gold_double_sell/data/models/payment_account_model.dart` |
| `ClientModel` | `gold_double_sell/data/models/client_model.dart` |
| `CreateClientRequestModel` | `gold_double_sell/data/models/create_client_request_model.dart` |
| `AccountCurrencyModel` | `gold_double_sell/data/models/account_currency_model.dart` |
| `UsdRateModel` | `home/data/models/usd_rate_model.dart` |

---

## 5. Data Layer — Models (NEW)

### 5.1 `diamond_product_model.dart`

API response: `GET /api/worker/unified/product/diamond/{id}`

```dart
class DiamondProductModel {
  final int id;
  final int shopId;
  final String name;
  final String type;              // always "diamond"
  final double totalGWeight;      // gold weight in grams (string → double)
  final double totalDWeight;      // diamond weight in carats (string → double)
  final double totalWeight;       // combined weight
  final double goldDollars;       // gold component USD
  final double dollars;           // diamond component USD (string → double)
  final double percentage;        // markup percentage (string → double)
  final double total;             // TOTAL USD PRICE — use for conversion
  final bool isSold;
  final List<String> media;       // extracted original_url strings

  // fromJson with defensive parsing (_parseDoubleOrZero, _parseIntOrZero)
  // same parsing pattern as GoldProductModel
}
```

**Key fields for cart building:**
- `id` → `pro_id`
- `total` → multiply by `usdRate` to get `product_price` (EGP)
- `name` → display name
- `totalWeight` → grams for cart item
- `media.first` → product image URL
- `totalDWeight` → subtitle: "Diamond: 0.25 ct"
- `totalGWeight` → subtitle: "Gold: 1.84 g"

### 5.2 `stone_product_model.dart`

API response: `GET /api/worker/unified/product/stone/{id}`

```dart
class StoneProductModel {
  final int id;
  final int shopId;
  final String name;              // usually the report number
  final String type;              // always "stone"
  final double weight;            // carat weight
  final String reportNumber;      // GIA report number
  final String proportion;
  final String polish;
  final String symmetry;
  final double rap;               // Rapaport list price
  final double discount;          // discount %
  final double dollars;           // USD after discount
  final double price;             // TOTAL USD PRICE — use for conversion
  final bool isSold;
  final List<String> media;       // extracted original_url strings

  // fromJson with defensive parsing
}
```

**Key fields for cart building:**
- `id` → `pro_id`
- `price` → multiply by `usdRate` to get `price` (EGP) — NOTE: same field name in request
- `name` → display name (report number)
- `weight` → carats for subtitle
- `media.first` → product image URL
- `reportNumber` → subtitle: "Report: 5496743922"

### 5.3 `diamond_sell_preload_data.dart`

Much simpler than gold/silver — only 2 items:

```dart
class DiamondSellPreloadData {
  final UsdRateModel usdRate;
  final List<PaymentAccountModel> accounts;

  DiamondSellPreloadData({
    required this.usdRate,
    required this.accounts,
  });
}
```

### 5.4 `diamond_sell_request_model.dart`

```dart
class DiamondSellRequestModel {
  final int clientId;
  final int workerId;
  final double total;           // grand total in EGP
  final String? notes;
  final List<Map<String, dynamic>> products;      // mixed diamond + stone items
  final List<Map<String, dynamic>> allAccounts;

  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'worker_id': workerId,
    'total': total,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'products': products,
    'all_accounts': allAccounts,
  };
}
```

**products[] item shape:**
```dart
// Diamond:
{'type': 'diamond', 'pro_id': id, 'product_price': egpPrice}
// Stone:
{'type': 'stone', 'pro_id': id, 'price': egpPrice}
```

> **CRITICAL:** Diamond uses `product_price`. Stone uses `price`. Wrong field name = server error.

### 5.5 `diamond_sell_result_model.dart`

```dart
class DiamondSellResultModel {
  final String status;
  final String unifiedId;
  final int? diamondSellId;     // null if no diamonds submitted
  final int? stoneSellId;       // null if no stones submitted
  final double grandTotal;

  factory DiamondSellResultModel.fromJson(Map<String, dynamic> json) {
    return DiamondSellResultModel(
      status: json['status']?.toString() ?? '',
      unifiedId: json['unified_id']?.toString() ?? '',
      diamondSellId: json['diamond_sell_id'] != null
          ? _parseInt(json['diamond_sell_id']) : null,
      stoneSellId: json['stone_sell_id'] != null
          ? _parseInt(json['stone_sell_id']) : null,
      grandTotal: _parseDouble(json['grand_total']),
    );
  }
}
```

---

## 6. Data Layer — Remote (API Service)

### 6.1 `diamond_sell_api_service.dart`

```dart
@RestApi(baseUrl: baseUrl)
abstract class DiamondSellApiService {
  // Preload
  static const String usdRateApi = 'worker/gold/usd';
  static const String accountsApi = 'worker/accounts';

  // Client
  static const String searchClientApi = 'worker/clients/search/{term}';
  static const String createClientApi = 'worker/clients/add';

  // Product lookup — returns raw Map because diamond/stone have different shapes
  static const String productLookupApi = 'worker/unified/product/{type}/{id}';

  // Submit
  static const String submitApi = 'worker/unified/sells/store';

  factory DiamondSellApiService(Dio dio, {String baseUrl}) =
      _DiamondSellApiService;

  @GET(usdRateApi)
  Future<UsdRateModel> getUsdRate();

  @GET(accountsApi)
  Future<List<PaymentAccountModel>> getAccounts();

  @GET(searchClientApi)
  Future<ClientModel> searchClient(@Path('term') String term);

  @POST(createClientApi)
  Future<ClientModel> createClient(@Body() CreateClientRequestModel request);

  @GET(productLookupApi)
  Future<Map<String, dynamic>> getProduct(
    @Path('type') String type,
    @Path('id') int id,
  );

  @POST(submitApi)
  Future<DiamondSellResultModel> submitSell(
    @Body() DiamondSellRequestModel request,
  );
}
```

> **Note:** `getProduct` returns raw `Map<String, dynamic>` because diamond and stone responses have completely different JSON structures. The repo parses them into the appropriate model based on `type`.

### 6.2 `diamond_sell_api_service.g.dart` (manual)

Write the manual Retrofit generated file following the exact same pattern as `gold_double_sell_api_service.g.dart`. Key implementation notes:

- `getProduct(type, id)` → `GET` to `worker/unified/product/$type/$id` → return `response.data` as `Map<String, dynamic>` directly
- `submitSell(request)` → `POST` to `worker/unified/sells/store` → parse response with `DiamondSellResultModel.fromJson(response.data)`
- All other methods follow the same pattern as gold's `.g.dart`

---

## 7. Data Layer — Repo

### 7.1 `diamond_sell_repo.dart`

```dart
class DiamondSellRepo {
  final DiamondSellApiService _apiService;

  DiamondSellRepo(this._apiService);

  /// Fetch USD rate + accounts in parallel
  Future<ApiResult<DiamondSellPreloadData>> fetchPreloadData() async {
    try {
      final usdFuture = _apiService.getUsdRate();
      final accountsFuture = _apiService.getAccounts();

      final usd = await usdFuture;
      final accounts = await accountsFuture;

      return ApiResult.success(
        DiamondSellPreloadData(usdRate: usd, accounts: accounts),
      );
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  /// Lookup a diamond or stone by type + id
  /// Returns the raw Map — caller decides how to parse based on type
  Future<ApiResult<Map<String, dynamic>>> fetchProduct(
    String type, int id,
  ) async {
    try {
      final result = await _apiService.getProduct(type, id);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ClientModel>> searchClient(String term) async {
    try {
      final result = await _apiService.searchClient(term);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ClientModel>> createClient(
    CreateClientRequestModel request,
  ) async {
    try {
      final result = await _apiService.createClient(request);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<DiamondSellResultModel>> submitSell(
    DiamondSellRequestModel request,
  ) async {
    try {
      final result = await _apiService.submitSell(request);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
```

---

## 8. Presentation Layer — Cubits (4 total)

### 8.1 `DiamondSellPreloadCubit`

**State:** `initial | loading | success(DiamondSellPreloadData) | error({required List<String> messages})`

```dart
class DiamondSellPreloadCubit extends Cubit<DiamondSellPreloadState> {
  final DiamondSellRepo _repo;
  DiamondSellPreloadCubit(this._repo) : super(const DiamondSellPreloadState.initial());

  Future<void> fetchPreloadData() async {
    emit(const DiamondSellPreloadState.loading());
    final result = await _repo.fetchPreloadData();
    result.when(
      success: (data) => emit(DiamondSellPreloadState.success(data)),
      failure: (failure) => emit(DiamondSellPreloadState.error(
        messages: _extractMessages(failure.errorModel),
      )),
    );
  }
}
```

### 8.2 `DiamondClientSearchCubit`

**State:** `initial | loading | found(ClientModel) | notFound | error({required List<String> messages})`

Identical pattern to `ClientSearchCubit` in gold — same `searchClient(term)` and `createClient(request)` methods. Just uses `DiamondSellRepo` instead of `GoldDoubleSellRepo`.

### 8.3 `DiamondProductLookupCubit`

**State:** `initial | loading | foundDiamond(DiamondProductModel) | foundStone(StoneProductModel) | notFound | alreadySold | invalidType | error({required List<String> messages})`

This is the most different cubit from gold. Key differences:
- Takes **two** parameters: `type` (String) and `id` (int)
- Returns raw `Map` from repo, then parses based on `type`
- Has **two found states** for the two product types
- Detects `is_sold` from raw JSON (not from a model bool)

```dart
class DiamondProductLookupCubit extends Cubit<DiamondProductLookupState> {
  final DiamondSellRepo _repo;
  DiamondProductLookupCubit(this._repo) : super(const DiamondProductLookupState.initial());

  Future<void> lookupProduct(String type, int id) async {
    if (id <= 0) {
      emit(const DiamondProductLookupState.error(messages: ['Please enter a valid ID']));
      return;
    }
    if (type != 'diamond' && type != 'stone') {
      emit(const DiamondProductLookupState.invalidType());
      return;
    }

    emit(const DiamondProductLookupState.loading());

    final response = await _repo.fetchProduct(type, id);
    response.when(
      success: (json) {
        // Check is_sold from raw JSON
        final isSold = (_parseIntOrZero(json['is_sold']) == 1);
        if (isSold) {
          emit(const DiamondProductLookupState.alreadySold());
          return;
        }

        if (type == 'diamond') {
          emit(DiamondProductLookupState.foundDiamond(
            DiamondProductModel.fromJson(json),
          ));
        } else {
          emit(DiamondProductLookupState.foundStone(
            StoneProductModel.fromJson(json),
          ));
        }
      },
      failure: (failure) {
        // same error pattern as gold: check for not found, already sold messages
        if (_isNotFound(failure.errorModel)) {
          emit(const DiamondProductLookupState.notFound());
          return;
        }
        if (_isAlreadySoldMessage(failure.errorModel)) {
          emit(const DiamondProductLookupState.alreadySold());
          return;
        }
        emit(DiamondProductLookupState.error(
          messages: _extractMessages(failure.errorModel),
        ));
      },
    );
  }

  void clearLookup() => emit(const DiamondProductLookupState.initial());
}
```

### 8.4 `DiamondSellSubmitCubit`

**State:** `initial | loading | success(DiamondSellResultModel) | error({required List<String> messages})`

Same pattern as `DoubleSellSubmitCubit`. Calls `_repo.submitSell(request)`.

---

## 9. Presentation Layer — Freezed States

All 4 state files follow the project's 4-state Freezed union pattern. Manual `.freezed.dart` files (no build_runner). Each one uses Diamond-prefixed class names.

### State class naming:

| Cubit | State class | Union variants |
|-------|-------------|----------------|
| `DiamondSellPreloadCubit` | `DiamondSellPreloadState` | `initial`, `loading`, `success(DiamondSellPreloadData data)`, `error({required List<String> messages})` |
| `DiamondClientSearchCubit` | `DiamondClientSearchState` | `initial`, `loading`, `found(ClientModel client)`, `notFound`, `error({required List<String> messages})` |
| `DiamondProductLookupCubit` | `DiamondProductLookupState` | `initial`, `loading`, `foundDiamond(DiamondProductModel product)`, `foundStone(StoneProductModel product)`, `notFound`, `alreadySold`, `invalidType`, `error({required List<String> messages})` |
| `DiamondSellSubmitCubit` | `DiamondSellSubmitState` | `initial`, `loading`, `success(DiamondSellResultModel data)`, `error({required List<String> messages})` |

> **Note:** `DiamondProductLookupState` has **7 variants** (not the standard 4) because it needs separate states for diamond/stone found, plus notFound, alreadySold, and invalidType.

---

## 10. UI Layer — Widgets

### 10.1 `diamond_sell_bloc_builder.dart`

Same pattern as `SilverDoubleSellBlocBuilder`:
- Wraps `BlocBuilder<DiamondSellPreloadCubit, DiamondSellPreloadState>`
- `loading` / `orElse` → `DiamondSellShimmer()`
- `success(data)` → `successBuilder(data)`
- `error(messages)` → `_ErrorView` with retry button

### 10.2 `diamond_sell_shimmer.dart`

Same structure as gold/silver shimmer. Dark-mode colors: `Color(0xFF1A1F2E)` / `Color(0xFF222840)` (blue-tinted dark for diamond theme).

### 10.3 `diamond_sell_client_section.dart`

Near-identical to gold's `DoubleSellClientSection`, using `DiamondClientSearchCubit` / `DiamondClientSearchState`. Same search field, same client card display, same "Create Client" button opening `DoubleSellCreateClientSheet`.

### 10.4 `diamond_sell_product_scanner.dart` ⭐ (NEW WIDGET — no gold equivalent)

This replaces gold's entire tab system (Inside/Box/Outside). It provides:

**UI layout:**
```
┌─────────────────────────────────────────┐
│  Scan Product                           │
│                                         │
│  ┌─────────────┐ ┌─────────────┐       │
│  │  💎 Diamond  │ │  💠 Stone   │       │  ← ToggleButtons or SegmentedButton
│  └─────────────┘ └─────────────┘       │
│                                         │
│  ┌──────────────────────┐ ┌──────┐     │
│  │  Enter product ID    │ │ Scan │     │  ← ID text field + scan button
│  └──────────────────────┘ └──────┘     │
│                                         │
│  (product card appears here on found)   │  ← DiamondSellProductCard
│  ┌──────────────────────────────────┐  │
│  │ [img] Ring  |  506 USD          │  │
│  │       Diamond: 0.25ct           │  │
│  │       Gold: 1.84g               │  │
│  │       EGP: 26,630.78   [+ Add] │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Behavior:**
1. Worker selects type: `diamond` or `stone` (SegmentedButton)
2. Worker enters product ID (TextFormField)
3. Worker taps "Search" → calls `DiamondProductLookupCubit.lookupProduct(type, id)`
4. `BlocListener` on `DiamondProductLookupState`:
   - `foundDiamond(product)` → show `DiamondSellProductCard` with add button
   - `foundStone(product)` → show `DiamondSellProductCard` with add button
   - `notFound` → snackbar "Product not found"
   - `alreadySold` → snackbar "Product already sold"
   - `invalidType` → snackbar "Select diamond or stone"
   - `error` → snackbar with messages
5. Worker taps "Add to Cart" → callback to screen to add `DoubleSellCartItemModel`

### 10.5 `diamond_sell_product_card.dart` ⭐ (NEW WIDGET — shows product image)

Unlike gold's `DoubleSellProductCard` (which ignores images), this card displays the product thumbnail from `media[]` and shows type-specific details.

**For diamond:**
```
┌──────────────────────────────────────┐
│ [product image]  Ring                │
│  68×68           Type: Diamond       │
│                  Diamond: 0.25 ct    │
│                  Gold: 1.84 g        │
│                  USD: $506.00        │
│                  EGP: 26,630.78      │
│                              [+ Add] │
└──────────────────────────────────────┘
```

**For stone:**
```
┌──────────────────────────────────────┐
│ [product image]  5496743922          │
│  68×68           Type: Stone         │
│                  Weight: 0.31 ct     │
│                  Report: 5496743922  │
│                  USD: $425.00        │
│                  EGP: 22,367.75      │
│                              [+ Add] │
└──────────────────────────────────────┘
```

Uses `Image.network` with error fallback placeholder, same as gold's product card pattern. Uses diamond accent color `Color(0xFF64B5F6)` for the border/highlights.

### 10.6 `diamond_sell_summary_widget.dart`

**Simpler than gold** — no buy total, no net, no tax field:

```
┌──────────────────────────────────┐
│  Summary                         │
│                                  │
│  Diamonds total      26,630.78   │
│  Stones total        22,367.75   │
│  ──────────────────────────────  │
│  Grand Total         48,998.53   │
│                                  │
│  ┌──────────────────────────┐   │
│  │  Notes (optional)        │   │
│  └──────────────────────────┘   │
└──────────────────────────────────┘
```

Shows diamond count, stone count, per-type totals, and the grand total. Includes an optional notes `TextFormField`.

---

## 11. UI Layer — Screen

### `diamond_sell_screen.dart`

**Structure mirrors gold/silver screens exactly:**

```dart
class DiamondSellScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const DiamondSellScreen({super.key, this.onMenuTap});
}
```

**Widget tree:**
```
Scaffold (no AppBar, like gold/silver)
└── SafeArea
    └── Column
        ├── _HeaderCard (diamond blue accent, Icons.diamond_rounded, "Diamond & Stone Sell")
        └── Expanded
            └── DiamondSellBlocBuilder(
                  onRetry: () => preloadCubit.fetchPreloadData(),
                  successBuilder: (data) => _DiamondSellFormView(data: data),
                )
```

**`_DiamondSellFormView` (StatefulWidget) — form state:**

```dart
// State variables:
ClientModel? _selectedClient;
final List<DoubleSellCartItemModel> _cartItems = [];
final List<DoubleSellPaymentEntry> _paymentEntries = [];
final TextEditingController _notesController = TextEditingController();
```

**Form layout (single scrollable column):**
```
SingleChildScrollView
├── DiamondSellClientSection           ← client search / select / create
├── SizedBox(12.h)
├── DiamondSellProductScanner          ← type toggle + ID + scan + product preview
│   └── on add: _addToCart(product)
├── SizedBox(12.h)
├── DoubleSellCartWidget               ← reused from gold (title: "Cart", accentColor: diamond blue)
│   └── items: _cartItems
│   └── onRemove: _removeFromCart
│   └── onPriceChanged: _updateCartPrice   ← allow manual price override
├── SizedBox(12.h)
├── DoubleSellPaymentSection           ← reused from gold
│   └── accounts: data.accounts
│   └── cartTotalAmount: _grandTotal
│   └── entries: _paymentEntries
├── SizedBox(12.h)
├── DiamondSellSummaryWidget           ← diamond/stone totals + notes
├── SizedBox(16.h)
├── CustomButton("Submit Sell")        ← calls _validateAndSubmit()
└── SizedBox(24.h)
```

### Cart Item Building Logic

When a product is found and user taps "Add":

```dart
void _addToCart(dynamic product, String type, double usdRate) {
  if (type == 'diamond') {
    final diamond = product as DiamondProductModel;
    final egpPrice = diamond.total * usdRate;
    _cartItems.add(DoubleSellCartItemModel(
      key: 'diamond_${diamond.id}',
      type: 'diamond',
      title: diamond.name,
      subtitle: 'Diamond: ${diamond.totalDWeight} ct • Gold: ${diamond.totalGWeight} g',
      grams: diamond.totalWeight,
      price: egpPrice,
      payload: {
        'pro_id': diamond.id,
        'usd_price': diamond.total,
        'product_type': 'diamond',
      },
    ));
  } else {
    final stone = product as StoneProductModel;
    final egpPrice = stone.price * usdRate;
    _cartItems.add(DoubleSellCartItemModel(
      key: 'stone_${stone.id}',
      type: 'stone',
      title: stone.name,
      subtitle: 'Weight: ${stone.weight} ct • Report: ${stone.reportNumber}',
      grams: stone.weight,    // carat weight, not grams — display as "ct" not "g"
      price: egpPrice,
      payload: {
        'pro_id': stone.id,
        'usd_price': stone.price,
        'product_type': 'stone',
      },
    ));
  }
  context.read<DiamondProductLookupCubit>().clearLookup();
  setState(() {});
}
```

### Submit Logic

```dart
void _validateAndSubmit() {
  // Validation checks:
  // 1. Client selected
  if (_selectedClient == null) → show error "Select a client"
  // 2. Cart not empty
  if (_cartItems.isEmpty) → show error "Add at least one product"
  // 3. No duplicate products (check payload['pro_id'] + payload['product_type'] pairs)
  // 4. Payment total == grand total
  final paymentSum = _paymentEntries.fold(0.0, (sum, e) => sum + (e.cash * e.currencyPrice));
  if ((paymentSum - _grandTotal).abs() > 0.01) → show error "Payment must match total"
  // 5. At least one payment entry
  if (_paymentEntries.isEmpty) → show error "Add at least one payment"

  // Build request:
  final products = _cartItems.map((item) {
    final proId = item.payload['pro_id'] as int;
    final productType = item.payload['product_type'] as String;
    if (productType == 'diamond') {
      return {'type': 'diamond', 'pro_id': proId, 'product_price': item.price};
    } else {
      return {'type': 'stone', 'pro_id': proId, 'price': item.price};
    }
  }).toList();

  final request = DiamondSellRequestModel(
    clientId: _selectedClient!.id,
    workerId: WorkerData.id,          // from stored auth
    total: _grandTotal,
    notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    products: products,
    allAccounts: _paymentEntries
        .where((e) => e.cash > 0)
        .map((e) => e.toRequestMap())
        .toList(),
  );

  context.read<DiamondSellSubmitCubit>().submit(request);
}
```

### Success Handler

```dart
BlocListener<DiamondSellSubmitCubit, DiamondSellSubmitState>(
  listener: (context, state) {
    state.whenOrNull(
      loading: () => EasyLoading.show(),
      success: (data) {
        EasyLoading.dismiss();
        successSnackBar(
          msg: 'Submitted successfully!\n'
               'Invoice: ${data.unifiedId}\n'
               'Total: ${data.grandTotal.toStringAsFixed(2)} EGP',
          context: context,
        );
        // Clear form
        setState(() {
          _selectedClient = null;
          _cartItems.clear();
          _paymentEntries.clear();
          _notesController.clear();
        });
      },
      error: (messages) {
        EasyLoading.dismiss();
        failureSnackBar(msg: messages.join('\n'), context: context);
      },
    );
  },
)
```

---

## 12. DI Registration

In `lib/core/di/dependency_injection.dart`:

```dart
// Diamond Sell
import 'package:kenooz_worker_app/features/diamond_sell/data/remote/diamond_sell_api_service.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/repo/diamond_sell_repo.dart';

// Inside setupGetIt():
getIt.registerLazySingleton<DiamondSellApiService>(
  () => DiamondSellApiService(dio),
);
getIt.registerLazySingleton<DiamondSellRepo>(
  () => DiamondSellRepo(getIt()),
);
```

---

## 13. Routes

### `routes.dart`
```dart
static const String diamondSellScreen = '/diamond_sell_screen';
```

### `app_router.dart`

Add imports:
```dart
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_client_search_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_product_lookup_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_submit_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui/diamond_sell_screen.dart';
```

Add case:
```dart
case Routes.diamondSellScreen:
  return CupertinoPageRoute(
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DiamondSellPreloadCubit(getIt())),
        BlocProvider(create: (_) => DiamondClientSearchCubit(getIt())),
        BlocProvider(create: (_) => DiamondProductLookupCubit(getIt())),
        BlocProvider(create: (_) => DiamondSellSubmitCubit(getIt())),
      ],
      child: const DiamondSellScreen(),
    ),
  );
```

---

## 14. Drawer Integration

### `main_layout_screen.dart`

Add imports:
```dart
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_client_search_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_product_lookup_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_submit_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui/diamond_sell_screen.dart';
```

Replace case 3:
```dart
case 3:
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => DiamondSellPreloadCubit(getIt())),
      BlocProvider(create: (_) => DiamondClientSearchCubit(getIt())),
      BlocProvider(create: (_) => DiamondProductLookupCubit(getIt())),
      BlocProvider(create: (_) => DiamondSellSubmitCubit(getIt())),
    ],
    child: DiamondSellScreen(onMenuTap: openDrawer),
  );
```

---

## 15. Implementation Order (step by step)

### Phase 1: Data Layer
1. `diamond_product_model.dart` + `.g.dart`
2. `stone_product_model.dart` + `.g.dart`
3. `diamond_sell_preload_data.dart`
4. `diamond_sell_request_model.dart`
5. `diamond_sell_result_model.dart`
6. `diamond_sell_api_service.dart` + `.g.dart`
7. `diamond_sell_repo.dart`

### Phase 2: Cubit Layer
8. `diamond_sell_preload_state.dart` + `.freezed.dart` + `diamond_sell_preload_cubit.dart`
9. `diamond_client_search_state.dart` + `.freezed.dart` + `diamond_client_search_cubit.dart`
10. `diamond_product_lookup_state.dart` + `.freezed.dart` + `diamond_product_lookup_cubit.dart`
11. `diamond_sell_submit_state.dart` + `.freezed.dart` + `diamond_sell_submit_cubit.dart`

### Phase 3: UI Layer
12. `diamond_sell_shimmer.dart`
13. `diamond_sell_bloc_builder.dart`
14. `diamond_sell_client_section.dart`
15. `diamond_sell_product_card.dart`
16. `diamond_sell_product_scanner.dart`
17. `diamond_sell_summary_widget.dart`
18. `diamond_sell_screen.dart`

### Phase 4: Wiring
19. `dependency_injection.dart` — add DiamondSellApiService + DiamondSellRepo
20. `routes.dart` — add diamondSellScreen constant
21. `app_router.dart` — add imports + case
22. `main_layout_screen.dart` — add imports + replace case 3

---

## 16. Price Conversion Quick Reference

```dart
// In the screen, after preload data is available:
final double usdRate = data.usdRate.usd;  // e.g. 52.63

// Diamond product → EGP price:
final double diamondEgp = diamondProduct.total * usdRate;

// Stone product → EGP price:
final double stoneEgp = stoneProduct.price * usdRate;

// Grand total:
final double grandTotal = _cartItems.fold(0.0, (sum, item) => sum + item.price);

// Submit products[] building:
// Diamond: {'type': 'diamond', 'pro_id': id, 'product_price': egpPrice}
// Stone:   {'type': 'stone',   'pro_id': id, 'price': egpPrice}
//                                              ^^^^^ NOT product_price!
```

---

## 17. Edge Cases & Validation Rules

1. **Duplicate product check:** Before adding to cart, check if `pro_id` + `type` combination already exists in `_cartItems`
2. **Price override:** Allow manual EGP price editing (same as gold's `priceEditable` in cart) — worker may negotiate
3. **Empty media:** Product may have no images — show placeholder icon (diamond icon for diamonds, stone/gem icon for stones)
4. **Mixed cart:** Cart can have any combination of diamonds and stones
5. **Single type sell:** Valid to submit only diamonds or only stones — server returns `null` for the absent sell ID
6. **Already sold race condition:** Product may sell between scan and submit — server returns 500 with "already sold" message → show error, suggest removing that item
7. **Daily not open:** Arabic error `"لم يتم فتح اليومية لهذا اليوم"` → show "Daily record not open — contact the shop manager"
8. **USD rate consistency:** Use the preloaded `usdRate` for all conversions in the same session — don't re-fetch mid-flow

---

## 18. Accent Color & Theming

```dart
// Diamond accent color — light blue
static const Color diamondAccentColor = Color(0xFF64B5F6);

// Header icon
Icons.diamond_rounded

// Shimmer dark mode tint (blue-tinted)
baseColor: Color(0xFF1A1F2E)
highlightColor: Color(0xFF222840)

// Cart widget: accentColor = diamondAccentColor
// Payment section: accentColor = diamondAccentColor
// Product card border: diamondAccentColor.withOpacity(0.18)
```
