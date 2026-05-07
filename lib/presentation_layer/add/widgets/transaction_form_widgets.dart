import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../core/enums.dart';
import '../../../core/formatters.dart';
import '../../../core/functions.dart';
import '../../../core/measurements.dart';
import '../../../core/reusables.dart';
import '../../../core/string_collection.dart';
import '../../../core/text_styles.dart';
import '../../../data_layer/models/expense_category.dart';
import '../../../data_layer/models/expense_transaction.dart';
import 'category_dialog.dart';

class TransactionFormScaffold extends StatelessWidget {
  const TransactionFormScaffold({
    required this.title,
    required this.itemTitleLabel,
    required this.itemTitleHint,
    required this.amountHint,
    required this.submitLabel,
    required this.titleController,
    required this.amountController,
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedDate,
    required this.tone,
    required this.onCategorySelected,
    required this.onDateSelected,
    required this.onSubmitTap,
    required this.filteredTransactions,
    super.key,
  });

  final String title;
  final String itemTitleLabel;
  final String itemTitleHint;
  final String amountHint;
  final String submitLabel;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final List<ExpenseCategory> categories;
  final String selectedCategoryId;
  final DateTime selectedDate;
  final TransactionTone tone;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onSubmitTap;
  final List<ExpenseTransaction> filteredTransactions;

  @override
  Widget build(BuildContext context) {
    Future<void> onOpenDatePicker() async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (pickedDate != null) {
        onDateSelected(pickedDate);
      }
    }

    void onAddCategoryTap() {
      showDialog<void>(
        context: context,
        builder: (context) => CategoryDialog(tone: tone),
      );
    }

    return AppScreen(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.viewInsetsOf(context).bottom +
              AppMeasurements.largeGap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: title,
              leading: CircleTextButton(
                label: AppStrings.back,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: AppMeasurements.sectionGap),
            CalendarCard(selectedDate: selectedDate, onTap: onOpenDatePicker),
            const SizedBox(height: AppMeasurements.gap),
            FilteredTransactionsPreview(
              transactions: filteredTransactions,
              categories: categories,
            ),
            const SizedBox(height: AppMeasurements.sectionGap),
            LabeledInputBox(
              label: itemTitleLabel,
              hint: itemTitleHint,
              controller: titleController,
            ),
            const SizedBox(height: AppMeasurements.largeGap),
            LabeledInputBox(
              label: AppStrings.amount,
              hint: amountHint,
              controller: amountController,
              leadingText: AppStrings.dollarSign,
              trailingText: AppStrings.amountStepper,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppMeasurements.largeGap),
            Text(AppStrings.category, style: AppTextStyles.fieldLabel),
            const SizedBox(height: AppMeasurements.smallGap),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        right: AppMeasurements.smallGap,
                      ),
                      child: CategoryChip(
                        label: category.name,
                        selected: category.id == selectedCategoryId,
                        onTap: () => onCategorySelected(category.id),
                      ),
                    );
                  }),
                  AddCategoryChip(onTap: onAddCategoryTap),
                ],
              ),
            ),
            const SizedBox(height: AppMeasurements.sectionGap),
            AppGradientButton(label: submitLabel, onTap: onSubmitTap),
          ],
        ),
      ),
    );
  }
}

class CalendarCard extends StatelessWidget {
  const CalendarCard({
    required this.selectedDate,
    required this.onTap,
    super.key,
  });

  final DateTime selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppMeasurements.cardRadius),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.softPurple,
          borderRadius: BorderRadius.circular(AppMeasurements.cardRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.selectDate, style: AppTextStyles.caption),
                  const SizedBox(height: AppMeasurements.compactGap),
                  Text(
                    AppFormatters.monthYear(selectedDate),
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.dateLabel(selectedDate),
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              alignment: Alignment.center,
              child: Text(
                selectedDate.day.toString(),
                style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilteredTransactionsPreview extends StatelessWidget {
  const FilteredTransactionsPreview({
    required this.transactions,
    required this.categories,
    super.key,
  });

  final List<ExpenseTransaction> transactions;
  final List<ExpenseCategory> categories;

  @override
  Widget build(BuildContext context) {
    final visibleTransactions = transactions.take(2).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMeasurements.gap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.filteredTransactions, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppMeasurements.compactGap),
          if (visibleTransactions.isEmpty)
            Text(AppStrings.noTransactionsForDate, style: AppTextStyles.caption)
          else
            ...visibleTransactions.map((transaction) {
              final category = categories.firstWhere(
                (category) => category.id == transaction.categoryId,
                orElse: () => categories.first,
              );
              return AppTransactionTile(
                emoji: category.emoji,
                title: transaction.title,
                subtitle: AppFormatters.timeLabel(transaction.dateTime),
                amount: AppFormatters.signedAmount(
                  amount: transaction.amount,
                  tone: transaction.tone,
                ),
                amountColor: AppFunctions.toneColor(transaction.tone),
                emojiBackgroundColor: AppFunctions.categorySoftColor(
                  category.colorKey,
                ),
              );
            }),
        ],
      ),
    );
  }
}

class LabeledInputBox extends StatelessWidget {
  const LabeledInputBox({
    required this.label,
    required this.hint,
    required this.controller,
    this.leadingText,
    this.trailingText,
    this.keyboardType,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? leadingText;
  final String? trailingText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: AppMeasurements.smallGap),
        Container(
          height: AppMeasurements.formFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppMeasurements.inputRadius),
          ),
          child: Row(
            children: [
              if (leadingText != null) ...[
                Text(
                  leadingText!,
                  style: AppTextStyles.input.copyWith(color: AppColors.primary),
                ),
                const SizedBox(width: AppMeasurements.smallGap),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTextStyles.input,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.input.copyWith(
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 0.9,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      onTap: onTap,
      child: Container(
        height: AppMeasurements.categoryChipHeight,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.softPurple,
          borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class AddCategoryChip extends StatelessWidget {
  const AddCategoryChip({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
      onTap: onTap,
      child: Container(
        width: AppMeasurements.categoryChipHeight,
        height: AppMeasurements.categoryChipHeight,
        decoration: BoxDecoration(
          color: AppColors.softPurple,
          borderRadius: BorderRadius.circular(AppMeasurements.smallRadius),
        ),
        alignment: Alignment.center,
        child: Text(AppStrings.plus, style: AppTextStyles.sectionTitle),
      ),
    );
  }
}
