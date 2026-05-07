import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../core/functions.dart';
import '../../core/measurements.dart';
import '../../core/reusables.dart';
import '../../core/string_collection.dart';
import '../../core/text_styles.dart';
import '../app/provider.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final summary = appProvider.balanceSummary;
        final chartWeeks = appProvider.chartWeeks;
        final selectedWeek = appProvider.selectedChartWeek;
        final transactions = appProvider.transactions;

        return AppScreen(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(
                title: AppStrings.overview,
                leading: CircleTextButton(label: AppStrings.menuEmoji),
              ),
              const SizedBox(height: AppMeasurements.largeGap),
              Row(
                children: [
                  Expanded(
                    child: OverviewSummaryCard(
                      title: AppStrings.totalIncome,
                      amount: AppFormatters.amount(summary.incomeTotal),
                      icon: AppStrings.incomeArrow,
                      accentColor: AppColors.primary,
                      backgroundColor: AppColors.softPurple,
                    ),
                  ),
                  const SizedBox(width: AppMeasurements.smallGap),
                  Expanded(
                    child: OverviewSummaryCard(
                      title: AppStrings.totalExpenses,
                      amount: AppFormatters.amount(summary.expenseTotal),
                      icon: AppStrings.expenseArrow,
                      accentColor: AppColors.orange,
                      backgroundColor: AppColors.softOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppMeasurements.largeGap),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.statistics,
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.aprDateRange,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppMeasurements.smallRadius,
                      ),
                    ),
                    child: Text(
                      '${AppStrings.monthly} ${AppStrings.down}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppMeasurements.gap),
              AnimatedBarChart(
                labels: chartWeeks.map((week) => week.label).toList(),
                incomeValues: chartWeeks
                    .map((week) => week.incomeRatio)
                    .toList(),
                expenseValues: chartWeeks
                    .map((week) => week.expenseRatio)
                    .toList(),
                selectedIndex: appProvider.selectedWeekIndex,
                onWeekTap: appProvider.selectChartWeek,
              ),
              const SizedBox(height: AppMeasurements.smallGap),
              SelectedWeekSummary(
                label: selectedWeek.label,
                incomeAmount: AppFormatters.currency(selectedWeek.incomeAmount),
                expenseAmount: AppFormatters.currency(
                  selectedWeek.expenseAmount,
                ),
              ),
              const SizedBox(height: AppMeasurements.gap),
              const ChartLegendToggle(),
              const SizedBox(height: AppMeasurements.smallGap),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final category = appProvider.categoryById(
                      transaction.categoryId,
                    );
                    return AppTransactionTile(
                      emoji: category.emoji,
                      title: transaction.title,
                      subtitle: AppFormatters.transactionSubtitle(
                        transaction.dateTime,
                      ),
                      amount: AppFormatters.signedAmount(
                        amount: transaction.amount,
                        tone: transaction.tone,
                      ),
                      amountColor: AppFunctions.toneColor(transaction.tone),
                      emojiBackgroundColor: AppFunctions.categorySoftColor(
                        category.colorKey,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OverviewSummaryCard extends StatelessWidget {
  const OverviewSummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    super.key,
  });

  final String title;
  final String amount;
  final String icon;
  final Color accentColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption),
          const SizedBox(height: AppMeasurements.compactGap),
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  icon,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${AppStrings.dollarSign}$amount',
                style: AppTextStyles.amountMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedBarChart extends StatelessWidget {
  const AnimatedBarChart({
    required this.labels,
    required this.incomeValues,
    required this.expenseValues,
    required this.selectedIndex,
    required this.onWeekTap,
    super.key,
  });

  final List<String> labels;
  final List<double> incomeValues;
  final List<double> expenseValues;
  final int selectedIndex;
  final ValueChanged<int> onWeekTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppMeasurements.chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: AppStrings.chartYAxis
                .map((label) => Text(label, style: AppTextStyles.caption))
                .toList(),
          ),
          const SizedBox(width: AppMeasurements.compactGap),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(incomeValues.length, (index) {
                      return ChartWeekBars(
                        incomeValue: incomeValues[index],
                        expenseValue: expenseValues[index],
                        selected: selectedIndex == index,
                        onTap: () => onWeekTap(index),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppMeasurements.compactGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: labels
                      .map((label) => Text(label, style: AppTextStyles.caption))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartWeekBars extends StatelessWidget {
  const ChartWeekBars({
    required this.incomeValue,
    required this.expenseValue,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final double incomeValue;
  final double expenseValue;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutCubic,
        builder: (context, animationValue, child) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: selected ? 1 : 0.58,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ChartBar(
                  value: incomeValue * animationValue,
                  color: AppColors.primary,
                  selected: selected,
                ),
                const SizedBox(width: 8),
                ChartBar(
                  value: expenseValue * animationValue,
                  color: AppColors.orange,
                  selected: selected,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChartBar extends StatelessWidget {
  const ChartBar({
    required this.value,
    required this.color,
    required this.selected,
    super.key,
  });

  final double value;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: value,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: AppMeasurements.chartBarWidth,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppMeasurements.chartBarWidth),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class SelectedWeekSummary extends StatelessWidget {
  const SelectedWeekSummary({
    required this.label,
    required this.incomeAmount,
    required this.expenseAmount,
    super.key,
  });

  final String label;
  final String incomeAmount;
  final String expenseAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      ),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.cardTitle),
          const Spacer(),
          Text(
            incomeAmount,
            style: AppTextStyles.caption.copyWith(color: AppColors.green),
          ),
          const SizedBox(width: AppMeasurements.smallGap),
          Text(
            expenseAmount,
            style: AppTextStyles.caption.copyWith(color: AppColors.red),
          ),
        ],
      ),
    );
  }
}

class ChartLegendToggle extends StatelessWidget {
  const ChartLegendToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      ),
      child: Row(
        children: const [
          Expanded(
            child: LegendPill(
              label: AppStrings.income,
              textColor: AppColors.textPrimary,
              backgroundColor: AppColors.surface,
            ),
          ),
          Expanded(
            child: LegendPill(
              label: AppStrings.expenses,
              textColor: Colors.white,
              backgroundColor: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class LegendPill extends StatelessWidget {
  const LegendPill({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    super.key,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
