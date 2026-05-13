import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/ui/widgets/invoice_type.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceRepo {
  final Dio _dio;

  InvoiceRepo(this._dio);

  Future<ApiResult<File>> downloadInvoice({
    required InvoiceType type,
    required int id,
  }) async {
    final path = 'worker/invoice/${type.pathSegment}/$id';
    try {
      final response = await _dio.get<List<int>>(
        path,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );
      final bytes = Uint8List.fromList(response.data ?? const []);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice-${type.pathSegment}-$id.pdf');
      await file.writeAsBytes(bytes, flush: true);
      return ApiResult.success(file);
    } on DioException catch (e) {
      _logServerError(e, path);
      _decodeBytesError(e);
      return ApiResult.failure(ErrorHandler.handle(e));
    } catch (e) {
      debugPrint('[InvoiceRepo] non-Dio error on $path: $e');
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  void _logServerError(DioException e, String path) {
    final status = e.response?.statusCode;
    final raw = e.response?.data;
    String body;
    if (raw is List<int>) {
      try {
        body = utf8.decode(raw);
      } catch (_) {
        body = '<${raw.length} non-utf8 bytes>';
      }
    } else {
      body = raw?.toString() ?? '<no body>';
    }
    debugPrint(
      '[InvoiceRepo] $path failed: status=$status\n'
      '--- server response ---\n$body\n--- end ---',
    );
  }

  void _decodeBytesError(DioException e) {
    final data = e.response?.data;
    if (data is List<int>) {
      try {
        final text = utf8.decode(data);
        e.response!.data = jsonDecode(text);
      } catch (_) {
        // Leave as-is — ErrorHandler will fall through to the default message.
      }
    }
  }
}
