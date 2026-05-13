// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/core/network/api_errors.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';

// Define DataSource enum
enum DataSource {
  CREATED,
  BAD_REQUEST,
  FORBIDDEN,
  UNAUTHORISED,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  PAYLOAD_TOO_LARGE,
  CONNECT_TIMEOUT,
  CANCEL,
  RECEIVE_TIMEOUT,
  SEND_TIMEOUT,
  CACHE_ERROR,
  NO_INTERNET_CONNECTION,
  DEFAULT,
}

// Define response codes
class ResponseCode {
  static const int SUCCESS = 200;
  static const int CREATED = 201;
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORISED = 401;
  static const int FORBIDDEN = 403;
  static const int INTERNAL_SERVER_ERROR = 500;
  static const int NOT_FOUND = 404;
  static const int PAYLOAD_TOO_LARGE = 413;
  static const int API_LOGIC_ERROR = 422;

  static const int CONNECT_TIMEOUT = -1;
  static const int CANCEL = -2;
  static const int RECEIVE_TIMEOUT = -3;
  static const int SEND_TIMEOUT = -4;
  static const int CACHE_ERROR = -5;
  static const int NO_INTERNET_CONNECTION = -6;
  static const int DEFAULT = -7;
}

// Define response messages
class ResponseMessage {
  static const String CREATED = ApiErrors.created;
  static const String BAD_REQUEST = ApiErrors.badRequestError;
  static const String UNAUTHORISED = ApiErrors.unauthorizedError;
  static const String FORBIDDEN = ApiErrors.forbiddenError;
  static const String INTERNAL_SERVER_ERROR = ApiErrors.internalServerError;
  static const String NOT_FOUND = ApiErrors.notFoundError;

  static String CONNECT_TIMEOUT = ApiErrors.timeoutError;
  static String CANCEL = ApiErrors.defaultError;
  static String RECEIVE_TIMEOUT = ApiErrors.timeoutError;
  static String SEND_TIMEOUT = ApiErrors.timeoutError;
  static String CACHE_ERROR = ApiErrors.cacheError;
  static String NO_INTERNET_CONNECTION = ApiErrors.noInternetError;
  static String DEFAULT = ApiErrors.defaultError;
}

// Extension to convert DataSource to error models
extension DataSourceExtension on DataSource {
  dynamic getFailure() {
    switch (this) {
      case DataSource.CREATED:
        return BaseErrorModel(message: ResponseMessage.CREATED);
      case DataSource.BAD_REQUEST:
        return BaseErrorModel(message: ResponseMessage.BAD_REQUEST);
      case DataSource.FORBIDDEN:
        return BaseErrorModel(message: ResponseMessage.FORBIDDEN);
      case DataSource.UNAUTHORISED:
        return BaseErrorModel(message: ResponseMessage.UNAUTHORISED);
      case DataSource.NOT_FOUND:
        return BaseErrorModel(message: ResponseMessage.NOT_FOUND);
      case DataSource.INTERNAL_SERVER_ERROR:
        return BaseErrorModel(message: ResponseMessage.INTERNAL_SERVER_ERROR);
      case DataSource.PAYLOAD_TOO_LARGE:
        return BaseErrorModel(
          message: 'Image is too large. Please select a smaller image.',
        );
      case DataSource.CONNECT_TIMEOUT:
        return BaseErrorModel(message: ResponseMessage.CONNECT_TIMEOUT);
      case DataSource.CANCEL:
        return BaseErrorModel(message: ResponseMessage.CANCEL);
      case DataSource.RECEIVE_TIMEOUT:
        return BaseErrorModel(message: ResponseMessage.RECEIVE_TIMEOUT);
      case DataSource.SEND_TIMEOUT:
        return BaseErrorModel(message: ResponseMessage.SEND_TIMEOUT);
      case DataSource.CACHE_ERROR:
        return BaseErrorModel(message: ResponseMessage.CACHE_ERROR);
      case DataSource.NO_INTERNET_CONNECTION:
        return BaseErrorModel(message: ResponseMessage.NO_INTERNET_CONNECTION);
      case DataSource.DEFAULT:
        return BaseErrorModel(message: ResponseMessage.DEFAULT);
    }
  }

