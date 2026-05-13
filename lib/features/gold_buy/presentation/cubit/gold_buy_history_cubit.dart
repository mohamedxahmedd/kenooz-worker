import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/repo/gold_buy_repo.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_history_state.dart';

class GoldBuyHistoryCubit extends Cubit<GoldBuyHistoryState> {
  final GoldBuyRepo _repo;
  GoldBuyHistoryCubit(this._repo) : super(const GoldBuyHistoryState.initial());

  Future<void> fetchHistory() async {
    emit(const GoldBuyHistoryState.loading());
    final response = await _repo.fetchBuyHistory();
    response.when(
      success: (buys) => emit(GoldBuyHistoryState.success(buys)),
      failure: (failure) => emit(GoldBuyHistoryState.error(_extractMessage(failure.errorModel))),
    );
  }

  String _extractMessage(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages.first;
    if (errorModel is BaseErrorModel) return errorModel.message ?? 'An unexpected error occurred';
    return 'An unexpected error occurred';
  }
}
