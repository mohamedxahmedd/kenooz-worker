import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/orders/data/repo/orders_repo.dart';
import 'order_action_state.dart';

class OrderActionCubit extends Cubit<OrderActionState<String>> {
  final OrdersRepo _repo;

  OrderActionCubit(this._repo) : super(const OrderActionState.initial());

  Future<void> emitAcceptOrder(int id) async {
    emit(const OrderActionState.loading());
    final response = await _repo.acceptOrder(id);
    response.when(
      success: (data) => emit(OrderActionState.success(data)),
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
        emit(OrderActionState.error(messages: messages));
      },
    );
  }

  Future<void> emitRejectOrder(int id) async {
    emit(const OrderActionState.loading());
    final response = await _repo.rejectOrder(id);
    response.when(
      success: (data) => emit(OrderActionState.success(data)),
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
        emit(OrderActionState.error(messages: messages));
      },
    );
  }

  Future<void> emitChangeStatus(int id, String status) async {
    emit(const OrderActionState.loading());
    final response = await _repo.changeOrderStatus(id, status);
    response.when(
      success: (data) => emit(OrderActionState.success(data)),
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
        emit(OrderActionState.error(messages: messages));
      },
    );
  }

  Future<void> emitMarkAsPaid(int id) async {
    emit(const OrderActionState.loading());
    final response = await _repo.markOrderAsPaid(id);
    response.when(
      success: (data) => emit(OrderActionState.success(data)),
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
        emit(OrderActionState.error(messages: messages));
      },
    );
  }
}
