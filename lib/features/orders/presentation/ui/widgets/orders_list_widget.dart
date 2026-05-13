import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_model.dart';
import 'order_card_widget.dart';

class OrdersListWidget extends StatelessWidget {
  final List<OrderModel> orders;
  final Future<void> Function()? onRefresh;
  final Function(OrderModel)? onAccept;
  final Function(OrderModel)? onReject;
  final Function(OrderModel)? onChangeStatus;
  final Function(OrderModel)? onMarkAsPaid;
  final String? emptyMessage;

  const OrdersListWidget({
    Key? key,
    required this.orders,
    this.onRefresh,
    this.onAccept,
    this.onReject,
    this.onChangeStatus,
    this.onMarkAsPaid,
    this.emptyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        color: AppColors.darkBrown,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
          children: [
            SizedBox(height: 84.h),
            _EmptyOrdersCard(
              isDark: isDark,
              message: emptyMessage ?? 'No orders found',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      color: AppColors.darkBrown,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
        itemCount: orders.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCardWidget(
            order: order,
            onAccept: onAccept != null ? () => onAccept!(order) : null,
            onReject: onReject != null ? () => onReject!(order) : null,
            onChangeStatus: onChangeStatus != null
                ? () => onChangeStatus!(order)
                : null,
            onMarkAsPaid: onMarkAsPaid != null
                ? () => onMarkAsPaid!(order)
                : null,
          );
        },
      ),
    );
  }
}

class _EmptyOrdersCard extends StatelessWidget {
  final bool isDark;
  final String message;

  const _EmptyOrdersCard({required this.isDark, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
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
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkThemeContainerColorElevated
                  : AppColors.darkBrown.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 30.sp,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Nothing here yet',
            style: AppFonts.heading(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkGreyTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 13.sp,
              color: AppColors.textGreyColor,
            ),
          ),
        ],
      ),
    );
  }
}
