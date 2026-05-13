# Sells History Screens — Implementation Plan
> Three history screens (Gold / Silver / Diamond), each sitting **before** the existing sell form.
> The history screen becomes the new drawer entry point; "Add New Order" pushes the form screen on top.

---

## 0 — Navigation Flow Change

```
BEFORE
  Drawer case 2  →  GoldDoubleSellScreen
  Drawer case 3  →  DiamondSellScreen
  Drawer case 4  →  SilverDoubleSellScreen

AFTER
  Drawer case 2  →  GoldSellHistoryScreen          ← NEW (entry point)
                        └─ "Add New Order" button
                              └─ Navigator.push → GoldDoubleSellScreen

  Drawer case 3  →  DiamondSellHistoryScreen        ← NEW
                        └─ "Add New Order" button
                              └─ Navigator.push → DiamondSellScreen

  Drawer case 4  →  SilverSellHistoryScreen         ← NEW
                        └─ "Add New Order" button
                              └─ Navigator.push → SilverDoubleSellScreen
```

**What this means for existing sell screens:**
- `GoldDoubleSellScreen`, `SilverDoubleSellScreen`, `DiamondSellScreen` **already** have `onMenuTap` as **nullable** (`VoidCallback? onMenuTap`)
- The gold `_HeaderCard` already handles `if (onMenuTap != null)` to show/hide the hamburger
- **NO changes needed** to existing sell screens — just pass `null` when pushing from history
- When `onMenuTap == null`, they simply omit the hamburger; we only need to add a back arrow in the `_HeaderCard` for the `null` case

---

## 1 — Endpoints

| Feature | Method | Endpoint |
|---|---|---|
| Gold history | GET | `worker/golds/sells/double` |
| Silver history | GET | `worker/silvers/sells/double` |
| Diamond history | GET | `worker/unified/sells` |

All return `{ "status": "success", "sells": [...] }` newest-first.

---

## 2 — Architecture (same clean-arch pattern as sell screens)

```
feature/
  data/
    models/          ← history models (new files, no build_runner)
    remote/          ← add 1 method to existing api service + .g.dart
    repo/            ← add 1 method to existing repo
  presentation/
    cubit/           ← 1 new cubit + state + freezed (3 files each feature)
    ui/
      *_sell_history_screen.dart
      widgets/
        *_sell_history_shimmer.dart
        *_sell_history_card.dart
        *_sell_history_bloc_builder.dart
```

**DI:** NO cubit registration needed. Following the existing pattern, cubits are **never** registered in `dependency_injection.dart` — they are created inline via `BlocProvider(create: (_) => SomeCubit(getIt()))`. Only `ApiService` and `Repo` instances are registered as `registerLazySingleton`. Since we add methods to existing services/repos, **zero DI changes are needed**.

**Routes:** no new routes needed — the sell form screens are pushed via `Navigator.push` from the history screen, so they don't need deep-link routes.

---

## 3 — Shared Simple Models

These are small inline reference objects used inside history models.
Create one shared file per feature (or inline as nested classes — your choice):

```dart
// Appears in history responses for all 3 features
class HistorySellClientRef {
  final int id;
  final String name;
  final String phone;
}

class HistorySellWorkerRef {
  final int id;
  final String name;
}
```

Put these in the **gold** feature folder and import them from silver/diamond, OR duplicate as tiny nested classes — both are fine.

---

## 4 — Gold Sell History

### 4a — Models (4 new files)

**`gold_sell_history_model.dart`**
```dart
class GoldSellHistoryModel {
  final int id;
  final double total;
  final String type;          // always "double"
  final String sellDate;      // ISO 8601 string
  final String? notes;
  final Map<String, double> cash;  // accountId → amount
  final HistorySellClientRef client;
  final HistorySellWorkerRef worker;
  final List<GoldSellItemHistoryModel> goldSellItems;
  final List<GoldBuyHistoryModel> goldBuys;

  // helpers
  bool get hasBuy => goldBuys.isNotEmpty;
  int get itemCount => goldSellItems.length;
}
```

