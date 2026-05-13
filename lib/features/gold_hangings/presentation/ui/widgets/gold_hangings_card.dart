import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/cached_image_widget.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hanged_gold_model.dart';

class GoldHangingsCard extends StatelessWidget {
  final HangedGoldModel item;
  final bool isUnhanging;
  final VoidCallback onUnhang;

  const GoldHangingsCard({
    super.key,
    required this.item,
    required this.isUnhanging,
    required this.onUnhang,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppColors.goldColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.primaryColor.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageBox(imageUrl: item.image, isDark: isDark),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppFonts.heading(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkBrown,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${'common.carat'.tr()} ${item.carat.carat} • ${item.grams.toStringAsFixed(2)}g',
                      style: AppFonts.body(
                        fontSize: 11.sp,
                        color: isDark
                            ? AppColors.textGreyColor
                            : AppColors.darkGreyTextColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        _MetaChip(
                          icon: Icons.person_outline_rounded,
                          label:
                              '${'gold_hangings.hangedBy'.tr()}: ${item.hangedBy?.name ?? '—'}',
                          accentColor: accentColor,
                        ),
                        _MetaChip(
                          icon: Icons.access_time_rounded,
                          label: _formatDate(item.hangedAt),
                          accentColor: accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : AppColors.primaryColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sticky_note_2_outlined,
                  size: 14.sp,
                  color: isDark
                      ? AppColors.textGreyColor
                      : AppColors.darkGreyTextColor,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    (item.hangNote != null && item.hangNote!.trim().isNotEmpty)
                        ? item.hangNote!
                        : 'gold_hangings.noNote'.tr(),
                    style: AppFonts.body(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.lightTextColorForDarkMood
                          : AppColors.darkBrown,
                    ).copyWith(
                      fontStyle: (item.hangNote == null ||
                              item.hangNote!.trim().isEmpty)
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isUnhanging ? null : onUnhang,
              icon: isUnhanging
                  ? SizedBox(
                      width: 14.sp,
                      height: 14.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.lock_open_rounded, size: 16.sp),
              label: Text(
                'gold_hangings.unhang'.tr(),
                style: AppFonts.body(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 11.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final y = dt.year;
      final mo = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$y-$mo-$d  $h:$mi';
    } catch (_) {
      return raw;
    }
  }
}

class _ImageBox extends StatelessWidget {
  final String? imageUrl;
  final bool isDark;
  const _ImageBox({required this.imageUrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : AppColors.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? CachedNetworkImageWidget(imageUrl: imageUrl!, fit: BoxFit.cover)
          : Icon(
              Icons.image_outlined,
              size: 26.sp,
              color: isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: accentColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppFonts.body(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
