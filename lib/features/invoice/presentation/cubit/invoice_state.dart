import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_state.freezed.dart';

enum InvoiceAction { open, share }

@freezed
class InvoiceState with _$InvoiceState {
  const factory InvoiceState.initial() = _Initial;
  const factory InvoiceState.loading({required InvoiceAction action}) = Loading;
  const factory InvoiceState.success({
    required File file,
    required InvoiceAction action,
  }) = Success;
  const factory InvoiceState.error({required List<String> messages}) = Error;
}
