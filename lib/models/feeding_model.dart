import 'package:hive/hive.dart';

part 'feeding_model.g.dart';

@HiveType(typeId: 8)
class FeedingModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String mealName;

  @HiveField(3)
  String time; // e.g. "08:00"

  @HiveField(4)
  String foodType;

  @HiveField(5)
  int quantityGrams;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  List<int> daysOfWeek; // 1=Monday ... 7=Sunday

  FeedingModel({
    required this.id,
    required this.petId,
    required this.mealName,
    required this.time,
    required this.foodType,
    required this.quantityGrams,
    this.notes,
    required this.daysOfWeek,
  });

  FeedingModel copyWith({
    String? id,
    String? petId,
    String? mealName,
    String? time,
    String? foodType,
    int? quantityGrams,
    String? notes,
    List<int>? daysOfWeek,
  }) {
    return FeedingModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      mealName: mealName ?? this.mealName,
      time: time ?? this.time,
      foodType: foodType ?? this.foodType,
      quantityGrams: quantityGrams ?? this.quantityGrams,
      notes: notes ?? this.notes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    );
  }
}
