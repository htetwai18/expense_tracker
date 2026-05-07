import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../core/string_collection.dart';
import '../../data_layer/models/expense_category.dart';
import '../../data_layer/models/expense_transaction.dart';
import '../../data_layer/repo/repository.dart';
import '../../data_layer/repo/repository_impl.dart';

class AddExpenseProvider extends ChangeNotifier {
  bool isDisposed = false;

  final Repository _repository = RepositoryImpl();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryEmojiController = TextEditingController();
  final TextEditingController categoryNameController = TextEditingController();
  StreamSubscription<dynamic>? _categorySubscription;
  StreamSubscription<dynamic>? _transactionSubscription;

  List<ExpenseCategory> categories = [];
  List<ExpenseTransaction> filteredTransactions = [];
  DateTime selectedDate = DateTime(2022, 4, 23);
  String selectedCategoryId = 'food';

  AddExpenseProvider() {
    _loadScreenData();
    _listenToHiveChanges();
  }

  void selectCategory(String categoryId) {
    selectedCategoryId = categoryId;
    _notifySafely();
  }

  void selectDate(DateTime dateTime) {
    selectedDate = dateTime;
    _loadFilteredTransactions();
    _notifySafely();
  }

  Future<void> addCategory() async {
    final emoji = categoryEmojiController.text.trim();
    final name = categoryNameController.text.trim();
    if (emoji.isEmpty || name.isEmpty) {
      return;
    }
    final category = ExpenseCategory(
      id: 'category_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      tone: TransactionTone.expense,
      colorKey: 'orange',
    );
    await _repository.saveCategory(category);
    selectedCategoryId = category.id;
    categoryEmojiController.clear();
    categoryNameController.clear();
    _loadScreenData();
    _notifySafely();
  }

  Future<bool> saveExpenseTransaction() async {
    final category = categoryById(selectedCategoryId);
    final title = titleController.text.trim().isEmpty
        ? category.name
        : titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      return false;
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
      tone: TransactionTone.expense,
    );
    await _repository.saveTransaction(transaction);
    titleController.clear();
    amountController.clear();
    _loadScreenData();
    _notifySafely();
    return true;
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
    categories = _repository
        .getAllCategories()
        .where((category) => category.tone == TransactionTone.expense)
        .toList();
    _ensureSelectedCategory();
    _loadFilteredTransactions();
  }

  void _loadFilteredTransactions() {
    filteredTransactions =
        _repository
            .getAllTransactions()
            .where(
              (transaction) =>
                  transaction.tone == TransactionTone.expense &&
                  _isSameDate(transaction.dateTime, selectedDate),
            )
            .toList()
          ..sort((left, right) => right.dateTime.compareTo(left.dateTime));
  }

  void _ensureSelectedCategory() {
    if (categories.isEmpty) {
      return;
    }
    if (!categories.any((category) => category.id == selectedCategoryId)) {
      selectedCategoryId = categories.first.id;
    }
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

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
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
    titleController.dispose();
    amountController.dispose();
    categoryEmojiController.dispose();
    categoryNameController.dispose();
    super.dispose();
  }
}
