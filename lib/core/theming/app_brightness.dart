enum AppBrightness {
  light,
  dark,
  deepDark;

  bool get isLight => this == AppBrightness.light;
  bool get isDark => this == AppBrightness.dark || this == AppBrightness.deepDark;

  static AppBrightness fromName(String? name) {
    return AppBrightness.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppBrightness.light,
    );
  }
}
