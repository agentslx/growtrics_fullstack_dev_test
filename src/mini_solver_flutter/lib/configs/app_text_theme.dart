import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../generated/colors.gen.dart';

class AppTextTheme {
  // static TextTheme defaultTextTheme = GoogleFonts.kanitTextTheme();

  static TextTheme defaultTextTheme = TextTheme(
    /// Equivalent to `Display-01'
    displayLarge: GoogleFonts.kanit().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 78,
      height: 104 / 78,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Display-02'
    displayMedium: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 60,
      color: ColorName.gray900,
      height: 80 / 60,
    ),

    /// Equivalent to `Display-03'
    displaySmall: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 64,
      height: 64 / 48,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Heading-01'
    titleLarge: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 40,
      height: 52 / 40,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Heading-02'
    titleMedium: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 32,
      height: 40 / 32,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Heading-03'
    titleSmall: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 24,
      height: 32 / 24,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Heading-04'
    headlineLarge: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 20,
      height: 28 / 20,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Heading-05'
    headlineMedium: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 16,
      height: 24 / 16,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Heading-06'
    headlineSmall: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 14,
      height: 20 / 14,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Label-01'
    labelLarge: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: 32,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Label-02'
    labelMedium: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      height: 28 / 20,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Label-04'
    labelSmall: GoogleFonts.exo2().copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      height: 20 / 14,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Body-01'
    bodyLarge: GoogleFonts.openSans().copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 24,
      height: 32 / 24,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Body-02'
    bodyMedium: GoogleFonts.openSans().copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 20,
      height: 28 / 20,
      color: ColorName.gray900,
    ),

    /// Equivalent to `Body-04'
    bodySmall: GoogleFonts.openSans().copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 20 / 14,
      color: ColorName.gray900,
    ),
  );
}