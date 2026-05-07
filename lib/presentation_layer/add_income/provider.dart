import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../core/string_collection.dart';
import '../../data_layer/models/expense_category.dart';
import '../../data_layer/models/expense_transaction.dart';
import '../../data_layer/repo/repository.dart';
import '../../data_layer/repo/repository_impl.dart';

class AddIncomeProvider extends ChangeNotifier {
  bool isDisposed = false;
  bool isLoading = false;
  String? userMessage;
  String? titleErrorText;
  String? amountErrorText;
  String? categoryErrorText;
  String? categoryEmojiErrorText;
  String? categoryNameErrorText;

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
  String selectedCategoryId = 'salary';

  AddIncomeProvider() {
    _loadScreenData();
    _listenToHiveChanges();
  }

  void clearUserMessage() {
    userMessage = null;
    _notifySafely();
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
    _clearCategoryErrors();
    final emoji = categoryEmojiController.text.trim();
    final name = categoryNameController.text.trim();
    if (!_validateCategoryInput(emoji: emoji, name: name)) {
      _notifySafely();
      return;
    }
    final category = ExpenseCategory(
      id: 'category_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      tone: TransactionTone.income,
      colorKey: 'green',
    );
    try {
      _showLoading();
      await _repository.saveCategory(category);
      selectedCategoryId = category.id;
      categoryEmojiController.clear();
      categoryNameController.clear();
      _setMessage(AppStrings.categorySaved);
      _loadScreenData();
    } catch (_) {
      _setMessage(AppStrings.categorySaveFailed);
    } finally {
      _hideLoading();
    }
  }

  Future<bool> saveIncomeTransaction() async {
    _clearTransactionErrors();
    final category = categoryById(selectedCategoryId);
    final title = titleController.text.trim().isEmpty
        ? category.name
        : titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());
    if (!_validateTransactionInput(amount: amount)) {
      _notifySafely();
      return false;
    }
    final validAmount = amount!;

    final now = DateTime.now();
    final transaction = ExpenseTransaction(
      id: 'tx_${now.microsecondsSinceEpoch}',
      title: title,
      amount: validAmount,
      dateTime: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        now.hour,
        now.minute,
      ),
      categoryId: selectedCategoryId,
      tone: TransactionTone.income,
    );
    try {
      _showLoading();
      await _repository.saveTransaction(transaction);
      titleController.clear();
      amountController.clear();
      _setMessage(AppStrings.transactionSaved);
      _loadScreenData();
      return true;
    } catch (_) {
      _setMessage(AppStrings.transactionSaveFailed);
      return false;
    } finally {
      _hideLoading();
    }
  }

  ExpenseCategory categoryById(String categoryId) {
    if (categories.isEmpty) {
      return const ExpenseCategory(
        id: 'fallback',
        name: AppStrings.category,
        emoji: AppStrings.cardEmoji,
        tone: TransactionTone.income,
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
      categories = _repository
          .getAllCategories()
          .where((category) => category.tone == TransactionTone.income)
          .toList();
      _ensureSelectedCategory();
      _loadFilteredTransactions();
    } catch (_) {
      _setMessage(AppStrings.dataRefreshFailed);
    }
  }

  void _loadFilteredTransactions() {
    filteredTransactions =
        _repository
            .getAllTransactions()
            .where(
              (transaction) =>
                  transaction.tone == TransactionTone.income &&
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
    }, onError: (_, _) => _handleStreamError());
    _transactionSubscription = _repository
        .getAllTransactionEventStream()
        .listen((_) {
          _loadScreenData();
          _notifySafely();
        }, onError: (_, _) => _handleStreamError());
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

  bool _validateTransactionInput({required double? amount}) {
    if (categories.isEmpty) {
      categoryErrorText = AppStrings.categoryRequired;
      userMessage = AppStrings.categoryRequired;
      return false;
    }
    if (!categories.any((category) => category.id == selectedCategoryId)) {
      _ensureSelectedCategory();
      if (!categories.any((category) => category.id == selectedCategoryId)) {
        categoryErrorText = AppStrings.categoryRequired;
        userMessage = AppStrings.categoryRequired;
        return false;
      }
    }
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      amountErrorText = AppStrings.amountRequired;
      userMessage = AppStrings.amountRequired;
      return false;
    }
    if (amount == null) {
      amountErrorText = AppStrings.amountInvalid;
      userMessage = AppStrings.amountInvalid;
      return false;
    }
    if (amount <= 0) {
      amountErrorText = AppStrings.amountMustBePositive;
      userMessage = AppStrings.amountMustBePositive;
      return false;
    }
    return true;
  }

  bool _validateCategoryInput({required String emoji, required String name}) {
    var isValid = true;
    if (emoji.isEmpty) {
      categoryEmojiErrorText = AppStrings.categoryEmojiRequired;
      userMessage = AppStrings.categoryEmojiRequired;
      isValid = false;
    } else if (emoji.runes.length > 4) {
      categoryEmojiErrorText = AppStrings.categoryEmojiInvalid;
      userMessage = AppStrings.categoryEmojiInvalid;
      isValid = false;
    }
    if (name.isEmpty) {
      categoryNameErrorText = AppStrings.categoryNameRequired;
      userMessage = AppStrings.categoryNameRequired;
      isValid = false;
    } else if (categories.any(
      (category) => category.name.toLowerCase() == name.toLowerCase(),
    )) {
      categoryNameErrorText = AppStrings.categoryAlreadyExists;
      userMessage = AppStrings.categoryAlreadyExists;
      isValid = false;
    }
    return isValid;
  }

  void _clearTransactionErrors() {
    titleErrorText = null;
    amountErrorText = null;
    categoryErrorText = null;
  }

  void _clearCategoryErrors() {
    categoryEmojiErrorText = null;
    categoryNameErrorText = null;
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
    titleController.dispose();
    amountController.dispose();
    categoryEmojiController.dispose();
    categoryNameController.dispose();
    super.dispose();
  }
}
