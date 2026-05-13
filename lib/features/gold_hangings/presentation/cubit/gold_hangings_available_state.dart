import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/available_gold_model.dart';

part 'gold_hangings_available_state.freezed.dart';

@freezed
class GoldHangingsAvailableState with _$GoldHangingsAvailableState {
  const factory GoldHangingsAvailableState.initial() = _Initial;
  const factory GoldHangingsAvailableState.loading() = Loading;
  const factory GoldHangingsAvailableState.success(
    List<AvailableGoldModel> items,
  ) = Success;
  const factory GoldHangingsAvailableState.error(String message) = Error;
}
