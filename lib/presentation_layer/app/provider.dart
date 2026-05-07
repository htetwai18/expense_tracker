import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../core/string_collection.dart';
import '../../data_layer/mock/expense_mock_data.dart';
import '../../data_layer/models/balance_summary.dart';
import '../../data_layer/models/chart_week_summary.dart';
import '../../data_layer/models/expense_category.dart';
import '../../data_layer/models/expense_transaction.dart';
import '../../data_layer/repo/repository.dart';
import '../../data_layer/repo/repository_impl.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _loadFromHive();
    unawaited(_seedHiveIfNeeded());
    _listenToHiveChanges();
  }

  final Repository _repository = RepositoryImpl();
  final TextEditingController incomeTitleController = TextEditingController();
  final TextEditingController incomeAmountController = TextEditingController();
  final TextEditingController expenseTitleController = TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController categoryEmojiController = TextEditingController();
  final TextEditingController categoryNameController = TextEditingController();

  StreamSubscription<dynamic>? _categorySubscription;
  StreamSubscription<dynamic>? _transactionSubscription;
  List<ExpenseCategory> _categories = [];
  List<ExpenseTransaction> _transactions = [];
  int _selectedTabIndex = 0;
  int _selectedWeekIndex = 3;
  DateTime _selectedIncomeDate = DateTime(2022, 4, 23);
  DateTime _selectedExpenseDate = DateTime(2022, 4, 23);
  String _selectedIncomeCategoryId = 'salary';
  String _selectedExpenseCategoryId = 'food';

  int get selectedTabIndex => _selectedTabIndex;
  int get selectedWeekIndex => _selectedWeekIndex;
  DateTime get selectedIncomeDate => _selectedIncomeDate;
  DateTime get selectedExpenseDate => _selectedExpenseDate;
  String get selectedIncomeCategoryId => _selectedIncomeCategoryId;
  String get selectedExpenseCategoryId => _selectedExpenseCategoryId;
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);

  List<ExpenseTransaction> get transactions {
    final sortedTransactions = List<ExpenseTransaction>.from(_transactions)
      ..sort((left, right) => right.dateTime.compareTo(left.dateTime));
    return sortedTransactions;
  }

  List<ExpenseTransaction> get recentTransactions {
    return transactions.take(6).toList();
  }

  List<ExpenseTransaction> get incomeTransactionsForSelectedDate {
    return _transactionsForDateAndTone(
      dateTime: _selectedIncomeDate,
      tone: TransactionTone.income,
    );
  }

  List<ExpenseTransaction> get expenseTransactionsForSelectedDate {
    return _transactionsForDateAndTone(
      dateTime: _selectedExpenseDate,
      tone: TransactionTone.expense,
    );
  }

  BalanceSummary get balanceSummary {
    final incomeTotal = _sumByTone(TransactionTone.income);
    final expenseTotal = _sumByTone(TransactionTone.expense);
    return BalanceSummary(
      totalBalance: incomeTotal - expenseTotal,
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
    );
  }

  List<ExpenseCategory> categoriesByTone(TransactionTone tone) {
    return _categories.where((category) => category.tone == tone).toList();
  }

  ExpenseCategory categoryById(String categoryId) {
    if (_categories.isEmpty) {
      return const ExpenseCategory(
        id: 'fallback',
        name: AppStrings.category,
        emoji: AppStrings.cardEmoji,
        tone: TransactionTone.expense,
        colorKey: 'purple',
      );
    }
    return _categories.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => _categories.first,
    );
  }

  List<ChartWeekSummary> get chartWeeks {
    final weekRanges = [
      (label: AppStrings.chartWeeks[0], startDay: 1, endDay: 7),
      (label: AppStrings.chartWeeks[1], startDay: 8, endDay: 14),
      (label: AppStrings.chartWeeks[2], startDay: 15, endDay: 21),
      (label: AppStrings.chartWeeks[3], startDay: 22, endDay: 30),
    ];

    final rawWeeks = weekRanges.map((range) {
      final weekTransactions = _transactions.where((transaction) {
        return transaction.dateTime.month == 4 &&
            transaction.dateTime.day >= range.startDay &&
            transaction.dateTime.day <= range.endDay;
      }).toList();
      return (
        label: range.label,
        income: _sumTransactionsByTone(
          weekTransactions,
          TransactionTone.income,
        ),
        expense: _sumTransactionsByTone(
          weekTransactions,
          TransactionTone.expense,
        ),
      );
    }).toList();

    final maxAmount = rawWeeks.fold<double>(1, (currentMax, week) {
      return [
        currentMax,
        week.income,
        week.expense,
      ].reduce((left, right) => left > right ? left : right);
    });

    return rawWeeks.map((week) {
      return ChartWeekSummary(
        label: week.label,
        incomeAmount: week.income,
        expenseAmount: week.expense,
        incomeRatio: week.income / maxAmount,
        expenseRatio: week.expense / maxAmount,
      );
    }).toList();
  }

  ChartWeekSummary get selectedChartWeek => chartWeeks[_selectedWeekIndex];

  void selectTab(int index) {
    if (_selectedTabIndex == index) {
      return;
    }
    _selectedTabIndex = index;
    notifyListeners();
  }

  void selectChartWeek(int index) {
    if (_selectedWeekIndex == index) {
      return;
    }
    _selectedWeekIndex = index;
    notifyListeners();
  }

  void selectIncomeCategory(String categoryId) {
    _selectedIncomeCategoryId = categoryId;
    notifyListeners();
  }

  void selectExpenseCategory(String categoryId) {
    _selectedExpenseCategoryId = categoryId;
    notifyListeners();
  }

  void selectIncomeDate(DateTime dateTime) {
    _selectedIncomeDate = dateTime;
    notifyListeners();
  }

  void selectExpenseDate(DateTime dateTime) {
    _selectedExpenseDate = dateTime;
    notifyListeners();
  }

  void addCategory(TransactionTone tone) {
    final emoji = categoryEmojiController.text.trim();
    final name = categoryNameController.text.trim();
    if (emoji.isEmpty || name.isEmpty) {
      return;
    }

    final category = ExpenseCategory(
      id: 'category_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      tone: tone,
      colorKey: tone == TransactionTone.income ? 'green' : 'orange',
    );
    _categories.add(category);
    unawaited(_repository.saveCategory(category));
    if (tone == TransactionTone.income) {
      _selectedIncomeCategoryId = category.id;
    } else {
      _selectedExpenseCategoryId = category.id;
    }
    categoryEmojiController.clear();
    categoryNameController.clear();
    notifyListeners();
  }

  void addIncomeTransaction() {
    _addTransaction(
      titleController: incomeTitleController,
      amountController: incomeAmountController,
      selectedDate: _selectedIncomeDate,
      selectedCategoryId: _selectedIncomeCategoryId,
      tone: TransactionTone.income,
    );
  }

  void addExpenseTransaction() {
    _addTransaction(
      titleController: expenseTitleController,
      amountController: expenseAmountController,
      selectedDate: _selectedExpenseDate,
      selectedCategoryId: _selectedExpenseCategoryId,
      tone: TransactionTone.expense,
    );
  }

  void _addTransaction({
    required TextEditingController titleController,
    required TextEditingController amountController,
    required DateTime selectedDate,
    required String selectedCategoryId,
    required TransactionTone tone,
  }) {
    final category = categoryById(selectedCategoryId);
    final title = titleController.text.trim().isEmpty
        ? category.name
        : titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      return;
    }

    final now = DateTime.now();
    final transaction = ExpenseTransaction(
      id: 'tx_${now.microsecondsSinceEpoch}',
      title: title,
      amount: amount,
      dateTime: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        now.hour,
        now.minute,
      ),
      categoryId: selectedCategoryId,
      tone: tone,
    );
    _transactions.add(transaction);
    unawaited(_repository.saveTransaction(transaction));
    titleController.clear();
    amountController.clear();
    notifyListeners();
  }

  Future<void> _seedHiveIfNeeded() async {
    if (_repository.getAllCategories().isEmpty) {
      await _repository.saveCategories(ExpenseMockData.categories);
    }
    if (_repository.getAllTransactions().isEmpty) {
      await _repository.saveTransactions(ExpenseMockData.transactions);
    }
    _loadFromHive();
    notifyListeners();
  }

  void _listenToHiveChanges() {
    _categorySubscription = _repository.getAllCategoryEventStream().listen((_) {
      _categories = _repository.getAllCategories();
      _ensureSelectedCategories();
      notifyListeners();
    });
    _transactionSubscription = _repository
        .getAllTransactionEventStream()
        .listen((_) {
          _transactions = _repository.getAllTransactions();
          notifyListeners();
        });
  }

  void _loadFromHive() {
    _categories = _repository.getAllCategories();
    _transactions = _repository.getAllTransactions();
    _ensureSelectedCategories();
  }

  void _ensureSelectedCategories() {
    if (_categories.isEmpty) {
      return;
    }
    if (!_categories.any(
      (category) => category.id == _selectedIncomeCategoryId,
    )) {
      final incomeCategories = categoriesByTone(TransactionTone.income);
      if (incomeCategories.isNotEmpty) {
        _selectedIncomeCategoryId = incomeCategories.first.id;
      }
    }
    if (!_categories.any(
      (category) => category.id == _selectedExpenseCategoryId,
    )) {
      final expenseCategories = categoriesByTone(TransactionTone.expense);
      if (expenseCategories.isNotEmpty) {
        _selectedExpenseCategoryId = expenseCategories.first.id;
      }
    }
  }

  double _sumByTone(TransactionTone tone) {
    return _sumTransactionsByTone(_transactions, tone);
  }

  double _sumTransactionsByTone(
    List<ExpenseTransaction> transactions,
    TransactionTone tone,
  ) {
    return transactions
        .where((transaction) => transaction.tone == tone)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  List<ExpenseTransaction> _transactionsForDateAndTone({
    required DateTime dateTime,
    required TransactionTone tone,
  }) {
    final filteredTransactions = _transactions.where((transaction) {
      return transaction.tone == tone &&
          _isSameDate(transaction.dateTime, dateTime);
    }).toList()..sort((left, right) => right.dateTime.compareTo(left.dateTime));
    return filteredTransactions;
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  @override
  void dispose() {
    unawaited(_categorySubscription?.cancel());
    unawaited(_transactionSubscription?.cancel());
    incomeTitleController.dispose();
    incomeAmountController.dispose();
    expenseTitleController.dispose();
    expenseAmountController.dispose();
    categoryEmojiController.dispose();
    categoryNameController.dispose();
    super.dispose();
  }
}
