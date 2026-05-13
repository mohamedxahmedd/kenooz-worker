import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class ConversationInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const ConversationInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        10.h,
        12.w,
        10.h + (bottomInset > 0 ? 0 : MediaQuery.paddingOf(context).bottom),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppColors.primaryColor.withOpacity(0.18),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkThemeContainerColorElevated
                    : AppColors.backGroundColorLight,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : AppColors.primaryColor.withOpacity(0.18),
                ),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                maxLength: 5000,
                textInputAction: TextInputAction.newline,
                style: AppFonts.body(
                  fontSize: 14.sp,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkGreyTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'chat.message.placeholder'.tr(),
                  hintStyle: AppFonts.body(
                    fontSize: 14.sp,
                    color: AppColors.textGreyColor,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  counterText: '',
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          _SendButton(onPressed: isSending ? null : onSend, isSending: isSending),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isSending;

  const _SendButton({required this.onPressed, required this.isSending});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            color: onPressed == null
                ? AppColors.darkBrown.withOpacity(0.5)
                : AppColors.darkBrown,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBrown.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isSending
              ? Padding(
                  padding: EdgeInsets.all(12.w),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
        ),
      ),
    );
  }
}
