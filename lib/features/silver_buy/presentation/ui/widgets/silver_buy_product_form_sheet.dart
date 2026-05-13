import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/services/toast_service.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_box_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_carat_model.dart';

class SilverBuyProductFormSheet extends StatefulWidget {
  final List<SilverCaratModel> carats;
  final List<SilverBoxModel> boxes;
  final VoidCallback onCreateCarat;

  const SilverBuyProductFormSheet({
    Key? key,
    required this.carats,
    required this.boxes,
    required this.onCreateCarat,
  }) : super(key: key);

  @override
  State<SilverBuyProductFormSheet> createState() =>
      _SilverBuyProductFormSheetState();
}

class _SilverBuyProductFormSheetState extends State<SilverBuyProductFormSheet> {
  SilverCaratModel? selectedCarat;
  SilverBoxModel? selectedBox;
  late TextEditingController gramsController;
  late TextEditingController lossController;
  late TextEditingController gramPriceController;
  double buyPrice = 0;

  @override
  void initState() {
    super.initState();
    gramsController = TextEditingController();
    lossController = TextEditingController(text: '0');
    gramPriceController = TextEditingController();
  }

  @override
  void dispose() {
    gramsController.dispose();
    lossController.dispose();
    gramPriceController.dispose();
    super.dispose();
  }

  void _onCaratSelected(SilverCaratModel? carat) {
    setState(() {
      selectedCarat = carat;
      if (carat != null) {
        gramPriceController.text = carat.price.toStringAsFixed(2);
        _updateBuyPrice();
      }
    });
  }

  void _updateBuyPrice() {
    final grams = double.tryParse(gramsController.text) ?? 0;
    final loss = double.tryParse(lossController.text) ?? 0;
    final gramPrice = double.tryParse(gramPriceController.text) ?? 0;

    double net = grams - loss;
    if (net < 0) net = 0;

    setState(() {
      buyPrice = net * gramPrice;
      if (buyPrice < 0) buyPrice = 0;
    });
  }

  void _submit() {
    if (selectedCarat == null) {
      ToastService.show('common.pleaseSelectCarat'.tr());
      return;
    }

    if (selectedBox == null) {
      ToastService.show('common.pleaseSelectBox'.tr());
      return;
    }

    final grams = double.tryParse(gramsController.text);
    if (grams == null || grams <= 0) {
      ToastService.show('silver_buy.gramsMustBeGreater'.tr());
      return;
    }

    final loss = double.tryParse(lossController.text) ?? 0;
    if (loss < 0) {
      ToastService.show('silver_buy.lossCannotBeNegative'.tr());
      return;
    }

    if (loss >= grams) {
      ToastService.show('silver_buy.lossMustBeLessThanGrams'.tr());
      return;
    }

    final gramPrice = double.tryParse(gramPriceController.text);
    if (gramPrice == null || gramPrice <= 0) {
      ToastService.show('silver_buy.gramPriceMustBeGreater'.tr());
      return;
    }

    final product = <String, dynamic>{
      'carat_id': selectedCarat!.id,
      'carat_label': selectedCarat!.carat,
      'box_id': selectedBox!.id,
      'box_name': selectedBox!.name,
      'grams': grams,
      'loss': loss,
      'gram_price': gramPrice,
      'buy_price': buyPrice,
    };

    Navigator.pop(context, product);
  }

  InputDecoration _inputDecoration(bool isDark, {String? labelText}) {
    return InputDecoration(
      labelText: labelText,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : AppColors.backGroundColorLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.silverColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'silver_buy.addSilverProduct'.tr(),
              style: AppFonts.heading(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.silverColor,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'common.carat'.tr(),
              style: AppFonts.heading(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.silverColor,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<SilverCaratModel>(
              value: selectedCarat,
              decoration: _inputDecoration(isDark),
              dropdownColor: isDark
                  ? AppColors.darkThemeContainerColorElevated
                  : Colors.white,
              iconEnabledColor: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.silverColor,
              items: widget.carats
                  .map(
                    (carat) => DropdownMenuItem<SilverCaratModel>(
                      value: carat,
                      child: Text(
                        '${carat.carat} - ${carat.price} ${'common.egp'.tr()}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _onCaratSelected,
            ),
            SizedBox(height: 16.h),
            Text(
              'common.box'.tr(),
              style: AppFonts.heading(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.silverColor,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<SilverBoxModel>(
              value: selectedBox,
              decoration: _inputDecoration(isDark),
              dropdownColor: isDark
                  ? AppColors.darkThemeContainerColorElevated
                  : Colors.white,
              iconEnabledColor: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.silverColor,
              items: widget.boxes
                  .map(
                    (box) => DropdownMenuItem<SilverBoxModel>(
                      value: box,
                      child: Text(box.name),
                    ),
                  )
                  .toList(),
              onChanged: (box) => setState(() => selectedBox = box),
            ),
            SizedBox(height: 16.h),
            Text(
              'silver_buy.weightDetails'.tr(),
              style: AppFonts.heading(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.silverColor,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: gramsController,
                    labelText: 'common.grams'.tr(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    height: 66.h,
                    borderRadius: BorderRadius.circular(12.r),
                    borderColor: isDark
                        ? Colors.white.withOpacity(0.08)
                        : AppColors.silverColor.withOpacity(0.14),
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.04)
                        : AppColors.backGroundColorLight,
                    onChanged: (_) => _updateBuyPrice(),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomTextFormField(
                    controller: lossController,
                    labelText: 'common.loss'.tr(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    height: 66.h,
                    borderRadius: BorderRadius.circular(12.r),
                    borderColor: isDark
                        ? Colors.white.withOpacity(0.08)
                        : AppColors.silverColor.withOpacity(0.14),
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.04)
                        : AppColors.backGroundColorLight,
                    onChanged: (_) => _updateBuyPrice(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'common.gramPrice'.tr(),
              style: AppFonts.heading(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.silverColor,
              ),
            ),
            SizedBox(height: 8.h),
            CustomTextFormField(
              controller: gramPriceController,
              labelText: 'common.gramPrice'.tr(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              height: 66.h,
              borderRadius: BorderRadius.circular(12.r),
              borderColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.silverColor.withOpacity(0.14),
              fillColor: isDark
                  ? Colors.white.withOpacity(0.04)
                  : AppColors.backGroundColorLight,
              onChanged: (_) => _updateBuyPrice(),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkThemeContainerColorElevated
                    : AppColors.backGroundColorLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.silverColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'silver_buy.buyPrice'.tr(),
                    style: AppFonts.body(
                      fontSize: 13.sp,
                      color: isDark
                          ? AppColors.textGreyColor
                          : AppColors.darkGreyTextColor,
                    ),
                  ),
                  Text(
                    '${buyPrice.toStringAsFixed(2)} ${'common.egp'.tr()}',
                    style: AppFonts.heading(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.silverColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.silverColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                icon: const Icon(Icons.add_rounded),
                label: Text('silver_buy.addProduct'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
