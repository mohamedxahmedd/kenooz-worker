import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/functions/date_format.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/settings_cubit.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/cubit/signup_cubit.dart';



class GenderAndBirthdateForm extends StatefulWidget {
  const GenderAndBirthdateForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GenderAndBirthdateFormState createState() => _GenderAndBirthdateFormState();
}

class _GenderAndBirthdateFormState extends State<GenderAndBirthdateForm> {
  String? _selectedGender;
  DateTime? _selectedDate;

  final List<String> _genders = ['signup.male'.tr(), 'signup.female'.tr()];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Gender Dropdown
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            dropdownColor: (context.read<SettingsCubit>().isDark)
                ? AppColors.bottomNavDarkThemeBackground
                : Colors.white,
            value: _selectedGender,
            items: _genders.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(
                  gender,
                  style: TextStyles.textStyle14.copyWith(),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(
                  color: AppColors.errorColor, // ← same or another error color
                  width: 1.5,
                ),
              ),

              // 3) border when the field has an error and is focused:
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(
                  color: AppColors.errorColor, // ← same or another error color
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent, // Background color of the dropdown
              labelText: 'signup.gender'.tr(),
              labelStyle: TextStyles.textStyle14.copyWith(
                  color: (_selectedGender != null)
                      ? AppColors.primaryColor
                      : Colors.grey.shade700,
                  fontWeight:
                      (_selectedGender != null) ? FontWeight.bold : null,
                  fontSize: (_selectedGender != null) ? 13.sp : 13.sp),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r), // Add border radius
                borderSide: BorderSide(
                  color: Colors.white, // Optional: Add a focus border color
                  width: 0.5,
                ), // Remove the border line
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r), // Add border radius
                borderSide: BorderSide(
                  color: Colors.white, // Optional: Add a focus border color
                  width: 0.5,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r), // Add border radius
                borderSide: BorderSide(
                  color: Colors.white, // Optional: Add a focus border color
                  width: 0.5,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 15.h,
                horizontal: 10.w,
              ),
            ),
            onChanged: (value) {
              setState(() {
                if (value == null) {
                  _selectedGender = "signup.gender".tr();
                }
                _selectedGender = value;
                if (value == "signup.male".tr()) {
                  context.read<SignupCubit>().gender = "Male";
                } else {
                  context.read<SignupCubit>().gender = "Female";
                }
              });
            },
          ),
        ),
        horizontalSpace(10.w),
        // Birthdate Picker
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  formatDate(pickedDate.toString());
                  _selectedDate = pickedDate;
                  context.read<SignupCubit>().birthdateController.text =
                      '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
                });
              }
            },
            child: AbsorbPointer(
              child: CustomTextFormField(
                controller: context.read<SignupCubit>().birthdateController,
                borderColor: Colors.white,
                borderWidth: 0.5,
                hintStyle: TextStyles.textStyle14.copyWith(
                  color: Colors.grey.shade700,
                ),
                hintText: _selectedDate == null
                    ? 'signup.selectYourBirthDate'.tr()
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
