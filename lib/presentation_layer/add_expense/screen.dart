import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums.dart';
import '../../core/string_collection.dart';
import '../app/provider.dart';
import '../add/widgets/transaction_form_widgets.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        void onSubmitTap() {
          appProvider.addExpenseTransaction();
          Navigator.of(context).pop();
        }

        return TransactionFormScaffold(
          title: AppStrings.addExpense,
          itemTitleLabel: AppStrings.expenseTitle,
          itemTitleHint: AppStrings.groceries,
          amountHint: AppStrings.amount850,
          submitLabel: AppStrings.addExpense,
          titleController: appProvider.expenseTitleController,
          amountController: appProvider.expenseAmountController,
          categories: appProvider.categoriesByTone(TransactionTone.expense),
          selectedCategoryId: appProvider.selectedExpenseCategoryId,
          selectedDate: appProvider.selectedExpenseDate,
          tone: TransactionTone.expense,
          onCategorySelected: appProvider.selectExpenseCategory,
          onDateSelected: appProvider.selectExpenseDate,
          onSubmitTap: onSubmitTap,
          filteredTransactions: appProvider.expenseTransactionsForSelectedDate,
        );
      },
    );
  }
}
