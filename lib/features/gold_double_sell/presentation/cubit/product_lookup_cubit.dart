import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/repo/gold_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/product_lookup_state.dart';

class ProductLookupCubit extends Cubit<ProductLookupState> {
  final GoldDoubleSellRepo _repo;

  ProductLookupCubit(this._repo) : super(const ProductLookupState.initial());

  Future<void> lookupProduct(int id) async {
    if (id <= 0) {
      emit(
        const ProductLookupState.error(messages: ['Please enter a valid ID']),
      );
      return;
    }

    emit(const ProductLookupState.loading());

    final response = await _repo.fetchProduct(id);
    response.when(
      success: (product) {
        if (product.isSold) {
          emit(const ProductLookupState.alreadySold());
          return;
        }
        emit(ProductLookupState.found(product));
      },
      failure: (failure) {
        if (_isNotFound(failure.errorModel)) {
          emit(const ProductLookupState.notFound());
          return;
        }

        if (_isAlreadySoldMessage(failure.errorModel)) {
          emit(const ProductLookupState.alreadySold());
          return;
        }

        emit(
          ProductLookupState.error(
            messages: _extractMessages(failure.errorModel),
          ),
        );
      },
    );
  }

  void clearLookup() {
    emit(const ProductLookupState.initial());
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

  bool _isAlreadySoldMessage(dynamic errorModel) {
    final matchers = ['already sold', 'sold before', 'تم بيعه', 'مباع'];

    if (errorModel is BaseErrorModel) {
      final message = (errorModel.message ?? '').toLowerCase();
      return matchers.any((matcher) => message.contains(matcher));
    }

    if (errorModel is ListErrorModel) {
      return errorModel.messages.any((message) {
        final lowerMessage = message.toLowerCase();
        return matchers.any((matcher) => lowerMessage.contains(matcher));
      });
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
