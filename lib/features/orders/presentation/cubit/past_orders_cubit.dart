import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_model.dart';
import 'package:kenooz_worker_app/features/orders/data/repo/orders_repo.dart';
import 'past_orders_state.dart';

class PastOrdersCubit extends Cubit<PastOrdersState<List<OrderModel>>> {
  final OrdersRepo _repo;

  PastOrdersCubit(this._repo) : super(const PastOrdersState.initial());

  Future<void> fetchPastOrders() async {
    emit(const PastOrdersState.loading());
    final response = await _repo.fetchPastOrders();
    response.when(
      success: (data) => emit(PastOrdersState.success(data)),
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
        emit(PastOrdersState.error(messages: messages));
      },
    );
  }
}
