import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar(
      {super.key,
      required this.title,
      required this.isBackButtonVisible,
      this.actions,
      this.onPressed});
  dynamic actions;
  final dynamic title;
  final bool isBackButtonVisible;
  VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: isBackButtonVisible,
      toolbarHeight: 60.h,
      leading: (isBackButtonVisible)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: (onPressed != null)
                  ? onPressed
                  : () {
                      Navigator.pop(context);
                    },
            )
          : null,
      title: title,
      actions: [
        (actions != null) ? actions : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);
}