  ListErrorModel getListFailure() {
    switch (this) {
      case DataSource.CREATED:
        return ListErrorModel(messages: [ResponseMessage.CREATED]);
      case DataSource.BAD_REQUEST:
        return ListErrorModel(messages: [ResponseMessage.BAD_REQUEST]);
      case DataSource.FORBIDDEN:
        return ListErrorModel(messages: [ResponseMessage.FORBIDDEN]);
      case DataSource.UNAUTHORISED:
        return ListErrorModel(messages: [ResponseMessage.UNAUTHORISED]);
      case DataSource.NOT_FOUND:
        return ListErrorModel(messages: [ResponseMessage.NOT_FOUND]);
      case DataSource.INTERNAL_SERVER_ERROR:
        return ListErrorModel(
          messages: [ResponseMessage.INTERNAL_SERVER_ERROR],
        );
      case DataSource.PAYLOAD_TOO_LARGE:
        return ListErrorModel(
          messages: ['Image is too large. Please select a smaller image.'],
        );
      case DataSource.CONNECT_TIMEOUT:
        return ListErrorModel(messages: [ResponseMessage.CONNECT_TIMEOUT]);
      case DataSource.CANCEL:
        return ListErrorModel(messages: [ResponseMessage.CANCEL]);
      case DataSource.RECEIVE_TIMEOUT:
        return ListErrorModel(messages: [ResponseMessage.RECEIVE_TIMEOUT]);
      case DataSource.SEND_TIMEOUT:
        return ListErrorModel(messages: [ResponseMessage.SEND_TIMEOUT]);
      case DataSource.CACHE_ERROR:
        return ListErrorModel(messages: [ResponseMessage.CACHE_ERROR]);
      case DataSource.NO_INTERNET_CONNECTION:
        return ListErrorModel(
          messages: [ResponseMessage.NO_INTERNET_CONNECTION],
        );
      case DataSource.DEFAULT:
        return ListErrorModel(messages: [ResponseMessage.DEFAULT]);
    }
  }
}

// Error Parser class
class ErrorParser {
  static dynamic parseError(dynamic json) {
    if (json is String) {
      return BaseErrorModel(message: _sanitizeMessage(json));
    } else if (json is List) {
      final messages = _normalizeMessages(
        json.map((e) => e.toString()).toList(),
      );
      return ListErrorModel(
        messages: messages.isNotEmpty ? messages : [ResponseMessage.DEFAULT],
      );
    } else if (json is Map<String, dynamic>) {
      final errors = _extractMessagesFromMap(json);
      return ListErrorModel(
        messages: errors.isNotEmpty ? errors : [ResponseMessage.DEFAULT],
      );
    } else {
      return BaseErrorModel(message: ResponseMessage.DEFAULT);
    }
  }

  static List<String> _extractMessagesFromMap(Map<String, dynamic> json) {
    final messages = <String>[];

    final directMessage = json['message'];
    if (directMessage is String && directMessage.trim().isNotEmpty) {
      messages.add(directMessage);
    }

    final directError = json['error'];
    if (directError is String && directError.trim().isNotEmpty) {
      messages.add(directError);
    }

    final errorsField = json['errors'];
    if (errorsField is Map) {
      errorsField.forEach((_, value) {
        if (value is List) {
          messages.addAll(value.map((e) => e.toString()));
        } else if (value is String) {
          messages.add(value);
        }
      });
    }

    if (messages.isEmpty) {
      json.forEach((_, value) {
        if (value is List) {
          messages.addAll(value.map((e) => e.toString()));
        } else if (value is String) {
          messages.add(value);
        }
      });
    }

    return _normalizeMessages(messages);
  }

