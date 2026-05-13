import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_button.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/create_carat_request_model.dart';

class GoldBuyCreateCaratSheet extends StatefulWidget {
  const GoldBuyCreateCaratSheet({super.key});

  @override
  State<GoldBuyCreateCaratSheet> createState() =>
      _GoldBuyCreateCaratSheetState();
}

class _GoldBuyCreateCaratSheetState extends State<GoldBuyCreateCaratSheet> {
  final TextEditingController _caratController = TextEditingController();
  final TextEditingController _fixedController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _caratController.dispose();
    _fixedController.dispose();
    _priceController.dispose();
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
              'gold_buy.createCarat'.tr(),
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
              controller: _caratController,
              labelText: 'common.carat'.tr(),
              height: 68.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
            SizedBox(height: 8.h),
            CustomTextFormField(
              controller: _fixedController,
              labelText: 'common.fixed'.tr(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              height: 68.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
            SizedBox(height: 8.h),
            CustomTextFormField(
              controller: _priceController,
              labelText: 'common.price'.tr(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              height: 68.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
            SizedBox(height: 14.h),
            CustomButton(
              text: 'gold_buy.createCarat'.tr(),
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

  void _submit() {
    final carat = _caratController.text.trim();
    final fixed = double.tryParse(_fixedController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0;

    if (carat.isEmpty || fixed <= 0 || price <= 0) {
      return;
    }

    Navigator.of(
      context,
    ).pop(CreateCaratRequestModel(carat: carat, fixed: fixed, price: price));
  }
}
