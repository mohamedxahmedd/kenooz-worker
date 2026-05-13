import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_stats_model.dart';
import 'package:kenooz_worker_app/features/orders/data/repo/orders_repo.dart';
import 'orders_stats_state.dart';

class OrdersStatsCubit extends Cubit<OrdersStatsState<OrderStatsModel>> {
  final OrdersRepo _repo;
  String currentPeriod = 'day';

  OrdersStatsCubit(this._repo) : super(const OrdersStatsState.initial());

  Future<void> fetchDayStats() async {
    emit(const OrdersStatsState.loading());
    currentPeriod = 'day';
    final response = await _repo.fetchDayStats();
    response.when(
      success: (data) => emit(OrdersStatsState.success(data)),
      failure: (error) {
        final errorModel = error.errorModel;
        List<String> messages;
        if (errorModel is ListErrorModel) {
          messages = errorModel.messages;
        } else if (errorModel is BaseErrorModel) {
          messages = [errorModel.message ?? 'An unexpected error occurred'];
        } else {
          messages = ['An unexpected error occurred'];
        }
        emit(OrdersStatsState.error(messages: messages));
      },
    );
  }

  Future<void> fetchWeekStats() async {
    emit(const OrdersStatsState.loading());
    currentPeriod = 'week';
    final response = await _repo.fetchWeekStats();
    response.when(
      success: (data) => emit(OrdersStatsState.success(data)),
      failure: (error) {
        final errorModel = error.errorModel;
        List<String> messages;
        if (errorModel is ListErrorModel) {
          messages = errorModel.messages;
        } else if (errorModel is BaseErrorModel) {
          messages = [errorModel.message ?? 'An unexpected error occurred'];
        } else {
          messages = ['An unexpected error occurred'];
        }
        emit(OrdersStatsState.error(messages: messages));
      },
    );
  }

  Future<void> fetchMonthStats() async {
    emit(const OrdersStatsState.loading());
    currentPeriod = 'month';
    final response = await _repo.fetchMonthStats();
    response.when(
      success: (data) => emit(OrdersStatsState.success(data)),
      failure: (error) {
        final errorModel = error.errorModel;
        List<String> messages;
        if (errorModel is ListErrorModel) {
          messages = errorModel.messages;
        } else if (errorModel is BaseErrorModel) {
          messages = [errorModel.message ?? 'An unexpected error occurred'];
        } else {
          messages = ['An unexpected error occurred'];
        }
        emit(OrdersStatsState.error(messages: messages));
      },
    );
  }

  Future<void> fetchYearStats() async {
    emit(const OrdersStatsState.loading());
    currentPeriod = 'year';
    final response = await _repo.fetchYearStats();
    response.when(
      success: (data) => emit(OrdersStatsState.success(data)),
      failure: (error) {
        final errorModel = error.errorModel;
        List<String> messages;
        if (errorModel is ListErrorModel) {
          messages = errorModel.messages;
        } else if (errorModel is BaseErrorModel) {
          messages = [errorModel.message ?? 'An unexpected error occurred'];
        } else {
          messages = ['An unexpected error occurred'];
        }
        emit(OrdersStatsState.error(messages: messages));
      },
    );
  }
}
