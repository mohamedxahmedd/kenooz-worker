


import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_request_model.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_response_model.dart';
import 'package:kenooz_worker_app/features/login/data/remote/login_api_services.dart';

class LoginRepo {
  final LoginApiService _loginApiService;
  LoginRepo(this._loginApiService);
  Future<ApiResult<LoginResponseModel>> login(
      {required LoginRequestModel loginReqModel}) async {
    try {
      final response = await _loginApiService.login(loginReqModel);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
