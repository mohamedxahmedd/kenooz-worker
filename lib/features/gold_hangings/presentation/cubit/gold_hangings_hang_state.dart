import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hang_response_model.dart';

part 'gold_hangings_hang_state.freezed.dart';

@freezed
class GoldHangingsHangState with _$GoldHangingsHangState {
  const factory GoldHangingsHangState.initial() = _Initial;
  const factory GoldHangingsHangState.loading() = Loading;
  const factory GoldHangingsHangState.success(HangResponseModel data) = Success;
  const factory GoldHangingsHangState.error({required List<String> messages}) =
      Error;
}
