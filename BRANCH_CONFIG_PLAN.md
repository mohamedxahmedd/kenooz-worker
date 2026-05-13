# Multi-Branch Runtime Config — Implementation Plan

## Overview

Refactor the Kenooz Worker App from a single hardcoded base URL (`https://system.kenooz.co/api/`) to support two branches selected at runtime. The user picks a branch on first launch; the choice persists, and all API calls use the saved base URL globally.

### Branch Configuration

| ID | Name | Base URL |
|----|------|----------|
| 1 | Kenooz | `https://system.kenooz.co/api/` |
| 2 | Kenooz (Retag) | `https://retag.kenooz.co/api/` |

---

## Current Architecture (What Exists Today)

### Where `baseUrl` Lives Now

The single URL is a top-level `const` in `lib/core/constant.dart`:

```dart
const String baseUrl = 'https://system.kenooz.co/api/';
```

It is referenced in **14 files across 3 categories**:

**Category 1 — Retrofit `@RestApi(baseUrl: baseUrl)` annotations (12 files):**
These use the const at compile time AND the generated `.g.dart` files hardcode it as a fallback (`baseUrl ??= 'https://system.kenooz.co/api/'`). However, Retrofit's generated code also uses `_combineBaseUrls(_dio.options.baseUrl, baseUrl)` — meaning **if we pass `baseUrl` to the constructor or set it on the Dio instance, it overrides the annotation**.

- `lib/features/login/data/remote/login_api_services.dart`
- `lib/features/sign_up/data/remote/signup_api_services.dart`
- `lib/features/profile/data/remote/profile_api_service.dart`
- `lib/features/home/data/remote/home_api_service.dart`
- `lib/features/logout/data/remote/logout_api_service.dart`
- `lib/features/refresh_token/data/remote/refresh_token_api_service.dart`
- `lib/features/orders/data/remote/orders_api_service.dart`
- `lib/features/gold_double_sell/data/remote/gold_double_sell_api_service.dart`
- `lib/features/silver_double_sell/data/remote/silver_double_sell_api_service.dart`
- `lib/features/diamond_sell/data/remote/diamond_sell_api_service.dart`
- `lib/features/gold_buy/data/remote/gold_buy_api_service.dart`
- `lib/features/silver_buy/data/remote/silver_buy_api_service.dart`

**Category 2 — Direct Dio calls using `baseUrl` (1 file):**
- `lib/features/profile/data/repo/profile_repo.dart` → `'${baseUrl}worker/saveImage'`

**Category 3 — Token Manager's dedicated Dio (1 file):**
- `lib/core/network/token_manager.dart` → `BaseOptions(baseUrl: baseUrl, ...)`

### How DioFactory Works

`lib/core/network/dio_factory.dart` creates a singleton `Dio` with **no `baseUrl` set on options**. The Retrofit-generated services provide their own base URL. DioFactory only handles headers, timeouts, and the `TokenRefreshInterceptor`.

### How DI Works

`lib/core/di/dependency_injection.dart` calls `DioFactory.getDio()` once, then registers all 12 API services and their repos as `registerLazySingleton` using that single Dio instance.

### Startup Flow

```
main() → setupGetIt() → CacheHelper.init() → EasyLocalization.init()
       → checkIfLoggedInUser() → TokenManager restore → runApp(KenoozWorker)
       → MaterialApp(initialRoute: Routes.mainlayoutScreen)
```

There is no splash screen or branch check today. The app always starts at `mainlayoutScreen`.

---

## Implementation Plan

### Phase 1: Branch Model & Config

**Step 1.1 — Create `lib/core/config/branch_model.dart`**

```dart
class BranchModel {
  final int id;
  final String name;
  final String baseUrl;

  const BranchModel({
    required this.id,
    required this.name,
    required this.baseUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'baseUrl': baseUrl,
  };

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
    id: json['id'] as int,
    name: json['name'] as String,
    baseUrl: json['baseUrl'] as String,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BranchModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
```

