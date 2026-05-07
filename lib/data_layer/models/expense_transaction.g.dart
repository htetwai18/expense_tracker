// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseTransactionAdapter extends TypeAdapter<ExpenseTransaction> {
  @override
  final int typeId = 2;

  @override
  ExpenseTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseTransaction(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      dateTime: fields[3] as DateTime,
      categoryId: fields[4] as String,
      tone: fields[5] as TransactionTone,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseTransaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.tone)
      ..writeByte(6)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
