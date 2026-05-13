import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/config/branches.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/network/dio_factory.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';

/// Singleton that manages the entire token lifecycle:
///
/// 1. **Reactive refresh** — called by [TokenRefreshInterceptor] when a 401
///    arrives. Uses a [Completer]-based lock so concurrent 401s don't fire
///    multiple refresh requests.
///
/// 2. **Proactive refresh** — a [Timer] that fires ~5 minutes before the
///    token expires, keeping the session alive transparently.
///
/// 3. **Forced logout** — when the refresh endpoint itself fails (401/error),
///    clears all auth data and navigates to the login screen via the global
///    [navigatorKey].
///
/// A **dedicated [Dio] instance** (`_refreshDio`) is used for the refresh call
/// to avoid triggering the interceptor on the main Dio (which would cause an
/// infinite loop).
class TokenManager {
  // ── Singleton ────────────────────────────────────────────────────────────
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  // ── Dedicated Dio for refresh (no interceptors) ──────────────────────────
  Dio? _refreshDio;

  /// Resolves the current branch's base URL from the cache.
  String get _currentBaseUrl {
    final branch = CacheHelper.getSavedBranch();
    return branch?.baseUrl ?? Branches.defaultBranch.baseUrl;
  }

  Dio get _dio {
    final url = _currentBaseUrl;
    // Recreate if null or if the base URL changed (branch switch).
    if (_refreshDio == null || _refreshDio!.options.baseUrl != url) {
      _refreshDio = Dio(BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ));
    }
    return _refreshDio!;
  }

  /// Resets the dedicated refresh Dio so it picks up a new base URL.
  void resetRefreshDio() {
    _refreshDio = null;
  }

  // ── Refresh lock ─────────────────────────────────────────────────────────
  /// When a refresh is already in flight, subsequent callers await this same
  /// completer instead of firing another network request.
  Completer<bool>? _refreshCompleter;
  bool get isRefreshing => _refreshCompleter != null;

  // ── Proactive timer ──────────────────────────────────────────────────────
  Timer? _proactiveTimer;

  // ── Public API ───────────────────────────────────────────────────────────

  /// Attempt to refresh the token. Returns `true` if a new token was obtained
  /// and saved, `false` otherwise (caller should force-logout on `false`).
  ///
  /// Thread-safe: only one refresh request is in flight at a time.
  Future<bool> refreshToken() async {
    // If a refresh is already in progress, wait for it.
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final currentToken =
          await CacheHelper.getSecuredString(CacheKeys.userToken);

      if (currentToken == null || currentToken.toString().isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // Use the dedicated Dio with the current token.
      _dio.options.headers['Authorization'] = 'Bearer $currentToken';

      final response = await _dio.post('worker/refresh');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['access_token'] as String?;
        final expiresIn = data['expires_in'] as int?;

        if (newToken != null && newToken.isNotEmpty) {
          await _saveToken(newToken);
          if (expiresIn != null) {
            scheduleProactiveRefresh(expiresIn);
          }
          _refreshCompleter!.complete(true);
          debugPrint('[TokenManager] Token refreshed successfully');
          return true;
        }
      }

      _refreshCompleter!.complete(false);
      return false;
    } on DioException catch (e) {
      debugPrint('[TokenManager] Refresh failed: ${e.response?.statusCode}');
      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      debugPrint('[TokenManager] Refresh error: $e');
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Save token to secure storage + update Dio default headers.
  Future<void> _saveToken(String token) async {
    await CacheHelper.setSecuredString(CacheKeys.userToken, token);
    DioFactory.setTokenIntoHeaderAfterLogin(token);
  }

  /// Schedule a timer that refreshes the token ~5 minutes before expiry.
  ///
  /// Call this after every successful login or token refresh.
  void scheduleProactiveRefresh(int expiresInSeconds) {
    _proactiveTimer?.cancel();

    // Save the absolute expiry time so we can restore the timer after app restart.
    final expiryMillis = DateTime.now()
        .add(Duration(seconds: expiresInSeconds))
        .millisecondsSinceEpoch;
    CacheHelper.saveData(key: CacheKeys.tokenExpiryTime, value: expiryMillis);

    // Refresh 5 minutes (300s) before expiry, but at least 30 seconds from now.
    final refreshInSeconds = max(expiresInSeconds - 300, 30);
    debugPrint(
        '[TokenManager] Proactive refresh scheduled in ${refreshInSeconds}s '
        '(token expires in ${expiresInSeconds}s)');

    _proactiveTimer = Timer(
      Duration(seconds: refreshInSeconds),
      _onProactiveRefresh,
    );
  }

  /// Restore the proactive timer from the saved expiry time.
  /// Called on app startup if user is already logged in.
  Future<void> restoreTimerIfNeeded() async {
    final expiryMillis = CacheHelper.getData(key: CacheKeys.tokenExpiryTime);
    if (expiryMillis == null || expiryMillis is! int) return;

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
    final now = DateTime.now();
    final remainingSeconds = expiryTime.difference(now).inSeconds;

    if (remainingSeconds <= 0) {
      // Token already expired — try to refresh now.
      debugPrint('[TokenManager] Token expired, attempting immediate refresh');
      final success = await refreshToken();
      if (!success) {
        forceLogout();
      }
    } else {
      // Token still valid — schedule proactive refresh.
      scheduleProactiveRefresh(remainingSeconds);
    }
  }

  /// Cancel the proactive timer (e.g. on logout).
  void cancelTimer() {
    _proactiveTimer?.cancel();
    _proactiveTimer = null;
  }

  /// Clear everything and navigate to login.
  Future<void> forceLogout() async {
    cancelTimer();

    try {
      // Clear auth data but keep biometric credentials.
      await CacheHelper.clearAuthDataPreservingBiometric();
      await CacheHelper.removeData(key: CacheKeys.tokenExpiryTime);
      await CacheHelper.removeData(key: CacheKeys.shopId);
      await CacheHelper.removeData(key: CacheKeys.userName);
      await CacheHelper.removeData(key: CacheKeys.userRole);
      isLoggedInUser = false;
      DioFactory.setTokenIntoHeaderAfterLogin('');
    } catch (_) {}

    // Navigate to login, clearing the entire navigation stack.
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamedAndRemoveUntil(
        Routes.loginScreen,
        (_) => false,
      );
      debugPrint('[TokenManager] Forced logout → navigated to login');
    }
  }

  // ── Private ──────────────────────────────────────────────────────────────

  Future<void> _onProactiveRefresh() async {
    debugPrint('[TokenManager] Proactive refresh triggered');
    final success = await refreshToken();
    if (!success) {
      debugPrint('[TokenManager] Proactive refresh failed → forcing logout');
      await forceLogout();
    }
  }
}
