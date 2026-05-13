import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_product_model.dart';

part 'silver_product_lookup_state.freezed.dart';

@freezed
class SilverProductLookupState with _$SilverProductLookupState {
  const factory SilverProductLookupState.initial() = _Initial;
  const factory SilverProductLookupState.loading() = Loading;
  const factory SilverProductLookupState.found(SilverProductModel product) = Found;
  const factory SilverProductLookupState.notFound() = NotFound;
  const factory SilverProductLookupState.alreadySold() = AlreadySold;
  const factory SilverProductLookupState.error({required List<String> messages}) = Error;
}
