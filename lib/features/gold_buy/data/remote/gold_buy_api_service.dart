import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/create_carat_request_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/account_currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_box_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_vendor_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';
import 'package:retrofit/retrofit.dart';

part 'gold_buy_api_service.g.dart';

@RestApi()
abstract class GoldBuyApiService {
  // ── Preload ──────────────────────────────────────────────
  static const String goldRatesApi    = 'worker/gold/rates';
  static const String boxesApi        = 'worker/gold/boxes';
  static const String vendorsApi      = 'worker/gold/vendors';
  static const String workersApi      = 'worker/gold/workers';
  static const String accountsApi     = 'worker/accounts';

  // ── Dynamic lookups ──────────────────────────────────────
  static const String accountCurrencyApi = 'worker/accounts/{id}/currency';
  static const String searchClientApi    = 'worker/clients/search/{term}';
  static const String createClientApi    = 'worker/clients/add';

  // ── Gold Buy specific ────────────────────────────────────
  static const String sellFindApi     = 'worker/gold/buy/sell/find/{id}';
  static const String sellClientApi   = 'worker/gold/buy/sell/client/{term}';
  static const String createCaratApi  = 'worker/gold/buy/carat/add';
  static const String storeBuyApi     = 'worker/gold/buys/store';
  static const String buyHistoryApi   = 'worker/gold/buys';

  factory GoldBuyApiService(Dio dio, {String baseUrl}) = _GoldBuyApiService;

  // ── Preload ──────────────────────────────────────────────
  @GET(goldRatesApi)
  Future<dynamic> getGoldRates();

  @GET(boxesApi)
  Future<List<GoldBoxModel>> getBoxes();

  @GET(vendorsApi)
  Future<List<GoldVendorModel>> getVendors();

  @GET(workersApi)
  Future<List<ShopWorkerModel>> getWorkers();

  @GET(accountsApi)
  Future<List<PaymentAccountModel>> getAccounts();

  // ── Dynamic lookups ──────────────────────────────────────
  @GET(accountCurrencyApi)
  Future<AccountCurrencyModel> getAccountCurrency(@Path('id') int accountId);

  @GET(searchClientApi)
  Future<ClientModel> searchClient(@Path('term') String term);

  @POST(createClientApi)
  Future<ClientModel> createClient(@Body() CreateClientRequestModel request);

  // ── Gold Buy specific ────────────────────────────────────
  @GET(sellFindApi)
  Future<dynamic> findSellById(@Path('id') int id);

  @GET(sellClientApi)
  Future<dynamic> findSellsByClient(@Path('term') String term);

  @POST(createCaratApi)
  Future<dynamic> createCarat(
      @Body() CreateCaratRequestModel request);

  @POST(storeBuyApi)
  Future<dynamic> submitGoldBuy(
      @Body() GoldBuyRequestModel request);

  @GET(buyHistoryApi)
  Future<dynamic> getBuyHistory();
}
