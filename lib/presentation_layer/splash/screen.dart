import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/measurements.dart';
import '../../core/reusables.dart';
import '../../core/string_collection.dart';
import '../../core/text_styles.dart';
import '../app/screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Move CTA handling and first-launch state into SplashProvider.
    void onStartPressed() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const AppShellScreen()),
      );
    }

    return AppScreen(
      child: Column(
        children: [
          const Spacer(),
          const AnimatedWalletHero(),
          const SizedBox(height: 56),
          Text(
            AppStrings.saveYourMoney,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppMeasurements.gap),
          Text(
            AppStrings.splashDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const Spacer(),
          SizedBox(
            width: 164,
            child: AppGradientButton(
              label: AppStrings.letsStart,
              onTap: onStartPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedWalletHero extends StatelessWidget {
  const AnimatedWalletHero({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        final scale = 0.82 + (animationValue * 0.18);
        final verticalOffset = (1 - animationValue) * 28;
        return Opacity(
          opacity: animationValue,
          child: Transform.translate(
            offset: Offset(0, verticalOffset),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: Container(
        width: 220,
        height: 220,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.softPurple,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Positioned(
              top: 42,
              child: Text(
                AppStrings.coinsEmoji,
                style: TextStyle(fontSize: 48),
              ),
            ),
            Text(AppStrings.walletEmoji, style: TextStyle(fontSize: 92)),
            Positioned(
              right: 45,
              top: 92,
              child: _FloatingBadge(
                label: AppStrings.incomeArrow,
                color: AppColors.green,
              ),
            ),
            Positioned(
              left: 43,
              bottom: 86,
              child: _FloatingBadge(
                label: AppStrings.expenseArrow,
                color: AppColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
