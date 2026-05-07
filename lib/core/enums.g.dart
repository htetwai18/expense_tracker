// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionToneAdapter extends TypeAdapter<TransactionTone> {
  @override
  final int typeId = 3;

  @override
  TransactionTone read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionTone.income;
      case 1:
        return TransactionTone.expense;
      default:
        return TransactionTone.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionTone obj) {
    switch (obj) {
      case TransactionTone.income:
        writer.writeByte(0);
        break;
      case TransactionTone.expense:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionToneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
