// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetModelAdapter extends TypeAdapter<PetModel> {
  @override
  final int typeId = 0;

  @override
  PetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      breed: fields[2] as String,
      birthdate: fields[3] as DateTime,
      weight: fields[4] as double,
      gender: fields[5] as String,
      photoPath: fields[6] as String?,
      microchipNumber: fields[7] as String?,
      insuranceInfo: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      selectedSkin: fields[10] as String?,
      ownedAccessories: (fields[11] as List?)?.cast<String>(),
      equippedHat: fields[12] as String?,
      equippedCollar: fields[13] as String?,
      equippedOutfit: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PetModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.breed)
      ..writeByte(3)
      ..write(obj.birthdate)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.gender)
      ..writeByte(6)
      ..write(obj.photoPath)
      ..writeByte(7)
      ..write(obj.microchipNumber)
      ..writeByte(8)
      ..write(obj.insuranceInfo)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.selectedSkin)
      ..writeByte(11)
      ..write(obj.ownedAccessories)
      ..writeByte(12)
      ..write(obj.equippedHat)
      ..writeByte(13)
      ..write(obj.equippedCollar)
      ..writeByte(14)
      ..write(obj.equippedOutfit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
