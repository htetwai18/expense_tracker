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
  StreamSubscription<dynamic>? _categorySubscription;
  StreamSubscription<dynamic>? _transactionSubscription;
  List<ExpenseCategory> _categories = [];
  List<ExpenseTransaction> _transactions = [];
  int _selectedTabIndex = 0;
  int _selectedWeekIndex = 3;

  int get selectedTabIndex => _selectedTabIndex;
  int get selectedWeekIndex => _selectedWeekIndex;
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);

  List<ExpenseTransaction> get transactions {
    final sortedTransactions = List<ExpenseTransaction>.from(_transactions)
      ..sort((left, right) => right.dateTime.compareTo(left.dateTime));
    return sortedTransactions;
  }

  List<ExpenseTransaction> get recentTransactions {
    return transactions.take(6).toList();
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

  @override
  void dispose() {
    unawaited(_categorySubscription?.cancel());
    unawaited(_transactionSubscription?.cancel());
    super.dispose();
  }
}
