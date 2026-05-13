import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';

part 'diamond_client_search_state.freezed.dart';

@freezed
class DiamondClientSearchState with _$DiamondClientSearchState {
  const factory DiamondClientSearchState.initial() = _Initial;
  const factory DiamondClientSearchState.loading() = Loading;
  const factory DiamondClientSearchState.found(ClientModel client) = Found;
  const factory DiamondClientSearchState.notFound() = NotFound;
  const factory DiamondClientSearchState.created(ClientModel client) = Created;
  const factory DiamondClientSearchState.error({required List<String> messages}) = Error;
}
