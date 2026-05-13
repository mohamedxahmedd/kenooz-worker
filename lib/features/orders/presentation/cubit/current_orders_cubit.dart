import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_model.dart';
import 'package:kenooz_worker_app/features/orders/data/repo/orders_repo.dart';
import 'current_orders_state.dart';

class CurrentOrdersCubit extends Cubit<CurrentOrdersState<List<OrderModel>>> {
  final OrdersRepo _repo;

  CurrentOrdersCubit(this._repo) : super(const CurrentOrdersState.initial());

  Future<void> fetchCurrentOrders() async {
    emit(const CurrentOrdersState.loading());
    final response = await _repo.fetchCurrentOrders();
    response.when(
      success: (data) => emit(CurrentOrdersState.success(data)),
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
        emit(CurrentOrdersState.error(messages: messages));
      },
    );
  }
}
