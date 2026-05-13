import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/account_currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_vendor_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_vendor_response_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_response_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_box_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_carat_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_kind_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_product_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_vendor_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/gold_rates_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/usd_rate_model.dart';
import 'package:retrofit/retrofit.dart';

part 'gold_double_sell_api_service.g.dart';

@RestApi()
abstract class GoldDoubleSellApiService {
  static const String caratsApi = 'carats/all';
  static const String currenciesApi = 'currency/all';
  static const String usdRateApi = 'worker/gold/usd';
  static const String goldRatesApi = 'worker/gold/rates';
  static const String workersApi = 'worker/gold/workers';
  static const String boxesApi = 'worker/gold/boxes';
  static const String vendorsApi = 'worker/gold/vendors';
  static const String accountsApi = 'worker/accounts';

  static const String kindsByCaratApi = 'worker/gold/kinds/{carat_id}';
  static const String accountCurrencyApi = 'worker/accounts/{id}/currency';

  static const String searchClientApi = 'worker/clients/search/{term}';
  static const String createClientApi = 'worker/clients/add';

  static const String createVendorApi = 'worker/vendors/add';

  static const String productByIdApi = 'worker/gold/product/{id}';

  static const String submitDoubleSellApi = 'worker/golds/sells/double/store';
  static const String goldSellHistoryApi = 'worker/golds/sells/double';

  factory GoldDoubleSellApiService(Dio dio, {String baseUrl}) =
      _GoldDoubleSellApiService;

  @GET(caratsApi)
  Future<List<GoldCaratModel>> getCarats();

  @GET(currenciesApi)
  Future<List<CurrencyModel>> getCurrencies();

  @GET(usdRateApi)
  Future<UsdRateModel> getUsdRate();

  @GET(goldRatesApi)
  Future<GoldRatesModel> getGoldRates();

  @GET(workersApi)
  Future<List<ShopWorkerModel>> getWorkers();

  @GET(boxesApi)
  Future<List<GoldBoxModel>> getBoxes();

  @GET(vendorsApi)
  Future<List<GoldVendorModel>> getVendors();

  @GET(accountsApi)
  Future<List<PaymentAccountModel>> getAccounts();

  @GET(kindsByCaratApi)
  Future<List<GoldKindModel>> getKindsByCarat(@Path('carat_id') int caratId);

  @GET(accountCurrencyApi)
  Future<AccountCurrencyModel> getAccountCurrency(@Path('id') int accountId);

  @GET(searchClientApi)
  Future<ClientModel> searchClient(@Path('term') String term);

  @POST(createClientApi)
  Future<ClientModel> createClient(@Body() CreateClientRequestModel request);

  @POST(createVendorApi)
  Future<CreateVendorResponseModel> createVendor(
    @Body() CreateVendorRequestModel request,
  );

  @GET(productByIdApi)
  Future<GoldProductModel> getProductById(@Path('id') int id);

  @POST(submitDoubleSellApi)
  Future<DoubleSellResponseModel> submitDoubleSell(
    @Body() DoubleSellRequestModel request,
  );

  @GET(goldSellHistoryApi)
  Future<dynamic> getGoldSellHistory();
}
