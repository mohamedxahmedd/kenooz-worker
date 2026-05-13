import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_double_sell_response_model.dart';

part 'silver_double_sell_submit_state.freezed.dart';

@freezed
class SilverDoubleSellSubmitState with _$SilverDoubleSellSubmitState {
  const factory SilverDoubleSellSubmitState.initial() = _Initial;
  const factory SilverDoubleSellSubmitState.loading() = Loading;
  const factory SilverDoubleSellSubmitState.success(
    SilverDoubleSellResponseModel data,
  ) = Success;
  const factory SilverDoubleSellSubmitState.error({
    required List<String> messages,
  }) = Error;
}
