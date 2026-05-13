import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_model.dart';

class BlogCard extends StatelessWidget {
  final BlogModel blog;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  const BlogCard({
    super.key,
    required this.blog,
    required this.onEdit,
    required this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.darkBrown;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : accent.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCover(isDark),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            blog.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.heading(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.lightTextColorForDarkMood
                                  : accent,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        _StatusBadge(isActive: blog.isActive),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      (blog.subtitle?.isNotEmpty ?? false)
                          ? blog.subtitle!
                          : '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textGreyColor
                            : AppColors.darkGreyTextColor,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _formatDate(blog.createdAt),
                      style: AppFonts.body(
                        fontSize: 10.sp,
                        color: isDark
                            ? AppColors.textGreyColor
                            : AppColors.darkGreyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : accent.withOpacity(0.10),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'blogs.edit'.tr(),
                  color: accent,
                  onPressed: isDeleting ? null : onEdit,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: isDeleting
                      ? 'blogs.deleting'.tr()
                      : 'blogs.delete'.tr(),
                  color: AppColors.errorColor,
                  onPressed: isDeleting ? null : onDelete,
                  loading: isDeleting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCover(bool isDark) {
    final coverUrl = blog.coverImageUrl;
    return Container(
      width: 80.w,
      height: 80.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : AppColors.darkBrown.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: coverUrl != null && coverUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: coverUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => Icon(
                Icons.image_not_supported_outlined,
                size: 28.sp,
                color: isDark
                    ? AppColors.textGreyColor
                    : AppColors.darkGreyTextColor,
              ),
            )
          : Icon(
              Icons.article_outlined,
              size: 32.sp,
              color: isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.successColor : AppColors.errorColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(
        isActive ? 'blogs.active'.tr() : 'blogs.hidden'.tr(),
        style: AppFonts.body(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
