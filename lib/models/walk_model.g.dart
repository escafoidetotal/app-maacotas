// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalkModelAdapter extends TypeAdapter<WalkModel> {
  @override
  final int typeId = 5;

  @override
  WalkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalkModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      walkDate: fields[2] as DateTime,
      durationMinutes: fields[3] as int,
      distanceKm: fields[4] as double?,
      notes: fields[5] as String?,
      isScheduled: fields[6] as bool,
      isCompleted: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WalkModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.walkDate)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.distanceKm)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.isScheduled)
      ..writeByte(7)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
