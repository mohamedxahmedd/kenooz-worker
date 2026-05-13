import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/repo/silver_buy_repo.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/cubit/silver_buy_history_state.dart';

class SilverBuyHistoryCubit extends Cubit<SilverBuyHistoryState> {
  final SilverBuyRepo _repo;
  SilverBuyHistoryCubit(this._repo) : super(const SilverBuyHistoryState.initial());

  Future<void> fetchHistory() async {
    emit(const SilverBuyHistoryState.loading());
    final response = await _repo.fetchBuyHistory();
    response.when(
      success: (buys) => emit(SilverBuyHistoryState.success(buys)),
      failure: (failure) => emit(SilverBuyHistoryState.error(_extractMessage(failure.errorModel))),
    );
  }

  String _extractMessage(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages.first;
    if (errorModel is BaseErrorModel) return errorModel.message ?? 'An unexpected error occurred';
    return 'An unexpected error occurred';
  }
}
