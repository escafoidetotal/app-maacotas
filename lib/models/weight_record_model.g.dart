// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightRecordModelAdapter extends TypeAdapter<WeightRecordModel> {
  @override
  final int typeId = 2;

  @override
  WeightRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightRecordModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      weight: fields[2] as double,
      recordDate: fields[3] as DateTime,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WeightRecordModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.recordDate)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
