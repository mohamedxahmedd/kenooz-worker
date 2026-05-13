import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/sign_up/data/models/signup_request_model.dart';
import 'package:kenooz_worker_app/features/sign_up/data/models/signup_response_model.dart';
import 'package:retrofit/retrofit.dart';



part 'signup_api_services.g.dart';

@RestApi()
abstract class SignupApiService {
  static const String signupApi = 'clients/register';
  factory SignupApiService(Dio dio, {String baseUrl}) = _SignupApiService;
  @POST(signupApi)
  Future<SignUpResponseModel> signup(
    @Body() SignupRequestModel body,
  );
}
