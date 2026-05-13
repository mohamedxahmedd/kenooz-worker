# Flutter Multi-Theme + Multi-Palette Playbook

**Hand this file to Claude in another Flutter project.** It describes a complete, working theming system: multiple brightness modes (light / dark / deep-dark) crossed with multiple color palettes (e.g. gold / silver / diamond / red). User picks brightness + palette in a settings screen; the entire app recolors instantly and the choice persists across restarts.

This playbook is app-agnostic. It does not assume any particular feature set, screen layout, or business domain. It only assumes a Flutter app using Material — anything else (state management, persistence, localization) has explicit fallbacks.

---

## What you (Claude in the target app) will produce

By the end of this playbook the target app will have:

1. **N brightness modes × M palettes = N×M ThemeData configurations** (default: 3 × 4 = 12).
2. A **`PaletteTokens`** value object holding all semantic colors.
3. A **theme builder** `buildAppTheme(palette, brightness) → ThemeData` plus a `ThemeExtension` so any widget can read `tokensOf(context)`.
4. A **`SettingsCubit`** (or equivalent) that owns brightness + palette and persists both.
5. A **dynamic `AppColors`** facade — runtime-mutable static fields populated from the active palette. This is the trick that lets every existing widget that reads `AppColors.primaryColor` follow the theme without per-widget edits.
6. A **Settings screen** with brightness picker + palette picker + live preview.
7. **Localization keys** added in all language files (or fallback strings if the app has no i18n).

When the user changes brightness or palette: `MaterialApp.theme` rebuilds, `AppColors.apply(tokens)` refreshes the facade fields, and Flutter's element rebuild cascades the new colors to every screen — including widgets that still reference the legacy color class.

---

## Before you start: gather these facts about the target app

Spend ~5 minutes investigating the codebase before writing anything. You need:

1. **State management**: Cubit/Bloc, Riverpod, Provider, GetX, or vanilla `setState`?
2. **Persistence**: SharedPreferences, Hive, secure storage, or none?
3. **Existing color class**: usually `AppColors`, `AppPalette`, `AppTheme`, or hex literals scattered everywhere. Find it with `grep -rn "static const.*Color" lib/`.
4. **`MaterialApp` location**: typically `main.dart` or an `app.dart`/`<projectname>.dart`. Find the `theme:` / `darkTheme:` / `themeMode:` parameters.
5. **Localization**: EasyLocalization, intl + Flutter gen, or none. Find with `grep -rn "easy_localization\|intl/intl.dart" lib/`.
6. **Routing**: declarative (go_router), imperative `onGenerateRoute`, or named routes. You need to know how to register a new screen.
7. **Settings entry-point**: drawer item, bottom-tab, profile screen, etc. Where will users tap to open the new settings screen?

Map these to the variables below. Where the playbook says "Cubit" assume the app's chosen state management; where it says "SharedPreferences" assume the app's chosen persistence.

---

## Decisions to confirm with the user before writing code

Always ask the user these four questions and wait for answers. Defaults in parentheses; don't assume.

1. **How many palettes and which colors?** (default: gold, silver, diamond, red — propose hex values)
2. **How many brightness modes?** (default: light, dark, deep-dark; deep-dark = pure-black `#000000` for OLED)
3. **Default combination for new users.** (e.g. "gold + light")
4. **Receipts / PDFs / brand assets** — should these follow the user's chosen palette, or stay locked to a brand color regardless?

If the user says "decide for me", pick sensible defaults and tell them what you chose.

---

## Phase 1 — Design tokens

