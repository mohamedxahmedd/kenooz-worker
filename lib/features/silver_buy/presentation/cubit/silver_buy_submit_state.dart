import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_response_model.dart';

part 'silver_buy_submit_state.freezed.dart';

@freezed
class SilverBuySubmitState with _$SilverBuySubmitState {
  const factory SilverBuySubmitState.initial() = _Initial;
  const factory SilverBuySubmitState.loading() = Loading;
  const factory SilverBuySubmitState.success(SilverBuyResponseModel data) = Success;
  const factory SilverBuySubmitState.error({
    required List<String> messages,
  }) = Error;
}
