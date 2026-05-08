import 'package:hive/hive.dart';

part 'medication_model.g.dart';

@HiveType(typeId: 4)
class MedicationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String dose;

  @HiveField(4)
  String frequency; // e.g., 'daily', 'twice_daily', 'weekly'

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  DateTime? endDate;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  bool reminderSet;

  MedicationModel({
    required this.id,
    required this.petId,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
    this.isActive = true,
    this.reminderSet = false,
  });

  MedicationModel copyWith({
    String? id,
    String? petId,
    String? name,
    String? dose,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    bool? isActive,
    bool? reminderSet,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      reminderSet: reminderSet ?? this.reminderSet,
    );
  }

  String get frequencyLabel {
    switch (frequency) {
      case 'daily':
        return '1x ao dia';
      case 'twice_daily':
        return '2x ao dia';
      case 'three_times':
        return '3x ao dia';
      case 'weekly':
        return '1x por semana';
      case 'biweekly':
        return '2x por semana';
      default:
        return frequency;
    }
  }
}