Create three files under `lib/core/theming/` (or wherever the app's existing colors live).

**`app_brightness.dart`**

```dart
enum AppBrightness {
  light,
  dark,
  deepDark;

  bool get isLight => this == AppBrightness.light;
  bool get isDark =>
      this == AppBrightness.dark || this == AppBrightness.deepDark;

  static AppBrightness fromName(String? name) {
    return AppBrightness.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppBrightness.light,
    );
  }
}
```

**`app_palette.dart`**

```dart
enum AppPalette {
  gold,
  silver,
  diamond,
  red;

  static AppPalette fromName(String? name) {
    return AppPalette.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppPalette.gold,
    );
  }
}
```

Adjust the enum members to match the user's chosen palettes.

**`palette_tokens.dart`** — the design contract. Every UI color the app needs goes here. Keep it minimal; widget code reads from this, never from raw hex literals.

```dart
import 'package:flutter/material.dart';

@immutable
class PaletteTokens {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color onSurface;
  final Color onSurfaceMuted;

  final Color appBarBg;
  final Color appBarFg;

  final Color bottomNavBg;
  final Color bottomNavSelected;
  final Color bottomNavUnselected;

  final Color buttonBg;
  final Color buttonFg;
  final Color buttonDisabled;

  final Color textFieldFill;
  final Color textFieldBorder;
  final Color textFieldFocused;

  final Color success;
  final Color error;
  final Color warning;
  final Color divider;

  final Color shimmerBase;
  final Color shimmerHighlight;

  // Brand accents — used where a palette-specific element must keep its
  // identity regardless of the active palette (e.g. a "gold" badge on a
  // gold-product card stays gold even when the user picks "red").
  final Color goldAccent;
  final Color silverAccent;
  final Color diamondAccent;
  final Color redAccent;

  const PaletteTokens({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.appBarBg,
    required this.appBarFg,
    required this.bottomNavBg,
    required this.bottomNavSelected,
    required this.bottomNavUnselected,
    required this.buttonBg,
    required this.buttonFg,
    required this.buttonDisabled,
    required this.textFieldFill,
    required this.textFieldBorder,
    required this.textFieldFocused,
    required this.success,
    required this.error,
    required this.warning,
    required this.divider,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.goldAccent,
    required this.silverAccent,
    required this.diamondAccent,
    required this.redAccent,
  });

  // Required by ThemeExtension.lerp — animates color changes when MaterialApp
  // swaps themes. Static so palette files can also use it.
  static PaletteTokens lerp(PaletteTokens a, PaletteTokens b, double t) {
    return PaletteTokens(
      primary: Color.lerp(a.primary, b.primary, t)!,
      onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      onSecondary: Color.lerp(a.onSecondary, b.onSecondary, t)!,
      background: Color.lerp(a.background, b.background, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceElevated: Color.lerp(a.surfaceElevated, b.surfaceElevated, t)!,
      onSurface: Color.lerp(a.onSurface, b.onSurface, t)!,
      onSurfaceMuted: Color.lerp(a.onSurfaceMuted, b.onSurfaceMuted, t)!,
      appBarBg: Color.lerp(a.appBarBg, b.appBarBg, t)!,
      appBarFg: Color.lerp(a.appBarFg, b.appBarFg, t)!,
      bottomNavBg: Color.lerp(a.bottomNavBg, b.bottomNavBg, t)!,
      bottomNavSelected:
          Color.lerp(a.bottomNavSelected, b.bottomNavSelected, t)!,
      bottomNavUnselected:
          Color.lerp(a.bottomNavUnselected, b.bottomNavUnselected, t)!,
      buttonBg: Color.lerp(a.buttonBg, b.buttonBg, t)!,
      buttonFg: Color.lerp(a.buttonFg, b.buttonFg, t)!,
      buttonDisabled: Color.lerp(a.buttonDisabled, b.buttonDisabled, t)!,
      textFieldFill: Color.lerp(a.textFieldFill, b.textFieldFill, t)!,
      textFieldBorder: Color.lerp(a.textFieldBorder, b.textFieldBorder, t)!,
      textFieldFocused: Color.lerp(a.textFieldFocused, b.textFieldFocused, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      error: Color.lerp(a.error, b.error, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      divider: Color.lerp(a.divider, b.divider, t)!,
      shimmerBase: Color.lerp(a.shimmerBase, b.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(a.shimmerHighlight, b.shimmerHighlight, t)!,
      goldAccent: Color.lerp(a.goldAccent, b.goldAccent, t)!,
      silverAccent: Color.lerp(a.silverAccent, b.silverAccent, t)!,
      diamondAccent: Color.lerp(a.diamondAccent, b.diamondAccent, t)!,
      redAccent: Color.lerp(a.redAccent, b.redAccent, t)!,
    );
  }
}
```

If the target app uses a different naming convention (e.g. `Color cardBg` instead of `surfaceElevated`), adjust names but keep the contract complete: every place a screen wants to read a color must have a token here.

---

## Phase 2 — Build the palette × brightness matrix

Create `lib/core/theming/palettes/` and one file per palette. Each file exports three top-level `const PaletteTokens` — one per brightness.

Template — adapt the hex values per palette. The structure is identical for every palette:

```dart
// lib/core/theming/palettes/<name>_palette.dart
import 'package:flutter/material.dart';
import 'package:<your_app>/core/theming/palette_tokens.dart';

const _primary = Color(0xFFC9A04E);   // brand primary for this palette
const _primaryDeep = Color(0xFF986A3E); // darker shade
const _goldAccent = Color(0xFFC9A04E);
const _silverAccent = Color(0xFF8E9AAF);
const _diamondAccent = Color(0xFF7FB3D5);
const _redAccent = Color(0xFFC0392B);

const PaletteTokens <name>Light = PaletteTokens(
  primary: _primaryDeep,
  onPrimary: Color(0xFFFFFFFF),
  // ...
  goldAccent: _goldAccent,
  silverAccent: _silverAccent,
  diamondAccent: _diamondAccent,
  redAccent: _redAccent,
);

const PaletteTokens <name>Dark = PaletteTokens(/* … */);
const PaletteTokens <name>DeepDark = PaletteTokens(/* … */);
```

**Deep-dark guidance** (true OLED-friendly):
- `background: Color(0xFF000000)`
- `surface: Color(0xFF0A0A0A)`
- `surfaceElevated: Color(0xFF141414)`
- `divider: Color(0xFF1F1F1F)`

**Brand accents (`goldAccent`, `silverAccent`, etc.)** are intentionally identical across all palettes/brightnesses — they preserve identity for badge-like elements that should always look gold/silver/diamond/red regardless of the user's chosen palette.

**Resolver** — `palette_resolver.dart`:

```dart
import 'package:<your_app>/core/theming/app_brightness.dart';
import 'package:<your_app>/core/theming/app_palette.dart';
import 'package:<your_app>/core/theming/palette_tokens.dart';
import 'package:<your_app>/core/theming/palettes/gold_palette.dart';
// ... import each palette file

PaletteTokens resolvePalette(AppPalette palette, AppBrightness brightness) {
  switch (palette) {
    case AppPalette.gold:
      switch (brightness) {
        case AppBrightness.light:    return goldLight;
        case AppBrightness.dark:     return goldDark;
        case AppBrightness.deepDark: return goldDeepDark;
      }
    // ... one block per palette
  }
}
```

---

## Phase 3 — Theme builder + ThemeExtension

**`app_theme_ext.dart`** — exposes tokens via `Theme.of(context).extension<AppThemeExt>()`:

```dart
import 'package:flutter/material.dart';
import 'package:<your_app>/core/theming/palette_tokens.dart';

class AppThemeExt extends ThemeExtension<AppThemeExt> {
  final PaletteTokens tokens;
  const AppThemeExt(this.tokens);

  static AppThemeExt of(BuildContext context) =>
      Theme.of(context).extension<AppThemeExt>()!;

  @override
  AppThemeExt copyWith({PaletteTokens? tokens}) =>
      AppThemeExt(tokens ?? this.tokens);

  @override
  AppThemeExt lerp(ThemeExtension<AppThemeExt>? other, double t) {
    if (other is! AppThemeExt) return this;
    return AppThemeExt(PaletteTokens.lerp(tokens, other.tokens, t));
  }
}
```

**`themes.dart`** — `buildAppTheme()` is the single source of truth for every `ThemeData`. Replaces any existing `lightTheme` / `darkTheme` constants:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:<your_app>/core/theming/app_brightness.dart';
import 'package:<your_app>/core/theming/app_palette.dart';
import 'package:<your_app>/core/theming/app_theme_ext.dart';
import 'package:<your_app>/core/theming/colors.dart';
import 'package:<your_app>/core/theming/palette_resolver.dart';
import 'package:<your_app>/core/theming/palette_tokens.dart';

ThemeData buildAppTheme({
  required AppPalette palette,
  required AppBrightness brightness,
}) {
  final tokens = resolvePalette(palette, brightness);
  // CRITICAL: refresh the legacy AppColors facade so widgets that still read
  // AppColors.xxx pick up the active palette on the next rebuild.
  AppColors.apply(tokens);

  final isDark = brightness.isDark;
  final base = isDark ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: tokens.background,
    primaryColor: tokens.primary,
    canvasColor: tokens.background,
    dividerColor: tokens.divider,
    colorScheme:
        (isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      secondary: tokens.secondary,
      onSecondary: tokens.onSecondary,
      surface: tokens.surface,
      onSurface: tokens.onSurface,
      error: tokens.error,
    ),
    progressIndicatorTheme:
        ProgressIndicatorThemeData(color: tokens.primary),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: tokens.appBarFg),
      actionsIconTheme: IconThemeData(color: tokens.appBarFg),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: tokens.bottomNavBg,
      selectedItemColor: tokens.bottomNavSelected,
      unselectedItemColor: tokens.bottomNavUnselected,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tokens.buttonBg,
        foregroundColor: tokens.buttonFg,
        disabledBackgroundColor: tokens.buttonDisabled,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: tokens.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tokens.primary,
        side: BorderSide(color: tokens.primary),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.textFieldFill,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: tokens.textFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: tokens.textFieldFocused, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: tokens.error),
      ),
      labelStyle: TextStyle(color: tokens.onSurfaceMuted),
      hintStyle: TextStyle(color: tokens.onSurfaceMuted),
    ),
    cardTheme: CardThemeData(
      color: tokens.surface,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(color: tokens.divider, thickness: 1),
    extensions: <ThemeExtension<dynamic>>[AppThemeExt(tokens)],
  );
}

