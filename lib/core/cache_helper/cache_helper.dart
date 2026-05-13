import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kenooz_worker_app/core/config/branch_model.dart';
import 'package:kenooz_worker_app/core/config/branches.dart';
import 'package:kenooz_worker_app/core/platform/app_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cache_values.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static dynamic getData({
    required String key,
  }) {
    return sharedPreferences.get(key);
  }

  static bool isEnglish() => getCurrentLanguage() == "en";

  static void changeLanguageToEn() async {
    await CacheHelper.saveData(key: CacheKeys.currentLanguage, value: "en");
  }

  static String getCurrentLanguage() {
    return CacheHelper.getData(
          key: CacheKeys.currentLanguage,
        ) ??
        "en";
  }

  static void changeLanguageToAr() async {
    await CacheHelper.saveData(key: CacheKeys.currentLanguage, value: "ar");
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return await sharedPreferences.setString(key, value);
    if (value is int) return await sharedPreferences.setInt(key, value);
    if (value is bool) return await sharedPreferences.setBool(key, value);

    return await sharedPreferences.setDouble(key, value);
  }

  static Future<bool> removeData({
    required String key,
  }) async {
    return await sharedPreferences.remove(key);
  }

  static Future<bool> clearAllData() async {
    return await sharedPreferences.clear();
  }

  /// Prefix applied to SharedPreferences entries that mirror secure-storage
  /// writes on desktop, where unsigned dev builds cannot reach the keychain.
  static const String _securedPrefix = 'sec_';

  /// Whether to use the OS keychain (mobile) or fall back to SharedPreferences
  /// (desktop). `flutter_secure_storage` cannot write to the macOS keychain
  /// without a real signing identity, so dev builds need the fallback.
  static bool get _useKeychain => AppPlatform.isMobile;

  /// Saves a [value] with a [key] in the FlutterSecureStorage (or a
  /// prefixed SharedPreferences entry on desktop).
  static Future<void> setSecuredString(String key, String value) async {
    if (_useKeychain) {
      const flutterSecureStorage = FlutterSecureStorage();
      await flutterSecureStorage.write(key: key, value: value);
      return;
    }
    await sharedPreferences.setString('$_securedPrefix$key', value);
  }

  /// Gets a String value from FlutterSecureStorage (or its desktop fallback)
  /// for the given [key]. Returns an empty string when nothing is stored.
  static Future<String> getSecuredString(String key) async {
    if (_useKeychain) {
      const flutterSecureStorage = FlutterSecureStorage();
      return await flutterSecureStorage.read(key: key) ?? '';
    }
    return sharedPreferences.getString('$_securedPrefix$key') ?? '';
  }

  /// Removes all keys and values from the FlutterSecureStorage (or every
  /// `_securedPrefix`-prefixed SharedPreferences entry on desktop).
  static Future<void> clearAllSecuredData() async {
    if (_useKeychain) {
      const flutterSecureStorage = FlutterSecureStorage();
      await flutterSecureStorage.deleteAll();
      return;
    }
    final keys = sharedPreferences
        .getKeys()
        .where((k) => k.startsWith(_securedPrefix))
        .toList();
    for (final k in keys) {
      await sharedPreferences.remove(k);
    }
  }

  // ── Branch management ───────────────────────────────────────────────────

  /// Returns the saved branch, or `null` if none has been selected yet.
  static BranchModel? getSavedBranch() {
    final id = getData(key: CacheKeys.selectedBranchId) as int?;
    if (id == null) return null;
    return Branches.getById(id);
  }

  /// Persists the selected branch.
  static Future<bool> saveBranch(BranchModel branch) async {
    return saveData(key: CacheKeys.selectedBranchId, value: branch.id);
  }

  /// Clears the saved branch selection.
  static Future<bool> clearBranch() async {
    return removeData(key: CacheKeys.selectedBranchId);
  }

  /// Clears authentication data but preserves biometric credentials (email/password)
  /// Use this for logout and token expiration scenarios so biometric login survives.
  static Future<void> clearAuthDataPreservingBiometric() async {
    if (_useKeychain) {
      const flutterSecureStorage = FlutterSecureStorage();
      // Only delete the token — keep userEmail & userPassword for biometric login.
      await flutterSecureStorage.delete(key: CacheKeys.userToken);
    } else {
      await sharedPreferences.remove('$_securedPrefix${CacheKeys.userToken}');
    }

    // Clear non-secure auth data; keep language, theme, branch, and biometric flag.
    await sharedPreferences.remove(CacheKeys.userId);
    await sharedPreferences.remove(CacheKeys.isAdmin);
    await sharedPreferences.remove(CacheKeys.cartShopId);
    await sharedPreferences.remove(CacheKeys.defaultAddressId);
  }
}
