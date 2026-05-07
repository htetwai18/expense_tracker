import 'package:hive_flutter/hive_flutter.dart';

import '../../persistence_layer/dao/expense_category_dao.dart';
import '../../persistence_layer/dao/expense_transaction_dao.dart';
import '../models/expense_category.dart';
import '../models/expense_transaction.dart';
import 'repository.dart';

class RepositoryImpl extends Repository {
  RepositoryImpl._internal();

  static final RepositoryImpl _singleton = RepositoryImpl._internal();

  factory RepositoryImpl() => _singleton;

  final ExpenseCategoryDao _categoryDao = ExpenseCategoryDao();
  final ExpenseTransactionDao _transactionDao = ExpenseTransactionDao();

  @override
  Future<void> saveCategory(ExpenseCategory category) {
    return _categoryDao.saveCategory(category);
  }

  @override
  Future<void> saveCategories(List<ExpenseCategory> categories) {
    return _categoryDao.saveCategories(categories);
  }

  @override
  Future<void> deleteCategory(String id) {
    return _categoryDao.deleteCategory(id);
  }

  @override
  List<ExpenseCategory> getAllCategories() {
    return _categoryDao.getAllCategories();
  }

  @override
  Stream<BoxEvent> getAllCategoryEventStream() {
    return _categoryDao.getAllCategoryEventStream();
  }

  @override
  Stream<List<ExpenseCategory>> getAllCategoriesStream() {
    return _categoryDao.getAllCategoriesStream();
  }

  @override
  Future<void> saveTransaction(ExpenseTransaction transaction) {
    return _transactionDao.saveTransaction(transaction);
  }

  @override
  Future<void> saveTransactions(List<ExpenseTransaction> transactions) {
    return _transactionDao.saveTransactions(transactions);
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _transactionDao.deleteTransaction(id);
  }

  @override
  Future<void> clearTransactions() {
    return _transactionDao.clearTransactions();
  }

  @override
  List<ExpenseTransaction> getAllTransactions() {
    return _transactionDao.getAllTransactions();
  }

  @override
  Stream<BoxEvent> getAllTransactionEventStream() {
    return _transactionDao.getAllTransactionEventStream();
  }

  @override
  Stream<List<ExpenseTransaction>> getAllTransactionsStream() {
    return _transactionDao.getAllTransactionsStream();
  }
}