**`gold_sell_item_history_model.dart`**
```dart
// Item subtype determined at runtime:
//   inside  → goldId != null, boxId == null
//   box     → boxId  != null, goldId == null
//   outside → both null

class GoldSellItemHistoryModel {
  final int id;
  final int? goldId;       // set for Inside items
  final int? boxId;        // set for Box items
  final double grams;
  final double? loss;      // only for Box items
  final double mc;
  final double profit;
  final double gramPrice;
  final double price;
  // nested refs
  final String? goldName;  // from gold.name
  final String caratLabel; // from carat.carat  e.g. "21"
  final String kindName;   // from kind.name
  final String vendorName; // from vendor.name
  final String? boxName;   // from box.name

  // computed
  GoldSellItemType get itemType {
    if (goldId != null) return GoldSellItemType.inside;
    if (boxId != null)  return GoldSellItemType.box;
    return GoldSellItemType.outside;
  }
}

enum GoldSellItemType { inside, box, outside }
```

**`gold_buy_history_model.dart`**
```dart
class GoldBuyHistoryModel {
  final int id;
  final double total;
  final List<GoldBuyItemHistoryModel> items; // from gold_buy_items
}
```

**`gold_buy_item_history_model.dart`**
```dart
class GoldBuyItemHistoryModel {
  final int id;
  final double grams;
  final double loss;
  final double gramPrice;
  final double price;
  final String caratLabel;
  final String? boxName;
}
```

> **No `.g.dart` needed** — write manual `fromJson` factories using defensive `_parseDouble` / `_parseInt` helpers (same pattern as all other models in the codebase).

---

### 4b — API Service addition

Add one method to **`gold_double_sell_api_service.dart`**:

```dart
static const String goldSellHistoryApi = 'worker/golds/sells/double';

@GET(goldSellHistoryApi)
Future<Map<String, dynamic>> getGoldSellHistory();
```

Returns raw `Map<String, dynamic>` because the `sells` array contains deeply nested objects — parsing is done manually in the repo, not by Retrofit's auto-parser.

Add corresponding implementation in **`gold_double_sell_api_service.g.dart`**:
```dart
@override
Future<Map<String, dynamic>> getGoldSellHistory() async {
  final _result = await _dio.fetch<Map<String, dynamic>>(
    _setStreamType<Map<String, dynamic>>(
      Options(method: 'GET', headers: _headers)
          .compose(_dio.options, 'worker/golds/sells/double')
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    ),
  );
  return _result.data!;
}
```

---

### 4c — Repo addition

Add one method to **`gold_double_sell_repo.dart`**:

```dart
Future<ApiResult<List<GoldSellHistoryModel>>> fetchSellHistory() async {
  try {
    final raw = await _apiService.getGoldSellHistory();
    final sellsList = raw['sells'] as List<dynamic>? ?? [];
    final models = sellsList
        .map((e) => GoldSellHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ApiResult.success(models);
  } catch (e) {
    return ApiResult.failure(ErrorHandler.handle(e));
  }
}
```

---

### 4d — Cubit (3 files)

**`gold_sell_history_state.dart`**
```dart
@freezed
class GoldSellHistoryState with _$GoldSellHistoryState {
  const factory GoldSellHistoryState.initial()  = _Initial;
  const factory GoldSellHistoryState.loading()  = _Loading;
  const factory GoldSellHistoryState.success(List<GoldSellHistoryModel> sells) = _Success;
  const factory GoldSellHistoryState.error(String message) = _Error;
}
```

**`gold_sell_history_cubit.dart`**
```dart
class GoldSellHistoryCubit extends Cubit<GoldSellHistoryState> {
  final GoldDoubleSellRepo _repo;
  GoldSellHistoryCubit(this._repo) : super(const GoldSellHistoryState.initial());

  Future<void> fetchHistory() async {
    emit(const GoldSellHistoryState.loading());
    final result = await _repo.fetchSellHistory();
    result.when(
      success: (sells) => emit(GoldSellHistoryState.success(sells)),
      failure: (f) => emit(GoldSellHistoryState.error(_extractMessage(f.errorModel))),
    );
  }
}
```

**No DI registration** — created inline: `BlocProvider(create: (_) => GoldSellHistoryCubit(getIt()))`

---

### 4e — UI (4 files)

**`gold_sell_history_shimmer.dart`**
Same pattern as `gold_double_sell_shimmer.dart` — shimmer list of 6 fake cards.
Color: dark-gold tinted dark mode background (`0xFF1C2B24` / `0xFF243630`).

---

