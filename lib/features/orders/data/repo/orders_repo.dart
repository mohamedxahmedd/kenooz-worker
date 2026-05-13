import 'dart:convert';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_action_request_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_status_request_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_stats_model.dart';
import 'package:kenooz_worker_app/features/orders/data/remote/orders_api_service.dart';

class OrdersRepo {
  final OrdersApiService _ordersApiService;

  OrdersRepo(this._ordersApiService);

  Future<ApiResult<List<OrderModel>>> fetchCurrentOrders() async {
    try {
      final result = await _ordersApiService.getCurrentOrders();
      return ApiResult.success(result.orders);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<OrderModel>>> fetchOngoingOrders() async {
    try {
      final result = await _ordersApiService.getOngoingOrders();
      return ApiResult.success(result.orders);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<OrderModel>>> fetchPastOrders() async {
    try {
      final result = await _ordersApiService.getPastOrders();
      return ApiResult.success(result.orders);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<String>> acceptOrder(int id) async {
    try {
      final result = await _ordersApiService.acceptOrder(OrderActionRequestModel(id: id));
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<String>> rejectOrder(int id) async {
    try {
      final result = await _ordersApiService.rejectOrder(OrderActionRequestModel(id: id));
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<String>> changeOrderStatus(int id, String status) async {
    try {
      final result = await _ordersApiService.changeOrderStatus(
        OrderStatusRequestModel(id: id, status: status),
      );
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<String>> markOrderAsPaid(int id) async {
    try {
      final result = await _ordersApiService.markOrderAsPaid(OrderActionRequestModel(id: id));
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<OrderStatsModel>> fetchDayStats() async {
    try {
      final raw = await _ordersApiService.getDayStats();
      if (raw.trim() == 'nothing to show') {
        return ApiResult.success(OrderStatsModel.empty());
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ApiResult.success(OrderStatsModel.fromJson(json, 'day'));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<OrderStatsModel>> fetchWeekStats() async {
    try {
      final raw = await _ordersApiService.getWeekStats();
      if (raw.trim() == 'nothing to show') {
        return ApiResult.success(OrderStatsModel.empty());
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ApiResult.success(OrderStatsModel.fromJson(json, 'week'));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<OrderStatsModel>> fetchMonthStats() async {
    try {
      final raw = await _ordersApiService.getMonthStats();
      if (raw.trim() == 'nothing to show') {
        return ApiResult.success(OrderStatsModel.empty());
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ApiResult.success(OrderStatsModel.fromJson(json, 'month'));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<OrderStatsModel>> fetchYearStats() async {
    try {
      final raw = await _ordersApiService.getYearStats();
      if (raw.trim() == 'nothing to show') {
        return ApiResult.success(OrderStatsModel.empty());
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ApiResult.success(OrderStatsModel.fromJson(json, 'year'));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
