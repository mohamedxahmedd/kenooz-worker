import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_paginator_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/create_blog_request_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/update_blog_request_model.dart';

class BlogsRepo {
  final Dio _dio;

  BlogsRepo(this._dio);

  Future<ApiResult<BlogPaginatorModel>> fetchBlogs({int? page}) async {
    try {
      final response = await _dio.get(
        'worker/blogs',
        queryParameters: page != null ? {'page': page} : null,
      );
      final body = response.data as Map<String, dynamic>;
      final blogsJson = body['blogs'] as Map<String, dynamic>? ?? {};
      return ApiResult.success(BlogPaginatorModel.fromJson(blogsJson));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<BlogModel>> createBlog(CreateBlogRequestModel request) async {
    try {
      final formData = FormData.fromMap({
        'title': request.title,
        if (request.subtitle != null && request.subtitle!.isNotEmpty)
          'subtitle': request.subtitle,
        'details': request.details,
        'is_active': request.isActive ? '1' : '0',
      });

      for (final path in request.imagePaths) {
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          ),
        );
      }

      final response = await _dio.post('worker/blogs', data: formData);
      final body = response.data as Map<String, dynamic>;
      final blogJson = body['blog'] as Map<String, dynamic>;
      return ApiResult.success(BlogModel.fromJson(blogJson));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<BlogModel>> updateBlog(UpdateBlogRequestModel request) async {
    try {
      final fields = <String, dynamic>{};
      if (request.title != null) fields['title'] = request.title;
      if (request.subtitle != null) fields['subtitle'] = request.subtitle;
      if (request.details != null) fields['details'] = request.details;
      if (request.isActive != null) {
        fields['is_active'] = request.isActive! ? '1' : '0';
      }
      if (request.newImagePaths.isNotEmpty) {
        fields['replace_images'] = request.replaceImages ? '1' : '0';
      }

      final formData = FormData.fromMap(fields);

      for (final path in request.newImagePaths) {
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          ),
        );
      }

      final response = await _dio.post(
        'worker/blogs/${request.id}',
        data: formData,
      );
      final body = response.data as Map<String, dynamic>;
      final blogJson = body['blog'] as Map<String, dynamic>;
      return ApiResult.success(BlogModel.fromJson(blogJson));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<String>> deleteBlog(int id) async {
    try {
      final response = await _dio.delete('worker/blogs/$id');
      final body = response.data as Map<String, dynamic>;
      final message = body['message']?.toString() ?? '';
      return ApiResult.success(message);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
