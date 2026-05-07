import 'package:flutter/material.dart';

import 'colors.dart';
import 'enums.dart';

abstract final class AppFunctions {
  static Color toneColor(TransactionTone tone) {
    return tone == TransactionTone.income ? AppColors.green : AppColors.red;
  }

  static Color toneSoftColor(TransactionTone tone) {
    return tone == TransactionTone.income
        ? AppColors.softGreen
        : AppColors.softOrange;
  }

  static Color categorySoftColor(String colorKey) {
    return switch (colorKey) {
      'green' => AppColors.softGreen,
      'blue' => AppColors.softBlue,
      'orange' => AppColors.softOrange,
      'purple' => AppColors.softPurple,
      _ => AppColors.softPurple,
    };
  }
}
