import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/repo/gold_buy_repo.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_preload_state.dart';

class GoldBuyPreloadCubit extends Cubit<GoldBuyPreloadState> {
  final GoldBuyRepo _repo;
  GoldBuyPreloadCubit(this._repo) : super(const GoldBuyPreloadState.initial());

  Future<void> fetchPreloadData() async {
    emit(const GoldBuyPreloadState.loading());
    final response = await _repo.fetchPreloadData();
    response.when(
      success: (data) => emit(GoldBuyPreloadState.success(data)),
      failure: (failure) => emit(GoldBuyPreloadState.error(messages: _extractMessages(failure.errorModel))),
    );
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) return [errorModel.message ?? 'An unexpected error occurred'];
    return ['An unexpected error occurred'];
  }
}
