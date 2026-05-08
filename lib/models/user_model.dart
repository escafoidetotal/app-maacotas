import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 7)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? photoPath;

  @HiveField(4)
  int pawPoints;

  @HiveField(5)
  List<String> ownedItems;

  @HiveField(6)
  Map<String, dynamic> pointsLog; // date -> event list to prevent double-counting

  @HiveField(7)
  int currentStreak;

  @HiveField(8)
  DateTime? lastWalkDate;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  String? selectedTheme;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.photoPath,
    this.pawPoints = 0,
    List<String>? ownedItems,
    Map<String, dynamic>? pointsLog,
    this.currentStreak = 0,
    this.lastWalkDate,
    required this.createdAt,
    this.selectedTheme,
  })  : ownedItems = ownedItems ?? [],
        pointsLog = pointsLog ?? {};

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoPath,
    int? pawPoints,
    List<String>? ownedItems,
    Map<String, dynamic>? pointsLog,
    int? currentStreak,
    DateTime? lastWalkDate,
    DateTime? createdAt,
    String? selectedTheme,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoPath: photoPath ?? this.photoPath,
      pawPoints: pawPoints ?? this.pawPoints,
      ownedItems: ownedItems ?? this.ownedItems,
      pointsLog: pointsLog ?? this.pointsLog,
      currentStreak: currentStreak ?? this.currentStreak,
      lastWalkDate: lastWalkDate ?? this.lastWalkDate,
      createdAt: createdAt ?? this.createdAt,
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }
}
