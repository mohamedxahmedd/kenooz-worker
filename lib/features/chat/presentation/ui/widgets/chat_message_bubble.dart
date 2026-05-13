import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_message_model.dart';
import 'chat_message_time_label.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMine = message.isFromWorker;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.75;

    final bubbleColor = isMine
        ? AppColors.darkBrown
        : (isDark
            ? AppColors.darkThemeContainerColorElevated
            : Colors.white);
    final textColor = isMine
        ? Colors.white
        : (isDark
            ? AppColors.lightTextColorForDarkMood
            : AppColors.darkGreyTextColor);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
                    bottomRight: Radius.circular(isMine ? 4.r : 16.r),
                  ),
                  border: isMine
                      ? null
                      : Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : AppColors.primaryColor.withOpacity(0.18),
                        ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.darkBrown.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  message.message,
                  style: AppFonts.body(
                    fontSize: 14.sp,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ChatMessageTimeLabel(createdAt: message.createdAt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
