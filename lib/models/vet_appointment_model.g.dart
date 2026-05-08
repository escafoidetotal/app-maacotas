// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vet_appointment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VetAppointmentModelAdapter extends TypeAdapter<VetAppointmentModel> {
  @override
  final int typeId = 6;

  @override
  VetAppointmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VetAppointmentModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      vetName: fields[2] as String,
      clinic: fields[3] as String?,
      appointmentDate: fields[4] as DateTime,
      reason: fields[5] as String?,
      notes: fields[6] as String?,
      reminderSet: fields[7] as bool,
      isCompleted: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VetAppointmentModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.vetName)
      ..writeByte(3)
      ..write(obj.clinic)
      ..writeByte(4)
      ..write(obj.appointmentDate)
      ..writeByte(5)
      ..write(obj.reason)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.reminderSet)
      ..writeByte(8)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VetAppointmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
