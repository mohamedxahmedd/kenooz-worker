import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_request_model.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_response_model.dart';
import 'package:retrofit/retrofit.dart';


part 'login_api_services.g.dart';

@RestApi()
abstract class LoginApiService {
  static const String loginApi = 'worker/login';
  factory LoginApiService(Dio dio, {String baseUrl}) = _LoginApiService;
  @POST(loginApi)
  Future<LoginResponseModel> login(
    @Body() LoginRequestModel body,
  );
}
