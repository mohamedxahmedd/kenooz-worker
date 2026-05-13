import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_item_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_record_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_unified_sell_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_sell_item_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_sell_record_history_model.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/ui/widgets/invoice_action_buttons.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/ui/widgets/invoice_type.dart';

class DiamondSellHistoryDetailModal extends StatelessWidget {
  final DiamondUnifiedSellHistoryModel sell;
  const DiamondSellHistoryDetailModal({super.key, required this.sell});

  static void show(BuildContext context, DiamondUnifiedSellHistoryModel sell) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DiamondSellHistoryDetailModal(sell: sell),
    );
  }

  static const Color _accentColor = Color(0xFF64B5F6);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shortId = sell.unifiedId.length > 8
        ? '${sell.unifiedId.substring(0, 8)}…'
        : sell.unifiedId;

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
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 12.w, 12.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                   
                    child: SvgPicture.asset('assets/images/diamond.svg'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'diamond_sell.title'.tr(),
                          style: AppFonts.heading(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.lightTextColorForDarkMood
                                : AppColors.darkBrown,
                          ),
                        ),
                        Text(
                          '${sell.client.name} · $shortId',
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

            // ── Summary chips ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              child: Row(
                children: [
                  _SummaryChip(
                    icon: Icons.calendar_today_rounded,
                    label: sell.sellDate,
                    accentColor: _accentColor,
                    isDark: isDark,
                  ),
                  SizedBox(width: 8.w),
                  _SummaryChip(
                    icon: Icons.monetization_on_rounded,
                    label:
                        '${sell.grandTotal.toStringAsFixed(2)} ${'common.egp'.tr()}',
                    accentColor: _accentColor,
                    isDark: isDark,
                  ),
                  SizedBox(width: 8.w),
                  _SummaryChip(
                    icon: Icons.person_outline_rounded,
                    label: sell.worker.name,
                    accentColor: _accentColor,
                    isDark: isDark,
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

            // ── Scrollable content ───────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Diamond Items
                    if (sell.totalDiamondItems > 0) ...[
                      _SectionHeader(
                        title: 'common.diamondItems'.tr(),
                        count: sell.totalDiamondItems,
                        isDark: isDark,
                        accentColor: _accentColor,
                      ),
                      SizedBox(height: 10.h),
                      ...sell.diamondSells
                          .map((record) => _DiamondRecordSection(
                              record: record,
                              isDark: isDark,
                              accentColor: _accentColor)),
                    ],

                    // Stone Items
                    if (sell.totalStoneItems > 0) ...[
                      SizedBox(height: sell.totalDiamondItems > 0 ? 20.h : 0),
                      _SectionHeader(
                        title: 'common.stoneItems'.tr(),
                        count: sell.totalStoneItems,
                        isDark: isDark,
                        accentColor: const Color(0xFF9C89B8),
                      ),
                      SizedBox(height: 10.h),
                      ...sell.stoneSells.map((record) =>
                          _StoneRecordSection(
                              record: record,
                              isDark: isDark,
                              accentColor: const Color(0xFF9C89B8))),
                    ],

                    if (sell.totalItemCount == 0)
                      _EmptySection(isDark: isDark),

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

// ── Diamond Record Section ───────────────────────────────────────────────────

class _DiamondRecordSection extends StatelessWidget {
  final DiamondSellRecordHistoryModel record;
  final bool isDark;
  final Color accentColor;
  const _DiamondRecordSection({
    required this.record,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${'diamond_sell.diamond'.tr()} #${record.id}',
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
              '${record.total.toStringAsFixed(2)} ${'common.egp'.tr()}',
              style: AppFonts.body(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const Spacer(),
            InvoiceActionButtons(
              type: InvoiceType.diamond,
              id: record.id,
              accentColor: accentColor,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _DiamondItemsTable(items: record.items, isDark: isDark),
        SizedBox(height: 10.h),
      ],
    );
  }
}

class _DiamondItemsTable extends StatelessWidget {
  final List<DiamondSellItemHistoryModel> items;
  final bool isDark;
  const _DiamondItemsTable({required this.items, required this.isDark});

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
          DataColumn(label: Text('common.diamondName'.tr())),
          DataColumn(label: Text('common.kind'.tr())),
          DataColumn(label: Text('common.vendor'.tr())),
          DataColumn(label: Text('common.weight'.tr())),
          DataColumn(label: Text('common.dollarPrice'.tr())),
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
              DataCell(Text(item.diamondName)),
              DataCell(Text(item.kindName)),
              DataCell(Text(item.vendorName)),
              DataCell(Text('${item.diamondWeight.toStringAsFixed(3)} ct')),
              DataCell(Text('\$${item.dollars.toStringAsFixed(2)}')),
              DataCell(Text(
                '${item.price.toStringAsFixed(2)} ${'common.egp'.tr()}',
                style: AppFonts.body(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64B5F6),
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Stone Record Section ─────────────────────────────────────────────────────

class _StoneRecordSection extends StatelessWidget {
  final StoneSellRecordHistoryModel record;
  final bool isDark;
  final Color accentColor;
  const _StoneRecordSection({
    required this.record,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${'diamond_sell.stone'.tr()} #${record.id}',
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
              '${record.total.toStringAsFixed(2)} ${'common.egp'.tr()}',
              style: AppFonts.body(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const Spacer(),
            InvoiceActionButtons(
              type: InvoiceType.stone,
              id: record.id,
              accentColor: accentColor,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _StoneItemsTable(items: record.items, isDark: isDark),
        SizedBox(height: 10.h),
      ],
    );
  }
}

class _StoneItemsTable extends StatelessWidget {
  final List<StoneSellItemHistoryModel> items;
  final bool isDark;
  const _StoneItemsTable({required this.items, required this.isDark});

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
          DataColumn(label: Text('common.stoneName'.tr())),
          DataColumn(label: Text('common.company'.tr())),
          DataColumn(label: Text('common.weight'.tr())),
          DataColumn(label: Text('common.dollarPrice'.tr())),
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
              DataCell(Text(item.stoneName)),
              DataCell(Text(item.companyName)),
              DataCell(Text('${item.weight.toStringAsFixed(3)} ct')),
              DataCell(Text('\$${item.dollars.toStringAsFixed(2)}')),
              DataCell(Text(
                '${item.price.toStringAsFixed(2)} ${'common.egp'.tr()}',
                style: AppFonts.body(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9C89B8),
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
  final bool isDark;
  final Color accentColor;
  const _SectionHeader(
      {required this.title,
      required this.count,
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
            color:
                isDark ? AppColors.textGreyColor : AppColors.darkGreyTextColor,
          ),
        ),
      ),
    );
  }
}
