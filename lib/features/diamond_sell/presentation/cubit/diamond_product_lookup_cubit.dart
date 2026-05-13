import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_product_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_product_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/repo/diamond_sell_repo.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_product_lookup_state.dart';

class DiamondProductLookupCubit extends Cubit<DiamondProductLookupState> {
  final DiamondSellRepo _repo;

  DiamondProductLookupCubit(this._repo)
    : super(const DiamondProductLookupState.initial());

  Future<void> lookupProduct(String type, int id) async {
    if (id <= 0) {
      emit(
        const DiamondProductLookupState.error(
          messages: ['Please enter a valid ID'],
        ),
      );
      return;
    }

    emit(const DiamondProductLookupState.loading());

    final response = await _repo.fetchProduct(type, id);
    response.when(
      success: (productMap) {
        if (_isInvalidType(type)) {
          emit(const DiamondProductLookupState.invalidType());
          return;
        }

        if (type.toLowerCase() == 'diamond') {
          final product = DiamondProductModel.fromJson(productMap);
          if (product.isSold) {
            emit(const DiamondProductLookupState.alreadySold());
            return;
          }
          emit(DiamondProductLookupState.foundDiamond(product));
        } else if (type.toLowerCase() == 'stone') {
          final product = StoneProductModel.fromJson(productMap);
          if (product.isSold) {
            emit(const DiamondProductLookupState.alreadySold());
            return;
          }
          emit(DiamondProductLookupState.foundStone(product));
        } else {
          emit(const DiamondProductLookupState.invalidType());
        }
      },
      failure: (failure) {
        if (_isNotFound(failure.errorModel)) {
          emit(const DiamondProductLookupState.notFound());
          return;
        }
        if (_isAlreadySoldMessage(failure.errorModel)) {
          emit(const DiamondProductLookupState.alreadySold());
          return;
        }
        emit(
          DiamondProductLookupState.error(
            messages: _extractMessages(failure.errorModel),
          ),
        );
      },
    );
  }

  void clearLookup() {
    emit(const DiamondProductLookupState.initial());
  }

  bool _isInvalidType(String type) {
    return type.toLowerCase() != 'diamond' && type.toLowerCase() != 'stone';
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