**`gold_sell_history_bloc_builder.dart`**
```dart
BlocBuilder<GoldSellHistoryCubit, GoldSellHistoryState>(
  builder: (context, state) => state.when(
    initial: ()         => const SizedBox.shrink(),
    loading: ()         => const GoldSellHistoryShimmer(),
    success: (sells)    => sells.isEmpty
                              ? _EmptyHistoryWidget(accentColor: goldAccent)
                              : _GoldHistoryList(sells: sells),
    error: (msg)        => _ErrorWidget(message: msg, onRetry: () => context.read<GoldSellHistoryCubit>().fetchHistory()),
  ),
);
```

---

**`gold_sell_history_card.dart`** — Expandable card widget

```
┌──────────────────────────────────────────────────────┐
│  [Avatar initials]  أحمد محمود         07/04/2026    │
│                     01012345678     3,250.00 ج.م     │
│  3 قطع مباعة  ●  [شراء موجود badge]         [▼/▲]   │
│━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  SELL ITEMS (expanded)                               │
│  [inside] سلسلة ذهب | 21K | 10.5g    4,462.50 ج.م  │
│  [box]    خاتم      | 21K | 8.0g     3,241.00 ج.م  │
│  ─── الشراء ────────────────────────               │
│  21K | 5.0g (خسارة 0.2g)             1,752.00 ج.م  │
└──────────────────────────────────────────────────────┘
```

- Collapsed height: ~72dp; tap anywhere to expand/collapse with `AnimatedSize`
- Item type badge: مباشر (blue), من العلبة (teal), خارجي (orange)
- "شراء موجود" badge: small red chip shown if `sell.hasBuy == true`

---

**`gold_sell_history_screen.dart`**

Uses the **exact same layout pattern** as `GoldDoubleSellScreen` and `HomeScreen`:
- `Scaffold` with `backgroundColor: isDark ? AppColors.darkThemeBackgroundColor : AppColors.backGroundColorLight`
- Top: `Padding(padding: EdgeInsets.fromLTRB(20.w, topInset + 12.h, 20.w, 10.h))` → `_HistoryHeaderCard`
- Body: `Expanded` → `GoldSellHistoryBlocBuilder`
- Pull-to-refresh via `RefreshIndicator` (matching `HomeScreen._SuccessView`)

```dart
class GoldSellHistoryScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const GoldSellHistoryScreen({super.key, this.onMenuTap});
}

// initState → context.read<GoldSellHistoryCubit>().fetchHistory();
```

**`_HistoryHeaderCard`** — matches gold `_HeaderCard` exactly:
```
┌──────────────────────────────────────────────────────────────┐
│  [☰ hamburger]  [🏷️ gold circle]  Gold Double Sell          │
│                                    Sell history & orders     │
│                                                              │
│  [  + طلب جديد  ]   ← "Add New Order" styled button        │
└──────────────────────────────────────────────────────────────┘
```

Structure:
- Same `Container` with `BoxDecoration` (darkThemeContainerColor / white, 18.r, border)
- Row: hamburger (onMenuTap) → gold circle icon `Icons.sell_rounded` → Column(title, subtitle)
- Below row: `SizedBox(height: 12.h)` → "Add New Order" button (full width)
- Button style: `AppColors.goldColor` bg, white text, `Icons.add_rounded` leading icon, `BorderRadius.circular(12.r)`
- Uses `AppFonts.heading` for title, `AppFonts.body` for subtitle — matches gold screen exactly

---

## 5 — Silver Sell History

Mirrors Gold exactly. All field names change `gold_` → `silver_`:

| Gold | Silver |
|---|---|
| `gold_sell_items` | `silver_sell_items` |
| `gold_id` | `silver_id` |
| `gold_buys` | `silver_buys` |
| `gold_buy_items` | `silver_buy_items` |
| `GoldSellHistoryModel` | `SilverSellHistoryModel` |
| `GoldSellItemType` | `SilverSellItemType` |
| `gold_double_sell_api_service` | `silver_double_sell_api_service` |
| `GoldDoubleSellRepo` | `SilverDoubleSellRepo` |

**API endpoint to add:** `worker/silvers/sells/double`

**Files:** 4 models + 1 cubit + 1 state + 1 freezed + 4 UI files = **11 files**

**DI:** None — created inline: `BlocProvider(create: (_) => SilverSellHistoryCubit(getIt()))`