PaletteTokens tokensOf(BuildContext context) =>
    AppThemeExt.of(context).tokens;
```

Preserve any custom font / typography theming the app already has; the snippet above intentionally omits it for clarity.

---

## Phase 4 — The dynamic `AppColors` facade (the key trick)

This is the most important step. **Without this, only the settings screen will recolor — every existing widget that reads `AppColors.primaryColor` will stay frozen.**

**The problem.** Most Flutter apps have a class like:

```dart
class AppColors {
  static const Color primaryColor = Color(0xFF986A3E);
  static const Color buttonColor = Color(0xFFE0BBB3);
  // ... 50+ static const Color fields
}
```

`static const` means compile-time constant. There is no way to change them at runtime.

**The fix.** Convert `AppColors` from `static const` to mutable `static Color` fields, populated by an `apply(tokens)` method that the theme builder calls on every rebuild.

```dart
import 'package:flutter/material.dart';
import 'package:<your_app>/core/theming/palette_tokens.dart';
import 'package:<your_app>/core/theming/palettes/gold_palette.dart'; // or whichever palette is the default

/// Palette-driven runtime colors.
///
/// Fields are populated from the active [PaletteTokens] via [apply], which is
/// called by the theme builder whenever brightness or palette changes.
///
/// IMPORTANT: these are intentionally NOT `const`. Do not place them inside
/// `const` constructors — drop the `const` keyword on the surrounding
/// expression instead.
class AppColors {
  AppColors._();

