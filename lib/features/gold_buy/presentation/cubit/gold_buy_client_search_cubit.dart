import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/repo/gold_buy_repo.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_client_search_state.dart';

class GoldBuyClientSearchCubit extends Cubit<GoldBuyClientSearchState> {
  final GoldBuyRepo _repo;
  GoldBuyClientSearchCubit(this._repo) : super(const GoldBuyClientSearchState.initial());

  Future<void> searchClient(String term) async {
    final trimmedTerm = term.trim();
    emit(const GoldBuyClientSearchState.loading());
    final response = await _repo.searchClient(trimmedTerm);
    response.when(
      success: (client) => emit(GoldBuyClientSearchState.found(client)),
      failure: (failure) {
        if (_isNotFound(failure.errorModel)) {
          emit(const GoldBuyClientSearchState.notFound());
        } else {
          emit(GoldBuyClientSearchState.error(messages: _extractMessages(failure.errorModel)));
        }
      },
    );
  }

  Future<void> createClient(CreateClientRequestModel request) async {
    emit(const GoldBuyClientSearchState.loading());
    final response = await _repo.createClient(request);
    response.when(
      success: (client) => emit(GoldBuyClientSearchState.created(client)),
      failure: (failure) => emit(GoldBuyClientSearchState.error(messages: _extractMessages(failure.errorModel))),
    );
  }

  void clearClient() {
    emit(const GoldBuyClientSearchState.initial());
  }

  bool _isNotFound(dynamic errorModel) {
    if (errorModel is BaseErrorModel) {
      return errorModel.message?.toLowerCase().contains('not found') ?? false;
    }
    if (errorModel is ListErrorModel) {
      return errorModel.messages.any((m) => m.toLowerCase().contains('not found'));
    }
    return false;
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) return [errorModel.message ?? 'An unexpected error occurred'];
    return ['An unexpected error occurred'];
  }
}
