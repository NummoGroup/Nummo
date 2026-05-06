// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsAdapter extends TypeAdapter<Savings> {
  @override
  final int typeId = 4;

  @override
  Savings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Savings(
      totalSaved: fields[0] as double,
      targetAmount: fields[1] as double,
      depositHistory: (fields[2] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, Savings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.totalSaved)
      ..writeByte(1)
      ..write(obj.targetAmount)
      ..writeByte(2)
      ..write(obj.depositHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
