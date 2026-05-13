

import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/sign_up/data/models/signup_request_model.dart';
import 'package:kenooz_worker_app/features/sign_up/data/models/signup_response_model.dart';
import 'package:kenooz_worker_app/features/sign_up/data/remote/signup_api_services.dart';

class SignupRepo {
  final SignupApiService _loginApiService;
  SignupRepo(this._loginApiService);
  Future<ApiResult<SignUpResponseModel>> signup(
      {required SignupRequestModel signupReqModel}) async {
    try {
      final response = await _loginApiService.signup(signupReqModel);
       return ApiResult.success(response);
    } catch (e) {
       return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
