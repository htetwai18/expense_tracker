import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense_category.dart';
import '../models/expense_transaction.dart';

abstract class Repository {
  Future<void> saveCategory(ExpenseCategory category);
  Future<void> saveCategories(List<ExpenseCategory> categories);
  Future<void> deleteCategory(String id);
  List<ExpenseCategory> getAllCategories();
  Stream<BoxEvent> getAllCategoryEventStream();
  Stream<List<ExpenseCategory>> getAllCategoriesStream();

  Future<void> saveTransaction(ExpenseTransaction transaction);
  Future<void> saveTransactions(List<ExpenseTransaction> transactions);
  Future<void> deleteTransaction(String id);
  Future<void> clearTransactions();
  List<ExpenseTransaction> getAllTransactions();
  Stream<BoxEvent> getAllTransactionEventStream();
  Stream<List<ExpenseTransaction>> getAllTransactionsStream();
}
