import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_button.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_image_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/create_blog_request_model.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/update_blog_request_model.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_form_cubit.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_form_state.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/ui/widgets/blog_form_image_picker.dart';

class BlogFormScreen extends StatefulWidget {
  /// `null` for create mode, populated for edit mode.
  final BlogModel? existingBlog;

  const BlogFormScreen({super.key, this.existingBlog});

  @override
  State<BlogFormScreen> createState() => _BlogFormScreenState();
}

class _BlogFormScreenState extends State<BlogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _detailsController;

  late bool _isActive;
  late bool _replaceExistingImages;
  late List<BlogImageModel> _existingImages;
  final List<String> _localImagePaths = [];

  bool get _isEditMode => widget.existingBlog != null;

  @override
  void initState() {
    super.initState();
    final blog = widget.existingBlog;
    _titleController = TextEditingController(text: blog?.title ?? '');
    _subtitleController = TextEditingController(text: blog?.subtitle ?? '');
    _detailsController = TextEditingController(text: blog?.details ?? '');
    _isActive = blog?.isActive ?? true;
    _replaceExistingImages = true;
    _existingImages = blog?.images ?? const [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.darkBrown;

    return BlocListener<BlogFormCubit, BlogFormState>(
      listener: _formListener,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkThemeBackgroundColor
            : AppColors.backGroundColorLight,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                MediaQuery.paddingOf(context).top + 12.h,
                20.w,
                10.h,
              ),
              child: _HeaderCard(
                isDark: isDark,
                accent: accent,
                title: _isEditMode
                    ? 'blogs.editBlogTitle'.tr()
                    : 'blogs.createBlogTitle'.tr(),
                subtitle: _isEditMode
                    ? 'blogs.editBlogSubtitle'.tr()
                    : 'blogs.createBlogSubtitle'.tr(),
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 80.h),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldsCard(isDark, accent),
                      SizedBox(height: 14.h),
                      BlogFormImagePicker(
                        existingImages: _existingImages,
                        localImagePaths: _localImagePaths,
                        isEditMode: _isEditMode,
                        replaceExistingImages: _replaceExistingImages,
                        onLocalImagesChanged: (paths) {
                          setState(() {
                            _localImagePaths
                              ..clear()
                              ..addAll(paths);
                          });
                        },
                        onReplaceModeChanged: (value) =>
                            setState(() => _replaceExistingImages = value),
                      ),
                      SizedBox(height: 14.h),
                      _buildActiveToggle(isDark, accent),
                      SizedBox(height: 18.h),
                      CustomButton(
                        text: _isEditMode
                            ? 'blogs.saveChanges'.tr()
                            : 'blogs.createBlog'.tr(),
                        onPressed: _onSave,
                        color: accent,
                        borderRadius: 12.r,
                        height: 52.h,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldsCard(bool isDark, Color accent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
          Text(
            'blogs.contentSection'.tr(),
            style: AppFonts.heading(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : accent,
            ),
          ),
          SizedBox(height: 8.h),
          CustomTextFormField(
            controller: _titleController,
            labelText: '${'blogs.titleField'.tr()} *',
            maxLength: 255,
            buildCounter: _hideCounter,
            fillColor: isDark
                ? AppColors.darkThemeTextFieldFillColor
                : AppColors.backGroundColorLight,
            borderRadius: BorderRadius.circular(12.r),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'blogs.titleRequired'.tr();
              if (value.length > 255) return 'blogs.titleTooLong'.tr();
              return null;
            },
          ),
          CustomTextFormField(
            controller: _subtitleController,
            labelText: 'blogs.subtitleField'.tr(),
            maxLength: 255,
            buildCounter: _hideCounter,
            fillColor: isDark
                ? AppColors.darkThemeTextFieldFillColor
                : AppColors.backGroundColorLight,
            borderRadius: BorderRadius.circular(12.r),
            validator: (v) {
              if (v != null && v.trim().length > 255) {
                return 'blogs.subtitleTooLong'.tr();
              }
              return null;
            },
          ),
          CustomTextFormField(
            controller: _detailsController,
            labelText: '${'blogs.details'.tr()} *',
            minLines: 6,
            maxLines: 12,
            height: 200.h,
            fillColor: isDark
                ? AppColors.darkThemeTextFieldFillColor
                : AppColors.backGroundColorLight,
            borderRadius: BorderRadius.circular(12.r),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'blogs.detailsRequired'.tr();
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToggle(bool isDark, Color accent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : accent.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: _isActive ? AppColors.successColor : AppColors.errorColor,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isActive
                      ? 'blogs.publishedTitle'.tr()
                      : 'blogs.draftTitle'.tr(),
                  style: AppFonts.body(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : accent,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _isActive
                      ? 'blogs.publishedHint'.tr()
                      : 'blogs.draftHint'.tr(),
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            activeThumbColor: accent,
          ),
        ],
      ),
    );
  }

  Widget? _hideCounter(
    BuildContext _, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) =>
      null;

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final cubit = context.read<BlogFormCubit>();
    if (_isEditMode) {
      final original = widget.existingBlog!;
      final newTitle = _titleController.text.trim();
      final newSubtitle = _subtitleController.text.trim();
      final newDetails = _detailsController.text.trim();

      cubit.updateBlog(
        UpdateBlogRequestModel(
          id: original.id,
          title: newTitle != original.title ? newTitle : null,
          subtitle: newSubtitle != (original.subtitle ?? '')
              ? newSubtitle
              : null,
          details: newDetails != original.details ? newDetails : null,
          isActive: _isActive != original.isActive ? _isActive : null,
          newImagePaths: List<String>.from(_localImagePaths),
          replaceImages: _replaceExistingImages,
        ),
      );
    } else {
      cubit.createBlog(
        CreateBlogRequestModel(
          title: _titleController.text.trim(),
          subtitle: _subtitleController.text.trim().isEmpty
              ? null
              : _subtitleController.text.trim(),
          details: _detailsController.text.trim(),
          isActive: _isActive,
          imagePaths: List<String>.from(_localImagePaths),
        ),
      );
    }
  }

  void _formListener(BuildContext context, BlogFormState state) {
    state.whenOrNull(
      loading: () => EasyLoading.show(),
      success: (blog) {
        EasyLoading.dismiss();
        successSnackBar(
          msg: _isEditMode
              ? 'blogs.updateSuccess'.tr()
              : 'blogs.createSuccess'.tr(),
          context: context,
        );
        Navigator.pop(context, blog);
      },
      error: (messages) {
        EasyLoading.dismiss();
        failureSnackBar(msg: messages.join('\n'), context: context);
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final String title;
  final String subtitle;

  const _HeaderCard({
    required this.isDark,
    required this.accent,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : accent.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : accent,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : accent,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppFonts.body(
                    fontSize: 11.sp,
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
    );
  }
}
