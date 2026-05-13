import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/logout/data/models/logout_response_model.dart';
import 'package:kenooz_worker_app/features/logout/data/remote/logout_api_service.dart';

class LogoutRepo {
  final LogoutApiService _logoutApiService;
  LogoutRepo(this._logoutApiService);

  Future<ApiResult<LogoutResponseModel>> logout() async {
    try {
      final response = await _logoutApiService.logout();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
