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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final summary = appProvider.balanceSummary;
        final transactions = appProvider.recentTransactions;

        return AppScreen(
          child: Column(
            children: [
              const AppHeader(
                title: AppStrings.home,
                leading: CircleTextButton(label: AppStrings.menuEmoji),
                trailing: CircleTextButton(label: AppStrings.bellEmoji),
              ),
              const SizedBox(height: AppMeasurements.largeGap),
              BalanceCard(
                totalBalance: AppFormatters.amount(summary.totalBalance),
                incomeAmount: AppFormatters.amount(summary.incomeTotal),
                expenseAmount: AppFormatters.amount(summary.expenseTotal),
              ),
              const SizedBox(height: AppMeasurements.largeGap),
              const SectionTitle(
                title: AppStrings.transactions,
                actionLabel: AppStrings.seeAll,
              ),
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

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.totalBalance,
    required this.incomeAmount,
    required this.expenseAmount,
    super.key,
  });

  final String totalBalance;
  final String incomeAmount;
  final String expenseAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.balanceGradient,
        borderRadius: BorderRadius.circular(AppMeasurements.cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x338B2CF5),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${AppStrings.totalBalance} ${AppStrings.down}',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
              const Spacer(),
              Text(
                AppStrings.more,
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppMeasurements.compactGap),
          Text(
            '${AppStrings.dollarSign}$totalBalance',
            style: AppTextStyles.amountLarge,
          ),
          const SizedBox(height: AppMeasurements.largeGap),
          Row(
            children: [
              Expanded(
                child: BalanceStat(
                  icon: AppStrings.incomeArrow,
                  title: AppStrings.income,
                  amount: incomeAmount,
                ),
              ),
              Expanded(
                child: BalanceStat(
                  icon: AppStrings.expenseArrow,
                  title: AppStrings.expenses,
                  amount: expenseAmount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BalanceStat extends StatelessWidget {
  const BalanceStat({
    required this.icon,
    required this.title,
    required this.amount,
    super.key,
  });

  final String icon;
  final String title;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0x22FFFFFF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            icon,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppMeasurements.compactGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 2),
            Text(
              '${AppStrings.dollarSign}$amount',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
