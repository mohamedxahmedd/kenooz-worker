import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_sell_find_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/cubit/silver_buy_sell_link_state.dart';

class SilverBuySellLinkSection extends StatefulWidget {
  final SilverBuySellLinkState state;
  final int? linkedSellId;
  final VoidCallback onClear;
  final Function(int id) onSearchById;
  final Function(String term) onSearchByClient;
  final Function(SilverSellFindModel sell) onSelectSell;

  const SilverBuySellLinkSection({
    Key? key,
    required this.state,
    required this.linkedSellId,
    required this.onClear,
    required this.onSearchById,
    required this.onSearchByClient,
    required this.onSelectSell,
  }) : super(key: key);

  @override
  State<SilverBuySellLinkSection> createState() =>
      _SilverBuySellLinkSectionState();
}

class _SilverBuySellLinkSectionState extends State<SilverBuySellLinkSection> {
  late TextEditingController orderIdController;
  late TextEditingController clientTermController;

  @override
  void initState() {
    super.initState();
    orderIdController = TextEditingController();
    clientTermController = TextEditingController();
  }

  @override
  void dispose() {
    orderIdController.dispose();
    clientTermController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.silverColor.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'silver_buy.linkToPriorSell'.tr(),
                style: AppFonts.heading(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.silverColor,
                ),
              ),
              const Spacer(),
              if (widget.linkedSellId != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.silverColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.silverColor.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${'silver_buy.linkToPriorSell'.tr()} #${widget.linkedSellId}',
                        style: AppFonts.body(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.silverColor,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: widget.onClear,
                        child: Icon(
                          Icons.close_rounded,
                          size: 14.sp,
                          color: AppColors.silverColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'silver_buy.optional'.tr(),
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: orderIdController,
                  labelText: 'silver_buy.orderId'.tr(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  height: 66.h,
                  borderRadius: BorderRadius.circular(12.r),
                  borderColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.silverColor.withOpacity(0.14),
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.04)
                      : AppColors.backGroundColorLight,
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () {
                    final id = int.tryParse(orderIdController.text.trim());
                    if (id != null) {
                      widget.onSearchById(id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.silverColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text('common.search'.tr()),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: clientTermController,
                  labelText: 'silver_buy.phoneOrEmail'.tr(),
                  height: 66.h,
                  borderRadius: BorderRadius.circular(12.r),
                  borderColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.silverColor.withOpacity(0.14),
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.04)
                      : AppColors.backGroundColorLight,
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () {
                    final term = clientTermController.text.trim();
                    if (term.isNotEmpty) {
                      widget.onSearchByClient(term);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.silverColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text('common.search'.tr()),
                ),
              ),
            ],
          ),
          _buildStateContent(isDark),
        ],
      ),
    );
  }

  Widget _buildStateContent(bool isDark) {
    return widget.state.maybeWhen(
      initial: () => Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Text(
          'silver_buy.searchByOrderIdOrClient'.tr(),
          style: AppFonts.body(
            fontSize: 12.sp,
            color: isDark
                ? AppColors.textGreyColor
                : AppColors.darkGreyTextColor,
          ),
        ),
      ),
      loading: () => Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: const LinearProgressIndicator(minHeight: 2),
      ),
      notFound: () => Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14.sp,
              color: AppColors.errorColor,
            ),
            SizedBox(width: 4.w),
            Text(
              'silver_buy.sellNotFound'.tr(),
              style: AppFonts.body(
                fontSize: 12.sp,
                color: AppColors.errorColor,
              ),
            ),
          ],
        ),
      ),
      foundSingle: (sell) => Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: _SellCard(sell: sell, onTap: () => widget.onSelectSell(sell)),
      ),
      foundClientSells: (clientSells) => Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: clientSells.silverSells.isEmpty
            ? Text(
                'silver_buy.noSellOrdersForClient'.tr(),
                style: AppFonts.body(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textGreyColor
                      : AppColors.darkGreyTextColor,
                ),
              )
            : Column(
                children: List.generate(
                  clientSells.silverSells.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == clientSells.silverSells.length - 1
                          ? 0
                          : 8.h,
                    ),
                    child: _SellCard(
                      sell: clientSells.silverSells[index],
                      onTap: () =>
                          widget.onSelectSell(clientSells.silverSells[index]),
                    ),
                  ),
                ),
              ),
      ),
      error: (messages) => Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Text(
          messages.join('\n'),
          style: AppFonts.body(fontSize: 12.sp, color: AppColors.errorColor),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _SellCard extends StatelessWidget {
  final SilverSellFindModel sell;
  final VoidCallback onTap;

  const _SellCard({Key? key, required this.sell, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkThemeContainerColorElevated
                : AppColors.backGroundColorLight,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : AppColors.silverColor.withOpacity(0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'silver_buy.sellRecord'.tr() + ' #${sell.id}',
                    style: AppFonts.heading(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.lightTextColorForDarkMood
                          : AppColors.silverColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    sell.sellDate,
                    style: AppFonts.body(
                      fontSize: 11.sp,
                      color: isDark
                          ? AppColors.textGreyColor
                          : AppColors.darkGreyTextColor,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12.sp,
                    color: AppColors.silverColor,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'common.total'.tr(),
                        style: AppFonts.body(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.textGreyColor
                              : AppColors.darkGreyTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${sell.total.toStringAsFixed(2)} ${'common.egp'.tr()}',
                        style: AppFonts.heading(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.silverColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'common.grams'.tr(),
                        style: AppFonts.body(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.textGreyColor
                              : AppColors.darkGreyTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${sell.totalGrams.toStringAsFixed(2)} g',
                        style: AppFonts.heading(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.lightTextColorForDarkMood
                              : AppColors.silverColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
