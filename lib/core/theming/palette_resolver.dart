import 'package:kenooz_worker_app/core/theming/app_brightness.dart';
import 'package:kenooz_worker_app/core/theming/app_palette.dart';
import 'package:kenooz_worker_app/core/theming/palette_tokens.dart';
import 'package:kenooz_worker_app/core/theming/palettes/diamond_palette.dart';
import 'package:kenooz_worker_app/core/theming/palettes/gold_palette.dart';
import 'package:kenooz_worker_app/core/theming/palettes/red_palette.dart';
import 'package:kenooz_worker_app/core/theming/palettes/silver_palette.dart';

PaletteTokens resolvePalette(AppPalette palette, AppBrightness brightness) {
  switch (palette) {
    case AppPalette.gold:
      switch (brightness) {
        case AppBrightness.light:
          return goldLight;
        case AppBrightness.dark:
          return goldDark;
        case AppBrightness.deepDark:
          return goldDeepDark;
      }
    case AppPalette.silver:
      switch (brightness) {
        case AppBrightness.light:
          return silverLight;
        case AppBrightness.dark:
          return silverDark;
        case AppBrightness.deepDark:
          return silverDeepDark;
      }
    case AppPalette.diamond:
      switch (brightness) {
        case AppBrightness.light:
          return diamondLight;
        case AppBrightness.dark:
          return diamondDark;
        case AppBrightness.deepDark:
          return diamondDeepDark;
      }
    case AppPalette.red:
      switch (brightness) {
        case AppBrightness.light:
          return redLight;
        case AppBrightness.dark:
          return redDark;
        case AppBrightness.deepDark:
          return redDeepDark;
      }
  }
}
