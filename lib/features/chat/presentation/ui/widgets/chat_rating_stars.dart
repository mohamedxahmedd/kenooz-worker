import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class ChatRatingStars extends StatelessWidget {
  final int? rating;
  final double size;

  const ChatRatingStars({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    if (rating == null || rating! <= 0) return const SizedBox.shrink();
    final clamped = rating!.clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < clamped;
        return Padding(
          padding: EdgeInsets.only(right: 2.w),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size.sp,
            color: filled
                ? AppColors.yellowColor
                : AppColors.textGreyColor.withOpacity(0.5),
          ),
        );
      }),
    );
  }
}
