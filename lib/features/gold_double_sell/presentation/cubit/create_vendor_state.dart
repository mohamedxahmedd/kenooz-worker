import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_vendor_response_model.dart';

part 'create_vendor_state.freezed.dart';

@freezed
class CreateVendorState with _$CreateVendorState {
  const factory CreateVendorState.initial() = _Initial;
  const factory CreateVendorState.loading() = Loading;
  const factory CreateVendorState.success(CreateVendorResponseModel vendor) =
      Success;
  const factory CreateVendorState.error({required List<String> messages}) =
      Error;
}
