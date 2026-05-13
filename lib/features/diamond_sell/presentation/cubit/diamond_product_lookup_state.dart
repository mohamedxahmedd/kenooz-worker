import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_product_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_product_model.dart';

part 'diamond_product_lookup_state.freezed.dart';

@freezed
class DiamondProductLookupState with _$DiamondProductLookupState {
  const factory DiamondProductLookupState.initial() = _Initial;
  const factory DiamondProductLookupState.loading() = Loading;
  const factory DiamondProductLookupState.foundDiamond(DiamondProductModel product) = FoundDiamond;
  const factory DiamondProductLookupState.foundStone(StoneProductModel product) = FoundStone;
  const factory DiamondProductLookupState.notFound() = NotFound;
  const factory DiamondProductLookupState.alreadySold() = AlreadySold;
  const factory DiamondProductLookupState.invalidType() = InvalidType;
  const factory DiamondProductLookupState.error({required List<String> messages}) = Error;
}
