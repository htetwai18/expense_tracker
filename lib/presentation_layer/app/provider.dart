import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../core/formatters.dart';
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
  TransactionTone _selectedOverviewTone = TransactionTone.expense;
  OverviewChartPeriod _selectedChartPeriod = OverviewChartPeriod.monthly;

  int get selectedTabIndex => _selectedTabIndex;
  int get selectedWeekIndex => _selectedWeekIndex;
  TransactionTone get selectedOverviewTone => _selectedOverviewTone;
  OverviewChartPeriod get selectedChartPeriod => _selectedChartPeriod;
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);

  List<ExpenseTransaction> get transactions {
    final sortedTransactions = List<ExpenseTransaction>.from(_transactions)
      ..sort((left, right) => right.dateTime.compareTo(left.dateTime));
    return sortedTransactions;
  }

  List<ExpenseTransaction> get recentTransactions {
    return transactions.take(6).toList();
  }

  List<ExpenseTransaction> get filteredOverviewTransactions {
    return transactions
        .where((transaction) => transaction.tone == _selectedOverviewTone)
        .toList();
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
    return switch (_selectedChartPeriod) {
      OverviewChartPeriod.weekly => _buildWeeklyChartSummaries(),
      OverviewChartPeriod.monthly => _buildMonthlyChartSummaries(),
      OverviewChartPeriod.yearly => _buildYearlyChartSummaries(),
    };
  }

  ChartWeekSummary get selectedChartWeek {
    final charts = chartWeeks;
    final safeIndex = _selectedWeekIndex.clamp(0, charts.length - 1);
    return charts[safeIndex];
  }

  String get selectedChartPeriodLabel {
    return switch (_selectedChartPeriod) {
      OverviewChartPeriod.weekly => AppStrings.weekly,
      OverviewChartPeriod.monthly => AppStrings.monthly,
      OverviewChartPeriod.yearly => AppStrings.yearly,
    };
  }

  String chartPeriodLabel(OverviewChartPeriod period) {
    return switch (period) {
      OverviewChartPeriod.weekly => AppStrings.weekly,
      OverviewChartPeriod.monthly => AppStrings.monthly,
      OverviewChartPeriod.yearly => AppStrings.yearly,
    };
  }

  String get selectedChartDateRangeLabel {
    final date = _chartAnchorDate;
    return switch (_selectedChartPeriod) {
      OverviewChartPeriod.weekly =>
        '${AppFormatters.dateLabel(_weekStart(date))} - ${AppFormatters.dateLabel(_weekStart(date).add(const Duration(days: 6)))}',
      OverviewChartPeriod.monthly => AppFormatters.monthYear(date),
      OverviewChartPeriod.yearly => date.year.toString(),
    };
  }

  void selectTab(int index) {
    if (_selectedTabIndex == index) {
      return;
    }
    _selectedTabIndex = index;
    notifyListeners();
  }

  void selectChartWeek(int index) {
    if (_selectedWeekIndex == index ||
        index < 0 ||
        index >= chartWeeks.length) {
      return;
    }
    _selectedWeekIndex = index;
    notifyListeners();
  }

  void selectOverviewTone(TransactionTone tone) {
    if (_selectedOverviewTone == tone) {
      return;
    }
    _selectedOverviewTone = tone;
    notifyListeners();
  }

  void selectChartPeriod(OverviewChartPeriod period) {
    if (_selectedChartPeriod == period) {
      return;
    }
    _selectedChartPeriod = period;
    _selectedWeekIndex = period == OverviewChartPeriod.monthly ? 3 : 0;
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

  DateTime get _chartAnchorDate {
    if (_transactions.isEmpty) {
      return DateTime.now();
    }
    return transactions.first.dateTime;
  }

  List<ChartWeekSummary> _buildWeeklyChartSummaries() {
    final weekStart = _weekStart(_chartAnchorDate);
    final rawDays = List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final dayTransactions = _transactions.where((transaction) {
        return _isSameDate(transaction.dateTime, day);
      }).toList();
      return (
        label: AppStrings.weekdays[index],
        income: _sumTransactionsByTone(dayTransactions, TransactionTone.income),
        expense: _sumTransactionsByTone(
          dayTransactions,
          TransactionTone.expense,
        ),
      );
    });
    return _buildChartSummaries(rawDays);
  }

  List<ChartWeekSummary> _buildMonthlyChartSummaries() {
    final date = _chartAnchorDate;
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0).day;
    final weekRanges = [
      (label: AppStrings.chartWeeks[0], startDay: 1, endDay: 7),
      (label: AppStrings.chartWeeks[1], startDay: 8, endDay: 14),
      (label: AppStrings.chartWeeks[2], startDay: 15, endDay: 21),
      (label: AppStrings.chartWeeks[3], startDay: 22, endDay: lastDayOfMonth),
    ];

    final rawWeeks = weekRanges.map((range) {
      final weekTransactions = _transactions.where((transaction) {
        return transaction.dateTime.year == date.year &&
            transaction.dateTime.month == date.month &&
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
    return _buildChartSummaries(rawWeeks);
  }

  List<ChartWeekSummary> _buildYearlyChartSummaries() {
    final year = _chartAnchorDate.year;
    final rawMonths = List.generate(12, (index) {
      final month = index + 1;
      final monthTransactions = _transactions.where((transaction) {
        return transaction.dateTime.year == year &&
            transaction.dateTime.month == month;
      }).toList();
      return (
        label: AppStrings.chartMonths[index],
        income: _sumTransactionsByTone(
          monthTransactions,
          TransactionTone.income,
        ),
        expense: _sumTransactionsByTone(
          monthTransactions,
          TransactionTone.expense,
        ),
      );
    });
    return _buildChartSummaries(rawMonths);
  }

  List<ChartWeekSummary> _buildChartSummaries(
    List<({String label, double income, double expense})> rawSummaries,
  ) {
    final maxAmount = rawSummaries.fold<double>(1, (currentMax, summary) {
      return [
        currentMax,
        summary.income,
        summary.expense,
      ].reduce((left, right) => left > right ? left : right);
    });

    return rawSummaries.map((summary) {
      return ChartWeekSummary(
        label: summary.label,
        incomeAmount: summary.income,
        expenseAmount: summary.expense,
        incomeRatio: summary.income / maxAmount,
        expenseRatio: summary.expense / maxAmount,
      );
    }).toList();
  }

  DateTime _weekStart(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day - (date.weekday - DateTime.monday),
    );
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
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