**Step 1.2 — Create `lib/core/config/branches.dart`**

Single source of truth. Zero hardcoded URLs anywhere else.

```dart
import 'branch_model.dart';

class Branches {
  Branches._();

  static const kenooz = BranchModel(
    id: 1,
    name: 'Kenooz',
    baseUrl: 'https://system.kenooz.co/api/',
  );

  static const kenoozRetag = BranchModel(
    id: 2,
    name: 'Kenooz (Retag)',
    baseUrl: 'https://retag.kenooz.co/api/',
  );

  static const List<BranchModel> all = [kenooz, kenoozRetag];

  /// Default branch for first-time users and migration.
  static const BranchModel defaultBranch = kenooz;

  /// Look up by saved ID. Returns defaultBranch if not found.
  static BranchModel getById(int id) {
    return all.firstWhere((b) => b.id == id, orElse: () => defaultBranch);
  }
}
```

---

### Phase 2: Cache Layer

**Step 2.1 — Add cache key in `lib/core/cache_helper/cache_values.dart`**

```dart
static const String selectedBranchId = 'selectedBranchId';
```

One integer is sufficient — we resolve the full `BranchModel` from `Branches.getById()`.

**Step 2.2 — Add helper methods to `lib/core/cache_helper/cache_helper.dart`**

```dart
/// Returns the saved branch, or null if none has been selected yet.
static BranchModel? getSavedBranch() {
  final id = getData(key: CacheKeys.selectedBranchId) as int?;
  if (id == null) return null;
  return Branches.getById(id);
}

/// Persists the selected branch.
static Future<void> saveBranch(BranchModel branch) async {
  await saveData(key: CacheKeys.selectedBranchId, value: branch.id);
}

/// Clears branch selection (used when switching branches).
static Future<void> clearBranch() async {
  await removeData(key: CacheKeys.selectedBranchId);
}
```

---

### Phase 3: Refactor Network Layer

**Step 3.1 — Refactor `lib/core/network/dio_factory.dart`**

Set `baseUrl` on Dio's `BaseOptions` so it propagates to all Retrofit services automatically:

```dart
class DioFactory {
  DioFactory._();

  static Dio? dio;

  static Future<Dio> getDio({required String baseUrl}) async {
    if (dio == null) {
      const timeOut = Duration(seconds: 30);
      dio = Dio(BaseOptions(
        baseUrl: baseUrl,                // ← dynamic from branch
        connectTimeout: timeOut,
        receiveTimeout: timeOut,
        followRedirects: false,
        maxRedirects: 0,
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ));
      await _initHeaders();
      dio!.interceptors.add(TokenRefreshInterceptor(dio!));
    }
    return dio!;
  }

  /// Updates the base URL at runtime (e.g., branch switch).
  static void updateBaseUrl(String newBaseUrl) {
    dio?.options.baseUrl = newBaseUrl;
  }

  /// Destroys the Dio instance entirely. Call before re-registering services.
  static void reset() {
    dio = null;
  }

  // ... _initHeaders() and setTokenIntoHeaderAfterLogin() stay the same
}
```

**Step 3.2 — Update `lib/core/network/token_manager.dart`**

Replace the hardcoded `baseUrl` in the dedicated refresh Dio with a dynamic lookup:

```dart
Dio get _dio {
  final branch = CacheHelper.getSavedBranch() ?? Branches.defaultBranch;
  if (_refreshDio == null || _refreshDio!.options.baseUrl != branch.baseUrl) {
    _refreshDio = Dio(BaseOptions(
      baseUrl: branch.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: { ... },
    ));
  }
  return _refreshDio!;
}
```

**Step 3.3 — Update `lib/features/profile/data/repo/profile_repo.dart`**

Replace `'${baseUrl}worker/saveImage'` with relative path so Dio's base URL is used:

```dart
final response = await _dio.post(
  'worker/saveImage',    // ← relative, uses Dio's baseUrl
  data: formData,
);
```

