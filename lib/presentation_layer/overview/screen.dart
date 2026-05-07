import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/enums.dart';
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
        final transactions = appProvider.filteredOverviewTransactions;

        return AppScreen(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(
                title: AppStrings.overview,
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
                        appProvider.selectedChartDateRangeLabel,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const Spacer(),
                  ChartPeriodDropdown(
                    selectedLabel: appProvider.selectedChartPeriodLabel,
                    selectedPeriod: appProvider.selectedChartPeriod,
                    onChanged: appProvider.selectChartPeriod,
                    labelForPeriod: appProvider.chartPeriodLabel,
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
              const SizedBox(height: AppMeasurements.gap),
              ChartLegendToggle(
                selectedTone: appProvider.selectedOverviewTone,
                onIncomeTap: () {
                  appProvider.selectOverviewTone(TransactionTone.income);
                },
                onExpenseTap: () {
                  appProvider.selectOverviewTone(TransactionTone.expense);
                },
              ),
              const SizedBox(height: AppMeasurements.smallGap),
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noRecentTransactions,
                          style: AppTextStyles.body,
                        ),
                      )
                    : ListView.builder(
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
                            amountColor: AppFunctions.toneColor(
                              transaction.tone,
                            ),
                            emojiBackgroundColor:
                                AppFunctions.categorySoftColor(
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

class ChartPeriodDropdown extends StatelessWidget {
  const ChartPeriodDropdown({
    required this.selectedLabel,
    required this.selectedPeriod,
    required this.onChanged,
    required this.labelForPeriod,
    super.key,
  });

  final String selectedLabel;
  final OverviewChartPeriod selectedPeriod;
  final ValueChanged<OverviewChartPeriod> onChanged;
  final String Function(OverviewChartPeriod period) labelForPeriod;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OverviewChartPeriod>(
      initialValue: selectedPeriod,
      onSelected: onChanged,
      itemBuilder: (context) {
        return OverviewChartPeriod.values.map((period) {
          return PopupMenuItem(
            value: period,
            child: Text(labelForPeriod(period)),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
        ),
        child: Text(
          '$selectedLabel ${AppStrings.down}',
          style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
        ),
      ),
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
    final isCompact = incomeValues.length > 7;
    final barWidth = isCompact ? 6.0 : AppMeasurements.chartBarWidth;
    final barGap = isCompact ? 3.0 : 8.0;

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
                        barWidth: barWidth,
                        barGap: barGap,
                        selected: selectedIndex == index,
                        onTap: () => onWeekTap(index),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppMeasurements.compactGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: labels.map((label) {
                    return Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(label, style: AppTextStyles.caption),
                      ),
                    );
                  }).toList(),
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
    required this.barWidth,
    required this.barGap,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final double incomeValue;
  final double expenseValue;
  final double barWidth;
  final double barGap;
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
                  width: barWidth,
                  selected: selected,
                ),
                SizedBox(width: barGap),
                ChartBar(
                  value: expenseValue * animationValue,
                  color: AppColors.orange,
                  width: barWidth,
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
    required this.width,
    required this.selected,
    super.key,
  });

  final double value;
  final Color color;
  final double width;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: value,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width,
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
  const ChartLegendToggle({
    required this.selectedTone,
    required this.onIncomeTap,
    required this.onExpenseTap,
    super.key,
  });

  final TransactionTone selectedTone;
  final VoidCallback onIncomeTap;
  final VoidCallback onExpenseTap;

  @override
  Widget build(BuildContext context) {
    final isIncomeSelected = selectedTone == TransactionTone.income;
    final isExpenseSelected = selectedTone == TransactionTone.expense;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: LegendPill(
              label: AppStrings.income,
              textColor: isIncomeSelected
                  ? Colors.white
                  : AppColors.textPrimary,
              backgroundColor: isIncomeSelected
                  ? AppColors.primary
                  : AppColors.surface,
              onTap: onIncomeTap,
            ),
          ),
          Expanded(
            child: LegendPill(
              label: AppStrings.expenses,
              textColor: isExpenseSelected
                  ? Colors.white
                  : AppColors.textPrimary,
              backgroundColor: isExpenseSelected
                  ? AppColors.orange
                  : AppColors.surface,
              onTap: onExpenseTap,
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
    required this.onTap,
    super.key,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