  static List<String> _normalizeMessages(List<String> rawMessages) {
    final normalized = <String>[];

    for (final message in rawMessages) {
      final cleaned = _sanitizeMessage(message);
      if (cleaned.isEmpty) continue;
      if (!normalized.contains(cleaned)) {
        normalized.add(cleaned);
      }
    }

    return normalized;
  }

  static String _sanitizeMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return ResponseMessage.DEFAULT;
    }

    if (_looksLikeHtml(trimmed)) {
      final extracted = _extractHtmlErrorMessage(trimmed);
      return extracted ?? ResponseMessage.INTERNAL_SERVER_ERROR;
    }

    final compact = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    if (compact.length > 240) {
      return '${compact.substring(0, 240)}...';
    }
    return compact;
  }

  static bool _looksLikeHtml(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('<!doctype html') || lower.contains('<html')) {
      return true;
    }
    return RegExp(r'<\/?[a-z][^>]*>', caseSensitive: false).hasMatch(text);
  }

  static String? _extractHtmlErrorMessage(String html) {
    final withoutScripts = html.replaceAll(
      RegExp(r'<script[\s\S]*?<\/script>', caseSensitive: false),
      ' ',
    );
    final withoutStyles = withoutScripts.replaceAll(
      RegExp(r'<style[\s\S]*?<\/style>', caseSensitive: false),
      ' ',
    );
    final textOnly = withoutStyles
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final nullPropertyMessage = RegExp(
      r'Attempt to read property[^.]+',
      caseSensitive: false,
    ).firstMatch(textOnly)?.group(0);
    if (nullPropertyMessage != null && nullPropertyMessage.isNotEmpty) {
      return nullPropertyMessage;
    }

    final internalServerError = RegExp(
      r'Internal Server Error',
      caseSensitive: false,
    ).firstMatch(textOnly);
    if (internalServerError != null) {
      return ResponseMessage.INTERNAL_SERVER_ERROR;
    }

    return null;
  }
}

// Error Handler class
class ErrorHandler implements Exception {
  late dynamic errorModel;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      errorModel = _handleError(error);
    } else {
      errorModel = DataSource.DEFAULT.getFailure();
    }
  }
}

dynamic _handleError(DioException error) {
  // ── Detect 302 redirect → session expired / auth failure ──
  final statusCode = error.response?.statusCode;
  if (statusCode == 302 || statusCode == 301) {
    return DataSource.UNAUTHORISED.getFailure();
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.CONNECT_TIMEOUT.getFailure();
    case DioExceptionType.sendTimeout:
      return DataSource.SEND_TIMEOUT.getFailure();
    case DioExceptionType.receiveTimeout:
      return DataSource.RECEIVE_TIMEOUT.getFailure();
    case DioExceptionType.badResponse:
      if (error.response != null) {
        final code = error.response!.statusCode;
        // Map known HTTP codes before raw-parsing the body
        if (code == 401) return DataSource.UNAUTHORISED.getFailure();
        if (code == 403) return DataSource.FORBIDDEN.getFailure();
        if (code == 404) return DataSource.NOT_FOUND.getFailure();
        if (code == 500) return DataSource.INTERNAL_SERVER_ERROR.getFailure();
        if (error.response?.data != null) {
          return ErrorParser.parseError(error.response!.data);
        }
      }
      return DataSource.DEFAULT.getFailure();
    case DioExceptionType.unknown:
      if (error.response != null && error.response?.data != null) {
        return ErrorParser.parseError(error.response!.data);
      } else {
        return DataSource.DEFAULT.getFailure();
      }
    case DioExceptionType.cancel:
      return DataSource.CANCEL.getFailure();
    case DioExceptionType.connectionError:
      return DataSource.DEFAULT.getFailure();
    case DioExceptionType.badCertificate:
      return DataSource.DEFAULT.getFailure();
  }
}

// Define API internal status
class ApiInternalStatus {
  // ignore: constant_identifier_names
  static const int SUCCESS = 0;
  // ignore: constant_identifier_names
  static const int FAILURE = 1;
  // ignore: constant_identifier_names
  static const int CREATED = 2;
}
