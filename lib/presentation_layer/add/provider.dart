import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../core/string_collection.dart';
import '../../data_layer/models/expense_category.dart';
import '../../data_layer/models/expense_transaction.dart';
import '../../data_layer/repo/repository.dart';
import '../../data_layer/repo/repository_impl.dart';

class AddProvider extends ChangeNotifier {
  bool isDisposed = false;

  final Repository _repository = RepositoryImpl();
  StreamSubscription<dynamic>? _categorySubscription;
  StreamSubscription<dynamic>? _transactionSubscription;

  List<ExpenseCategory> categories = [];
  List<ExpenseTransaction> recentTransactions = [];

  AddProvider() {
    _loadScreenData();
    _listenToHiveChanges();
  }

  ExpenseCategory categoryById(String categoryId) {
    if (categories.isEmpty) {
      return const ExpenseCategory(
        id: 'fallback',
        name: AppStrings.category,
        emoji: AppStrings.cardEmoji,
        tone: TransactionTone.expense,
        colorKey: 'purple',
      );
    }
    return categories.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => categories.first,
    );
  }

  void _loadScreenData() {
    categories = _repository.getAllCategories();
    final transactions = _repository.getAllTransactions()
      ..sort((left, right) => right.dateTime.compareTo(left.dateTime));
    recentTransactions = transactions.take(6).toList();
  }

  void _listenToHiveChanges() {
    _categorySubscription = _repository.getAllCategoryEventStream().listen((_) {
      _loadScreenData();
      _notifySafely();
    });
    _transactionSubscription = _repository
        .getAllTransactionEventStream()
        .listen((_) {
          _loadScreenData();
          _notifySafely();
        });
  }

  void _notifySafely() {
    if (!isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    unawaited(_categorySubscription?.cancel());
    unawaited(_transactionSubscription?.cancel());
    super.dispose();
  }
}