**Shimmer accent:** silver-neutral grey (`0xFF1C1C1C` / `0xFF2A2A2A`)

**History card:** same structure, but `hasBuy` badge shows "شراء فضة موجود"

---

## 6 — Diamond Unified Sell History

More complex — no buy section, but two product arrays per unified sell.

### 6a — Models (5 files)

**`diamond_unified_sell_history_model.dart`**
```dart
class DiamondUnifiedSellHistoryModel {
  final String unifiedId;      // UUID string
  final String sellDate;
  final String? notes;
  final double grandTotal;
  final HistorySellClientRef client;
  final HistorySellWorkerRef worker;
  final List<DiamondSellRecordModel> diamondSells;
  final List<StoneSellRecordModel> stoneSells;

  // helpers
  int get totalDiamondItems => diamondSells.fold(0, (s, d) => s + d.items.length);
  int get totalStoneItems   => stoneSells.fold(0, (s, d) => s + d.items.length);
}
```

**`diamond_sell_record_model.dart`** ← one diamond_sell inside unified
```dart
class DiamondSellRecordModel {
  final int id;
  final double total;
  final List<DiamondSellItemHistoryModel> items; // from diamond_sell_items
}
```

**`diamond_sell_item_history_model.dart`**
```dart
class DiamondSellItemHistoryModel {
  final int id;
  final double price;    // EGP
  final double dollars;  // USD
  final String diamondName;   // from diamond.name
  final double diamondWeight; // from diamond.weight  (carats)
  final String kindName;
  final String vendorName;
}
```

**`stone_sell_record_model.dart`**
```dart
class StoneSellRecordModel {
  final int id;
  final double total;
  final List<StoneSellItemHistoryModel> items;
}
```

**`stone_sell_item_history_model.dart`**
```dart
class StoneSellItemHistoryModel {
  final int id;
  final double price;    // EGP
  final double dollars;  // USD
  final double weight;
  final String stoneName;    // from stone.name
  final String companyName;  // from company.name
}
```

---

### 6b — API addition to `diamond_sell_api_service.dart`

```dart
static const String unifiedSellHistoryApi = 'worker/unified/sells';

@GET(unifiedSellHistoryApi)
Future<Map<String, dynamic>> getUnifiedSellHistory();
```

---

### 6c — Repo addition to `diamond_sell_repo.dart`

```dart
Future<ApiResult<List<DiamondUnifiedSellHistoryModel>>> fetchSellHistory() async {
  try {
    final raw = await _apiService.getUnifiedSellHistory();
    final sellsList = raw['sells'] as List<dynamic>? ?? [];
    final models = sellsList
        .map((e) => DiamondUnifiedSellHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ApiResult.success(models);
  } catch (e) {
    return ApiResult.failure(ErrorHandler.handle(e));
  }
}
```

---

### 6d — Cubit (3 files)

```dart
@freezed
class DiamondSellHistoryState with _$DiamondSellHistoryState {
  const factory DiamondSellHistoryState.initial()  = _Initial;
  const factory DiamondSellHistoryState.loading()  = _Loading;
  const factory DiamondSellHistoryState.success(List<DiamondUnifiedSellHistoryModel> sells) = _Success;
  const factory DiamondSellHistoryState.error(String message) = _Error;
}
```

**DI:** None — created inline: `BlocProvider(create: (_) => DiamondSellHistoryCubit(getIt()))`

---

### 6e — UI (4 files)

**Card layout:**
```
┌────────────────────────────────────────────────────────┐
│  [Avatar]  أحمد محمود          07/04/2026             │
│            01012345678     800.00 ج.م                 │
│  2 ماس  ●  1 أحجار                          [▼/▲]    │
│━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  [💎 DIAMONDS] ──────────────────────                 │
│  ماسة 0.5 قيراط | خاتم ماس      300.00 ج.م (6.0$)   │
│  [🪨 STONES] ────────────────────────                 │
│  ياقوت أحمر | شركة الأحجار     300.00 ج.م (6.0$)    │
│  ─────────── الإجمالي: 800.00 ج.م ────────────        │
└────────────────────────────────────────────────────────┘
```

- Diamond items grouped under blue "💎" header
- Stone items grouped under purple "🪨" header
- Each item shows EGP + USD in parentheses
- Shimmer accent: blue-tinted dark (`0xFF1A1F2E` / `0xFF222840`)