**Step 3.4 — Remove `baseUrl` from `lib/core/constant.dart`**

Delete the line:
```dart
const String baseUrl = 'https://system.kenooz.co/api/';
```

---

### Phase 4: Refactor Retrofit API Services (12 files)

For every `@RestApi(baseUrl: baseUrl)` annotation, remove it so the services use Dio's base URL:

**Change from:**
```dart
import 'package:kenooz_worker_app/core/constant.dart';
@RestApi(baseUrl: baseUrl)
abstract class LoginApiService {
```

**Change to:**
```dart
@RestApi()
abstract class LoginApiService {
```

Remove the `import 'package:kenooz_worker_app/core/constant.dart';` from each file (if no other constant from that file is used).

**Files to update (12):**
1. `lib/features/login/data/remote/login_api_services.dart`
2. `lib/features/sign_up/data/remote/signup_api_services.dart`
3. `lib/features/profile/data/remote/profile_api_service.dart`
4. `lib/features/home/data/remote/home_api_service.dart`
5. `lib/features/logout/data/remote/logout_api_service.dart`
6. `lib/features/refresh_token/data/remote/refresh_token_api_service.dart`
7. `lib/features/orders/data/remote/orders_api_service.dart`
8. `lib/features/gold_double_sell/data/remote/gold_double_sell_api_service.dart`
9. `lib/features/silver_double_sell/data/remote/silver_double_sell_api_service.dart`
10. `lib/features/diamond_sell/data/remote/diamond_sell_api_service.dart`
11. `lib/features/gold_buy/data/remote/gold_buy_api_service.dart`
12. `lib/features/silver_buy/data/remote/silver_buy_api_service.dart`

