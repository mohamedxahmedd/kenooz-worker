import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';

class DoubleSellPaymentEntry {
  final int accountId;
  final int currencyId;
  final double originalCashAmount;
  final double cash;
  final double currencyPrice;
  final String accountName;
  final String currencyCode;

  const DoubleSellPaymentEntry({
    required this.accountId,
    required this.currencyId,
    required this.originalCashAmount,
    required this.cash,
    required this.currencyPrice,
    required this.accountName,
    required this.currencyCode,
  });

  Map<String, dynamic> toRequestMap() {
    return {
      'account_id': accountId,
      'currency_id': currencyId,
      'cash': cash,
      'currency_price': currencyPrice,
    };
  }
}

class DoubleSellPaymentSection extends StatefulWidget {
  final String title;
  final String restAmountLabel;
  final double cartTotalAmount;
  final Color accentColor;
  final List<PaymentAccountModel> accounts;
  final List<DoubleSellPaymentEntry> entries;
  final ValueChanged<DoubleSellPaymentEntry> onAdd;
  final ValueChanged<int> onRemove;
  final bool isRateEditable;

  const DoubleSellPaymentSection({
    super.key,
    required this.title,
    required this.restAmountLabel,
    required this.cartTotalAmount,
    required this.accentColor,
    required this.accounts,
    required this.entries,
    required this.onAdd,
    required this.onRemove,
    this.isRateEditable = false,
  });

  @override
  State<DoubleSellPaymentSection> createState() =>
      _DoubleSellPaymentSectionState();
}

class _DoubleSellPaymentSectionState extends State<DoubleSellPaymentSection> {
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  PaymentAccountModel? _selectedAccount;

  double _parseAmount(String value) => double.tryParse(value.trim()) ?? 0;

  double get _enteredRate {
    if (widget.isRateEditable) {
      return _parseAmount(_rateController.text);
    }
    return _selectedAccount?.currencyPrice ?? 0;
  }

  double get _enteredCashAmount => _parseAmount(_cashController.text);

  double get _totalInEgp => _enteredRate * _enteredCashAmount;

  double get _addedAccountsTotal =>
      widget.entries.fold(0.0, (sum, entry) => sum + entry.cash);

  double get _restOfCartTotal => widget.cartTotalAmount - _addedAccountsTotal;

