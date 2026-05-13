import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_response_model.dart';
import 'package:kenooz_worker_app/features/refresh_token/data/remote/refresh_token_api_service.dart';

class RefreshTokenRepo {
  final RefreshTokenApiService _refreshTokenApiService;
  RefreshTokenRepo(this._refreshTokenApiService);

  Future<ApiResult<LoginResponseModel>> refreshToken() async {
    try {
      final response = await _refreshTokenApiService.refreshToken();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
