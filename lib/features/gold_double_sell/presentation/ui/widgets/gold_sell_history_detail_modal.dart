import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_buy_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_buy_item_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_sell_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_sell_item_history_model.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/ui/widgets/invoice_action_buttons.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/ui/widgets/invoice_type.dart';

class GoldSellHistoryDetailModal extends StatelessWidget {
  final GoldSellHistoryModel sell;
  const GoldSellHistoryDetailModal({super.key, required this.sell});

  static void show(BuildContext context, GoldSellHistoryModel sell) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => GoldSellHistoryDetailModal(sell: sell),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppColors.goldColor;

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
                : AppColors.primaryColor.withOpacity(0.14),
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
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 12.w, 12.h),
              child: Row(
                children: [
                  Container(
                    width: 33.w,
                    height: 33.w,
                    
                    child: SvgPicture.asset('assets/images/gold-bars.svg'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'gold_double_sell.title'.tr(),
                          style: AppFonts.heading(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.lightTextColorForDarkMood
                                : AppColors.darkBrown,
                          ),
                        ),
                        Text(
                          '${sell.client.name} · #${sell.id}',
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
                    type: InvoiceType.gold,
                    id: sell.id,
                    accentColor: accentColor,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded,
                        size: 22.sp,
                        color: isDark
                            ? AppColors.textGreyColor
                            : AppColors.darkGreyTextColor),
                  ),
                ],
              ),
            ),

            // ── Summary chips ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              child: Row(
                children: [
                  _SummaryChip(
                    icon: Icons.calendar_today_rounded,
                    label: sell.sellDate,
                    isDark: isDark,
                    accentColor: accentColor,
                  ),
                  SizedBox(width: 8.w),
                  _SummaryChip(
                    icon: Icons.monetization_on_rounded,
                    label:
                        '${sell.total.toStringAsFixed(2)} ${'common.egp'.tr()}',
                    isDark: isDark,
                    accentColor: accentColor,
                  ),
                  SizedBox(width: 8.w),
                  _SummaryChip(
                    icon: Icons.person_outline_rounded,
                    label: sell.worker.name,
                    isDark: isDark,
                    accentColor: accentColor,
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : AppColors.primaryColor.withOpacity(0.12),
            ),

            // ── Scrollable content ─────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sell Items Section
                    _SectionHeader(
                      title: 'common.sellItemsSection'.tr(),
                      count: sell.goldSellItems.length,
                      totalAmount: sell.goldSellItems.fold<double>(
                          0, (sum, item) => sum + item.price),
                      isDark: isDark,
                      accentColor: accentColor,
                    ),
                    SizedBox(height: 10.h),
                    if (sell.goldSellItems.isEmpty)
                      _EmptySection(isDark: isDark)
                    else
                      _GoldSellItemsTable(
                          items: sell.goldSellItems, isDark: isDark),

                    // Buy Items Section (if double sell)
                    if (sell.hasBuy) ...[
                      SizedBox(height: 20.h),
                      _SectionHeader(
                        title: 'common.buyItemsSection'.tr(),
                        count: sell.goldBuys
                            .fold(0, (s, b) => s + b.items.length),
                        totalAmount: sell.goldBuys.fold<double>(
                            0,
                            (sum, buy) =>
                                sum +
                                buy.items.fold<double>(
                                    0, (s, item) => s + item.price)),
                        isDark: isDark,
                        accentColor: AppColors.darkBrown,
                      ),
                      SizedBox(height: 10.h),
                      ...sell.goldBuys
                          .map((buy) => _GoldBuySection(buy: buy, isDark: isDark)),
                    ],

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

// ── Gold Sell Items Table ────────────────────────────────────────────────────

class _GoldSellItemsTable extends StatelessWidget {
  final List<GoldSellItemHistoryModel> items;
  final bool isDark;
  const _GoldSellItemsTable({required this.items, required this.isDark});

  String _typeLabel(GoldSellItemType t) {
    switch (t) {
      case GoldSellItemType.inside:
        return 'common.inside'.tr();
      case GoldSellItemType.box:
        return 'common.box'.tr();
      case GoldSellItemType.outside:
        return 'common.outside'.tr();
    }
  }

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
              : AppColors.darkBrown,
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
                : AppColors.primaryColor.withOpacity(0.1),
          ),
        ),
        columns: [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('common.type'.tr())),
          DataColumn(label: Text('common.carat'.tr())),
          DataColumn(label: Text('common.kind'.tr())),
          DataColumn(label: Text('common.vendor'.tr())),
          DataColumn(label: Text('common.grams'.tr())),
          DataColumn(label: Text('common.loss'.tr())),
          DataColumn(label: Text('common.mc'.tr())),
          DataColumn(label: Text('common.profit'.tr())),
          DataColumn(label: Text('common.gramPrice'.tr())),
          DataColumn(label: Text('common.total'.tr())),
        ],
        rows: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return DataRow(
            color: WidgetStateProperty.resolveWith((states) => i.isOdd
                ? (isDark
                    ? Colors.white.withOpacity(0.03)
                    : AppColors.primaryColor.withOpacity(0.03))
                : null),
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(_typeLabel(item.itemType))),
              DataCell(Text(item.caratLabel)),
              DataCell(Text(item.kindName)),
              DataCell(Text(item.vendorName)),
              DataCell(Text(item.grams.toStringAsFixed(3))),
              DataCell(Text(
                  item.loss != null ? item.loss!.toStringAsFixed(3) : '-')),
              DataCell(Text(item.mc.toStringAsFixed(2))),
              DataCell(Text(item.profit.toStringAsFixed(2))),
              DataCell(Text(item.gramPrice.toStringAsFixed(2))),
              DataCell(Text(
                item.price.toStringAsFixed(2),
                style: AppFonts.body(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldColor,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Gold Buy Section ─────────────────────────────────────────────────────────

class _GoldBuySection extends StatelessWidget {
  final GoldBuyHistoryModel buy;
  final bool isDark;
  const _GoldBuySection({required this.buy, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Buy #${buy.id}',
              style: AppFonts.body(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '${buy.items.fold<double>(0, (sum, item) => sum + item.price).toStringAsFixed(2)} ${'common.egp'.tr()}',
              style: AppFonts.body(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.goldColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _GoldBuyItemsTable(items: buy.items, isDark: isDark),
        SizedBox(height: 10.h),
      ],
    );
  }
}

class _GoldBuyItemsTable extends StatelessWidget {
  final List<GoldBuyItemHistoryModel> items;
  final bool isDark;
  const _GoldBuyItemsTable({required this.items, required this.isDark});

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
              : AppColors.darkBrown,
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
                : AppColors.primaryColor.withOpacity(0.1),
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
            color: WidgetStateProperty.resolveWith((states) => i.isOdd
                ? (isDark
                    ? Colors.white.withOpacity(0.03)
                    : AppColors.primaryColor.withOpacity(0.03))
                : null),
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(item.caratLabel)),
              DataCell(Text(item.boxName ?? '-')),
              DataCell(Text(item.grams.toStringAsFixed(3))),
              DataCell(Text(item.loss.toStringAsFixed(3))),
              DataCell(Text(item.netGrams.toStringAsFixed(3))),
              DataCell(Text(item.gramPrice.toStringAsFixed(2))),
              DataCell(Text(
                item.price.toStringAsFixed(2),
                style: AppFonts.body(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldColor,
                ),
              )),
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
  final double totalAmount;
  final bool isDark;
  final Color accentColor;
  const _SectionHeader(
      {required this.title,
      required this.count,
      required this.totalAmount,
      required this.isDark,
      required this.accentColor});

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
                : AppColors.darkBrown,
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
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '${totalAmount.toStringAsFixed(2)} ${'common.egp'.tr()}',
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
  const _SummaryChip(
      {required this.icon,
      required this.label,
      required this.isDark,
      required this.accentColor});

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
            color: isDark ? AppColors.textGreyColor : AppColors.darkGreyTextColor,
          ),
        ),
      ),
    );
  }
}
