import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/invoice/data/repo/invoice_repo.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/ui/widgets/invoice_type.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final InvoiceRepo _repo;

  InvoiceCubit(this._repo) : super(const InvoiceState.initial());

  Future<void> downloadAndOpen({
    required InvoiceType type,
    required int id,
  }) =>
      _download(type: type, id: id, action: InvoiceAction.open);

  Future<void> downloadAndShare({
    required InvoiceType type,
    required int id,
  }) =>
      _download(type: type, id: id, action: InvoiceAction.share);

  Future<void> _download({
    required InvoiceType type,
    required int id,
    required InvoiceAction action,
  }) async {
    emit(InvoiceState.loading(action: action));
    final response = await _repo.downloadInvoice(type: type, id: id);
    if (isClosed) return;
    response.when(
      success: (file) => emit(InvoiceState.success(file: file, action: action)),
      failure: (error) => emit(
        InvoiceState.error(messages: _extractMessages(error.errorModel)),
      ),
    );
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) {
      return [errorModel.message ?? 'An unexpected error occurred'];
    }
    return ['An unexpected error occurred'];
  }
}
