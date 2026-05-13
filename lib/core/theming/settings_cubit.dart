import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/theming/app_brightness.dart';
import 'package:kenooz_worker_app/core/theming/app_palette.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsStates> {
  SettingsCubit() : super(SettingsInitial());
  static SettingsCubit get(context) => BlocProvider.of(context);

  AppBrightness brightness = AppBrightness.light;
  AppPalette palette = AppPalette.gold;

  bool get isDark => brightness.isDark;

  Future<void> changeLanguage({
    required BuildContext context,
    required String lang,
    required String country,
  }) async {
    emit(LocalizationLoading());
    (lang == 'ar')
        ? CacheHelper.changeLanguageToAr()
        : CacheHelper.changeLanguageToEn();
    await EasyLocalization.of(context)!.setLocale(Locale(lang, country));
    emit(LocalizationChange());
  }

  void hydrateFromCache() {
    final brightnessName =
        CacheHelper.getData(key: CacheKeys.appBrightness) as String?;
    final paletteName =
        CacheHelper.getData(key: CacheKeys.appPalette) as String?;

    if (brightnessName != null) {
      brightness = AppBrightness.fromName(brightnessName);
    } else {
      // Migrate legacy `isDark` boolean if present.
      final legacyIsDark = CacheHelper.getData(key: CacheKeys.isDark) as bool?;
      brightness = (legacyIsDark ?? false) ? AppBrightness.dark : AppBrightness.light;
    }

    palette = AppPalette.fromName(paletteName);
    emit(ThemeChanged(brightness: brightness, palette: palette));
  }

  Future<void> changeBrightness(AppBrightness next) async {
    brightness = next;
    await CacheHelper.saveData(
      key: CacheKeys.appBrightness,
      value: next.name,
    );
    // Keep legacy key in sync so any unmigrated reader still works.
    await CacheHelper.saveData(key: CacheKeys.isDark, value: next.isDark);
    emit(ThemeChanged(brightness: brightness, palette: palette));
  }

  Future<void> changePalette(AppPalette next) async {
    palette = next;
    await CacheHelper.saveData(key: CacheKeys.appPalette, value: next.name);
    emit(ThemeChanged(brightness: brightness, palette: palette));
  }
}
