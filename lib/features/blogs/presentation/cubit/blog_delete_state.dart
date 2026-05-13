import 'package:freezed_annotation/freezed_annotation.dart';

part 'blog_delete_state.freezed.dart';

@freezed
class BlogDeleteState with _$BlogDeleteState {
  const factory BlogDeleteState.initial() = _Initial;
  const factory BlogDeleteState.loading(int id) = Loading;
  const factory BlogDeleteState.success({
    required int id,
    required String message,
  }) = Success;
  const factory BlogDeleteState.error({
    required int id,
    required String message,
  }) = Error;
}
