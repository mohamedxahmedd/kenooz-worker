import 'package:flutter/material.dart';
import 'package:kenooz_worker_app/core/theming/palette_tokens.dart';

class AppThemeExt extends ThemeExtension<AppThemeExt> {
  final PaletteTokens tokens;

  const AppThemeExt(this.tokens);

  static AppThemeExt of(BuildContext context) {
    return Theme.of(context).extension<AppThemeExt>()!;
  }

  @override
  AppThemeExt copyWith({PaletteTokens? tokens}) {
    return AppThemeExt(tokens ?? this.tokens);
  }

  @override
  AppThemeExt lerp(ThemeExtension<AppThemeExt>? other, double t) {
    if (other is! AppThemeExt) return this;
    return AppThemeExt(PaletteTokens.lerp(tokens, other.tokens, t));
  }
}
