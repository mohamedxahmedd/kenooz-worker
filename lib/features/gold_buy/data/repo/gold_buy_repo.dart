import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/client_sells_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/create_carat_request_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_full_history_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_preload_data.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_request_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_response_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/sell_find_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/remote/gold_buy_api_service.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/account_currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_carat_model.dart';

class GoldBuyRepo {
  final GoldBuyApiService _apiService;

  GoldBuyRepo(this._apiService);

  // ── Preload all 5 sets of data in parallel ────────────────────────────────
  Future<ApiResult<GoldBuyPreloadData>> fetchPreloadData() async {
    try {
      final ratesFuture = _apiService.getGoldRates();
      final boxesFuture = _apiService.getBoxes();
      final vendorsFuture = _apiService.getVendors();
      final workersFuture = _apiService.getWorkers();
      final accountsFuture = _apiService.getAccounts();

      final ratesRaw = await ratesFuture;
      final boxes = await boxesFuture;
      final vendors = await vendorsFuture;
      final workers = await workersFuture;
      final accounts = await accountsFuture;

      // GET /worker/gold/rates returns { "carats": [...] }
      final rawCarats = ratesRaw['carats'] as List<dynamic>? ?? [];
      final carats = rawCarats
          .map((e) => GoldCaratModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResult.success(
        GoldBuyPreloadData(
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
  Future<ApiResult<SellFindModel>> findSellById(int id) async {
    try {
      final raw = await _apiService.findSellById(id);
      return ApiResult.success(SellFindModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ClientSellsModel>> findSellsByClient(String term) async {
    try {
      final raw = await _apiService.findSellsByClient(term);
      return ApiResult.success(ClientSellsModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  // ── Create carat on-the-fly ───────────────────────────────────────────────
  Future<ApiResult<GoldCaratModel>> createCarat(
    CreateCaratRequestModel request,
  ) async {
    try {
      final raw = await _apiService.createCarat(request);
      return ApiResult.success(GoldCaratModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  // ── Submit gold buy ───────────────────────────────────────────────────────
  Future<ApiResult<GoldBuyResponseModel>> submitGoldBuy(
    GoldBuyRequestModel request,
  ) async {
    try {
      final raw = await _apiService.submitGoldBuy(request);
      return ApiResult.success(GoldBuyResponseModel.fromJson(raw));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  // ── Buy history ───────────────────────────────────────────────────────────
  Future<ApiResult<List<GoldBuyFullHistoryModel>>> fetchBuyHistory() async {
    try {
      final raw = await _apiService.getBuyHistory();
      final buysList = raw['buys'] as List<dynamic>? ?? [];
      final models = buysList
          .map(
            (e) =>
                GoldBuyFullHistoryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      return ApiResult.success(models);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