**For each `.g.dart` file (12):** Update the generated fallback from:
```dart
baseUrl ??= 'https://system.kenooz.co/api/';
```
to remove that line entirely (the Dio instance's baseUrl will be used via `_combineBaseUrls`).

---

### Phase 5: Refactor Dependency Injection

**Step 5.1 — Update `lib/core/di/dependency_injection.dart`**

Make `setupGetIt()` accept a `baseUrl` parameter:

```dart
Future<void> setupGetIt({required String baseUrl}) async {
  Dio dio = await DioFactory.getDio(baseUrl: baseUrl);
  // ... all existing registerLazySingleton calls stay the same
}
```

Add a function for branch switching that resets and re-registers everything:

```dart
Future<void> resetServicesForBranch(String baseUrl) async {
  // 1. Reset DioFactory to destroy old instance
  DioFactory.reset();

  // 2. Reset all lazy singletons so they get recreated with new Dio
  getIt.resetLazySingleton<LoginApiService>();
  getIt.resetLazySingleton<LoginRepo>();
  getIt.resetLazySingleton<SignupApiService>();
  getIt.resetLazySingleton<SignupRepo>();
  getIt.resetLazySingleton<ProfileApiService>();
  getIt.resetLazySingleton<ProfileRepo>();
  getIt.resetLazySingleton<LogoutApiService>();
  getIt.resetLazySingleton<LogoutRepo>();
  getIt.resetLazySingleton<RefreshTokenApiService>();
  getIt.resetLazySingleton<RefreshTokenRepo>();
  getIt.resetLazySingleton<HomeApiService>();
  getIt.resetLazySingleton<HomeRepo>();
  getIt.resetLazySingleton<OrdersApiService>();
  getIt.resetLazySingleton<OrdersRepo>();
  getIt.resetLazySingleton<GoldDoubleSellApiService>();
  getIt.resetLazySingleton<GoldDoubleSellRepo>();
  getIt.resetLazySingleton<SilverDoubleSellApiService>();
  getIt.resetLazySingleton<SilverDoubleSellRepo>();
  getIt.resetLazySingleton<DiamondSellApiService>();
  getIt.resetLazySingleton<DiamondSellRepo>();
  getIt.resetLazySingleton<GoldBuyApiService>();
  getIt.resetLazySingleton<GoldBuyRepo>();
  getIt.resetLazySingleton<SilverBuyApiService>();
  getIt.resetLazySingleton<SilverBuyRepo>();

  // 3. Get new Dio with new baseUrl — lazy singletons will pick it up
  await DioFactory.getDio(baseUrl: baseUrl);
}
```

**Important:** `resetLazySingleton` disposes the old instance and marks it for re-creation on next access. Since each lazy singleton's factory closure captures the `dio` variable, we actually need a different approach — register with a factory that calls `DioFactory.getDio()`:

**Alternative (cleaner) approach — change registrations to use `getIt` for Dio:**

```dart
Future<void> setupGetIt({required String baseUrl}) async {
  // Register Dio itself as a singleton
  Dio dio = await DioFactory.getDio(baseUrl: baseUrl);
  getIt.registerSingleton<Dio>(dio);

  // All services use getIt<Dio>() through their factory closures
  getIt.registerLazySingleton<LoginApiService>(() => LoginApiService(getIt<Dio>()));
  // ... etc
}

Future<void> resetServicesForBranch(String baseUrl) async {
  DioFactory.reset();
  Dio newDio = await DioFactory.getDio(baseUrl: baseUrl);

  // Unregister old Dio and re-register new one
  getIt.unregister<Dio>();
  getIt.registerSingleton<Dio>(newDio);

  // Reset all lazy singletons — they'll recreate with the new Dio
  getIt.resetLazySingleton<LoginApiService>();
  getIt.resetLazySingleton<LoginRepo>();
  // ... etc for all services
}
```

---

### Phase 6: Startup Flow Changes

**Step 6.1 — Update `lib/main.dart`**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();
  await EasyLocalization.ensureInitialized();

  // Resolve branch BEFORE DI setup
  final savedBranch = CacheHelper.getSavedBranch();
  final baseUrl = savedBranch?.baseUrl ?? Branches.defaultBranch.baseUrl;

  await setupGetIt(baseUrl: baseUrl);
  Bloc.observer = MyBlocObserver();
  await ScreenUtil.ensureScreenSize();
  await checkIfLoggedInUser();

  if (isLoggedInUser) {
    await TokenManager().restoreTimerIfNeeded();
  }

  // ... rest stays the same

  runApp(
    EasyLocalization(
      // ... same config
      child: KenoozWorker(
        appRouter: AppRouter(),
        hasBranch: savedBranch != null,   // ← new param
      ),
    ),
  );
}
```

**Step 6.2 — Update `lib/kenooz_worker.dart`**

Add `hasBranch` parameter to decide the initial route:

```dart
class KenoozWorker extends StatelessWidget {
  KenoozWorker({
    super.key,
    required this.appRouter,
    required this.hasBranch,
  });
  final AppRouter appRouter;
  final bool hasBranch;
  final isdark = CacheHelper.getData(key: CacheKeys.isDark) ?? false;

  @override
  Widget build(BuildContext context) {
    // ... existing BlocProvider<SettingsCubit> wrapper ...
    return MaterialApp(
      // ...
      initialRoute: hasBranch
          ? Routes.mainlayoutScreen       // branch already chosen
          : Routes.branchSelectionScreen, // first launch
      // ...
    );
  }
}
```

---

### Phase 7: Branch Selection Screen

**Step 7.1 — Add route in `lib/core/routing/routes.dart`**

```dart
static const String branchSelectionScreen = '/branch_selection_screen';
```

**Step 7.2 — Create `lib/features/branch_selection/presentation/ui/branch_selection_screen.dart`**

Full-screen with two selectable branch cards. Design matches the existing app aesthetic:

- Scaffold background: `AppColors.backGroundColorLight` / `AppColors.darkThemeBackgroundColor`
- Cards: 18.r rounded, same shadow pattern as profile cards
- Each card shows: branch name, base URL preview (subdomain only), Kenooz logo
- Selected state: `AppColors.primaryColor` border highlight
- "Continue" button: `CustomButton` at the bottom

**Flow on selection:**
1. User taps a branch card → visual selection
2. User taps "Continue"
3. Save branch via `CacheHelper.saveBranch(branch)`
4. If this is the initial selection (not a switch): Navigate to `Routes.mainlayoutScreen`
5. If switching from settings: clear auth data, reset services, navigate to `Routes.loginScreen`

**Step 7.3 — Wire in `lib/core/routing/app_router.dart`**

```dart
case Routes.branchSelectionScreen:
  return CupertinoPageRoute(
    builder: (_) => const BranchSelectionScreen(),
  );
