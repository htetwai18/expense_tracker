import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../core/functions.dart';
import '../../core/measurements.dart';
import '../../core/reusables.dart';
import '../../core/string_collection.dart';
import '../../core/text_styles.dart';
import '../add_expense/screen.dart';
import '../add_income/screen.dart';
import 'provider.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddProvider(),
      child: Consumer<AddProvider>(
        builder: (context, addProvider, child) {
          void onIncomeTap() {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const AddIncomeScreen(),
              ),
            );
          }

          void onExpenseTap() {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const AddExpenseScreen(),
              ),
            );
          }

          final recentEntries = addProvider.recentTransactions;

          return AppScreen(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(
                  title: AppStrings.add,
                  leading: null
                ),
                const SizedBox(height: AppMeasurements.sectionGap),
                Row(
                  children: [
                    Expanded(
                      child: AddOptionCard(
                        emoji: AppStrings.cardEmoji,
                        title: AppStrings.addIncome,
                        backgroundColor: AppColors.softPurple,
                        accentColor: AppColors.primary,
                        onTap: onIncomeTap,
                      ),
                    ),
                    const SizedBox(width: AppMeasurements.gap),
                    Expanded(
                      child: AddOptionCard(
                        emoji: AppStrings.cardEmoji,
                        title: AppStrings.addExpense,
                        backgroundColor: AppColors.softOrange,
                        accentColor: AppColors.orange,
                        onTap: onExpenseTap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppMeasurements.sectionGap),
                Text(AppStrings.lastAdded, style: AppTextStyles.sectionTitle),
                const SizedBox(height: AppMeasurements.smallGap),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: recentEntries.length,
                    itemBuilder: (context, index) {
                      final entry = recentEntries[index];
                      final category = addProvider.categoryById(
                        entry.categoryId,
                      );
                      return AppTransactionTile(
                        emoji: category.emoji,
                        title: entry.title,
                        subtitle: AppFormatters.transactionSubtitle(
                          entry.dateTime,
                        ),
                        amount: AppFormatters.signedAmount(
                          amount: entry.amount,
                          tone: entry.tone,
                        ),
                        amountColor: AppFunctions.toneColor(entry.tone),
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
      ),
    );
  }
}

class AddOptionCard extends StatelessWidget {
  const AddOptionCard({
    required this.emoji,
    required this.title,
    required this.backgroundColor,
    required this.accentColor,
    required this.onTap,
    super.key,
  });

  final String emoji;
  final String title;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppMeasurements.cardRadius),
      onTap: onTap,
      child: Container(
        height: 104,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppMeasurements.cardRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 34, color: accentColor)),
            const SizedBox(height: AppMeasurements.smallGap),
            Text(title, style: AppTextStyles.cardTitle),
          ],
        ),
      ),
    );
  }
}
