import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_model.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_delete_cubit.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_delete_state.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blogs_list_cubit.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blogs_list_state.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/ui/widgets/blog_card.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/ui/widgets/blogs_list_shimmer.dart';

class BlogsListBlocBuilder extends StatelessWidget {
  final VoidCallback onAddNew;
  final ValueChanged<BlogModel> onEditBlog;
  final ValueChanged<BlogModel> onDeleteBlog;
  final ScrollController scrollController;

  const BlogsListBlocBuilder({
    super.key,
    required this.onAddNew,
    required this.onEditBlog,
    required this.onDeleteBlog,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlogsListCubit, BlogsListState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const BlogsListShimmer(),
          loaded: (blogs, hasMore, isLoadingMore, _) => _SuccessView(
            blogs: blogs,
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
            onAddNew: onAddNew,
            onEditBlog: onEditBlog,
            onDeleteBlog: onDeleteBlog,
            scrollController: scrollController,
          ),
          error: (message) => _ErrorView(
            message: message,
            onRetry: () =>
                context.read<BlogsListCubit>().fetchFirstPage(),
          ),
          orElse: () => const BlogsListShimmer(),
        );
      },
    );
  }
}

class _SuccessView extends StatelessWidget {
  final List<BlogModel> blogs;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onAddNew;
  final ValueChanged<BlogModel> onEditBlog;
  final ValueChanged<BlogModel> onDeleteBlog;
  final ScrollController scrollController;

  const _SuccessView({
    required this.blogs,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onAddNew,
    required this.onEditBlog,
    required this.onDeleteBlog,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (blogs.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<BlogsListCubit>().fetchFirstPage(),
        child: ListView(
          children: [
            SizedBox(height: 80.h),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 52.sp,
                      color: isDark
                          ? AppColors.textGreyColor
                          : AppColors.darkGreyTextColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'blogs.emptyTitle'.tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.heading(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkBrown,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'blogs.emptySubtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        fontSize: 13.sp,
                        color: isDark
                            ? AppColors.textGreyColor
                            : AppColors.darkGreyTextColor,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onAddNew,
                        icon: Icon(Icons.add_rounded, size: 18.sp),
                        label: Text(
                          'blogs.addBlog'.tr(),
                          style: AppFonts.body(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBrown,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BlogsListCubit>().fetchFirstPage(),
      child: BlocBuilder<BlogDeleteCubit, BlogDeleteState>(
        builder: (context, deleteState) {
          final deletingId = deleteState.maybeWhen(
            loading: (id) => id,
            orElse: () => null,
          );

          return ListView.separated(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
            itemCount: blogs.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              if (index >= blogs.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ),
                );
              }
              final blog = blogs[index];
              return BlogCard(
                blog: blog,
                onEdit: () => onEditBlog(blog),
                onDelete: () => onDeleteBlog(blog),
                isDeleting: deletingId == blog.id,
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.errorColor.withOpacity(0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.errorColor,
                size: 34.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                'blogs.unableToLoad'.tr(),
                style: AppFonts.heading(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkBrown,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.textGreyColor
                      : AppColors.darkGreyTextColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('common.retry'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
