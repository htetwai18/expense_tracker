import 'package:hive/hive.dart';

import '../persistence_layer/hive_constants.dart';

part 'enums.g.dart';

@HiveType(
  typeId: HIVE_TYPE_ID_TRANSACTION_TONE,
  adapterName: 'TransactionToneAdapter',
)
enum TransactionTone {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}
