import 'package:hive/hive.dart';

part 'vaccine_model.g.dart';

@HiveType(typeId: 1)
class VaccineModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime vaccineDate;

  @HiveField(4)
  DateTime? nextDoseDate;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  String? veterinarian;

  @HiveField(7)
  bool reminderSet;

  VaccineModel({
    required this.id,
    required this.petId,
    required this.name,
    required this.vaccineDate,
    this.nextDoseDate,
    this.notes,
    this.veterinarian,
    this.reminderSet = false,
  });

  VaccineModel copyWith({
    String? id,
    String? petId,
    String? name,
    DateTime? vaccineDate,
    DateTime? nextDoseDate,
    String? notes,
    String? veterinarian,
    bool? reminderSet,
  }) {
    return VaccineModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      vaccineDate: vaccineDate ?? this.vaccineDate,
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      notes: notes ?? this.notes,
      veterinarian: veterinarian ?? this.veterinarian,
      reminderSet: reminderSet ?? this.reminderSet,
    );
  }
}
