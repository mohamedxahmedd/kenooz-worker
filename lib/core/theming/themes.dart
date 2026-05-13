import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenooz_worker_app/core/theming/app_brightness.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/app_palette.dart';
import 'package:kenooz_worker_app/core/theming/app_theme_ext.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/palette_resolver.dart';
import 'package:kenooz_worker_app/core/theming/palette_tokens.dart';

ThemeData buildAppTheme({
  required AppPalette palette,
  required AppBrightness brightness,
}) {
  final tokens = resolvePalette(palette, brightness);
  // Refresh runtime AppColors so legacy widgets that still read AppColors.xxx
  // pick up the active palette on the next rebuild.
  AppColors.apply(tokens);
  final isDark = brightness.isDark;
  final base = isDark ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: tokens.background,
    primaryColor: tokens.primary,
    canvasColor: tokens.background,
    dividerColor: tokens.divider,
    textTheme: AppFonts.textTheme(base.textTheme),
    colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light())
        .copyWith(
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      secondary: tokens.secondary,
      onSecondary: tokens.onSecondary,
      surface: tokens.surface,
      onSurface: tokens.onSurface,
      error: tokens.error,
      onError: Colors.white,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: tokens.primary,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      backgroundColor: Colors.transparent,
      titleTextStyle: AppFonts.heading(
        fontSize: isDark ? 25 : 22,
        fontWeight: isDark ? FontWeight.bold : FontWeight.w600,
        color: tokens.appBarFg,
      ),
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

PaletteTokens tokensOf(BuildContext context) => AppThemeExt.of(context).tokens;

// Legacy fallbacks — preserved so any pre-migration imports continue to compile.
// New code must use `buildAppTheme(...)` and read colors from Theme.of(context).
final ThemeData lightTheme = buildAppTheme(
  palette: AppPalette.gold,
  brightness: AppBrightness.light,
);

final ThemeData darkTheme = buildAppTheme(
  palette: AppPalette.gold,
  brightness: AppBrightness.dark,
);

final MaterialColor customSwatch = createMaterialColor(AppColors.primaryColor);

MaterialColor createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final swatch = <int, Color>{};
  // ignore: deprecated_member_use
  final int r = color.red, g = color.green, b = color.blue;

  for (var i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  // ignore: deprecated_member_use
  return MaterialColor(color.value, swatch);
}
