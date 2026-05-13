import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/create_silver_vendor_response_model.dart';

part 'silver_create_vendor_state.freezed.dart';

@freezed
class SilverCreateVendorState with _$SilverCreateVendorState {
  const factory SilverCreateVendorState.initial() = _Initial;
  const factory SilverCreateVendorState.loading() = Loading;
  const factory SilverCreateVendorState.success(
    CreateSilverVendorResponseModel vendor,
  ) = Success;
  const factory SilverCreateVendorState.error({
    required List<String> messages,
  }) = Error;
}
