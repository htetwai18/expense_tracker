import 'package:hive/hive.dart';

import '../../core/enums.dart';
import '../../persistence_layer/hive_constants.dart';

part 'expense_category.g.dart';

@HiveType(
  typeId: HIVE_TYPE_ID_EXPENSE_CATEGORY,
  adapterName: 'ExpenseCategoryAdapter',
)
class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.tone,
    required this.colorKey,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String emoji;
  @HiveField(3)
  final TransactionTone tone;
  @HiveField(4)
  final String colorKey;
}
