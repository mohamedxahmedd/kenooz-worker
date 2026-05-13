import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/repo/diamond_sell_repo.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_history_state.dart';

class DiamondSellHistoryCubit extends Cubit<DiamondSellHistoryState> {
  final DiamondSellRepo _repo;

  DiamondSellHistoryCubit(this._repo)
      : super(const DiamondSellHistoryState.initial());

  Future<void> fetchHistory() async {
    emit(const DiamondSellHistoryState.loading());
    final result = await _repo.fetchSellHistory();
    result.when(
      success: (sells) => emit(DiamondSellHistoryState.success(sells)),
      failure: (f) => emit(DiamondSellHistoryState.error(_extractMessage(f.errorModel))),
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