  static void apply(PaletteTokens tokens) {
    primaryColor = tokens.primary;
    buttonColor = tokens.buttonBg;
    // ... map every existing AppColors field to its closest token
  }

  // Initialised from the default palette so first-paint is correct
  // before apply() runs.
  static Color primaryColor = goldLight.primary;
  static Color buttonColor = goldLight.buttonBg;
  // ... one static field per existing AppColors entry
}
```

**Mapping legacy fields to tokens.** Find every name the existing `AppColors` defines, then map to the closest semantic token. Common patterns:

| Legacy field | Maps to |
|---|---|
| `primaryColor`, `accentColor`, `brandColor` | `tokens.primary` |
| `buttonColor` | `tokens.buttonBg` |
| `scaffoldBackground`, `bgColor`, `*BackgroundColor` | `tokens.background` |
| `containerColor`, `cardColor`, `*ContainerColor` | `tokens.surface` |
| `elevatedContainerColor` | `tokens.surfaceElevated` |
| `errorColor`, `redColor` | `tokens.error` |
| `successColor`, `greenColor` | `tokens.success` |
| `warningColor`, `yellowColor` | `tokens.warning` |
| `bodyText*`, `darkText*`, `lightText*` | `tokens.onSurface` (or `onSurfaceMuted` for greys) |
| `bottomNav*Background` | `tokens.bottomNavBg` |
| Brand-specific (`goldColor`, `darkBrown`, etc.) | `tokens.primary` (so they follow the user's palette) |

When the user picks "red" palette, `AppColors.primaryColor` returns red, `AppColors.darkBrown` returns red, etc. Every widget reading these gets the new value on next rebuild.

**Find every used field with**:

```bash
grep -rho "AppColors\.[a-zA-Z_][a-zA-Z0-9_]*" lib --include="*.dart" | sort -u
```

Make sure every name in that list has both an `apply()` line and a default-value line in the rewritten `AppColors`.

---

## Phase 5 — Fix `const` call-sites that block the conversion

After step 4, the analyzer will report many errors like:

- `Invalid constant value` — at lines like `const BorderSide(color: AppColors.primaryColor)`
- `Const variables must be initialized with a constant value` — at lines like `const accent = AppColors.goldColor;`
- `The values in a const list literal must be constants` — at lines like `const [AppColors.darkBrown, AppColors.goldColor]`

These can't compile because `AppColors.xxx` is no longer `const`. Find them all with:

```bash
flutter analyze --no-pub lib/ 2>&1 | grep -E "^\s+error\s+•" > /tmp/errors.txt
cat /tmp/errors.txt
```

Fix each one by **removing the `const` keyword** at that exact location. Examples:

```dart
// Before
borderSide: const BorderSide(color: AppColors.darkBrown),
// After
borderSide: BorderSide(color: AppColors.darkBrown),

