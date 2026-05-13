import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/repo/silver_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_sell_history_state.dart';

class SilverSellHistoryCubit extends Cubit<SilverSellHistoryState> {
  final SilverDoubleSellRepo _repo;

  SilverSellHistoryCubit(this._repo)
      : super(const SilverSellHistoryState.initial());

  Future<void> fetchHistory() async {
    emit(const SilverSellHistoryState.loading());
    final result = await _repo.fetchSellHistory();
    result.when(
      success: (sells) => emit(SilverSellHistoryState.success(sells)),
      failure: (f) => emit(SilverSellHistoryState.error(_extractMessage(f.errorModel))),
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
