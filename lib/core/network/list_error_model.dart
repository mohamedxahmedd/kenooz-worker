import 'package:json_annotation/json_annotation.dart';

part 'list_error_model.g.dart';

@JsonSerializable()
class ListErrorModel {
  final List<String> messages;

  ListErrorModel({required this.messages});

  factory ListErrorModel.fromJson(dynamic json) {
    if (json is List<dynamic>) {
      return ListErrorModel(
        messages: List<String>.from(json),
      );
    } else {
      throw ArgumentError('Expected a List<dynamic> but got $json');
    }
  }

  Map<String, dynamic> toJson() => _$ListErrorModelToJson(this);
}
