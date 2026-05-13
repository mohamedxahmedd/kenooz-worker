import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/services/image_pick_service.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_image_model.dart';

/// Maximum file size accepted by the server (5 MB).
const int kBlogImageMaxBytes = 5 * 1024 * 1024;
const Set<String> kBlogImageAllowedExtensions = {
  'jpg',
  'jpeg',
  'png',
  'webp',
};

class BlogFormImagePicker extends StatelessWidget {
  /// Already-uploaded images coming from the server (only used in edit mode).
  final List<BlogImageModel> existingImages;

  /// Newly picked local images that haven't been uploaded yet.
  final List<String> localImagePaths;

  /// `true` when editing an existing blog (allows the "replace vs append" toggle).
  final bool isEditMode;

  /// Whether picked images should replace existing ones (true) or append (false).
  final bool replaceExistingImages;

  final ValueChanged<List<String>> onLocalImagesChanged;
  final ValueChanged<bool> onReplaceModeChanged;

  const BlogFormImagePicker({
    super.key,
    required this.existingImages,
    required this.localImagePaths,
    required this.isEditMode,
    required this.replaceExistingImages,
    required this.onLocalImagesChanged,
    required this.onReplaceModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.darkBrown;
    final hasNewImages = localImagePaths.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : accent.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, size: 18.sp, color: accent),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'blogs.images'.tr(),
                  style: AppFonts.heading(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : accent,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _pickImages(context),
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 14.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        'blogs.addImages'.tr(),
                        style: AppFonts.body(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'blogs.imagesHint'.tr(),
            style: AppFonts.body(
              fontSize: 11.sp,
              color: isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
          ),
          if (existingImages.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'blogs.existingImages'.tr(),
              style: AppFonts.body(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : accent,
              ),
            ),
            SizedBox(height: 8.h),
            _buildExistingImagesGrid(isDark),
          ],
          if (localImagePaths.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'blogs.newImages'.tr(),
              style: AppFonts.body(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : accent,
              ),
            ),
            SizedBox(height: 8.h),
            _buildLocalImagesGrid(isDark),
          ],
          if (isEditMode && existingImages.isNotEmpty && hasNewImages) ...[
            SizedBox(height: 12.h),
            _buildReplaceToggle(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildExistingImagesGrid(bool isDark) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: existingImages.map((image) {
        return _ImageThumb(
          isDark: isDark,
          child: CachedNetworkImage(
            imageUrl: image.url,
            width: 80.w,
            height: 80.w,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Icon(
              Icons.broken_image_outlined,
              size: 24.sp,
              color: AppColors.darkGreyTextColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocalImagesGrid(bool isDark) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(localImagePaths.length, (index) {
        final path = localImagePaths[index];
        return _ImageThumb(
          isDark: isDark,
          onRemove: () {
            final next = [...localImagePaths]..removeAt(index);
            onLocalImagesChanged(next);
          },
          child: Image.file(
            File(path),
            width: 80.w,
            height: 80.w,
            fit: BoxFit.cover,
          ),
        );
      }),
    );
  }

  Widget _buildReplaceToggle(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : AppColors.darkBrown.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  replaceExistingImages
                      ? 'blogs.replaceImages'.tr()
                      : 'blogs.appendImages'.tr(),
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  replaceExistingImages
                      ? 'blogs.replaceImagesHint'.tr()
                      : 'blogs.appendImagesHint'.tr(),
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
          Switch(
            value: replaceExistingImages,
            onChanged: onReplaceModeChanged,
            activeThumbColor: AppColors.darkBrown,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages(BuildContext context) async {
    final picked = await ImagePickService.instance.pickMulti(
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (picked.isEmpty) return;

    final accepted = <String>[];
    final rejectedSize = <String>[];
    final rejectedType = <String>[];

    for (final file in picked) {
      final ext = file.path.split('.').last.toLowerCase();
      if (!kBlogImageAllowedExtensions.contains(ext)) {
        rejectedType.add(file.name);
        continue;
      }
      final size = await File(file.path).length();
      if (size > kBlogImageMaxBytes) {
        rejectedSize.add(file.name);
        continue;
      }
      accepted.add(file.path);
    }

    if (accepted.isNotEmpty) {
      onLocalImagesChanged([...localImagePaths, ...accepted]);
    }
    if (!context.mounted) return;
    if (rejectedSize.isNotEmpty) {
      failureSnackBar(
        msg: 'blogs.imageTooLarge'.tr(),
        context: context,
      );
    } else if (rejectedType.isNotEmpty) {
      failureSnackBar(
        msg: 'blogs.unsupportedImageType'.tr(),
        context: context,
      );
    }
  }
}

class _ImageThumb extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final VoidCallback? onRemove;

  const _ImageThumb({
    required this.child,
    required this.isDark,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.w,
      height: 80.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 80.w,
              height: 80.w,
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : AppColors.darkBrown.withOpacity(0.06),
              child: child,
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: -6.h,
              right: -6.w,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
