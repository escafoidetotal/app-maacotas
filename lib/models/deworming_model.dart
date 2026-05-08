import 'package:hive/hive.dart';

part 'deworming_model.g.dart';

@HiveType(typeId: 3)
class DewormingModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String type; // 'internal' or 'external'

  @HiveField(3)
  String productName;

  @HiveField(4)
  DateTime applicationDate;

  @HiveField(5)
  DateTime? nextApplicationDate;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  bool reminderSet;

  DewormingModel({
    required this.id,
    required this.petId,
    required this.type,
    required this.productName,
    required this.applicationDate,
    this.nextApplicationDate,
    this.notes,
    this.reminderSet = false,
  });

  DewormingModel copyWith({
    String? id,
    String? petId,
    String? type,
    String? productName,
    DateTime? applicationDate,
    DateTime? nextApplicationDate,
    String? notes,
    bool? reminderSet,
  }) {
    return DewormingModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      productName: productName ?? this.productName,
      applicationDate: applicationDate ?? this.applicationDate,
      nextApplicationDate: nextApplicationDate ?? this.nextApplicationDate,
      notes: notes ?? this.notes,
      reminderSet: reminderSet ?? this.reminderSet,
    );
  }
}
