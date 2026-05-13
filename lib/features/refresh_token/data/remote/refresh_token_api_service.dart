import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'refresh_token_api_service.g.dart';

@RestApi()
abstract class RefreshTokenApiService {
  static const String refreshTokenApi = 'worker/refresh';
  factory RefreshTokenApiService(Dio dio, {String baseUrl}) =
      _RefreshTokenApiService;

  @POST(refreshTokenApi)
  Future<LoginResponseModel> refreshToken();
}
