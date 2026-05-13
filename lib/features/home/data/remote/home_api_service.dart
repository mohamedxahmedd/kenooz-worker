import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/home/data/models/gold_rates_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/silver_rates_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_gold_request_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_price_response_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_silver_request_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_usd_request_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/usd_rate_model.dart';
import 'package:retrofit/retrofit.dart';

part 'home_api_service.g.dart';

@RestApi()
abstract class HomeApiService {
  static const String usdRateApi = 'worker/gold/usd';
  static const String goldRatesApi = 'worker/gold/rates';
  static const String silverRatesApi = 'worker/silver/rates';
  static const String updateUsdApi = 'worker/prices/usd';
  static const String updateGoldApi = 'worker/prices/gold';
  static const String updateSilverApi = 'worker/prices/silver';

  factory HomeApiService(Dio dio, {String baseUrl}) = _HomeApiService;

  @GET(usdRateApi)
  Future<UsdRateModel> getUsdRate();

  @GET(goldRatesApi)
  Future<GoldRatesModel> getGoldRates();

  @GET(silverRatesApi)
  Future<SilverRatesModel> getSilverRates();

  @POST(updateUsdApi)
  Future<UpdatePriceResponseModel> updateUsdRate(
    @Body() UpdateUsdRequestModel body,
  );

  @POST(updateGoldApi)
  Future<UpdatePriceResponseModel> updateGoldPrice(
    @Body() UpdateGoldRequestModel body,
  );

  @POST(updateSilverApi)
  Future<UpdatePriceResponseModel> updateSilverPrice(
    @Body() UpdateSilverRequestModel body,
  );
}
