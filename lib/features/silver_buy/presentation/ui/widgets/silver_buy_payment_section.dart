import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';

class SilverBuyPaymentEntry {
  final int accountId;
  final String accountName;
  final String currencyCode;
  final double originalCashAmount;
  final double cash;
  final double currencyPrice;

  const SilverBuyPaymentEntry({
    required this.accountId,
    required this.accountName,
    required this.currencyCode,
    required this.originalCashAmount,
    required this.cash,
    required this.currencyPrice,
  });

  Map<String, dynamic> toRequestMap() {
    return {
      'account_id': accountId,
      'cash': cash,
      'currency_price': currencyPrice,
    };
  }
}

class SilverBuyPaymentSection extends StatefulWidget {
  final double totalBuyPrice;
  final List<PaymentAccountModel> accounts;
  final List<SilverBuyPaymentEntry> entries;
  final ValueChanged<SilverBuyPaymentEntry> onAdd;
  final ValueChanged<int> onRemove;

  const SilverBuyPaymentSection({
    super.key,
    required this.totalBuyPrice,
    required this.accounts,
    required this.entries,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<SilverBuyPaymentSection> createState() =>
      _SilverBuyPaymentSectionState();
}

class _SilverBuyPaymentSectionState extends State<SilverBuyPaymentSection> {
  final TextEditingController _cashController = TextEditingController();
  PaymentAccountModel? _selectedAccount;

  double _parseAmount(String value) => double.tryParse(value.trim()) ?? 0;

  double get _enteredRate => _selectedAccount?.currencyPrice ?? 0;

  double get _enteredCashAmount => _parseAmount(_cashController.text);

  double get _totalInEgp => _enteredRate * _enteredCashAmount;

  double get _addedAccountsTotal =>
      widget.entries.fold(0.0, (sum, entry) => sum + entry.cash);

  double get _restOfCartTotal => widget.totalBuyPrice - _addedAccountsTotal;

  @override
  void dispose() {
    _cashController.dispose();
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
              : AppColors.silverColor.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'common.paymentAccounts'.tr(),
            style: AppFonts.heading(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.silverColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${'silver_buy.rest'.tr()}: ${_restOfCartTotal.toStringAsFixed(2)} ${'common.egp'.tr()}',
            style: AppFonts.body(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.silverColor,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '${widget.totalBuyPrice.toStringAsFixed(2)} - ${_addedAccountsTotal.toStringAsFixed(2)} = ${_restOfCartTotal.toStringAsFixed(2)}',
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
                : AppColors.silverColor,
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
              });
            },
          ),
          SizedBox(height: 8.h),
          if (_selectedAccount != null)
            Text(
              'Rate: ${_selectedAccount!.currencyPrice.toStringAsFixed(2)}',
              style: AppFonts.body(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textGreyColor
                    : AppColors.darkGreyTextColor,
              ),
            ),
          SizedBox(height: 8.h),
          if (_selectedAccount != null)
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
                  : AppColors.silverColor.withOpacity(0.14),
              fillColor: isDark
                  ? Colors.white.withOpacity(0.04)
                  : AppColors.backGroundColorLight,
            ),
          if (_selectedAccount != null) ...[
            SizedBox(height: 2.h),
            Text(
              '${'common.total'.tr()} (${'common.egp'.tr()}): ${_totalInEgp.toStringAsFixed(2)}',
              style: AppFonts.body(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.silverColor,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.silverColor,
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
                                      : AppColors.silverColor,
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
    final rate = account?.currencyPrice ?? 0;
    if (account == null || cashAmount <= 0 || rate <= 0) return;

    final totalCash = cashAmount * rate;

    widget.onAdd(
      SilverBuyPaymentEntry(
        accountId: account.id,
        accountName: account.name,
        currencyCode: account.currencyCode,
        originalCashAmount: cashAmount,
        cash: totalCash,
        currencyPrice: rate,
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
              : AppColors.silverColor.withOpacity(0.16),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.silverColor.withOpacity(0.16),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.silverColor),
      ),
    );
  }
}