```

---

### Phase 8: Settings / Branch Switch

There is no settings screen yet. The profile screen's menu already has a "Settings" item that navigates to `Routes.settingsScreen`, but the route and screen don't exist.

**Option A (Recommended) — Add "Switch Branch" to the existing Profile Info widget:**

In `lib/features/profile/presentation/ui/widgets/profile_info_widget.dart`, add a new `ProfileItem` in the "General" section:

```dart
ProfileItem(
  svgPath: Assets.assetsImagesSettingIcon,  // or a suitable branch icon
  title: 'branch.switchBranch'.tr(),
  onTap: () => _showBranchSwitchDialog(context),
),
```

The dialog confirms the switch, then:
1. `await CacheHelper.clearBranch()`
2. `await CacheHelper.clearAuthDataPreservingBiometric()`
3. `TokenManager().cancelTimer()`
4. `await resetServicesForBranch(Branches.defaultBranch.baseUrl)` (temporary, will be set properly on selection)
5. Navigate to `Routes.branchSelectionScreen` with `pushNamedAndRemoveUntil`

**Option B — Create a dedicated Settings screen and add the branch switch there.**

---

### Phase 9: Translation Keys

**Add to all 4 language JSON files** (`en.json`, `ar.json`, `en-UK.json`, `ar-EG.json`):

**English:**
```json
"branch": {
    "selectBranch": "Select Branch",
    "selectDescription": "Choose your working branch to get started",
    "continue": "Continue",
    "switchBranch": "Switch Branch",
    "switchConfirm": "Switching branches will log you out. Are you sure?",
    "switchConfirmButton": "Switch",
    "cancel": "Cancel",
    "currentBranch": "Current Branch"
}
```

**Arabic:**
```json
"branch": {
    "selectBranch": "اختر الفرع",
    "selectDescription": "اختر فرع العمل للبدء",
    "continue": "متابعة",
    "switchBranch": "تبديل الفرع",
    "switchConfirm": "تبديل الفرع سيقوم بتسجيل خروجك. هل أنت متأكد؟",
    "switchConfirmButton": "تبديل",
    "cancel": "إلغاء",
    "currentBranch": "الفرع الحالي"
}
```

---

### Phase 10: Migration for Existing Users

Existing users who update the app will have **no** `selectedBranchId` saved. The startup flow handles this gracefully:

```dart
final savedBranch = CacheHelper.getSavedBranch(); // returns null
final baseUrl = savedBranch?.baseUrl ?? Branches.defaultBranch.baseUrl;
// → Uses "https://system.kenooz.co/api/" (same as before)
```

**However**, `hasBranch` will be `false`, so the app would show the branch selection screen. To avoid disrupting existing logged-in users:

```dart
// In main.dart, after checking login:
bool hasBranch = savedBranch != null;

