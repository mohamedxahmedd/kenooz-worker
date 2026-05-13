import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';

part 'client_search_state.freezed.dart';

@freezed
class ClientSearchState with _$ClientSearchState {
  const factory ClientSearchState.initial() = _Initial;
  const factory ClientSearchState.loading() = Loading;
  const factory ClientSearchState.found(ClientModel client) = Found;
  const factory ClientSearchState.notFound() = NotFound;
  const factory ClientSearchState.created(ClientModel client) = Created;
  const factory ClientSearchState.error({required List<String> messages}) = Error;
}
