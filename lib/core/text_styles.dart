import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

abstract final class AppTextStyles {
  static TextStyle get titleLarge => GoogleFonts.poppins(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get screenTitle => GoogleFonts.poppins(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get sectionTitle => GoogleFonts.poppins(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get cardTitle => GoogleFonts.poppins(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get body => GoogleFonts.poppins(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get caption => GoogleFonts.poppins(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get button => GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get amountLarge => GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get amountMedium => GoogleFonts.poppins(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get fieldLabel => GoogleFonts.poppins(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get input => GoogleFonts.poppins(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}
