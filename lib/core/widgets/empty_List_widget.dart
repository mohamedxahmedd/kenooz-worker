import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';


import '../theming/settings_cubit.dart';


// ignore: must_be_immutable
class EmptyListWidget extends StatelessWidget {
  EmptyListWidget({super.key, this.spacing});
  double? spacing;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          verticalSpace(spacing ?? 170),
          SvgPicture.asset(
            Assets.assetsImagesEmptyRescheduleReqs,
            height: 200,
            width: 200,
            colorFilter: ColorFilter.mode(
                (SettingsCubit.get(context).isDark)
                    ? Colors.grey.shade800
                    : Colors.grey.shade400,
                BlendMode.srcIn),
          ),
          verticalSpace(20),
          Text("emptyList.noData".tr(),
              style:
                  TextStyles.textStyle14.copyWith(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
