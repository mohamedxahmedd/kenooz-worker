import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';

class OrderStatusBottomSheet extends StatefulWidget {
  final String currentStatus;
  final Function(String) onStatusSelected;

  const OrderStatusBottomSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  State<OrderStatusBottomSheet> createState() => _OrderStatusBottomSheetState();
}

class _OrderStatusBottomSheetState extends State<OrderStatusBottomSheet> {
  late String _selectedStatus;

  static const List<String> _statusOptions = [
    'pending',
    'accepted',
    'processing',
    'on_the_way',
    'ready',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus.toLowerCase();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'accepted':
        return const Color(0xFF2196F3);
      case 'processing':
        return const Color(0xFF3F51B5);
      case 'on_the_way':
        return const Color(0xFF009688);
      case 'ready':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF2E7D32);
      default:
        return AppColors.textGreyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, bottomInset + 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.primaryColor.withOpacity(0.14),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.25)
                    : AppColors.darkBrown.withOpacity(0.25),
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'orders.changeOrderStatus'.tr(),
            style: AppFonts.heading(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkGreyTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'orders.selectNextStage'.tr(),
            style: AppFonts.body(
              fontSize: 12.sp,
              color: AppColors.textGreyColor,
            ),
          ),
          SizedBox(height: 16.h),
          ..._statusOptions.map((status) {
            final isSelected = _selectedStatus == status;
            final statusColor = _getStatusColor(status);
            return GestureDetector(
              onTap: () {
                setState(() => _selectedStatus = status);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? statusColor.withOpacity(isDark ? 0.24 : 0.14)
                      : (isDark
                            ? AppColors.darkThemeContainerColorElevated
                            : AppColors.backGroundColorLight),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? statusColor.withOpacity(0.6)
                        : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : AppColors.darkBrown.withOpacity(0.08)),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          status.toUpperCase().replaceAll('_', ' '),
                          style: AppFonts.body(
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isDark
                                ? AppColors.lightTextColorForDarkMood
                                : AppColors.darkGreyTextColor,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: statusColor, size: 20.sp),
                  ],
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.12)
                          : AppColors.darkBrown.withOpacity(0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'common.cancel'.tr(),
                    style: AppFonts.body(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onStatusSelected(_selectedStatus);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'common.update'.tr(),
                    style: AppFonts.body(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
