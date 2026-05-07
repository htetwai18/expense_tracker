import 'package:flutter/material.dart';

import 'colors.dart';
import 'measurements.dart';
import 'text_styles.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppMeasurements.screenPadding,
      AppMeasurements.screenTopPadding,
      AppMeasurements.screenPadding,
      AppMeasurements.screenPadding,
    ),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading ?? const SizedBox(width: AppMeasurements.menuButtonSize),
        Expanded(
          child: Center(child: Text(title, style: AppTextStyles.screenTitle)),
        ),
        trailing ?? const SizedBox(width: AppMeasurements.menuButtonSize),
      ],
    );
  }
}

class CircleTextButton extends StatelessWidget {
  const CircleTextButton({
    required this.label,
    this.onTap,
    this.backgroundColor = AppColors.surface,
    this.labelColor = AppColors.textPrimary,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      onTap: onTap,
      child: Container(
        width: AppMeasurements.menuButtonSize,
        height: AppMeasurements.menuButtonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.cardTitle.copyWith(color: labelColor),
        ),
      ),
    );
  }
}

class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppMeasurements.buttonRadius),
      onTap: onTap,
      child: Container(
        height: AppMeasurements.buttonHeight,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppMeasurements.buttonRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x338B2CF5),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    this.actionLabel,
    this.onActionTap,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }
}

class EmojiTile extends StatelessWidget {
  const EmojiTile({
    required this.emoji,
    this.backgroundColor = AppColors.softPurple,
    this.size = AppMeasurements.transactionIconSize,
    super.key,
  });

  final String emoji;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * 0.48)),
    );
  }
}

class AmountText extends StatelessWidget {
  const AmountText({required this.amount, required this.color, super.key});

  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      amount,
      style: AppTextStyles.amountMedium.copyWith(color: color),
    );
  }
}

class AppTransactionTile extends StatelessWidget {
  const AppTransactionTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    this.emojiBackgroundColor = AppColors.softPurple,
    super.key,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final Color emojiBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          EmojiTile(emoji: emoji, backgroundColor: emojiBackgroundColor),
          const SizedBox(width: AppMeasurements.smallGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          AmountText(amount: amount, color: amountColor),
        ],
      ),
    );
  }
}
