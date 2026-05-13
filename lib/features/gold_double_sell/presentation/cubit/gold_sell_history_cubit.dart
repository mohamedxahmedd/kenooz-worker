import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/repo/gold_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_sell_history_state.dart';

class GoldSellHistoryCubit extends Cubit<GoldSellHistoryState> {
  final GoldDoubleSellRepo _repo;

  GoldSellHistoryCubit(this._repo)
      : super(const GoldSellHistoryState.initial());

  Future<void> fetchHistory() async {
    emit(const GoldSellHistoryState.loading());
    final result = await _repo.fetchSellHistory();
    result.when(
      success: (sells) => emit(GoldSellHistoryState.success(sells)),
      failure: (f) => emit(GoldSellHistoryState.error(_extractMessage(f.errorModel))),
    );
  }

  String _extractMessage(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages.first;
    if (errorModel is BaseErrorModel) {
      return errorModel.message ?? 'An unexpected error occurred';
    }
    return 'An unexpected error occurred';
  }
}
