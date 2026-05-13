import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/logout/data/models/logout_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'logout_api_service.g.dart';

@RestApi()
abstract class LogoutApiService {
  static const String logoutApi = 'worker/logout';
  factory LogoutApiService(Dio dio, {String baseUrl}) = _LogoutApiService;

  @POST(logoutApi)
  Future<LogoutResponseModel> logout();
}
