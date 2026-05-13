import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_model.dart';

part 'blog_form_state.freezed.dart';

@freezed
class BlogFormState with _$BlogFormState {
  const factory BlogFormState.initial() = _Initial;
  const factory BlogFormState.loading() = Loading;
  const factory BlogFormState.success(BlogModel blog) = Success;
  const factory BlogFormState.error({
    required List<String> messages,
  }) = Error;
}
