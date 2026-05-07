import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color scaffold = Color(0xFFFDFBFF);
  static const Color surface = Colors.white;
  static const Color softPurple = Color(0xFFF5EEFF);
  static const Color softOrange = Color(0xFFFFF2EC);
  static const Color softGreen = Color(0xFFEFFFF5);
  static const Color softBlue = Color(0xFFEFF5FF);

  static const Color primary = Color(0xFF8B2CF5);
  static const Color primaryDark = Color(0xFF5B28D8);
  static const Color violet = Color(0xFFB045F8);
  static const Color lavender = Color(0xFFCDAFFF);
  static const Color orange = Color(0xFFFF6247);
  static const Color green = Color(0xFF36C777);
  static const Color red = Color(0xFFE64B5E);

  static const Color textPrimary = Color(0xFF242434);
  static const Color textSecondary = Color(0xFF737184);
  static const Color textMuted = Color(0xFFB6B2C5);
  static const Color border = Color(0xFFE6E1EC);
  static const Color divider = Color(0xFFF1EEF6);
  static const Color navInactive = Color(0xFFC8C3D3);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8D2DF5), Color(0xFFB133F3)],
  );

  static const LinearGradient balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF537AEF), Color(0xFF8D2DF5), Color(0xFFFF7354)],
  );
}