// Before
const accentColor = AppColors.goldColor;
// After
final accentColor = AppColors.goldColor;

// Before
gradient: const LinearGradient(colors: [AppColors.darkBrown, AppColors.goldColor]),
// After (drop only the outer `const`; the list literal becomes implicit)
gradient: LinearGradient(colors: [AppColors.darkBrown, AppColors.goldColor]),

// Before
colorFilter: const ColorFilter.mode(AppColors.errorColor, BlendMode.srcIn),
// After
colorFilter: ColorFilter.mode(AppColors.errorColor, BlendMode.srcIn),
```

Re-run `flutter analyze` until errors are zero. **Do not** convert these to `tokensOf(context)` unless the surrounding code already has access to a `BuildContext` and the file is small — for the bulk of the migration, just dropping `const` is enough because `AppColors.apply(tokens)` keeps the legacy field values fresh.

---

## Phase 6 — Settings cubit + persistence + MaterialApp wiring

Adapt this to the app's existing state management. Cubit example:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:<your_app>/core/cache_helper/cache_helper.dart';
import 'package:<your_app>/core/cache_helper/cache_values.dart';
import 'package:<your_app>/core/theming/app_brightness.dart';
import 'package:<your_app>/core/theming/app_palette.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsStates> {
  SettingsCubit() : super(SettingsInitial());

  AppBrightness brightness = AppBrightness.light;
  AppPalette palette = AppPalette.gold;

  void hydrateFromCache() {
    final brightnessName =
        CacheHelper.getData(key: CacheKeys.appBrightness) as String?;
    final paletteName =
        CacheHelper.getData(key: CacheKeys.appPalette) as String?;
    brightness = AppBrightness.fromName(brightnessName);
    palette = AppPalette.fromName(paletteName);
    emit(ThemeChanged(brightness: brightness, palette: palette));
  }

  Future<void> changeBrightness(AppBrightness next) async {
    brightness = next;
    await CacheHelper.saveData(
        key: CacheKeys.appBrightness, value: next.name);
    emit(ThemeChanged(brightness: brightness, palette: palette));
  }

  Future<void> changePalette(AppPalette next) async {
    palette = next;
    await CacheHelper.saveData(key: CacheKeys.appPalette, value: next.name);
    emit(ThemeChanged(brightness: brightness, palette: palette));
  }
}
```

