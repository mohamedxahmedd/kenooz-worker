import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_model.dart';

part 'blogs_list_state.freezed.dart';

@freezed
class BlogsListState with _$BlogsListState {
  const factory BlogsListState.initial() = BlogsListInitial;
  const factory BlogsListState.loading() = BlogsListLoading;
  const factory BlogsListState.loaded({
    required List<BlogModel> blogs,
    required bool hasMore,
    required bool isLoadingMore,
    required int currentPage,
  }) = BlogsListLoaded;
  const factory BlogsListState.error(String message) = BlogsListError;
}
