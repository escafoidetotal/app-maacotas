// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deworming_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DewormingModelAdapter extends TypeAdapter<DewormingModel> {
  @override
  final int typeId = 3;

  @override
  DewormingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DewormingModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      type: fields[2] as String,
      productName: fields[3] as String,
      applicationDate: fields[4] as DateTime,
      nextApplicationDate: fields[5] as DateTime?,
      notes: fields[6] as String?,
      reminderSet: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DewormingModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.applicationDate)
      ..writeByte(5)
      ..write(obj.nextApplicationDate)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.reminderSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DewormingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
