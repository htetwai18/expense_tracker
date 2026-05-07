import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums.dart';
import '../../core/string_collection.dart';
import '../add/widgets/transaction_form_widgets.dart';
import 'provider.dart';

class AddIncomeScreen extends StatelessWidget {
  const AddIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddIncomeProvider(),
      child: Consumer<AddIncomeProvider>(
        builder: (context, provider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final message = provider.userMessage;
            if (message != null && context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
              provider.clearUserMessage();
            }
          });

          Future<void> onSubmitTap() async {
            final isSaved = await provider.saveIncomeTransaction();
            if (isSaved && context.mounted) {
              Navigator.of(context).pop();
            }
          }

          return TransactionFormScaffold(
            title: AppStrings.addIncome,
            itemTitleLabel: AppStrings.incomeTitle,
            itemTitleHint: AppStrings.remoteJob,
            amountHint: AppStrings.amount2500,
            submitLabel: AppStrings.addIncome,
            titleController: provider.titleController,
            amountController: provider.amountController,
            categories: provider.categories,
            selectedCategoryId: provider.selectedCategoryId,
            selectedDate: provider.selectedDate,
            tone: TransactionTone.income,
            onCategorySelected: provider.selectCategory,
            onDateSelected: provider.selectDate,
            onSubmitTap: onSubmitTap,
            filteredTransactions: provider.filteredTransactions,
            categoryEmojiController: provider.categoryEmojiController,
            categoryNameController: provider.categoryNameController,
            onAddCategory: provider.addCategory,
            isLoading: provider.isLoading,
            categoryEmojiErrorTextGetter: () => provider.categoryEmojiErrorText,
            categoryNameErrorTextGetter: () => provider.categoryNameErrorText,
            titleErrorText: provider.titleErrorText,
            amountErrorText: provider.amountErrorText,
            categoryErrorText: provider.categoryErrorText,
            categoryEmojiErrorText: provider.categoryEmojiErrorText,
            categoryNameErrorText: provider.categoryNameErrorText,
          );
        },
      ),
    );
  }
}
