import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/create_blog_request_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/update_blog_request_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/repo/blogs_repo.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_form_state.dart';

class BlogFormCubit extends Cubit<BlogFormState> {
  final BlogsRepo _repo;
  BlogFormCubit(this._repo) : super(const BlogFormState.initial());

  Future<void> createBlog(CreateBlogRequestModel request) async {
    emit(const BlogFormState.loading());
    final response = await _repo.createBlog(request);
    response.when(
      success: (blog) => emit(BlogFormState.success(blog)),
      failure: (failure) => emit(BlogFormState.error(
        messages: _extractMessages(failure.errorModel),
      )),
    );
  }

  Future<void> updateBlog(UpdateBlogRequestModel request) async {
    emit(const BlogFormState.loading());
    final response = await _repo.updateBlog(request);
    response.when(
      success: (blog) => emit(BlogFormState.success(blog)),
      failure: (failure) => emit(BlogFormState.error(
        messages: _extractMessages(failure.errorModel),
      )),
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
