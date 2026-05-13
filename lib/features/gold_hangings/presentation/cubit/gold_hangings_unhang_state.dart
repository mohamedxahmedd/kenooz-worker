import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/unhang_response_model.dart';

part 'gold_hangings_unhang_state.freezed.dart';

@freezed
class GoldHangingsUnhangState with _$GoldHangingsUnhangState {
  const factory GoldHangingsUnhangState.initial() = _Initial;
  const factory GoldHangingsUnhangState.loading(int goldId) = Loading;
  const factory GoldHangingsUnhangState.success(UnhangResponseModel data) =
      Success;
  const factory GoldHangingsUnhangState.error({
    required List<String> messages,
  }) = Error;
}
