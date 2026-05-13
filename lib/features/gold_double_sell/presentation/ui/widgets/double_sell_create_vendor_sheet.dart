import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_button.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_vendor_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_carat_model.dart';

class DoubleSellCreateVendorSheet extends StatefulWidget {
  final List<GoldCaratModel> carats;
  final List<CurrencyModel> currencies;

  const DoubleSellCreateVendorSheet({
    super.key,
    required this.carats,
    required this.currencies,
  });

  @override
  State<DoubleSellCreateVendorSheet> createState() =>
      _DoubleSellCreateVendorSheetState();
}

class _DoubleSellCreateVendorSheetState extends State<DoubleSellCreateVendorSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  GoldCaratModel? _selectedCarat;
  CurrencyModel? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    if (widget.carats.isNotEmpty) {
      _selectedCarat = widget.carats.first;
    }
    if (widget.currencies.isNotEmpty) {
      _selectedCurrency = widget.currencies.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'common.createVendor'.tr(),
              style: AppFonts.heading(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextFormField(
              controller: _nameController,
              labelText: 'common.name'.tr(),
              height: 68.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
            CustomTextFormField(
              controller: _phoneController,
              labelText: 'common.phoneOptional'.tr(),
              keyboardType: TextInputType.phone,
              height: 68.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
            DropdownButtonFormField<GoldCaratModel>(
              value: _selectedCarat,
              decoration: _inputDecoration('common.carat'.tr(), isDark),
              items: widget.carats
                  .map(
                    (carat) => DropdownMenuItem(
                      value: carat,
                      child: Text(carat.carat),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedCarat = value),
            ),
            SizedBox(height: 10.h),
            DropdownButtonFormField<CurrencyModel>(
              value: _selectedCurrency,
              decoration: _inputDecoration('gold_double_sell.currency'.tr(), isDark),
              items: widget.currencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text('${currency.code} - ${currency.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedCurrency = value),
            ),
            SizedBox(height: 10.h),
            CustomTextFormField(
              controller: _notesController,
              labelText: 'common.notesOptional'.tr(),
              height: 90.h,
              minLines: 3,
              maxLines: 3,
              borderRadius: BorderRadius.circular(12.r),
            ),
            SizedBox(height: 14.h),
            CustomButton(
              text: 'common.createVendor'.tr(),
              onPressed: _submit,
              color: AppColors.darkBrown,
              borderRadius: 12.r,
              height: 48.h,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : AppColors.backGroundColorLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedCarat == null || _selectedCurrency == null) {
      return;
    }

    Navigator.of(context).pop(
      CreateVendorRequestModel(
        name: name,
        caratId: _selectedCarat!.id,
        currencyId: _selectedCurrency!.id,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }
}