---

## 7 — Minor Edit to Existing Sell Screen Headers (back arrow when pushed)

All three sell screens already have `VoidCallback? onMenuTap` (nullable). However, the gold `_HeaderCard` currently uses `if (onMenuTap != null)` to show the hamburger, but does **nothing** when `onMenuTap == null` — so there's no back arrow.

**Only change:** In each sell screen's `_HeaderCard` (or equivalent), add a back-arrow fallback when `onMenuTap == null`:

```dart
// Gold _HeaderCard — BEFORE (existing code):
if (onMenuTap != null) ...[
  InkWell(onTap: onMenuTap, ..., child: Icon(Icons.menu_rounded, ...)),
  SizedBox(width: 8.w),
],

// AFTER — add else branch:
if (onMenuTap != null) ...[
  InkWell(onTap: onMenuTap, ..., child: Icon(Icons.menu_rounded, ...)),
  SizedBox(width: 8.w),
] else ...[
  InkWell(
    onTap: () => Navigator.pop(context),
    borderRadius: BorderRadius.circular(10.r),
    child: Container(
      width: 40.w, height: 40.w,
      decoration: /* same box decoration as hamburger */,
      child: Icon(Icons.arrow_back_ios_rounded, ...),
    ),
  ),
  SizedBox(width: 8.w),
],
```

Apply this same back-arrow pattern to `SilverDoubleSellScreen` and `DiamondSellScreen` headers.

---

## 8 — main_layout_screen.dart Changes

```dart
// case 2 — was GoldDoubleSellScreen, now GoldSellHistoryScreen
case 2:
  return BlocProvider(
    create: (_) => GoldSellHistoryCubit(getIt()),
    child: GoldSellHistoryScreen(onMenuTap: openDrawer),
  );

// case 3 — was DiamondSellScreen, now DiamondSellHistoryScreen
case 3:
  return BlocProvider(
    create: (_) => DiamondSellHistoryCubit(getIt()),
    child: DiamondSellHistoryScreen(onMenuTap: openDrawer),
  );

// case 4 — was SilverDoubleSellScreen, now SilverSellHistoryScreen
case 4:
  return BlocProvider(
    create: (_) => SilverSellHistoryCubit(getIt()),
    child: SilverSellHistoryScreen(onMenuTap: openDrawer),
  );
```

The history screen (not main_layout) is responsible for providing cubits when it pushes the form screen.

---

## 9 — "Add New Order" Button in History Screen (all three)

When the button is pressed, push the sell form screen with all required cubits:

**Gold history screen "Add New Order":**
```dart
Navigator.push(
  context,
  CupertinoPageRoute(
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DoubleSellPreloadCubit(getIt())),
        BlocProvider(create: (_) => ClientSearchCubit(getIt())),
        BlocProvider(create: (_) => ProductLookupCubit(getIt())),
        BlocProvider(create: (_) => GoldKindsCubit(getIt())),
        BlocProvider(create: (_) => DoubleSellSubmitCubit(getIt())),
        BlocProvider(create: (_) => CreateVendorCubit(getIt())),
      ],
      child: const GoldDoubleSellScreen(), // onMenuTap: null → shows back arrow
    ),
  ),
).then((_) {
  // Refresh history list after returning from form
  context.read<GoldSellHistoryCubit>().fetchHistory();
});
```

> **Important:** call `.then((_) => fetchHistory())` so the history list refreshes after the user submits an order and pops back.

**Silver history screen "Add New Order":** same pattern with **5** silver cubits:
```dart
BlocProvider(create: (_) => SilverDoubleSellPreloadCubit(getIt())),
BlocProvider(create: (_) => SilverClientSearchCubit(getIt())),
BlocProvider(create: (_) => SilverProductLookupCubit(getIt())),
BlocProvider(create: (_) => SilverDoubleSellSubmitCubit(getIt())),
BlocProvider(create: (_) => SilverCreateVendorCubit(getIt())),
// child: const SilverDoubleSellScreen()
```

**Diamond history screen "Add New Order":** same pattern with **4** diamond cubits:
```dart
BlocProvider(create: (_) => DiamondSellPreloadCubit(getIt())),
BlocProvider(create: (_) => DiamondClientSearchCubit(getIt())),
BlocProvider(create: (_) => DiamondProductLookupCubit(getIt())),
BlocProvider(create: (_) => DiamondSellSubmitCubit(getIt())),
// child: const DiamondSellScreen()
```

