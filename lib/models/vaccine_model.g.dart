// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineModelAdapter extends TypeAdapter<VaccineModel> {
  @override
  final int typeId = 1;

  @override
  VaccineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      name: fields[2] as String,
      vaccineDate: fields[3] as DateTime,
      nextDoseDate: fields[4] as DateTime?,
      notes: fields[5] as String?,
      veterinarian: fields[6] as String?,
      reminderSet: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.vaccineDate)
      ..writeByte(4)
      ..write(obj.nextDoseDate)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.veterinarian)
      ..writeByte(7)
      ..write(obj.reminderSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
