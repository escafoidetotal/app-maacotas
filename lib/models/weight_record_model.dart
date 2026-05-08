import 'package:hive/hive.dart';

part 'weight_record_model.g.dart';

@HiveType(typeId: 2)
class WeightRecordModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  double weight;

  @HiveField(3)
  DateTime recordDate;

  @HiveField(4)
  String? notes;

  WeightRecordModel({
    required this.id,
    required this.petId,
    required this.weight,
    required this.recordDate,
    this.notes,
  });

  WeightRecordModel copyWith({
    String? id,
    String? petId,
    double? weight,
    DateTime? recordDate,
    String? notes,
  }) {
    return WeightRecordModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      weight: weight ?? this.weight,
      recordDate: recordDate ?? this.recordDate,
      notes: notes ?? this.notes,
    );
  }
}