---

## 10 — File Count Summary

| Feature | New models | New API method | New cubit/state/freezed | New UI files | Total new |
|---|---|---|---|---|---|
| Gold history | 4 | 1 (+ .g.dart update) | 3 | 4 | **12** |
| Silver history | 4 | 1 (+ .g.dart update) | 3 | 4 | **12** |
| Diamond history | 5 | 1 (+ .g.dart update) | 3 | 4 | **13** |
| **Total new files** | | | | | **37** |

Plus **edits to** existing files:
- `gold_double_sell_api_service.dart` + `.g.dart` — add 1 history method (2 edits)
- `silver_double_sell_api_service.dart` + `.g.dart` — add 1 history method (2 edits)
- `diamond_sell_api_service.dart` + `.g.dart` — add 1 history method (2 edits)
- `gold_double_sell_repo.dart` — add `fetchSellHistory()` method (1 edit)
- `silver_double_sell_repo.dart` — add `fetchSellHistory()` method (1 edit)
- `diamond_sell_repo.dart` — add `fetchSellHistory()` method (1 edit)
- `main_layout_screen.dart` — replace cases 2, 3, 4 + add imports (1 edit)
- `gold_double_sell_screen.dart` `_HeaderCard` — add back-arrow fallback (1 edit)
- `silver_double_sell_screen.dart` header — add back-arrow fallback (1 edit)
- `diamond_sell_screen.dart` header — add back-arrow fallback (1 edit)

**NO DI changes** (cubits are created inline, services/repos already registered)

---

## 11 — Implementation Order

1. **Models first** (all 3 features, 13 model files total)
2. **API service + .g.dart** for all 3 (add history method to each)
3. **Repo** additions for all 3
4. **Cubits + states + freezed** for all 3
5. **Add back-arrow fallback** to the 3 existing sell screen `_HeaderCard` widgets
6. **UI: shimmer** for all 3 history screens
7. **UI: history card** for all 3 (most complex — do gold first, pattern-copy for silver, adapt for diamond)
8. **UI: bloc_builder** for all 3
9. **UI: history screen** for all 3 (incl. _HistoryHeaderCard + "Add New Order" push with .then refresh)
10. **main_layout_screen.dart** — replace cases 2, 3, 4 with history screens + add imports

---

## 12 — UI Design System Rules (MUST match existing app)

All three history screens MUST follow the exact same design language used in `HomeScreen`, `GoldDoubleSellScreen`, and `OrdersScreen`. These are NOT generic Material screens — they use the app's custom design tokens:

### 12a — Scaffold + Background
```dart
Scaffold(
  backgroundColor: isDark
      ? AppColors.darkThemeBackgroundColor   // 0xFF0F1610
      : AppColors.backGroundColorLight,      // 0xFFFDF7EF (warm cream)
  body: Column(children: [
    Padding(..., child: _HistoryHeaderCard(...)),
    Expanded(child: /* BlocBuilder or list */),
  ]),
)
```

### 12b — Header Card (NOT AppBar)
The app does NOT use Material `AppBar`. Every screen uses a custom `_HeaderCard` container:
```dart
Container(
  width: double.infinity,
  padding: EdgeInsets.all(14.w),
  decoration: BoxDecoration(
    color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
    borderRadius: BorderRadius.circular(18.r),
    border: Border.all(
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : AppColors.primaryColor.withOpacity(0.14),
    ),
  ),
  // ... content
)
```
Padding from screen edge: `EdgeInsets.fromLTRB(20.w, topInset + 12.h, 20.w, 10.h)`

### 12c — Typography
- Title: `AppFonts.heading(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ...)`
  - Dark: `AppColors.lightTextColorForDarkMood`
  - Light: `AppColors.darkBrown`
- Subtitle/body: `AppFonts.body(fontSize: 12.sp, color: ...)`
  - Dark: `AppColors.textGreyColor`
  - Light: `AppColors.darkGreyTextColor`
- **Font family**: heading = `Hedvig Letters Serif` (via `AppFonts.heading`), body = `Inter` (via `AppFonts.body`)

