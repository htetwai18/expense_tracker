import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums.dart';
import '../../core/string_collection.dart';
import '../app/provider.dart';
import '../add/widgets/transaction_form_widgets.dart';

class AddIncomeScreen extends StatelessWidget {
  const AddIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        void onSubmitTap() {
          appProvider.addIncomeTransaction();
          Navigator.of(context).pop();
        }

        return TransactionFormScaffold(
          title: AppStrings.addIncome,
          itemTitleLabel: AppStrings.incomeTitle,
          itemTitleHint: AppStrings.remoteJob,
          amountHint: AppStrings.amount2500,
          submitLabel: AppStrings.addIncome,
          titleController: appProvider.incomeTitleController,
          amountController: appProvider.incomeAmountController,
          categories: appProvider.categoriesByTone(TransactionTone.income),
          selectedCategoryId: appProvider.selectedIncomeCategoryId,
          selectedDate: appProvider.selectedIncomeDate,
          tone: TransactionTone.income,
          onCategorySelected: appProvider.selectIncomeCategory,
          onDateSelected: appProvider.selectIncomeDate,
          onSubmitTap: onSubmitTap,
          filteredTransactions: appProvider.incomeTransactionsForSelectedDate,
        );
      },
    );
  }
}
