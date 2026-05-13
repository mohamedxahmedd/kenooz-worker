import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_vendor_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/repo/gold_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/create_vendor_state.dart';

class CreateVendorCubit extends Cubit<CreateVendorState> {
  final GoldDoubleSellRepo _repo;

  CreateVendorCubit(this._repo) : super(const CreateVendorState.initial());

  Future<void> createVendor(CreateVendorRequestModel request) async {
    emit(const CreateVendorState.loading());

    final response = await _repo.createVendor(request);
    response.when(
      success: (vendor) => emit(CreateVendorState.success(vendor)),
      failure: (failure) {
        emit(
          CreateVendorState.error(messages: _extractMessages(failure.errorModel)),
        );
      },
    );
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
