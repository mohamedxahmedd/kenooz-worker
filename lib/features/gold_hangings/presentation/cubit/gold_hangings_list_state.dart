import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hanged_gold_model.dart';

part 'gold_hangings_list_state.freezed.dart';

@freezed
class GoldHangingsListState with _$GoldHangingsListState {
  const factory GoldHangingsListState.initial() = _Initial;
  const factory GoldHangingsListState.loading() = Loading;
  const factory GoldHangingsListState.success(List<HangedGoldModel> items) =
      Success;
  const factory GoldHangingsListState.error(String message) = Error;
}
