import 'package:hive/hive.dart';

part 'vet_appointment_model.g.dart';

@HiveType(typeId: 6)
class VetAppointmentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String vetName;

  @HiveField(3)
  String? clinic;

  @HiveField(4)
  DateTime appointmentDate;

  @HiveField(5)
  String? reason;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  bool reminderSet;

  @HiveField(8)
  bool isCompleted;

  VetAppointmentModel({
    required this.id,
    required this.petId,
    required this.vetName,
    this.clinic,
    required this.appointmentDate,
    this.reason,
    this.notes,
    this.reminderSet = false,
    this.isCompleted = false,
  });

  VetAppointmentModel copyWith({
    String? id,
    String? petId,
    String? vetName,
    String? clinic,
    DateTime? appointmentDate,
    String? reason,
    String? notes,
    bool? reminderSet,
    bool? isCompleted,
  }) {
    return VetAppointmentModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      vetName: vetName ?? this.vetName,
      clinic: clinic ?? this.clinic,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      reminderSet: reminderSet ?? this.reminderSet,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
