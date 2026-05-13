import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_client_search_state.dart';

class SilverDoubleSellClientSection extends StatelessWidget {
  final TextEditingController searchController;
  final SilverClientSearchState state;
  final ClientModel? selectedClient;
  final VoidCallback onSearch;
  final VoidCallback onOpenCreateClientSheet;
  final VoidCallback onClear;

  const SilverDoubleSellClientSection({
    super.key,
    required this.searchController,
    required this.state,
    required this.selectedClient,
    required this.onSearch,
    required this.onOpenCreateClientSheet,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stateClient = state.whenOrNull(
      found: (client) => client,
      created: (client) => client,
    );
    final effectiveClient = selectedClient ?? stateClient;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.primaryColor.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'common.client'.tr(),
                style: AppFonts.heading(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lightTextColorForDarkMood : AppColors.darkBrown,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onOpenCreateClientSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.darkBrown.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.darkBrown.withOpacity(0.20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 15.sp,
                        color: isDark ? AppColors.lightTextColorForDarkMood : AppColors.darkBrown,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'common.addClient'.tr(),
                        style: AppFonts.body(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.lightTextColorForDarkMood : AppColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: searchController,
                  hintText: 'common.searchByPhoneOrEmail'.tr(),
                  height: 66.h,
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
              SizedBox(
                height: 46.h,
                child: ElevatedButton(
                  onPressed: onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
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
          state.maybeWhen(
            loading: () => Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: const LinearProgressIndicator(minHeight: 2),
            ),
            notFound: () => Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14.sp, color: AppColors.errorColor),
                  SizedBox(width: 4.w),
                  Text(
                    'common.clientNotFound'.tr(),
                    style: AppFonts.body(fontSize: 12.sp, color: AppColors.errorColor),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: onOpenCreateClientSheet,
                    child: Text(
                      'common.createOne'.tr(),
                      style: AppFonts.body(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            error: (messages) => Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                messages.join('\n'),
                style: AppFonts.body(fontSize: 12.sp, color: AppColors.errorColor),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          if (effectiveClient != null) ...[
            SizedBox(height: 8.h),
            _ClientCard(client: effectiveClient, onClear: onClear),
          ],
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onClear;

  const _ClientCard({required this.client, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
              : AppColors.successColor.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, size: 18.sp, color: AppColors.successColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: AppFonts.body(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.lightTextColorForDarkMood : AppColors.darkBrown,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${client.phone} • ${client.email}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    color: isDark ? AppColors.textGreyColor : AppColors.darkGreyTextColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: Icon(Icons.close_rounded, color: AppColors.errorColor, size: 18.sp),
          ),
        ],
      ),
    );
  }
}
