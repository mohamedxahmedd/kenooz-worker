import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/repo/diamond_sell_repo.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_client_search_state.dart';

class DiamondClientSearchCubit extends Cubit<DiamondClientSearchState> {
  final DiamondSellRepo _repo;

  DiamondClientSearchCubit(this._repo)
    : super(const DiamondClientSearchState.initial());

  Future<void> searchClient(String term) async {
    final normalizedTerm = term.trim();
    if (normalizedTerm.isEmpty) {
      emit(const DiamondClientSearchState.initial());
      return;
    }

    emit(const DiamondClientSearchState.loading());

    final response = await _repo.searchClient(normalizedTerm);
    response.when(
      success: (client) => emit(DiamondClientSearchState.found(client)),
      failure: (failure) {
        if (_isNotFound(failure.errorModel)) {
          emit(const DiamondClientSearchState.notFound());
          return;
        }
        emit(
          DiamondClientSearchState.error(
            messages: _extractMessages(failure.errorModel),
          ),
        );
      },
    );
  }

  Future<void> createClient(CreateClientRequestModel request) async {
    emit(const DiamondClientSearchState.loading());

    final response = await _repo.createClient(request);
    response.when(
      success: (client) => emit(DiamondClientSearchState.created(client)),
      failure: (failure) {
        emit(
          DiamondClientSearchState.error(
            messages: _extractMessages(failure.errorModel),
          ),
        );
      },
    );
  }

  void clearClient() {
    emit(const DiamondClientSearchState.initial());
  }

  bool _isNotFound(dynamic errorModel) {
    if (errorModel is BaseErrorModel) {
      final message = (errorModel.message ?? '').toLowerCase();
      return message.contains('not found');
    }
    if (errorModel is ListErrorModel) {
      return errorModel.messages.any(
        (message) => message.toLowerCase().contains('not found'),
      );
    }
    return false;
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) {
      return errorModel.messages;
    }
    if (errorModel is BaseErrorModel) {
      return [errorModel.message ?? 'An unexpected error occurred'];
    }
    return ['An unexpected error occurred'];
  }
}
