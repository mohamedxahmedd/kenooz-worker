import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/available_gold_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hang_request_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hang_response_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hanged_gold_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/unhang_request_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/unhang_response_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/remote/gold_hangings_api_service.dart';

class GoldHangingsRepo {
  final GoldHangingsApiService _apiService;

  GoldHangingsRepo(this._apiService);

  Future<ApiResult<List<HangedGoldModel>>> fetchHangedList() async {
    try {
      final raw = await _apiService.getHangedList();
      final list = raw['hanged'] as List<dynamic>? ?? [];
      final models = list
          .map((e) => HangedGoldModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(models);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<AvailableGoldModel>>> fetchAvailableList() async {
    try {
      final raw = await _apiService.getAvailableList();
      final list = raw['available'] as List<dynamic>? ?? [];
      final models = list
          .map((e) => AvailableGoldModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(models);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<HangResponseModel>> hangGolds(
    HangRequestModel request,
  ) async {
    try {
      final raw = await _apiService.hangGolds(request);
      return ApiResult.success(HangResponseModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<UnhangResponseModel>> unhangGold(
    UnhangRequestModel request,
  ) async {
    try {
      final raw = await _apiService.unhangGold(request);
      return ApiResult.success(UnhangResponseModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
