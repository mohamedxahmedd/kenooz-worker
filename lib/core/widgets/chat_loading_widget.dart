import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/settings_cubit.dart';
import 'package:shimmer/shimmer.dart';


class ChatLoadingWidget extends StatelessWidget {
  const ChatLoadingWidget({super.key});

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
          ListView.builder(
              shrinkWrap: true,
              itemCount: 4,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(10.h),
                  height: 60.h,
                  width: 170.w,
                  decoration: BoxDecoration(
                    color: (context.read<SettingsCubit>().isDark)
                        ? AppColors.darkThemeContainerColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
