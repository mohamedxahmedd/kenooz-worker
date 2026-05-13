import 'package:flutter/material.dart';
import 'package:kenooz_worker_app/core/theming/palette_tokens.dart';
import 'package:kenooz_worker_app/core/theming/palettes/gold_palette.dart';

/// Palette-driven runtime colors.
///
/// Fields are populated from the active [PaletteTokens] via [apply], which is
/// called by the theme builder whenever brightness or palette changes. Every
/// rebuild after that picks up the new values, so existing widgets that read
/// `AppColors.xxx` automatically follow the selected theme.
///
/// IMPORTANT: these are intentionally NOT `const`. Do not place them inside
/// `const` constructors — drop the `const` keyword on the surrounding
/// expression instead.
class AppColors {
  AppColors._();

  static void apply(PaletteTokens tokens) {
    primaryColor = tokens.primary;
    buttonColor = tokens.buttonBg;
    greenColor = tokens.primary;
    darkBrown = tokens.primary;
    goldColor = tokens.primary;
    silverColor = tokens.primary;
    creamyColor = tokens.surfaceElevated;
    backGroundColorLight = tokens.background;
    secondryColor = tokens.surfaceElevated;
    scaffoldBackground = tokens.background;
    bottomNavLightThemeBackground = tokens.bottomNavBg;
    bottomNavDarkThemeBackground = tokens.bottomNavBg;
    lightThemeBackgroundColor = tokens.background;
    darkThemeBackgroundColor = tokens.background;
    darkThemeContainerColor = tokens.surface;
    darkThemeContainerColorElevated = tokens.surfaceElevated;
    darkThemeTextFieldFillColor = tokens.textFieldFill;
    lightTextColorForDarkMood = tokens.onSurface;
    textGreyColor = tokens.onSurfaceMuted;
    darkGreyTextColor = tokens.onSurfaceMuted;
    homeHeadersLightThemeColor = tokens.primary;
    lightBlueFillColor = tokens.surfaceElevated;
    successColor = tokens.success;
    errorColor = tokens.error;
    yellowColor = tokens.warning;
  }

  // Initialised from the default gold-light palette so any code path that
  // reads colors before `apply` has run still gets sane values.
  static Color primaryColor = goldLight.primary;
  static Color buttonColor = goldLight.buttonBg;
  static Color greenColor = goldLight.primary;
  static Color darkBrown = goldLight.primary;
  static Color goldColor = goldLight.primary;
  static Color silverColor = goldLight.primary;
  static Color creamyColor = goldLight.surfaceElevated;
  static Color backGroundColorLight = goldLight.background;
  static Color secondryColor = goldLight.surfaceElevated;
  static Color scaffoldBackground = goldLight.background;
  static Color bottomNavLightThemeBackground = goldLight.bottomNavBg;
  static Color bottomNavDarkThemeBackground = goldLight.bottomNavBg;
  static Color lightThemeBackgroundColor = goldLight.background;
  static Color darkThemeBackgroundColor = goldLight.background;
  static Color darkThemeContainerColor = goldLight.surface;
  static Color darkThemeContainerColorElevated = goldLight.surfaceElevated;
  static Color darkThemeTextFieldFillColor = goldLight.textFieldFill;
  static Color lightTextColorForDarkMood = goldLight.onSurface;
  static Color textGreyColor = goldLight.onSurfaceMuted;
  static Color darkGreyTextColor = goldLight.onSurfaceMuted;
  static Color homeHeadersLightThemeColor = goldLight.primary;
  static Color lightBlueFillColor = goldLight.surfaceElevated;
  static Color successColor = goldLight.success;
  static Color errorColor = goldLight.error;
  static Color yellowColor = goldLight.warning;
}
