import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/repo/silver_buy_repo.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/cubit/silver_buy_preload_state.dart';

class SilverBuyPreloadCubit extends Cubit<SilverBuyPreloadState> {
  final SilverBuyRepo _repo;
  SilverBuyPreloadCubit(this._repo) : super(const SilverBuyPreloadState.initial());

  Future<void> fetchPreloadData() async {
    emit(const SilverBuyPreloadState.loading());
    final response = await _repo.fetchPreloadData();
    response.when(
      success: (data) => emit(SilverBuyPreloadState.success(data)),
      failure: (failure) => emit(SilverBuyPreloadState.error(messages: _extractMessages(failure.errorModel))),
    );
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) return [errorModel.message ?? 'An unexpected error occurred'];
    return ['An unexpected error occurred'];
  }
}
