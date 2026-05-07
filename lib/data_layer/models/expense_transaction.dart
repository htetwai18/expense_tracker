import 'package:hive/hive.dart';

import '../../core/enums.dart';
import '../../persistence_layer/hive_constants.dart';

part 'expense_transaction.g.dart';

@HiveType(
  typeId: HIVE_TYPE_ID_EXPENSE_TRANSACTION,
  adapterName: 'ExpenseTransactionAdapter',
)
class ExpenseTransaction {
  const ExpenseTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.dateTime,
    required this.categoryId,
    required this.tone,
    this.note,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime dateTime;
  @HiveField(4)
  final String categoryId;
  @HiveField(5)
  final TransactionTone tone;
  @HiveField(6)
  final String? note;
}
