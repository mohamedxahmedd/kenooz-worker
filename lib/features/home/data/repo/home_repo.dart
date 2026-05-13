import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/home/data/models/home_data_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_gold_request_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_price_response_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_silver_request_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_usd_request_model.dart';
import 'package:kenooz_worker_app/features/home/data/remote/home_api_service.dart';

class HomeRepo {
  final HomeApiService _homeApiService;
  HomeRepo(this._homeApiService);

  Future<ApiResult<HomeDataModel>> fetchAllRates() async {
    try {
      final usdRate = await _homeApiService.getUsdRate();
      final goldRates = await _homeApiService.getGoldRates();
      final silverRates = await _homeApiService.getSilverRates();
      return ApiResult.success(HomeDataModel(
        usdRate: usdRate,
        goldRates: goldRates,
        silverRates: silverRates,
      ));
    } catch (e, st) {
      // ignore: avoid_print
      print('[HomeRepo.fetchAllRates] ${e.runtimeType}: $e\n$st');
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<UpdatePriceResponseModel>> updateUsdRate(
    UpdateUsdRequestModel request,
  ) async {
    try {
      final response = await _homeApiService.updateUsdRate(request);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<UpdatePriceResponseModel>> updateGoldPrice(
    UpdateGoldRequestModel request,
  ) async {
    try {
      final response = await _homeApiService.updateGoldPrice(request);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<UpdatePriceResponseModel>> updateSilverPrice(
    UpdateSilverRequestModel request,
  ) async {
    try {
      final response = await _homeApiService.updateSilverPrice(request);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
