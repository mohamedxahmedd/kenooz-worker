import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_response_model.dart';

part 'double_sell_submit_state.freezed.dart';

@freezed
class DoubleSellSubmitState with _$DoubleSellSubmitState {
  const factory DoubleSellSubmitState.initial() = _Initial;
  const factory DoubleSellSubmitState.loading() = Loading;
  const factory DoubleSellSubmitState.success(DoubleSellResponseModel data) =
      Success;
  const factory DoubleSellSubmitState.error({required List<String> messages}) =
      Error;
}
