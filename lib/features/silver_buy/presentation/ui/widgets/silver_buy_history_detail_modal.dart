import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_full_history_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_buy_item_history_model.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/ui/widgets/invoice_action_buttons.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/ui/widgets/invoice_type.dart';

class SilverBuyHistoryDetailModal extends StatelessWidget {
  final SilverBuyFullHistoryModel buy;
  const SilverBuyHistoryDetailModal({super.key, required this.buy});

  static void show(BuildContext context, SilverBuyFullHistoryModel buy) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SilverBuyHistoryDetailModal(buy: buy),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppColors.silverColor;

    final sourceName = buy.hasClient
        ? buy.client!.name
        : (buy.hasVendor ? buy.vendor!.name : 'common.worker'.tr());

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.silverColor.withOpacity(0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 12.w, 12.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    
                    child: SvgPicture.asset('assets/images/silver-bars.svg'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'silver_buy.title'.tr(),
                          style: AppFonts.heading(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.lightTextColorForDarkMood
                                : AppColors.silverColor,
                          ),
                        ),
                        Text(
                          '$sourceName · #${buy.id}',
                          style: AppFonts.body(
                            fontSize: 12.sp,
                            color: isDark
                                ? AppColors.textGreyColor
                                : AppColors.darkGreyTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InvoiceActionButtons(
                    type: InvoiceType.silverBuy,
                    id: buy.id,
                    accentColor: accentColor,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 22.sp,
                      color: isDark
                          ? AppColors.textGreyColor
                          : AppColors.darkGreyTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // ── Summary chips ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              child: Row(
                children: [
                  _SummaryChip(
                    icon: Icons.calendar_today_rounded,
                    label: buy.createdAt.length >= 10
                        ? buy.createdAt.substring(0, 10)
                        : buy.createdAt,
                    accentColor: accentColor,
                    isDark: isDark,
                  ),
                  SizedBox(width: 8.w),
                  _SummaryChip(
                    icon: Icons.monetization_on_rounded,
                    label:
                        '${buy.total.toStringAsFixed(2)} ${'common.egp'.tr()}',
                    accentColor: accentColor,
                    isDark: isDark,
                  ),
                  SizedBox(width: 8.w),
                  _SummaryChip(
                    icon: Icons.person_outline_rounded,
                    label: buy.worker.name,
                    accentColor: accentColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // Linked sell chip if applicable
            if (buy.isLinkedToSell)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 13.sp,
                          color: accentColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${'silver_buy.sellRecord'.tr()} #${buy.sellId}',
                          style: AppFonts.body(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : AppColors.silverColor.withOpacity(0.16),
            ),

            // ── Scrollable content ───────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'common.allItems'.tr(),
                      count: buy.items.length,
                      isDark: isDark,
                      accentColor: accentColor,
                    ),
                    SizedBox(height: 10.h),
                    if (buy.items.isEmpty)
                      _EmptySection(isDark: isDark)
                    else
                      _SilverBuyItemsTable(items: buy.items, isDark: isDark),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Silver Buy Items Table ───────────────────────────────────────────────────

class _SilverBuyItemsTable extends StatelessWidget {
  final List<SilverBuyItemHistoryModel> items;
  final bool isDark;
  const _SilverBuyItemsTable({required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36.h,
        dataRowMinHeight: 40.h,
        dataRowMaxHeight: 48.h,
        columnSpacing: 18.w,
        horizontalMargin: 12.w,
        headingTextStyle: AppFonts.body(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.lightTextColorForDarkMood
              : AppColors.silverColor,
        ),
        dataTextStyle: AppFonts.body(
          fontSize: 11.sp,
          color: isDark ? AppColors.textGreyColor : AppColors.darkGreyTextColor,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkThemeContainerColorElevated
              : AppColors.backGroundColorLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppColors.silverColor.withOpacity(0.14),
          ),
        ),
        columns: [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('common.carat'.tr())),
          DataColumn(label: Text('common.box'.tr())),
          DataColumn(label: Text('common.grams'.tr())),
          DataColumn(label: Text('common.loss'.tr())),
          DataColumn(label: Text('common.netGrams'.tr())),
          DataColumn(label: Text('common.gramPrice'.tr())),
          DataColumn(label: Text('common.total'.tr())),
        ],
        rows: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return DataRow(
            color: WidgetStateProperty.resolveWith(
              (states) => i.isOdd
                  ? (isDark
                        ? Colors.white.withOpacity(0.03)
                        : AppColors.silverColor.withOpacity(0.06))
                  : null,
            ),
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(item.caratLabel)),
              DataCell(Text(item.boxName ?? '-')),
              DataCell(Text(item.grams.toStringAsFixed(3))),
              DataCell(Text(item.loss.toStringAsFixed(3))),
              DataCell(Text(item.netGrams.toStringAsFixed(3))),
              DataCell(Text(item.gramPrice.toStringAsFixed(2))),
              DataCell(
                Text(
                  item.price.toStringAsFixed(2),
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.silverColor,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Shared sub-widgets ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;
  final Color accentColor;
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppFonts.heading(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.silverColor,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$count',
            style: AppFonts.body(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color accentColor;
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
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
            Flexible(
              child: Text(
                label,
                style: AppFonts.body(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final bool isDark;
  const _EmptySection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(
          'common.noItemsAdded'.tr(),
          style: AppFonts.body(
            fontSize: 13.sp,
            color: isDark
                ? AppColors.textGreyColor
                : AppColors.darkGreyTextColor,
          ),
        ),
      ),
    );
  }
}
