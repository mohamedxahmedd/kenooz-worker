import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/profile/data/models/profile_response_model.dart';
import 'package:kenooz_worker_app/features/profile/data/models/update_profile_request_model.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api_service.g.dart';

@RestApi()
abstract class ProfileApiService {
  static const String profileApi = 'worker/profile';
  static const String updateProfileApi = 'worker/update';
  static const String saveImageApi = 'worker/saveImage';

  factory ProfileApiService(Dio dio, {String baseUrl}) = _ProfileApiService;

  @GET(profileApi)
  Future<ProfileResponseModel> getProfile();

  @POST(updateProfileApi)
  Future<ProfileResponseModel> updateProfile(
    @Body() UpdateProfileRequestModel body,
  );
}
