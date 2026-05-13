part of 'settings_cubit.dart';

sealed class SettingsStates extends Equatable {
  const SettingsStates();

  @override
  List<Object> get props => [];
}

final class SettingsInitial extends SettingsStates {}

final class LocalizationLoading extends SettingsStates {}

final class LocalizationChange extends SettingsStates {}

final class ThemeChanged extends SettingsStates {
  final AppBrightness brightness;
  final AppPalette palette;
  const ThemeChanged({required this.brightness, required this.palette});

  bool get isDark => brightness.isDark;

  @override
  List<Object> get props => [brightness, palette];
}
