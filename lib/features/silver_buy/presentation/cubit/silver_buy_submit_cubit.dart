import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_request_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/repo/silver_buy_repo.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/cubit/silver_buy_submit_state.dart';

class SilverBuySubmitCubit extends Cubit<SilverBuySubmitState> {
  final SilverBuyRepo _repo;
  SilverBuySubmitCubit(this._repo) : super(const SilverBuySubmitState.initial());

  Future<void> submitSilverBuy(SilverBuyRequestModel request) async {
    emit(const SilverBuySubmitState.loading());
    final response = await _repo.submitSilverBuy(request);
    response.when(
      success: (data) => emit(SilverBuySubmitState.success(data)),
      failure: (failure) => emit(SilverBuySubmitState.error(messages: _extractMessages(failure.errorModel))),
    );
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) return [errorModel.message ?? 'An unexpected error occurred'];
    return ['An unexpected error occurred'];
  }
}
