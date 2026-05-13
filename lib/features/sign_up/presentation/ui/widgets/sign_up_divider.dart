import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';

class SignUpDivider extends StatelessWidget {
  const SignUpDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0.sp),
                    child: Text(
                      "Or",
                      style: TextStyles.textStyle14,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            );
  }
}
