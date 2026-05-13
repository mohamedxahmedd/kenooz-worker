import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_button.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';

class DoubleSellCreateClientSheet extends StatefulWidget {
  const DoubleSellCreateClientSheet({super.key});

  @override
  State<DoubleSellCreateClientSheet> createState() =>
      _DoubleSellCreateClientSheetState();
}

class _DoubleSellCreateClientSheetState extends State<DoubleSellCreateClientSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _gender = 'male';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h + keyboardInset),
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
              'common.createClient'.tr(),
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
            SizedBox(height: 8.h),
            CustomTextFormField(
              controller: _phoneController,
              labelText: 'common.phone'.tr(),
              keyboardType: TextInputType.phone,
              height: 68.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
            SizedBox(height: 8.h),
            CustomTextFormField(
              controller: _emailController,
              labelText: 'common.email'.tr(),
              keyboardType: TextInputType.emailAddress,
              height: 68.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
            SizedBox(height: 10.h),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(
                labelText: 'common.gender'.tr(),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.04)
                    : AppColors.backGroundColorLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              items: [
                DropdownMenuItem(value: 'male', child: Text('common.male'.tr())),
                DropdownMenuItem(value: 'female', child: Text('common.female'.tr())),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _gender = value);
              },
            ),
            SizedBox(height: 14.h),
            CustomButton(
              text: 'common.createClient'.tr(),
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
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      CreateClientRequestModel(
        clientName: name,
        clientPhone: phone,
        clientEmail: email,
        clientGender: _gender,
      ),
    );
  }
}
