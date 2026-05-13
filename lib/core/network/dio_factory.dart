import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/network/token_refresh_interceptor.dart';

class DioFactory {
  /// Private constructor — this class is not meant to be instantiated.
  DioFactory._();

  static Dio? dio;

  /// Returns the shared [Dio] instance, creating it on the first call.
  ///
  /// [baseUrl] is required on the first call to configure the Dio instance
  /// with the correct branch endpoint. Subsequent calls return the cached
  /// instance (ignoring [baseUrl]).
  static Future<Dio> getDio({required String baseUrl}) async {
    if (dio == null) {
      const timeOut = Duration(seconds: 30);

      dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeOut,
        receiveTimeout: timeOut,
        followRedirects: false,
        maxRedirects: 0,
        validateStatus: (status) {
          // Treat 2xx as success; everything else (including 3xx redirects)
          // should be thrown as a DioException so the error handler can
          // detect 302 auth redirects instead of silently following them.
          return status != null && status >= 200 && status < 300;
        },
      ));

      // Await the stored token before setting headers.
      await _initHeaders();

      // Add token-refresh interceptor so 401s are handled automatically.
      dio!.interceptors.add(TokenRefreshInterceptor(dio!));
    }
    return dio!;
  }

  /// Updates the base URL at runtime (e.g. after a branch switch).
  static void updateBaseUrl(String newBaseUrl) {
    dio?.options.baseUrl = newBaseUrl;
  }

  /// Destroys the current Dio instance so the next [getDio] call creates
  /// a fresh one. Call this before re-registering services on branch switch.
  static void reset() {
    dio = null;
  }

  /// Reads the stored token and sets all default headers.
  static Future<void> _initHeaders() async {
    final token = await CacheHelper.getSecuredString(CacheKeys.userToken);
    dio?.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token',
    };
  }

  /// Call after login/refresh to immediately update the Authorization header.
  static void setTokenIntoHeaderAfterLogin(String token) {
    dio?.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token',
    };
  }
}
