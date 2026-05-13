import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';

abstract class TextStyles {
  static final textStyle10 = AppFonts.body(fontSize: 10.sp);
  static final textStyle13 = AppFonts.body(fontSize: 13.sp);
  static final textStyle15 = AppFonts.body(fontSize: 15.sp);
  static final textStyle18 = AppFonts.body(fontSize: 18.sp);
  static final appBarTextStyle = AppFonts.heading(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );
  static final bookingSessionNowFont = AppFonts.body(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
  );
  static final textStyle20 = AppFonts.body(fontSize: 20.sp);
  static final textStyle24 = AppFonts.body(fontSize: 24.sp);
  static final textStyle26 = AppFonts.body(fontSize: 26.sp);
  static final textStyle30 = AppFonts.body(fontSize: 30.sp);
  static final textStyle14 = AppFonts.body(fontSize: 14.sp);

  static final heading20 = AppFonts.heading(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );
  static final heading24 = AppFonts.heading(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
  );

  static final textStyle155 = GoogleFonts.dancingScript(fontSize: 15.sp);

  static final textStyle16 = AppFonts.body(fontSize: 16.sp);

  static final font15BMeduim = AppFonts.body(
    fontSize: 15.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle font15Bold = AppFonts.body(
    fontSize: 15.sp,
    fontWeight: FontWeight.bold,
  );
  static final textStyle11 = AppFonts.body(fontSize: 11.sp);
  static final textStyle12 = AppFonts.body(fontSize: 12.sp);
  static final font12BlackMedium = AppFonts.body(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );
}
