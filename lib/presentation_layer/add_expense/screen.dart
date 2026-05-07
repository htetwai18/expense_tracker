import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums.dart';
import '../../core/string_collection.dart';
import '../add/widgets/transaction_form_widgets.dart';
import 'provider.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddExpenseProvider(),
      child: Consumer<AddExpenseProvider>(
        builder: (context, provider, child) {
          Future<void> onSubmitTap() async {
            final isSaved = await provider.saveExpenseTransaction();
            if (isSaved && context.mounted) {
              Navigator.of(context).pop();
            }
          }

          return TransactionFormScaffold(
            title: AppStrings.addExpense,
            itemTitleLabel: AppStrings.expenseTitle,
            itemTitleHint: AppStrings.groceries,
            amountHint: AppStrings.amount850,
            submitLabel: AppStrings.addExpense,
            titleController: provider.titleController,
            amountController: provider.amountController,
            categories: provider.categories,
            selectedCategoryId: provider.selectedCategoryId,
            selectedDate: provider.selectedDate,
            tone: TransactionTone.expense,
            onCategorySelected: provider.selectCategory,
            onDateSelected: provider.selectDate,
            onSubmitTap: onSubmitTap,
            filteredTransactions: provider.filteredTransactions,
            categoryEmojiController: provider.categoryEmojiController,
            categoryNameController: provider.categoryNameController,
            onAddCategory: provider.addCategory,
          );
        },
      ),
    );
  }
}
