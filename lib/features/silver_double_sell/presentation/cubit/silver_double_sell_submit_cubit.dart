import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_double_sell_request_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/repo/silver_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_double_sell_submit_state.dart';

class SilverDoubleSellSubmitCubit extends Cubit<SilverDoubleSellSubmitState> {
  final SilverDoubleSellRepo _repo;

  SilverDoubleSellSubmitCubit(this._repo)
    : super(const SilverDoubleSellSubmitState.initial());

  Future<void> submitSell(SilverDoubleSellRequestModel request) async {
    emit(const SilverDoubleSellSubmitState.loading());

    final response = await _repo.submitDoubleSell(request);
    response.when(
      success: (data) => emit(SilverDoubleSellSubmitState.success(data)),
      failure: (failure) {
        emit(
          SilverDoubleSellSubmitState.error(
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
