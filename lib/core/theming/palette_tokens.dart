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

  PaletteTokens copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? appBarBg,
    Color? appBarFg,
    Color? bottomNavBg,
    Color? bottomNavSelected,
    Color? bottomNavUnselected,
    Color? buttonBg,
    Color? buttonFg,
    Color? buttonDisabled,
    Color? textFieldFill,
    Color? textFieldBorder,
    Color? textFieldFocused,
    Color? success,
    Color? error,
    Color? warning,
    Color? divider,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? goldAccent,
    Color? silverAccent,
    Color? diamondAccent,
    Color? redAccent,
  }) {
    return PaletteTokens(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      appBarBg: appBarBg ?? this.appBarBg,
      appBarFg: appBarFg ?? this.appBarFg,
      bottomNavBg: bottomNavBg ?? this.bottomNavBg,
      bottomNavSelected: bottomNavSelected ?? this.bottomNavSelected,
      bottomNavUnselected: bottomNavUnselected ?? this.bottomNavUnselected,
      buttonBg: buttonBg ?? this.buttonBg,
      buttonFg: buttonFg ?? this.buttonFg,
      buttonDisabled: buttonDisabled ?? this.buttonDisabled,
      textFieldFill: textFieldFill ?? this.textFieldFill,
      textFieldBorder: textFieldBorder ?? this.textFieldBorder,
      textFieldFocused: textFieldFocused ?? this.textFieldFocused,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      divider: divider ?? this.divider,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      goldAccent: goldAccent ?? this.goldAccent,
      silverAccent: silverAccent ?? this.silverAccent,
      diamondAccent: diamondAccent ?? this.diamondAccent,
      redAccent: redAccent ?? this.redAccent,
    );
  }

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
      bottomNavSelected: Color.lerp(a.bottomNavSelected, b.bottomNavSelected, t)!,
      bottomNavUnselected: Color.lerp(a.bottomNavUnselected, b.bottomNavUnselected, t)!,
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
      shimmerHighlight: Color.lerp(a.shimmerHighlight, b.shimmerHighlight, t)!,
      goldAccent: Color.lerp(a.goldAccent, b.goldAccent, t)!,
      silverAccent: Color.lerp(a.silverAccent, b.silverAccent, t)!,
      diamondAccent: Color.lerp(a.diamondAccent, b.diamondAccent, t)!,
      redAccent: Color.lerp(a.redAccent, b.redAccent, t)!,
    );
  }
}
