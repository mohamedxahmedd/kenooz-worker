import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/create_silver_carat_request_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/account_currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_box_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_vendor_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';
import 'package:retrofit/retrofit.dart';

part 'silver_buy_api_service.g.dart';

@RestApi()
abstract class SilverBuyApiService {
  // ── Preload ──────────────────────────────────────────────
  static const String silverRatesApi  = 'worker/silver/rates';
  static const String boxesApi        = 'worker/silver/boxes';
  static const String vendorsApi      = 'worker/silver/vendors';
  static const String workersApi      = 'worker/gold/workers';
  static const String accountsApi     = 'worker/accounts';

  // ── Dynamic lookups ──────────────────────────────────────
  static const String accountCurrencyApi = 'worker/accounts/{id}/currency';
  static const String searchClientApi    = 'worker/clients/search/{term}';
  static const String createClientApi    = 'worker/clients/add';

  // ── Silver Buy specific ──────────────────────────────────
  static const String sellFindApi     = 'worker/silver/buy/sell/find/{id}';
  static const String sellClientApi   = 'worker/silver/buy/sell/client/{term}';
  static const String createCaratApi  = 'worker/silver/buy/carat/add';
  static const String storeBuyApi     = 'worker/silver/buys/store';
  static const String buyHistoryApi   = 'worker/silver/buys';

  factory SilverBuyApiService(Dio dio, {String baseUrl}) = _SilverBuyApiService;

  // ── Preload ──────────────────────────────────────────────
  @GET(silverRatesApi)
  Future<dynamic> getSilverRates();

  @GET(boxesApi)
  Future<List<SilverBoxModel>> getBoxes();

  @GET(vendorsApi)
  Future<List<SilverVendorModel>> getVendors();

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

  // ── Silver Buy specific ──────────────────────────────────
  @GET(sellFindApi)
  Future<dynamic> findSellById(@Path('id') int id);

  @GET(sellClientApi)
  Future<dynamic> findSellsByClient(@Path('term') String term);

  @POST(createCaratApi)
  Future<dynamic> createCarat(
      @Body() CreateSilverCaratRequestModel request);

  @POST(storeBuyApi)
  Future<dynamic> submitSilverBuy(
      @Body() SilverBuyRequestModel request);

  @GET(buyHistoryApi)
  Future<dynamic> getBuyHistory();
}
