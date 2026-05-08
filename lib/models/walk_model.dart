import 'package:hive/hive.dart';

part 'walk_model.g.dart';

@HiveType(typeId: 5)
class WalkModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  DateTime walkDate;

  @HiveField(3)
  int durationMinutes;

  @HiveField(4)
  double? distanceKm;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  bool isScheduled;

  @HiveField(7)
  bool isCompleted;

  WalkModel({
    required this.id,
    required this.petId,
    required this.walkDate,
    required this.durationMinutes,
    this.distanceKm,
    this.notes,
    this.isScheduled = false,
    this.isCompleted = false,
  });

  WalkModel copyWith({
    String? id,
    String? petId,
    DateTime? walkDate,
    int? durationMinutes,
    double? distanceKm,
    String? notes,
    bool? isScheduled,
    bool? isCompleted,
  }) {
    return WalkModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      walkDate: walkDate ?? this.walkDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      notes: notes ?? this.notes,
      isScheduled: isScheduled ?? this.isScheduled,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
