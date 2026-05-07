import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/measurements.dart';
import '../../core/string_collection.dart';
import '../../core/text_styles.dart';
import '../add/screen.dart';
import '../home/screen.dart';
import '../overview/screen.dart';
import 'provider.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.scaffold,
          body: IndexedStack(
            index: appProvider.selectedTabIndex,
            children: const [HomeScreen(), OverviewScreen(), AddScreen()],
          ),
          bottomNavigationBar: AppBottomNavigationBar(
            selectedIndex: appProvider.selectedTabIndex,
            onItemSelected: appProvider.selectTab,
          ),
        );
      },
    );
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppMeasurements.screenPadding,
          0,
          AppMeasurements.screenPadding,
          AppMeasurements.smallGap,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppMeasurements.smallGap,
          vertical: AppMeasurements.compactGap,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppMeasurements.cardRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: BottomNavItem(
                emoji: AppStrings.houseEmoji,
                label: AppStrings.home,
                selected: selectedIndex == 0,
                onTap: () => onItemSelected(0),
              ),
            ),
            Expanded(
              child: BottomNavItem(
                emoji: AppStrings.chartEmoji,
                label: AppStrings.overview,
                selected: selectedIndex == 1,
                onTap: () => onItemSelected(1),
              ),
            ),
            Expanded(
              child: BottomNavItem(
                emoji: AppStrings.plus,
                label: AppStrings.add,
                selected: selectedIndex == 2,
                onTap: () => onItemSelected(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 54,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.navInactive,
                fontSize: selected ? 18 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? Colors.white : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
