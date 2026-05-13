import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/repo/silver_buy_repo.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/cubit/silver_buy_client_search_state.dart';

class SilverBuyClientSearchCubit extends Cubit<SilverBuyClientSearchState> {
  final SilverBuyRepo _repo;
  SilverBuyClientSearchCubit(this._repo) : super(const SilverBuyClientSearchState.initial());

  Future<void> searchClient(String term) async {
    final trimmedTerm = term.trim();
    emit(const SilverBuyClientSearchState.loading());
    final response = await _repo.searchClient(trimmedTerm);
    response.when(
      success: (client) => emit(SilverBuyClientSearchState.found(client)),
      failure: (failure) {
        if (_isNotFound(failure.errorModel)) {
          emit(const SilverBuyClientSearchState.notFound());
        } else {
          emit(SilverBuyClientSearchState.error(messages: _extractMessages(failure.errorModel)));
        }
      },
    );
  }

  Future<void> createClient(CreateClientRequestModel request) async {
    emit(const SilverBuyClientSearchState.loading());
    final response = await _repo.createClient(request);
    response.when(
      success: (client) => emit(SilverBuyClientSearchState.created(client)),
      failure: (failure) => emit(SilverBuyClientSearchState.error(messages: _extractMessages(failure.errorModel))),
    );
  }

  void clearClient() {
    emit(const SilverBuyClientSearchState.initial());
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
