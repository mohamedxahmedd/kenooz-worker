import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/account_currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/create_silver_vendor_request_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/create_silver_vendor_response_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_box_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_double_sell_request_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_double_sell_response_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_kind_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_product_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_rates_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_vendor_model.dart';
import 'package:retrofit/retrofit.dart';

part 'silver_double_sell_api_service.g.dart';

@RestApi()
abstract class SilverDoubleSellApiService {
  static const String silverRatesApi = 'worker/silver/rates';
  static const String silverKindsApi = 'worker/silver/kinds';
  static const String silverBoxesApi = 'worker/silver/boxes';
  static const String silverVendorsApi = 'worker/silver/vendors';
  static const String workersApi = 'worker/gold/workers';
  static const String accountsApi = 'worker/accounts';

  static const String accountCurrencyApi = 'worker/accounts/{id}/currency';

  static const String searchClientApi = 'worker/clients/search/{term}';
  static const String createClientApi = 'worker/clients/add';

  static const String createVendorApi = 'worker/silver/vendors/add';

  static const String productByIdApi = 'worker/silver/product/{id}';

  static const String submitDoubleSellApi =
      'worker/silvers/sells/double/store';
  static const String silverSellHistoryApi = 'worker/silvers/sells/double';

  factory SilverDoubleSellApiService(Dio dio, {String baseUrl}) =
      _SilverDoubleSellApiService;

  @GET(silverRatesApi)
  Future<SilverRatesModel> getSilverRates();

  @GET(silverKindsApi)
  Future<List<SilverKindModel>> getSilverKinds();

  @GET(silverBoxesApi)
  Future<List<SilverBoxModel>> getSilverBoxes();

  @GET(silverVendorsApi)
  Future<List<SilverVendorModel>> getSilverVendors();

  @GET(workersApi)
  Future<List<ShopWorkerModel>> getWorkers();

  @GET(accountsApi)
  Future<List<PaymentAccountModel>> getAccounts();

  @GET(accountCurrencyApi)
  Future<AccountCurrencyModel> getAccountCurrency(@Path('id') int accountId);

  @GET(searchClientApi)
  Future<ClientModel> searchClient(@Path('term') String term);

  @POST(createClientApi)
  Future<ClientModel> createClient(@Body() CreateClientRequestModel request);

  @POST(createVendorApi)
  Future<CreateSilverVendorResponseModel> createVendor(
    @Body() CreateSilverVendorRequestModel request,
  );

  @GET(productByIdApi)
  Future<SilverProductModel> getProductById(@Path('id') int id);

  @POST(submitDoubleSellApi)
  Future<SilverDoubleSellResponseModel> submitDoubleSell(
    @Body() SilverDoubleSellRequestModel request,
  );

  @GET(silverSellHistoryApi)
  Future<dynamic> getSilverSellHistory();
}
