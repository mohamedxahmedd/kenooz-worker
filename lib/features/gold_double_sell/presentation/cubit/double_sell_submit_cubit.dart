import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/repo/gold_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_submit_state.dart';

class DoubleSellSubmitCubit extends Cubit<DoubleSellSubmitState> {
  final GoldDoubleSellRepo _repo;

  DoubleSellSubmitCubit(this._repo) : super(const DoubleSellSubmitState.initial());

  Future<void> submitSell(DoubleSellRequestModel request) async {
    emit(const DoubleSellSubmitState.loading());

    final response = await _repo.submitDoubleSell(request);
    response.when(
      success: (data) => emit(DoubleSellSubmitState.success(data)),
      failure: (failure) {
        emit(
          DoubleSellSubmitState.error(
            messages: _extractMessages(failure.errorModel),
          ),
        );
      },
    );
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) {
      return errorModel.messages;
    }
    if (errorModel is BaseErrorModel) {
      return [errorModel.message ?? 'An unexpected error occurred'];
    }
    return ['An unexpected error occurred'];
  }
}
