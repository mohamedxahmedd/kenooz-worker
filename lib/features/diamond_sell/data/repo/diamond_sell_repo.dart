import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_unified_sell_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_preload_data.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_request_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_result_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/remote/diamond_sell_api_service.dart';

class DiamondSellRepo {
  final DiamondSellApiService _apiService;

  DiamondSellRepo(this._apiService);

  Future<ApiResult<DiamondSellPreloadData>> fetchPreloadData() async {
    try {
      final usdFuture = _apiService.getUsdRate();
      final accountsFuture = _apiService.getAccounts();

      final usd = await usdFuture;
      final accounts = await accountsFuture;

      return ApiResult.success(
        DiamondSellPreloadData(usdRate: usd, accounts: accounts),
      );
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> fetchProduct(
    String type,
    int id,
  ) async {
    try {
      final result = await _apiService.getProduct(type, id);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ClientModel>> searchClient(String term) async {
    try {
      final result = await _apiService.searchClient(term);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ClientModel>> createClient(
    CreateClientRequestModel request,
  ) async {
    try {
      final result = await _apiService.createClient(request);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<DiamondSellResultModel>> submitSell(
    DiamondSellRequestModel request,
  ) async {
    try {
      final result = await _apiService.submitSell(request);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<DiamondUnifiedSellHistoryModel>>>
      fetchSellHistory() async {
    try {
      final raw = await _apiService.getUnifiedSellHistory();
      final sellsList = raw['sells'] as List<dynamic>? ?? [];
      final models = sellsList
          .map((e) => DiamondUnifiedSellHistoryModel.fromJson(
              e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(models);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
