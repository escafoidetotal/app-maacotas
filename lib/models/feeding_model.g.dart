// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written Hive adapter for FeedingModel

part of 'feeding_model.dart';

class FeedingModelAdapter extends TypeAdapter<FeedingModel> {
  @override
  final int typeId = 8;

  @override
  FeedingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedingModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      mealName: fields[2] as String,
      time: fields[3] as String,
      foodType: fields[4] as String,
      quantityGrams: fields[5] as int,
      notes: fields[6] as String?,
      daysOfWeek: (fields[7] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, FeedingModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.mealName)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.foodType)
      ..writeByte(5)
      ..write(obj.quantityGrams)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.daysOfWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
