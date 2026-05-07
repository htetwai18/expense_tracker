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
  bool isLoading = false;
  String? userMessage;
  String get emptyStateText => AppStrings.noRecentTransactions;

  final Repository _repository = RepositoryImpl();
  StreamSubscription<dynamic>? _categorySubscription;
  StreamSubscription<dynamic>? _transactionSubscription;

  List<ExpenseCategory> categories = [];
  List<ExpenseTransaction> recentTransactions = [];

  AddProvider() {
    _showLoading();
    _loadScreenData();
    _listenToHiveChanges();
    _hideLoading();
  }

  void clearUserMessage() {
    userMessage = null;
    _notifySafely();
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
    try {
      categories = _repository.getAllCategories();
      final transactions = _repository.getAllTransactions()
        ..sort((left, right) => right.dateTime.compareTo(left.dateTime));
      recentTransactions = transactions.take(6).toList();
    } catch (_) {
      _setMessage(AppStrings.dataRefreshFailed);
    }
  }

  void _listenToHiveChanges() {
    _categorySubscription = _repository.getAllCategoryEventStream().listen((_) {
      _loadScreenData();
      _notifySafely();
    }, onError: (_, _) => _handleStreamError());
    _transactionSubscription = _repository
        .getAllTransactionEventStream()
        .listen((_) {
          _loadScreenData();
          _notifySafely();
        }, onError: (_, _) => _handleStreamError());
  }

  void _notifySafely() {
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void _showLoading() {
    isLoading = true;
    _notifySafely();
  }

  void _hideLoading() {
    isLoading = false;
    _notifySafely();
  }

  void _setMessage(String message) {
    userMessage = message;
  }

  void _handleStreamError() {
    _setMessage(AppStrings.dataRefreshFailed);
    _notifySafely();
  }

  @override
  void dispose() {
    isDisposed = true;
    unawaited(_categorySubscription?.cancel());
    unawaited(_transactionSubscription?.cancel());
    super.dispose();
  }
}
