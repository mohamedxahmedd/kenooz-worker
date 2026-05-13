import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/repo/blogs_repo.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blogs_list_state.dart';

class BlogsListCubit extends Cubit<BlogsListState> {
  final BlogsRepo _repo;
  BlogsListCubit(this._repo) : super(const BlogsListState.initial());

  Future<void> fetchFirstPage() async {
    emit(const BlogsListState.loading());
    final response = await _repo.fetchBlogs(page: 1);
    response.when(
      success: (paginator) => emit(BlogsListState.loaded(
        blogs: paginator.data,
        hasMore: paginator.hasMore,
        isLoadingMore: false,
        currentPage: paginator.currentPage,
      )),
      failure: (failure) =>
          emit(BlogsListState.error(_extractMessage(failure.errorModel))),
    );
  }

  Future<void> fetchNextPage() async {
    final current = state;
    if (current is! BlogsListLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.currentPage + 1;
    final response = await _repo.fetchBlogs(page: nextPage);
    response.when(
      success: (paginator) => emit(BlogsListState.loaded(
        blogs: [...current.blogs, ...paginator.data],
        hasMore: paginator.hasMore,
        isLoadingMore: false,
        currentPage: paginator.currentPage,
      )),
      failure: (_) => emit(current.copyWith(isLoadingMore: false)),
    );
  }

  void removeBlogLocally(int id) {
    final current = state;
    if (current is! BlogsListLoaded) return;
    emit(current.copyWith(
      blogs: current.blogs.where((b) => b.id != id).toList(),
    ));
  }

  void prependBlog(BlogModel blog) {
    final current = state;
    if (current is! BlogsListLoaded) return;
    emit(current.copyWith(blogs: [blog, ...current.blogs]));
  }

  void replaceBlog(BlogModel blog) {
    final current = state;
    if (current is! BlogsListLoaded) return;
    emit(current.copyWith(
      blogs: current.blogs.map((b) => b.id == blog.id ? blog : b).toList(),
    ));
  }

  String _extractMessage(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages.first;
    if (errorModel is BaseErrorModel) {
      return errorModel.message ?? 'An unexpected error occurred';
    }
    return 'An unexpected error occurred';
  }
}
