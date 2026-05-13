import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hang_request_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/unhang_request_model.dart';
import 'package:retrofit/retrofit.dart';

part 'gold_hangings_api_service.g.dart';

@RestApi()
abstract class GoldHangingsApiService {
  static const String hangedListApi = 'worker/golds/hangings';
  static const String availableListApi = 'worker/golds/hangings/available';
  static const String hangApi = 'worker/golds/hangings/hang';
  static const String unhangApi = 'worker/golds/hangings/unhang';

  factory GoldHangingsApiService(Dio dio, {String baseUrl}) =
      _GoldHangingsApiService;

  @GET(hangedListApi)
  Future<dynamic> getHangedList();

  @GET(availableListApi)
  Future<dynamic> getAvailableList();

  @POST(hangApi)
  Future<dynamic> hangGolds(@Body() HangRequestModel request);

  @POST(unhangApi)
  Future<dynamic> unhangGold(@Body() UnhangRequestModel request);
}
