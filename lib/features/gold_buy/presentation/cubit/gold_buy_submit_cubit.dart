import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_request_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/repo/gold_buy_repo.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_submit_state.dart';

class GoldBuySubmitCubit extends Cubit<GoldBuySubmitState> {
  final GoldBuyRepo _repo;
  GoldBuySubmitCubit(this._repo) : super(const GoldBuySubmitState.initial());

  Future<void> submitGoldBuy(GoldBuyRequestModel request) async {
    emit(const GoldBuySubmitState.loading());
    final response = await _repo.submitGoldBuy(request);
    response.when(
      success: (data) => emit(GoldBuySubmitState.success(data)),
      failure: (failure) => emit(GoldBuySubmitState.error(messages: _extractMessages(failure.errorModel))),
    );
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) return [errorModel.message ?? 'An unexpected error occurred'];
    return ['An unexpected error occurred'];
  }
}
