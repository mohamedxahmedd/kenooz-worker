import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/create_silver_vendor_request_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/repo/silver_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_create_vendor_state.dart';

class SilverCreateVendorCubit extends Cubit<SilverCreateVendorState> {
  final SilverDoubleSellRepo _repo;

  SilverCreateVendorCubit(this._repo)
    : super(const SilverCreateVendorState.initial());

  Future<void> createVendor(CreateSilverVendorRequestModel request) async {
    emit(const SilverCreateVendorState.loading());

    final response = await _repo.createVendor(request);
    response.when(
      success: (vendor) => emit(SilverCreateVendorState.success(vendor)),
      failure: (failure) {
        emit(
          SilverCreateVendorState.error(
            messages: _extractMessages(failure.errorModel),
          ),
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
