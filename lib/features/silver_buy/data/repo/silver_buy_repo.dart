import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_client_sells_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/create_silver_carat_request_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_full_history_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_preload_data.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_request_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_response_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_sell_find_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/remote/silver_buy_api_service.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/account_currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_carat_model.dart';

class SilverBuyRepo {
  final SilverBuyApiService _apiService;

  SilverBuyRepo(this._apiService);

  // ── Preload all 5 sets of data in parallel ────────────────────────────────
  Future<ApiResult<SilverBuyPreloadData>> fetchPreloadData() async {
    try {
      final ratesFuture = _apiService.getSilverRates();
      final boxesFuture = _apiService.getBoxes();
      final vendorsFuture = _apiService.getVendors();
      final workersFuture = _apiService.getWorkers();
      final accountsFuture = _apiService.getAccounts();

      final ratesRaw = await ratesFuture;
      final boxes = await boxesFuture;
      final vendors = await vendorsFuture;
      final workers = await workersFuture;
      final accounts = await accountsFuture;

      // GET /worker/silver/rates returns { "carats": [...] }
      final rawCarats = ratesRaw['carats'] as List<dynamic>? ?? [];
      final carats = rawCarats
          .map((e) => SilverCaratModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResult.success(
        SilverBuyPreloadData(
          carats: carats,
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

  // ── Account currency rate ─────────────────────────────────────────────────
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

  // ── Client search / create ────────────────────────────────────────────────
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

  // ── Sell link ─────────────────────────────────────────────────────────────
  Future<ApiResult<SilverSellFindModel>> findSellById(int id) async {
    try {
      final raw = await _apiService.findSellById(id);
      return ApiResult.success(SilverSellFindModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<SilverClientSellsModel>> findSellsByClient(String term) async {
    try {
      final raw = await _apiService.findSellsByClient(term);
      return ApiResult.success(SilverClientSellsModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  // ── Create carat on-the-fly ───────────────────────────────────────────────
  Future<ApiResult<SilverCaratModel>> createCarat(
    CreateSilverCaratRequestModel request,
  ) async {
    try {
      final raw = await _apiService.createCarat(request);
      return ApiResult.success(SilverCaratModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  // ── Submit silver buy ────────────────────────────────────────────────────
  Future<ApiResult<SilverBuyResponseModel>> submitSilverBuy(
    SilverBuyRequestModel request,
  ) async {
    try {
      final raw = await _apiService.submitSilverBuy(request);
      return ApiResult.success(SilverBuyResponseModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  // ── Buy history ───────────────────────────────────────────────────────────
  Future<ApiResult<List<SilverBuyFullHistoryModel>>> fetchBuyHistory() async {
    try {
      final raw = await _apiService.getBuyHistory();
      final buysList = raw['buys'] as List<dynamic>? ?? [];
      final models = buysList
          .map(
            (e) =>
                SilverBuyFullHistoryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      return ApiResult.success(models);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
