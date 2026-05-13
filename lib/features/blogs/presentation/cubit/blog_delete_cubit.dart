import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/repo/blogs_repo.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_delete_state.dart';

class BlogDeleteCubit extends Cubit<BlogDeleteState> {
  final BlogsRepo _repo;
  BlogDeleteCubit(this._repo) : super(const BlogDeleteState.initial());

  Future<void> deleteBlog(int id) async {
    emit(BlogDeleteState.loading(id));
    final response = await _repo.deleteBlog(id);
    response.when(
      success: (message) => emit(BlogDeleteState.success(
        id: id,
        message: message,
      )),
      failure: (failure) => emit(BlogDeleteState.error(
        id: id,
        message: _extractMessage(failure.errorModel),
      )),
    );
  }

  void resetState() {
    emit(const BlogDeleteState.initial());
  }

  String _extractMessage(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages.first;
    if (errorModel is BaseErrorModel) {
      return errorModel.message ?? 'An unexpected error occurred';
    }
    return 'An unexpected error occurred';
  }
}
