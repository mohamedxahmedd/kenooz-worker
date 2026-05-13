import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/network/token_manager.dart';

/// Dio [Interceptor] that intercepts **401 Unauthorized** (and 302 auth
/// redirects) and transparently refreshes the token before retrying the
/// original request.
///
/// Flow:
/// 1. A request returns 401 (or 302 redirect, which this API uses for expired
///    sessions).
/// 2. If the failed request was the refresh endpoint itself, we force-logout
///    immediately (avoids infinite loops).
/// 3. Otherwise, delegate to [TokenManager.refreshToken()]. The manager uses a
///    lock so concurrent 401s trigger only **one** refresh.
/// 4. On success, the original request is cloned with the new token and
///    retried.
/// 5. On failure, force-logout and reject the original error.
class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;

  TokenRefreshInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final isAuthError = statusCode == 401 || statusCode == 302;

    if (!isAuthError) {
      return handler.next(err);
    }

    // Don't try to refresh if the refresh endpoint itself failed.
    final path = err.requestOptions.path;
    if (path.contains('worker/refresh') || path.contains('worker/login')) {
      debugPrint('[Interceptor] Auth error on $path — skipping refresh');
      return handler.next(err);
    }

    debugPrint('[Interceptor] 401 on $path — attempting token refresh');

    try {
      final success = await TokenManager().refreshToken();

      if (success) {
        // Get the fresh token and retry the original request.
        final newToken =
            await CacheHelper.getSecuredString(CacheKeys.userToken);

        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';

        // Retry with the main Dio (which carries all default settings).
        final retryResponse = await _dio.fetch(opts);
        return handler.resolve(retryResponse);
      } else {
        // Refresh failed — force logout and propagate the error.
        debugPrint('[Interceptor] Refresh failed — forcing logout');
        await TokenManager().forceLogout();
        return handler.reject(err);
      }
    } catch (e) {
      debugPrint('[Interceptor] Retry error: $e');
      await TokenManager().forceLogout();
      return handler.reject(err);
    }
  }
}
