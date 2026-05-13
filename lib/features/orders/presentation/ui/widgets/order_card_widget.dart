import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_model.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onChangeStatus;
  final VoidCallback? onMarkAsPaid;

  const OrderCardWidget({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
    this.onChangeStatus,
    this.onMarkAsPaid,
  });

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
      case 'paid':
        return const Color(0xFF9C27B0);
      case 'cancelled':
        return AppColors.errorColor;
      default:
        return AppColors.textGreyColor;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatStatusLabel(String status) {
    return status.toUpperCase().replaceAll('_', ' ');
  }

  String _money(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(order.status);
    final orderName = order.name.trim().isEmpty ? 'orders.orderDetails'.tr() : order.name;
    final clientName = (order.client?.name ?? '').trim().isEmpty
        ? 'orders.unknownClient'.tr()
        : order.client!.name;
    final actionButtons = _buildActionButtons(isDark: isDark);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppColors.primaryColor.withOpacity(0.14),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.darkBrown.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: AppFonts.heading(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.lightTextColorForDarkMood
                              : AppColors.darkGreyTextColor,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        orderName,
                        style: AppFonts.body(
                          fontSize: 13.sp,
                          color: isDark
                              ? AppColors.textGreyColor
                              : AppColors.darkGreyTextColor.withOpacity(0.72),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(isDark ? 0.24 : 0.13),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: statusColor.withOpacity(0.45)),
                  ),
                  child: Text(
                    _formatStatusLabel(order.status),
                    style: AppFonts.body(
                      fontSize: 10.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _OrderMetaChip(
                  isDark: isDark,
                  icon: Icons.person_outline_rounded,
                  label: clientName,
                ),
                _OrderMetaChip(
                  isDark: isDark,
                  icon: Icons.local_shipping_outlined,
                  label: order.pickupType.toUpperCase(),
                ),
                _OrderMetaChip(
                  isDark: isDark,
                  icon: Icons.event_outlined,
                  label: _formatDate(order.createdAt),
                ),
              ],
            ),

            if (order.orderItems.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: _OrderItemsPreview(
                  order: order,
                  isDark: isDark,
                  moneyFormatter: _money,
                ),
              ),

            if (order.notes != null && order.notes!.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkThemeContainerColorElevated
                        : AppColors.backGroundColorLight,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : AppColors.primaryColor.withOpacity(0.16),
                    ),
                  ),
                  child: Text(
                    order.notes!,
                    style: AppFonts.body(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.lightTextColorForDarkMood
                          : AppColors.darkGreyTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            SizedBox(height: 12.h),
            Divider(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.primaryColor.withOpacity(0.18),
            ),
            SizedBox(height: 10.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'common.total'.tr(),
                      style: AppFonts.body(
                        fontSize: 11.sp,
                        color: AppColors.textGreyColor,
                      ),
                    ),
                    Text(
                      _money(order.total),
                      style: AppFonts.heading(
                        fontSize: 24.sp,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkBrown,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (order.shippingFee > 0)
                      Text(
                        'Shipping: ${_money(order.shippingFee)}',
                        style: AppFonts.body(
                          fontSize: 11.sp,
                          color: AppColors.textGreyColor,
                        ),
                      ),
                    if (order.discount != null && order.discount! > 0)
                      Text(
                        'Discount: -${_money(order.discount!)}',
                        style: AppFonts.body(
                          fontSize: 11.sp,
                          color: AppColors.successColor,
                        ),
                      ),
                    if (order.isPaid == 1) ...[
                      SizedBox(height: 5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColors.successColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'orders.paid'.tr(),
                          style: AppFonts.body(
                            fontSize: 10.sp,
                            color: AppColors.successColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            if (actionButtons != null) ...[
              SizedBox(height: 12.h),
              actionButtons,
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildActionButtons({required bool isDark}) {
    final status = order.status.toLowerCase();
    final isPaid = order.isPaid == 1;
    final buttons = <Widget>[];

    if (status == 'pending') {
      if (onAccept != null) {
        buttons.add(
          _buildFilledActionButton(
            label: 'orders.accept'.tr(),
            icon: Icons.check_rounded,
            onPressed: onAccept!,
            backgroundColor: AppColors.successColor,
          ),
        );
      }
      if (onReject != null) {
        buttons.add(
          _buildOutlinedActionButton(
            label: 'orders.reject'.tr(),
            icon: Icons.close_rounded,
            onPressed: onReject!,
            isDark: isDark,
            color: AppColors.errorColor,
          ),
        );
      }
    }

    if (['accepted', 'processing', 'on_the_way', 'ready'].contains(status)) {
      if (onChangeStatus != null) {
        buttons.add(
          _buildFilledActionButton(
            label: 'orders.changeStatus'.tr(),
            icon: Icons.sync_alt_rounded,
            onPressed: onChangeStatus!,
            backgroundColor: AppColors.darkBrown,
          ),
        );
      }
      if (onMarkAsPaid != null && !isPaid) {
        buttons.add(
          _buildOutlinedActionButton(
            label: 'orders.markAsPaid'.tr(),
            icon: Icons.payments_outlined,
            onPressed: onMarkAsPaid!,
            isDark: isDark,
            color: AppColors.successColor,
          ),
        );
      }
    }

    if (status == 'completed' && !isPaid && onMarkAsPaid != null) {
      buttons.add(
        _buildFilledActionButton(
          label: 'orders.markAsPaid'.tr(),
          icon: Icons.payments_rounded,
          onPressed: onMarkAsPaid!,
          backgroundColor: AppColors.successColor,
        ),
      );
    }

    if (buttons.isEmpty) {
      return null;
    }

    if (buttons.length == 1) {
      return SizedBox(width: double.infinity, child: buttons.first);
    }

    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          Expanded(child: buttons[i]),
          if (i < buttons.length - 1) SizedBox(width: 10.w),
        ],
      ],
    );
  }

  Widget _buildFilledActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return SizedBox(
      height: 42.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16.sp),
        label: Text(
          label,
          style: AppFonts.body(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    required Color color,
  }) {
    return SizedBox(
      height: 42.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16.sp, color: color),
        label: Text(
          label,
          style: AppFonts.body(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? color.withOpacity(0.55) : color.withOpacity(0.35),
          ),
          backgroundColor: color.withOpacity(isDark ? 0.12 : 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

class _OrderMetaChip extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;

  const _OrderMetaChip({
    required this.isDark,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : AppColors.darkBrown.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.darkBrown.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.darkBrown,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppFonts.body(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemsPreview extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  final String Function(double) moneyFormatter;

  const _OrderItemsPreview({
    required this.order,
    required this.isDark,
    required this.moneyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final previewItems = order.orderItems.take(3).toList();
    final extraItems = order.orderItems.length - previewItems.length;
    final totalPieces = order.orderItems.fold<int>(
      0,
      (sum, item) => sum + item.qty,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkThemeContainerColorElevated
            : AppColors.backGroundColorLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : AppColors.primaryColor.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'orders.items'.tr(),
                style: AppFonts.body(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkGreyTextColor,
                ),
              ),
              const Spacer(),
              Text(
                '$totalPieces pcs',
                style: AppFonts.body(
                  fontSize: 11.sp,
                  color: AppColors.textGreyColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...previewItems.map((item) {
            final productName = (item.product?.name ?? '').trim().isEmpty
                ? 'orders.unknownProduct'.tr()
                : item.product!.name;
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$productName x${item.qty}',
                      style: AppFonts.body(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkGreyTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    moneyFormatter(item.subtotal),
                    style: AppFonts.body(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.lightTextColorForDarkMood
                          : AppColors.darkGreyTextColor,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (extraItems > 0)
            Text(
              '+$extraItems ${'orders.moreItems'.tr()}',
              style: AppFonts.body(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textGreyColor,
              ),
            ),
        ],
      ),
    );
  }
}