### 12d — Container & Card Decorations
All cards and containers use:
```dart
BoxDecoration(
  color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
  borderRadius: BorderRadius.circular(16.r),
  border: Border.all(
    color: isDark
        ? Colors.white.withOpacity(0.08)
        : AppColors.primaryColor.withOpacity(0.14),
  ),
  boxShadow: isDark ? null : [
    BoxShadow(
      color: AppColors.darkBrown.withOpacity(0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ],
)
```

### 12e — Hamburger Button (same across all screens)
```dart
InkWell(
  onTap: onMenuTap,
  borderRadius: BorderRadius.circular(10.r),
  child: Container(
    width: 40.w, height: 40.w,
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withOpacity(0.08) : AppColors.darkBrown.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.08) : AppColors.darkBrown.withOpacity(0.1),
      ),
    ),
    child: Icon(Icons.menu_rounded, color: isDark ? AppColors.lightTextColorForDarkMood : AppColors.darkBrown, size: 22.sp),
  ),
)
```

### 12f — Feature Circle Icon (per-feature accent)
```dart
Container(
  width: 40.w, height: 40.w,
  decoration: BoxDecoration(
    color: accentColor.withOpacity(0.15),
    shape: BoxShape.circle,
  ),
  child: Icon(featureIcon, color: accentColor, size: 22.sp),
)
```
- Gold: `AppColors.goldColor` + `Icons.sell_rounded`
- Silver: `const Color(0xFF9E9E9E)` + `Icons.sell_rounded`
- Diamond: `const Color(0xFF64B5F6)` + `Icons.diamond_rounded`

### 12g — "Add New Order" Button Style
Inside the header card, below the title row:
```dart
SizedBox(
  width: double.infinity,
  height: 44.h,
  child: ElevatedButton.icon(
    onPressed: _pushToSellForm,
    icon: Icon(Icons.add_rounded, size: 20.sp),
    label: Text('طلب جديد', style: AppFonts.body(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
  ),
)
```

### 12h — List Layout
- `RefreshIndicator` wrapping a `ListView.builder` (same as `HomeScreen._SuccessView`)
- `RefreshIndicator` color: `AppColors.darkBrown`, bg: dark container or white
- List padding: `EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 8.h, bottom: 100.h)`
- Item spacing: `SizedBox(height: 12.h)` between cards

### 12i — Empty State
Uses same error container style as `HomeBlocBuilder._ErrorView`:
- Centered container with rounded corners, icon circle, title text, subtitle text, and a CTA button
- The CTA button doubles as "Add New Order"

### 12j — Error View
Reuse the exact same `_ErrorView` pattern from `HomeBlocBuilder`:
- Icon in circle (error icon) → "Something went wrong" title → error message → "Try Again" button
- Match colors, padding, button style exactly

---

## 13 — Edge Cases & Validation Notes

- **Empty state:** History list could be empty (new worker with no sells). Show empty state widget with the "Add New Order" button inside it too.
- **`sells` key on error:** API might return non-200 if shop has no history. `fetchSellHistory()` already wraps in `ApiResult.failure` via `ErrorHandler.handle(e)`.
- **Diamond with only diamonds or only stones:** `diamond_sells` or `stone_sells` can be `[]`. Show only the non-empty section.
- **`notes` field:** can be `null` or empty string in gold/silver. Skip the notes row in the card if both null and empty.
- **`cash` map:** keys are strings (`"1"`, `"2"`, etc.) not ints. Parse with `.toString()` when building the map.
- **Date formatting:** Use `DateFormat('dd/MM/yyyy').format(DateTime.parse(sell.sellDate))` for date display. Reuse `lib/core/functions/date_format.dart` if it has a suitable formatter.
- **Sell screen back arrow:** When user pops from the sell form back to history, `.then((_) => fetchHistory())` refreshes the list — even if they didn't submit anything.

---

## 14 — Theming Quick Reference

| Screen | Accent color | Shimmer bg | Shimmer card |
|---|---|---|---|
| Gold history | `AppColors.primaryColor` (gold) | `0xFF1C2B24` | `0xFF243630` |
| Silver history | `const Color(0xFF9E9E9E)` | `0xFF1C1C1C` | `0xFF2A2A2A` |
| Diamond history | `const Color(0xFF64B5F6)` | `0xFF1A1F2E` | `0xFF222840` |
