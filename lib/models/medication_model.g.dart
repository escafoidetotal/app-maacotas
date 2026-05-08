// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationModelAdapter extends TypeAdapter<MedicationModel> {
  @override
  final int typeId = 4;

  @override
  MedicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      name: fields[2] as String,
      dose: fields[3] as String,
      frequency: fields[4] as String,
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime?,
      notes: fields[7] as String?,
      isActive: fields[8] as bool,
      reminderSet: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.dose)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.reminderSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
