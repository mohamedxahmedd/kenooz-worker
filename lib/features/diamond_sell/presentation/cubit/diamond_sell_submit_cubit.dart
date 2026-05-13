import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_request_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/repo/diamond_sell_repo.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_submit_state.dart';

class DiamondSellSubmitCubit extends Cubit<DiamondSellSubmitState> {
  final DiamondSellRepo _repo;

  DiamondSellSubmitCubit(this._repo)
    : super(const DiamondSellSubmitState.initial());

  Future<void> submitSell(DiamondSellRequestModel request) async {
    emit(const DiamondSellSubmitState.loading());

    final response = await _repo.submitSell(request);
    response.when(
      success: (data) => emit(DiamondSellSubmitState.success(data)),
      failure: (failure) {
        emit(
          DiamondSellSubmitState.error(
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