// Auto-assign default branch for existing logged-in users
if (!hasBranch && isLoggedInUser) {
  await CacheHelper.saveBranch(Branches.defaultBranch);
  hasBranch = true;
}
```

This means: if you're already logged in but have no branch saved, you're clearly an existing user → default to Kenooz and skip selection.

---

## File Change Summary

### New Files (3)
| File | Purpose |
|------|---------|
| `lib/core/config/branch_model.dart` | Branch data class |
| `lib/core/config/branches.dart` | Branch list (single source of truth) |
| `lib/features/branch_selection/presentation/ui/branch_selection_screen.dart` | Branch picker UI |

### Modified Files (20+)
| File | Change |
|------|--------|
| `lib/core/constant.dart` | Remove `baseUrl` const |
| `lib/core/cache_helper/cache_values.dart` | Add `selectedBranchId` key |
| `lib/core/cache_helper/cache_helper.dart` | Add `getSavedBranch()`, `saveBranch()`, `clearBranch()` |
| `lib/core/network/dio_factory.dart` | Accept `baseUrl` param, add `reset()`, `updateBaseUrl()` |
| `lib/core/network/token_manager.dart` | Dynamic baseUrl from saved branch |
| `lib/core/di/dependency_injection.dart` | Accept `baseUrl`, add `resetServicesForBranch()` |
| `lib/core/routing/routes.dart` | Add `branchSelectionScreen` route |
| `lib/core/routing/app_router.dart` | Wire branch selection route |
| `lib/main.dart` | Resolve branch before DI, pass `hasBranch`, migration logic |
| `lib/kenooz_worker.dart` | Dynamic `initialRoute` based on `hasBranch` |
| `lib/features/profile/data/repo/profile_repo.dart` | Use relative URL for saveImage |
| `lib/features/profile/presentation/ui/widgets/profile_info_widget.dart` | Add "Switch Branch" option |
| 12x `*_api_service.dart` | Remove `baseUrl` from `@RestApi()` annotation |
| 12x `*_api_service.g.dart` | Remove hardcoded fallback URL |
| 4x `assets/languages/*.json` | Add `branch` translation section |

---

## Implementation Order

Execute in this exact sequence to avoid broken intermediate states:

1. **Phase 1** — Create `branch_model.dart` and `branches.dart` (no existing code breaks)
2. **Phase 2** — Add cache keys and helpers (no existing code breaks)
3. **Phase 9** — Add translation keys (no existing code breaks)
4. **Phase 3.3** — Fix `profile_repo.dart` to use relative URL (still works with current Dio)
5. **Phase 4** — Update all 12 API services + their `.g.dart` files (remove `@RestApi(baseUrl:)`)
6. **Phase 3.1** — Refactor `DioFactory.getDio()` to require `baseUrl`
7. **Phase 3.2** — Update `TokenManager` to use dynamic branch lookup
8. **Phase 5** — Refactor `dependency_injection.dart`
9. **Phase 6** — Update `main.dart` and `kenooz_worker.dart` startup flow
10. **Phase 7** — Create `BranchSelectionScreen` and wire route
11. **Phase 8** — Add "Switch Branch" to profile/settings
12. **Phase 10** — Test migration path for existing users
13. **Phase 3.4** — Remove `baseUrl` from `constant.dart` (final cleanup — only after all references are gone)

---

## Risk Areas

1. **`.g.dart` files have hardcoded URLs** — These are hand-maintained in this project (not auto-generated). Each of the 12 `.g.dart` files must be updated to remove the `baseUrl ??= '...'` fallback line, so they rely on Dio's baseUrl.

2. **`constant.dart` has other usages** — Files like `login_cubit.dart`, `main_layout_cubit.dart`, `forget_password.dart` import `constant.dart` for things other than `baseUrl` (e.g., `isLoggedInUser`, `navigatorKey`, `mainLayoutIntitalScreenIndex`). Only remove the `baseUrl` line, not the file.

3. **GetIt resetLazySingleton** — When switching branches, lazy singletons that have already been accessed need to be reset. The `resetLazySingleton` method requires the type to have been registered with `registerLazySingleton` (not `registerSingleton`). This is already the case for all services.

4. **TokenManager singleton** — The refresh Dio instance is cached. On branch switch, `_refreshDio` must be set to `null` so it recreates with the new base URL. Add a `resetRefreshDio()` method.

5. **Active sessions during switch** — Switching branches while a request is in-flight could cause issues. The switch flow should: cancel timer → clear auth → reset Dio → navigate to branch selection. This naturally serializes the transition.
