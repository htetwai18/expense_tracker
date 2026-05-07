import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../core/measurements.dart';
import '../../../core/reusables.dart';
import '../../../core/string_collection.dart';
import '../../../core/text_styles.dart';

class CategoryDialog extends StatelessWidget {
  const CategoryDialog({
    required this.emojiController,
    required this.nameController,
    required this.onSave,
    this.emojiErrorText,
    this.nameErrorText,
    super.key,
  });

  final TextEditingController emojiController;
  final TextEditingController nameController;
  final Future<void> Function() onSave;
  final String? emojiErrorText;
  final String? nameErrorText;

  @override
  Widget build(BuildContext context) {
    void onCancelPressed() => Navigator.of(context).pop();
    Future<void> onSavePressed() async {
      final navigator = Navigator.of(context);
      await onSave();
      navigator.pop();
    }

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppMeasurements.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppMeasurements.largeGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.addCategory, style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppMeasurements.largeGap),
            DialogTextField(
              label: AppStrings.categoryEmoji,
              hint: AppStrings.emojiHint,
              controller: emojiController,
              errorText: emojiErrorText,
            ),
            const SizedBox(height: AppMeasurements.gap),
            DialogTextField(
              label: AppStrings.categoryName,
              hint: AppStrings.categoryNameHint,
              controller: nameController,
              errorText: nameErrorText,
            ),
            const SizedBox(height: AppMeasurements.largeGap),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancelPressed,
                    child: Text(
                      AppStrings.cancel,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppMeasurements.smallGap),
                Expanded(
                  child: AppGradientButton(
                    label: AppStrings.save,
                    onTap: onSavePressed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DialogTextField extends StatelessWidget {
  const DialogTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.errorText,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.cardTitle),
        const SizedBox(height: AppMeasurements.compactGap),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.input.copyWith(color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppMeasurements.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppMeasurements.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppMeasurements.inputRadius),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.red),
          ),
        ),
      ],
    );
  }
}
