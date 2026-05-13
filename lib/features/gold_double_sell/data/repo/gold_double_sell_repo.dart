import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_sell_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/account_currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_vendor_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_vendor_response_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_preload_data.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_response_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_kind_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_product_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/remote/gold_double_sell_api_service.dart';

class GoldDoubleSellRepo {
  final GoldDoubleSellApiService _apiService;

  GoldDoubleSellRepo(this._apiService);

  Future<ApiResult<DoubleSellPreloadData>> fetchPreloadData() async {
    try {
      final caratsFuture = _apiService.getCarats();
      final currenciesFuture = _apiService.getCurrencies();
      final usdRateFuture = _apiService.getUsdRate();
      final goldRatesFuture = _apiService.getGoldRates();
      final workersFuture = _apiService.getWorkers();
      final boxesFuture = _apiService.getBoxes();
      final vendorsFuture = _apiService.getVendors();
      final accountsFuture = _apiService.getAccounts();

      final carats = await caratsFuture;
      final currencies = await currenciesFuture;
      final usdRate = await usdRateFuture;
      final goldRates = await goldRatesFuture;
      final workers = await workersFuture;
      final boxes = await boxesFuture;
      final vendors = await vendorsFuture;
      final accounts = await accountsFuture;

      return ApiResult.success(
        DoubleSellPreloadData(
          carats: carats,
          currencies: currencies,
          usdRate: usdRate,
          goldRates: goldRates,
          workers: workers,
          boxes: boxes,
          vendors: vendors,
          accounts: accounts,
        ),
      );
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<GoldKindModel>>> fetchKindsByCarat(int caratId) async {
    try {
      final result = await _apiService.getKindsByCarat(caratId);
      return ApiResult.success(result);
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

  Future<ApiResult<CreateVendorResponseModel>> createVendor(
    CreateVendorRequestModel request,
  ) async {
    try {
      final result = await _apiService.createVendor(request);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<GoldProductModel>> fetchProduct(int id) async {
    try {
      final result = await _apiService.getProductById(id);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<DoubleSellResponseModel>> submitDoubleSell(
    DoubleSellRequestModel request,
  ) async {
    try {
      final result = await _apiService.submitDoubleSell(request);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<GoldSellHistoryModel>>> fetchSellHistory() async {
    try {
      final raw = await _apiService.getGoldSellHistory();
      final sellsList = raw['sells'] as List<dynamic>? ?? [];
      final models = sellsList
          .map((e) => GoldSellHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(models);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
