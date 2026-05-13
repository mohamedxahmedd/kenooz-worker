import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/profile/data/models/profile_response_model.dart';
import 'package:kenooz_worker_app/features/profile/data/models/update_profile_request_model.dart';
import 'package:kenooz_worker_app/features/profile/data/remote/profile_api_service.dart';

class ProfileRepo {
  final ProfileApiService _profileApiService;
  final Dio _dio;

  ProfileRepo(this._profileApiService, this._dio);

  Future<ApiResult<ProfileResponseModel>> getProfile() async {
    try {
      final response = await _profileApiService.getProfile();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ProfileResponseModel>> updateProfile(
    UpdateProfileRequestModel request,
  ) async {
    try {
      final response = await _profileApiService.updateProfile(request);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  /// Uploads a profile image via multipart/form-data.
  ///
  /// Uses Dio directly (not Retrofit) because multipart file uploads
  /// are cleaner and more reliable with direct FormData handling.
  Future<ApiResult<ProfileResponseModel>> saveProfileImage(
    String filePath,
  ) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        'worker/saveImage',
        data: formData,
      );

      final profile = ProfileResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiResult.success(profile);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
