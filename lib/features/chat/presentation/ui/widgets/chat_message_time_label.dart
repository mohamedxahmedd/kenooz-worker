import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class ChatMessageTimeLabel extends StatelessWidget {
  final String createdAt;

  const ChatMessageTimeLabel({super.key, required this.createdAt});

  String _formatTime(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final ampm = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $ampm';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _formatTime(createdAt);
    if (formatted.isEmpty) return const SizedBox.shrink();

    return Text(
      formatted,
      style: AppFonts.body(
        fontSize: 10.sp,
        color: AppColors.textGreyColor,
      ),
    );
  }
}
