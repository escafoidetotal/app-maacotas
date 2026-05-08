import 'package:hive/hive.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 0)
class PetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String breed;

  @HiveField(3)
  DateTime birthdate;

  @HiveField(4)
  double weight;

  @HiveField(5)
  String gender; // 'male' or 'female'

  @HiveField(6)
  String? photoPath;

  @HiveField(7)
  String? microchipNumber;

  @HiveField(8)
  String? insuranceInfo;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  String? selectedSkin;

  @HiveField(11)
  List<String> ownedAccessories;

  @HiveField(12)
  String? equippedHat;

  @HiveField(13)
  String? equippedCollar;

  @HiveField(14)
  String? equippedOutfit;

  PetModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthdate,
    required this.weight,
    required this.gender,
    this.photoPath,
    this.microchipNumber,
    this.insuranceInfo,
    required this.createdAt,
    this.selectedSkin,
    List<String>? ownedAccessories,
    this.equippedHat,
    this.equippedCollar,
    this.equippedOutfit,
  }) : ownedAccessories = ownedAccessories ?? [];

  PetModel copyWith({
    String? id,
    String? name,
    String? breed,
    DateTime? birthdate,
    double? weight,
    String? gender,
    String? photoPath,
    String? microchipNumber,
    String? insuranceInfo,
    DateTime? createdAt,
    String? selectedSkin,
    List<String>? ownedAccessories,
    String? equippedHat,
    String? equippedCollar,
    String? equippedOutfit,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthdate: birthdate ?? this.birthdate,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      photoPath: photoPath ?? this.photoPath,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      createdAt: createdAt ?? this.createdAt,
      selectedSkin: selectedSkin ?? this.selectedSkin,
      ownedAccessories: ownedAccessories ?? this.ownedAccessories,
      equippedHat: equippedHat ?? this.equippedHat,
      equippedCollar: equippedCollar ?? this.equippedCollar,
      equippedOutfit: equippedOutfit ?? this.equippedOutfit,
    );
  }
}
