import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_request_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_result_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/usd_rate_model.dart';
import 'package:retrofit/retrofit.dart';

part 'diamond_sell_api_service.g.dart';

@RestApi()
abstract class DiamondSellApiService {
  static const String usdRateApi = 'worker/gold/usd';
  static const String accountsApi = 'worker/accounts';
  static const String searchClientApi = 'worker/clients/search/{term}';
  static const String createClientApi = 'worker/clients/add';
  static const String productLookupApi = 'worker/unified/product/{type}/{id}';
  static const String submitApi = 'worker/unified/sells/store';
  static const String unifiedSellHistoryApi = 'worker/unified/sells';

  factory DiamondSellApiService(Dio dio, {String baseUrl}) =
      _DiamondSellApiService;

  @GET(usdRateApi)
  Future<UsdRateModel> getUsdRate();

  @GET(accountsApi)
  Future<List<PaymentAccountModel>> getAccounts();

  @GET(searchClientApi)
  Future<ClientModel> searchClient(@Path('term') String term);

  @POST(createClientApi)
  Future<ClientModel> createClient(@Body() CreateClientRequestModel request);

  @GET(productLookupApi)
  Future<dynamic> getProduct(
    @Path('type') String type,
    @Path('id') int id,
  );

  @POST(submitApi)
  Future<DiamondSellResultModel> submitSell(
    @Body() DiamondSellRequestModel request,
  );

  @GET(unifiedSellHistoryApi)
  Future<dynamic> getUnifiedSellHistory();
}