```dart
// settings_state.dart
part of 'settings_cubit.dart';

sealed class SettingsStates extends Equatable {
  const SettingsStates();
  @override List<Object> get props => [];
}

final class SettingsInitial extends SettingsStates {}

final class ThemeChanged extends SettingsStates {
  final AppBrightness brightness;
  final AppPalette palette;
  const ThemeChanged({required this.brightness, required this.palette});
  @override List<Object> get props => [brightness, palette];
}
```

**If the app uses Riverpod**, replace the cubit with two `StateNotifierProvider`s — one for brightness, one for palette — both reading/writing the same persistence keys.

**If the app uses Provider/GetX/setState**, the same logic applies; the only requirement is that whatever holds brightness+palette can trigger a `MaterialApp` rebuild.

**Persistence keys** — add to whichever cache key class the app uses (e.g. `CacheKeys`):

```dart
static const String appBrightness = "appBrightness";
static const String appPalette = "appPalette";
```

**`MaterialApp` wiring** — find the existing `MaterialApp(...)` and replace its `theme:`/`darkTheme:`/`themeMode:` with a single `theme:` driven by the cubit:

```dart
// In whichever widget owns the MaterialApp:
return BlocProvider(
  create: (_) => SettingsCubit()..hydrateFromCache(),
  child: BlocConsumer<SettingsCubit, SettingsStates>(
    listener: (_, __) {},
    buildWhen: (_, c) => c is ThemeChanged,
    builder: (context, _) {
      final cubit = context.read<SettingsCubit>();
      return MaterialApp(
        // ... all existing MaterialApp params kept …
        theme: buildAppTheme(
          palette: cubit.palette,
          brightness: cubit.brightness,
        ),
      );
    },
  ),
);
```

Drop the old `darkTheme:` and `themeMode:` parameters — the builder owns them now. Keep `EasyLocalization`/locale wiring intact if the app uses it.

---

## Phase 7 — Settings screen UI

Three pieces — adapt to the app's existing widget conventions (font helpers, sizing utilities like `flutter_screenutil`, etc.).

### 7.1 — Brightness picker

Three tappable tiles, each showing a real preview background of the brightness it represents:

```dart
class BrightnessPicker extends StatelessWidget {
  final AppBrightness selected;
  final ValueChanged<AppBrightness> onChanged;
  const BrightnessPicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final mode in AppBrightness.values)
          Expanded(
            child: _BrightnessTile(
              mode: mode,
              isSelected: mode == selected,
              onTap: () => onChanged(mode),
            ),
          ),
      ],
    );
  }
}
```

