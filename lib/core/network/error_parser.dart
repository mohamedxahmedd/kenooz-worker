// import 'package:zone_refactor/core/network/base_error_model.dart';
// import 'package:zone_refactor/core/network/list_error_model.dart';

// class ErrorParser {
//   static dynamic parseError(dynamic json) {
//     if (json is String) {
//       return BaseErrorModel(message: json);
//     } else if (json is List) {
//       return ListErrorModel.fromJson(json);
//     } else if (json is Map<String, dynamic>) {
//       return BaseErrorModel.fromJson(json);
//     } else {
//       return BaseErrorModel(message: 'Unknown error format');
//     }
//   }
// }
// class ErrorParser {
//   static dynamic parseError(dynamic json) {
//     if (json is String) {
//       return BaseErrorModel(message: json);
//     } else if (json is List) {
//       return ListErrorModel(messages: List<String>.from(json));
//     } else if (json is Map<String, dynamic>) {
//       return BaseErrorModel.fromJson(json);
//     } else {
//       return BaseErrorModel(message: 'Unknown error format');
//     }
//   }
// }