  @override
  void dispose() {
    _cashController.dispose();
    _rateController.dispose();
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
              : widget.accentColor.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppFonts.heading(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${widget.restAmountLabel}: ${_restOfCartTotal.toStringAsFixed(2)} ${'common.egp'.tr()}',
            style: AppFonts.body(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '${widget.cartTotalAmount.toStringAsFixed(2)} - ${_addedAccountsTotal.toStringAsFixed(2)} = ${_restOfCartTotal.toStringAsFixed(2)}',
            style: AppFonts.body(
              fontSize: 11.sp,
              color: isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField<PaymentAccountModel>(
            value: _selectedAccount,
            decoration: _inputDecoration(isDark),
            dropdownColor: isDark
                ? AppColors.darkThemeContainerColorElevated
                : Colors.white,
            iconEnabledColor: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.darkBrown,
            items: widget.accounts
                .map(
                  (account) => DropdownMenuItem<PaymentAccountModel>(
                    value: account,
                    child: Text(
                      '${account.name} (${account.currencyCode})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedAccount = value;
                if (widget.isRateEditable) {
                  _rateController.text =
                      value?.currencyPrice.toStringAsFixed(2) ?? '';
                }
              });
            },
          ),
          SizedBox(height: 8.h),
          if (_selectedAccount != null && !widget.isRateEditable)
            Text(
              '${'gold_double_sell.rate'.tr()}: ${_selectedAccount!.currencyPrice.toStringAsFixed(2)}',
              style: AppFonts.body(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textGreyColor
                    : AppColors.darkGreyTextColor,
              ),
            ),
          SizedBox(height: 8.h),
          if (_selectedAccount != null && widget.isRateEditable)
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _rateController,
                    labelText: 'gold_double_sell.rate'.tr(),
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    height: 68.h,
                    borderRadius: BorderRadius.circular(12.r),
                    borderColor: isDark
                        ? Colors.white.withOpacity(0.08)
                        : AppColors.darkBrown.withOpacity(0.1),
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.04)
                        : AppColors.backGroundColorLight,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomTextFormField(
                    controller: _cashController,
                    labelText: 'common.cashAmount'.tr(),
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    height: 68.h,
                    borderRadius: BorderRadius.circular(12.r),
                    borderColor: isDark
                        ? Colors.white.withOpacity(0.08)
                        : AppColors.darkBrown.withOpacity(0.1),
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.04)
                        : AppColors.backGroundColorLight,
                  ),
                ),
              ],
            )
          else
            CustomTextFormField(
              controller: _cashController,
              labelText: 'common.cashAmount'.tr(),
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              height: 68.h,
              borderRadius: BorderRadius.circular(12.r),
              borderColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.darkBrown.withOpacity(0.1),
              fillColor: isDark
                  ? Colors.white.withOpacity(0.04)
                  : AppColors.backGroundColorLight,
            ),
          if (_selectedAccount != null) ...[
            // SizedBox(height: 6.h),
            // Text(
            //   'Total = Rate x Cash amount',
            //   style: AppFonts.body(
            //     fontSize: 12.sp,
            //     color: isDark
            //         ? AppColors.textGreyColor
            //         : AppColors.darkGreyTextColor,
            //   ),
            // ),
            SizedBox(height: 2.h),
            Text(
              '${'common.summary'.tr()} (${'common.egp'.tr()}): ${_totalInEgp.toStringAsFixed(2)}',
              style: AppFonts.body(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text('common.addAccount'.tr()),
            ),
          ),
          SizedBox(height: 10.h),
          if (widget.entries.isEmpty)
            Text(
              'common.noAccountsAdded'.tr(),
              style: AppFonts.body(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textGreyColor
                    : AppColors.darkGreyTextColor,
              ),
            )
          else
            Column(
              children: List.generate(widget.entries.length, (index) {
                final entry = widget.entries[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == widget.entries.length - 1 ? 0 : 8.h,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkThemeContainerColorElevated
                          : AppColors.backGroundColorLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.originalCashAmount.toStringAsFixed(2)} ${entry.currencyCode} - ${entry.accountName}',
                                style: AppFonts.body(
                                  fontSize: 12.sp,
                                  color: isDark
                                      ? AppColors.lightTextColorForDarkMood
                                      : AppColors.darkBrown,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${entry.originalCashAmount.toStringAsFixed(2)} x ${entry.currencyPrice.toStringAsFixed(2)} = ${entry.cash.toStringAsFixed(2)} EGP',
                                style: AppFonts.body(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textGreyColor
                                      : AppColors.darkGreyTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => widget.onRemove(index),
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.errorColor,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  void _addEntry() {
    final account = _selectedAccount;
    final cashAmount = double.tryParse(_cashController.text.trim()) ?? 0;
    final rate = widget.isRateEditable
        ? (double.tryParse(_rateController.text.trim()) ?? 0)
        : (account?.currencyPrice ?? 0);
    if (account == null || cashAmount <= 0 || rate <= 0) return;

    final totalCash = cashAmount * rate;

    widget.onAdd(
      DoubleSellPaymentEntry(
        accountId: account.id,
        currencyId: account.currencyId,
        originalCashAmount: cashAmount,
        cash: totalCash,
        currencyPrice: rate,
        accountName: account.name,
        currencyCode: account.currencyCode,
      ),
    );

    _cashController.clear();
  }

  InputDecoration _inputDecoration(bool isDark) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : AppColors.backGroundColorLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.darkBrown.withOpacity(0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.darkBrown.withOpacity(0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.darkBrown),
      ),
    );
  }
}