For `_BrightnessTile`: use a hardcoded preview background (`#FDF7EF` light, `#1C2B24` dark, `#000000` deep-dark) so the user sees what they're choosing regardless of currently active palette.

### 7.2 — Palette picker

A 2×2 grid where each tile renders the palette's actual primary/secondary/elevated colors as swatches, plus the palette name. Use `resolvePalette(palette, currentBrightness)` to render the swatches in the user's current brightness.

```dart
class PalettePicker extends StatelessWidget {
  final AppPalette selected;
  final AppBrightness brightness;
  final ValueChanged<AppPalette> onChanged;
  const PalettePicker({
    super.key,
    required this.selected,
    required this.brightness,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      children: [
        for (final p in AppPalette.values)
          _PaletteTile(
            palette: p,
            preview: resolvePalette(p, brightness),
            isSelected: p == selected,
            onTap: () => onChanged(p),
          ),
      ],
    );
  }
}
```

### 7.3 — Live preview card

A small card showing primary button + chip + body text rendered with the currently active tokens, so the user sees the effect of their choice instantly.

### 7.4 — Settings screen

```dart
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsStates>(
      buildWhen: (_, c) => c is ThemeChanged,
      builder: (context, _) {
        final cubit = context.read<SettingsCubit>();
        return Scaffold(
          appBar: AppBar(title: Text('settings.title'.tr())),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ThemePreviewCard(),
                  const SizedBox(height: 24),
                  Text('settings.appearance'.tr()),
                  const SizedBox(height: 12),
                  BrightnessPicker(
                    selected: cubit.brightness,
                    onChanged: cubit.changeBrightness,
                  ),
                  const SizedBox(height: 24),
                  Text('settings.colorPalette'.tr()),
                  const SizedBox(height: 12),
                  PalettePicker(
                    selected: cubit.palette,
                    brightness: cubit.brightness,
                    onChanged: cubit.changePalette,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

### 7.5 — Wire the route + entry point

Add the screen to the app's routing system. Add a navigation entry from a sensible place (profile screen item, drawer item, etc.) — match existing entry-style conventions exactly.

### 7.6 — Localization keys

If the app uses EasyLocalization or any JSON i18n, add these keys to **every language file**:

```json
"settings": {
    "title": "Theme & Appearance",
    "appearance": "Brightness",
    "colorPalette": "Color Palette",
    "light": "Light",
    "dark": "Dark",
    "deepDark": "Deep Dark",
    "paletteGold": "Gold",
    "paletteSilver": "Silver",
    "paletteDiamond": "Diamond",
    "paletteRed": "Red",
    "preview": "PREVIEW",
    "previewButton": "Primary action",
    "previewChip": "Chip",
    "previewBody": "This is how text looks in your selected theme."
}
```

**Watch for duplicate top-level `settings` keys** — many apps have a pre-existing `settings` block with unrelated entries. Merge into that existing block instead of adding a second one (the analyzer will report duplicate object keys).

If the app has no localization, hardcode English strings.

---

## Brand-locked assets (PDFs / receipts / share images)

If step 0 question 4 was "stay locked": leave any PDF/receipt color constants as-is. They are intentionally not theme-aware.

If "follow palette": pass the current `PaletteTokens` (or just `AppPalette` + `AppBrightness`) into the PDF generator and convert tokens to `PdfColor.fromInt(token.value)` at the point of use.

---

## Verification checklist

1. ✅ `flutter analyze --no-pub lib/ 2>&1 | grep -E "^\s+error\s+•"` returns **zero** lines.
2. ✅ `flutter build apk --debug` (or platform equivalent) succeeds.
3. ✅ Open the app cold → default combo applies (e.g. gold + light).
4. ✅ Navigate to settings → tap each brightness tile → entire app recolors instantly, not just the settings screen.
5. ✅ Tap each palette tile → primary buttons, app bars, scaffolds, bottom nav, and any custom widgets that previously read `AppColors.xxx` all show the new palette color.
6. ✅ Kill the app and reopen → previous combo persists.
7. ✅ Smoke-test a screen you didn't migrate by hand. If a hard-coded `Color(0xFF...)` still shows the old color, that's expected — only the legacy `AppColors.xxx` references auto-follow. Either:
   - Migrate that specific call-site to `tokensOf(context).whatever`, or
   - Add the hex literal as a new field on `AppColors` and let `apply()` map it.

---

## Common pitfalls

1. **"Only the settings screen recolors."** You forgot Phase 4 (the dynamic `AppColors` facade) or `buildAppTheme` doesn't call `AppColors.apply(tokens)`. Recheck both.
2. **`Invalid constant value` errors after Phase 4.** Expected. Phase 5 fixes them by dropping `const` from the offending lines.
3. **`MaterialApp` doesn't rebuild on palette change.** Make sure `buildWhen` includes the relevant state, or that the parent of `MaterialApp` is wrapped in the state-management subscription. With Cubit/Bloc: use `BlocConsumer` with `buildWhen: (_, c) => c is ThemeChanged`.
4. **First frame shows wrong palette.** The cubit hadn't hydrated yet. Ensure `..hydrateFromCache()` is chained on the cubit's creation, or call it synchronously in `main()` before `runApp`.
5. **Locale toggling races with theme rebuild.** If the app uses EasyLocalization, do **not** rebuild `MaterialApp` for locale-related states — let EasyLocalization handle that internally. Filter `buildWhen` strictly to `ThemeChanged`.
6. **Duplicate `settings` JSON keys.** Pre-existing settings blocks in language files. Merge, don't append.
7. **`useMaterial3: true` deprecation hint.** Don't pass it explicitly — `ThemeData.dark()` / `.light()` already default to Material 3 in current Flutter. Drop the parameter.
8. **`withOpacity` deprecation infos.** Pre-existing in most apps. Match the codebase's existing conventions; don't migrate unless asked.

---

## Files you will create or modify

Create:
- `lib/core/theming/app_brightness.dart`
- `lib/core/theming/app_palette.dart`
- `lib/core/theming/palette_tokens.dart`
- `lib/core/theming/app_theme_ext.dart`
- `lib/core/theming/palette_resolver.dart`
- `lib/core/theming/palettes/<each>_palette.dart`
- `lib/features/settings/presentation/ui/settings_screen.dart` (or wherever the app puts feature screens)
- `lib/features/settings/presentation/ui/widgets/brightness_picker.dart`
- `lib/features/settings/presentation/ui/widgets/palette_picker.dart`
- `lib/features/settings/presentation/ui/widgets/theme_preview_card.dart`

Modify:
- `lib/core/theming/colors.dart` (or whatever the legacy color class is) — convert to dynamic facade
- `lib/core/theming/themes.dart` — replace static themes with `buildAppTheme`
- The settings cubit / state holder + cache keys
- The widget that owns `MaterialApp`
- Routing — register the new settings screen
- One existing screen — add navigation entry to the new settings screen
- Every language file — add the `settings.*` keys
- ~10–30 widget files with `const … AppColors.xxx` references — drop the `const`

Total file count varies by app size. For a small app (~20 features) expect ~15 new files and ~20–40 modified files.

---

## Summary for the Claude reading this in another project

1. Read this whole file before starting.
2. Run the prerequisite investigation (5 min).
3. Confirm the four decisions with the user; defaults in parentheses if they say "decide for me".
4. Execute phases 1–7 in order. Phase 4 is the load-bearing one — don't skip the dynamic `AppColors` facade.
5. After Phase 4, run `flutter analyze` and fix every `const`-related error in Phase 5.
6. Verify with the 7-point checklist.
7. If a screen still shows old colors after switching, find the hex literal or untracked color reference and either tokenize it or add it to `AppColors`.

If a step doesn't apply (no localization, different state management, no PDF assets), adapt the spirit of the step rather than skipping it.
