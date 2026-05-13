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
