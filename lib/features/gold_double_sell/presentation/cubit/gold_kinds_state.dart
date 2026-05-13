import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_kind_model.dart';

part 'gold_kinds_state.freezed.dart';

@freezed
class GoldKindsState with _$GoldKindsState {
  const factory GoldKindsState.initial() = _Initial;
  const factory GoldKindsState.loading() = Loading;
  const factory GoldKindsState.success(List<GoldKindModel> kinds) = Success;
  const factory GoldKindsState.error({required List<String> messages}) = Error;
}
