import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_gold_request_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_silver_request_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_usd_request_model.dart';
import 'package:kenooz_worker_app/features/home/data/repo/home_repo.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/update_rates_state.dart';

class UpdateRatesCubit extends Cubit<UpdateRatesState> {
  final HomeRepo _homeRepo;
  UpdateRatesCubit(this._homeRepo) : super(const UpdateRatesState.initial());

  final TextEditingController usdController = TextEditingController();
  final TextEditingController goldController = TextEditingController();
  final TextEditingController silverController = TextEditingController();

  final GlobalKey<FormState> usdFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> goldFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> silverFormKey = GlobalKey<FormState>();

  Future<void> emitUpdateUsdStates() async {
    if (!usdFormKey.currentState!.validate()) return;
    emit(const UpdateRatesState.loading());
    final response = await _homeRepo.updateUsdRate(
      UpdateUsdRequestModel(price: double.parse(usdController.text)),
    );
    response.when(
      success: (data) => emit(UpdateRatesState.success(data)),
      failure: (error) => _emitError(error),
    );
  }

  Future<void> emitUpdateGoldStates() async {
    if (!goldFormKey.currentState!.validate()) return;
    emit(const UpdateRatesState.loading());
    final response = await _homeRepo.updateGoldPrice(
      UpdateGoldRequestModel(price21: double.parse(goldController.text)),
    );
    response.when(
      success: (data) => emit(UpdateRatesState.success(data)),
      failure: (error) => _emitError(error),
    );
  }

  Future<void> emitUpdateSilverStates() async {
    if (!silverFormKey.currentState!.validate()) return;
    emit(const UpdateRatesState.loading());
    final response = await _homeRepo.updateSilverPrice(
      UpdateSilverRequestModel(price: double.parse(silverController.text)),
    );
    response.when(
      success: (data) => emit(UpdateRatesState.success(data)),
      failure: (error) => _emitError(error),
    );
  }

  void _emitError(dynamic error) {
    if (error.errorModel is BaseErrorModel) {
      emit(UpdateRatesState.error(
          messages: [error.errorModel.message ?? 'Unknown error']));
    } else if (error.errorModel is ListErrorModel) {
      emit(UpdateRatesState.error(messages: error.errorModel.messages));
    } else {
      emit(const UpdateRatesState.error(messages: ['Unknown error']));
    }
  }

  @override
  Future<void> close() {
    usdController.dispose();
    goldController.dispose();
    silverController.dispose();
    return super.close();
  }
}
