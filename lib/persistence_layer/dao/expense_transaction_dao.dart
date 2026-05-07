import 'package:hive_flutter/hive_flutter.dart';

import '../../data_layer/models/expense_transaction.dart';
import '../hive_constants.dart';

class ExpenseTransactionDao {
  ExpenseTransactionDao._internal();

  static final ExpenseTransactionDao _singleton =
      ExpenseTransactionDao._internal();

  factory ExpenseTransactionDao() => _singleton;

  Future<void> saveTransaction(ExpenseTransaction transaction) {
    return getTransactionBox().put(transaction.id, transaction);
  }

  Future<void> saveTransactions(List<ExpenseTransaction> transactions) {
    final transactionMap = {
      for (final transaction in transactions) transaction.id: transaction,
    };
    return getTransactionBox().putAll(transactionMap);
  }

  Future<void> deleteTransaction(String id) {
    return getTransactionBox().delete(id);
  }

  Future<void> clearTransactions() {
    return getTransactionBox().clear();
  }

  List<ExpenseTransaction> getAllTransactions() {
    return getTransactionBox().values.toList();
  }

  Stream<BoxEvent> getAllTransactionEventStream() {
    return getTransactionBox().watch();
  }

  Stream<List<ExpenseTransaction>> getAllTransactionsStream() {
    return Stream.value(getAllTransactions());
  }

  Box<ExpenseTransaction> getTransactionBox() {
    return Hive.box<ExpenseTransaction>(BOX_NAME_EXPENSE_TRANSACTION);
  }
}
