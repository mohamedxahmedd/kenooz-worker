import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppFonts {
  static const String fontHeading = 'Hedvig Letters Serif';
  static const String fontBody = 'Inter';

  static TextStyle heading({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.hedvigLettersSerif(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme(TextTheme base) {
    final bodyTheme = GoogleFonts.interTextTheme(base);

    return bodyTheme.copyWith(
      displayLarge: GoogleFonts.hedvigLettersSerif(
        textStyle: bodyTheme.displayLarge,
      ),
      displayMedium: GoogleFonts.hedvigLettersSerif(
        textStyle: bodyTheme.displayMedium,
      ),
      displaySmall: GoogleFonts.hedvigLettersSerif(
        textStyle: bodyTheme.displaySmall,
      ),
      headlineLarge: GoogleFonts.hedvigLettersSerif(
        textStyle: bodyTheme.headlineLarge,
      ),
      headlineMedium: GoogleFonts.hedvigLettersSerif(
        textStyle: bodyTheme.headlineMedium,
      ),
      headlineSmall: GoogleFonts.hedvigLettersSerif(
        textStyle: bodyTheme.headlineSmall,
      ),
      titleLarge: GoogleFonts.hedvigLettersSerif(
        textStyle: bodyTheme.titleLarge,
      ),
      titleMedium: GoogleFonts.hedvigLettersSerif(
        textStyle: bodyTheme.titleMedium,
      ),
      titleSmall: GoogleFonts.hedvigLettersSerif(
        textStyle: bodyTheme.titleSmall,
      ),
    );
  }
}
