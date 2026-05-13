import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_sell_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/account_currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/create_silver_vendor_request_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/create_silver_vendor_response_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_double_sell_preload_data.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_double_sell_request_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_double_sell_response_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_product_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/remote/silver_double_sell_api_service.dart';

class SilverDoubleSellRepo {
  final SilverDoubleSellApiService _apiService;

  SilverDoubleSellRepo(this._apiService);

  Future<ApiResult<SilverDoubleSellPreloadData>> fetchPreloadData() async {
    try {
      final ratesFuture = _apiService.getSilverRates();
      final kindsFuture = _apiService.getSilverKinds();
      final boxesFuture = _apiService.getSilverBoxes();
      final vendorsFuture = _apiService.getSilverVendors();
      final workersFuture = _apiService.getWorkers();
      final accountsFuture = _apiService.getAccounts();

      final rates = await ratesFuture;
      final kinds = await kindsFuture;
      final boxes = await boxesFuture;
      final vendors = await vendorsFuture;
      final workers = await workersFuture;
      final accounts = await accountsFuture;

      return ApiResult.success(
        SilverDoubleSellPreloadData(
          carats: rates.carats,
          kinds: kinds,
          boxes: boxes,
          vendors: vendors,
          workers: workers,
          accounts: accounts,
        ),
      );
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<AccountCurrencyModel>> fetchAccountCurrency(
    int accountId,
  ) async {
    try {
      final result = await _apiService.getAccountCurrency(accountId);
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

  Future<ApiResult<CreateSilverVendorResponseModel>> createVendor(
    CreateSilverVendorRequestModel request,
  ) async {
    try {
      final result = await _apiService.createVendor(request);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<SilverProductModel>> fetchProduct(int id) async {
    try {
      final result = await _apiService.getProductById(id);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<SilverDoubleSellResponseModel>> submitDoubleSell(
    SilverDoubleSellRequestModel request,
  ) async {
    try {
      final result = await _apiService.submitDoubleSell(request);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<SilverSellHistoryModel>>> fetchSellHistory() async {
    try {
      final raw = await _apiService.getSilverSellHistory();
      final sellsList = raw['sells'] as List<dynamic>? ?? [];
      final models = sellsList
          .map(
              (e) => SilverSellHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(models);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
