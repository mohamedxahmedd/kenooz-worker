import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/features/orders/data/models/orders_list_response_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_action_request_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_status_request_model.dart';
import 'package:retrofit/retrofit.dart';

part 'orders_api_service.g.dart';

@RestApi()
abstract class OrdersApiService {
  factory OrdersApiService(Dio dio, {String baseUrl}) = _OrdersApiService;

  @POST('orders/worker/current')
  Future<OrdersListResponseModel> getCurrentOrders();

  @POST('orders/worker/ongoing')
  Future<OrdersListResponseModel> getOngoingOrders();

  @POST('orders/worker/past')
  Future<OrdersListResponseModel> getPastOrders();

  @POST('worker/orders/accept')
  Future<String> acceptOrder(@Body() OrderActionRequestModel body);

  @POST('worker/orders/reject')
  Future<String> rejectOrder(@Body() OrderActionRequestModel body);

  @POST('worker/orders/status')
  Future<String> changeOrderStatus(@Body() OrderStatusRequestModel body);

  @POST('worker/orders/markaspaid')
  Future<String> markOrderAsPaid(@Body() OrderActionRequestModel body);

  @POST('worker/orders/day')
  Future<String> getDayStats();

  @POST('worker/orders/week')
  Future<String> getWeekStats();

  @POST('worker/orders/month')
  Future<String> getMonthStats();

  @POST('worker/orders/year')
  Future<String> getYearStats();
}
