import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/settings_cubit.dart';
import 'package:shimmer/shimmer.dart';



class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: (context.read<SettingsCubit>().isDark)
          ? Colors.black12
          : Colors.grey.shade200,
      highlightColor: (context.read<SettingsCubit>().isDark)
          ? AppColors.darkThemeBackgroundColor
          : AppColors.lightThemeBackgroundColor,
      child: Column(
        children: [
          verticalSpace(40),
          ListView.builder(
              shrinkWrap: true,
              itemCount: 3,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 13.sp, vertical: 3.h),
                  child: Container(
                    width: 220.w,
                    height: 163.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11.sp),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: -1,
                          )
                        ]),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
