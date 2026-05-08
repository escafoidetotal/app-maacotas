import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import 'user_provider.dart';

enum PointsEvent {
  walkLogged,      // +10
  vaccineUpdated,  // +25
  streakBonus,     // +50
  adWatched,       // +15
  weightUpdated,   // +10
}

extension PointsEventExtension on PointsEvent {
  int get points {
    switch (this) {
      case PointsEvent.walkLogged:
        return 10;
      case PointsEvent.vaccineUpdated:
        return 25;
      case PointsEvent.streakBonus:
        return 50;
      case PointsEvent.adWatched:
        return 15;
      case PointsEvent.weightUpdated:
        return 10;
    }
  }

  String get label {
    switch (this) {
      case PointsEvent.walkLogged:
        return 'Passeio diário registrado';
      case PointsEvent.vaccineUpdated:
        return 'Vacina atualizada';
      case PointsEvent.streakBonus:
        return 'Sequência de 7 dias!';
      case PointsEvent.adWatched:
        return 'Anúncio assistido';
      case PointsEvent.weightUpdated:
        return 'Peso mensal atualizado';
    }
  }

  String get key {
    switch (this) {
      case PointsEvent.walkLogged:
        return 'walk';
      case PointsEvent.vaccineUpdated:
        return 'vaccine';
      case PointsEvent.streakBonus:
        return 'streak';
      case PointsEvent.adWatched:
        return 'ad';
      case PointsEvent.weightUpdated:
        return 'weight';
    }
  }
}

class PawPointsNotifier extends StateNotifier<int> {
  final Ref ref;

  PawPointsNotifier(this.ref) : super(0) {
    _load();
  }

  void _load() {
    final user = ref.read(userProvider);
    if (user != null) {
      state = user.pawPoints;
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _monthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  bool _hasEarnedToday(UserModel user, String eventKey) {
    final todayKey = _todayKey();
    final todayLog = user.pointsLog[todayKey] as List?;
    if (todayLog == null) return false;
    return todayLog.contains(eventKey);
  }

  bool _hasEarnedThisMonth(UserModel user, String eventKey) {
    final monthKey = _monthKey();
    final monthLog = user.pointsLog[monthKey] as List?;
    if (monthLog == null) return false;
    return monthLog.contains(eventKey);
  }

  Future<bool> earnPoints(PointsEvent event) async {
    final user = ref.read(userProvider);
    if (user == null) return false;

    // Check daily restrictions
    if (event == PointsEvent.walkLogged && _hasEarnedToday(user, event.key)) {
      return false; // Already logged walk today
    }
    if (event == PointsEvent.weightUpdated && _hasEarnedThisMonth(user, '${event.key}_month')) {
      return false; // Already logged weight this month
    }

    final points = event.points;
    final newBalance = user.pawPoints + points;

    // Update log
    final log = Map<String, dynamic>.from(user.pointsLog);
    if (event == PointsEvent.weightUpdated) {
      final monthKey = _monthKey();
      final monthList = List<String>.from((log[monthKey] as List?) ?? []);
      monthList.add('${event.key}_month');
      log[monthKey] = monthList;
    } else {
      final todayKey = _todayKey();
      final todayList = List<String>.from((log[todayKey] as List?) ?? []);
      todayList.add(event.key);
      log[todayKey] = todayList;
    }

    final updated = user.copyWith(pawPoints: newBalance, pointsLog: log);
    await HiveService.saveUser(updated);
    ref.read(userProvider.notifier).syncUser(updated);
    state = newBalance;

    // Check streak bonus
    if (event == PointsEvent.walkLogged) {
      await _updateStreak(user, updated);
    }

    return true;
  }

  Future<void> _updateStreak(UserModel oldUser, UserModel currentUser) async {
    final now = DateTime.now();
    final lastWalk = oldUser.lastWalkDate;
    int streak = currentUser.currentStreak;

    if (lastWalk == null) {
      streak = 1;
    } else {
      final diff = now.difference(lastWalk).inDays;
      if (diff == 1) {
        streak += 1;
      } else if (diff == 0) {
        // Same day, no change
      } else {
        streak = 1; // Reset streak
      }
    }

    final updated = currentUser.copyWith(
      currentStreak: streak,
      lastWalkDate: now,
    );
    await HiveService.saveUser(updated);
    ref.read(userProvider.notifier).syncUser(updated);

    // Award streak bonus at 7 days
    if (streak > 0 && streak % 7 == 0) {
      await earnPoints(PointsEvent.streakBonus);
    }
  }

  Future<bool> spendPoints(int amount) async {
    final user = ref.read(userProvider);
    if (user == null) return false;
    if (user.pawPoints < amount) return false;

    final newBalance = user.pawPoints - amount;
    final updated = user.copyWith(pawPoints: newBalance);
    await HiveService.saveUser(updated);
    ref.read(userProvider.notifier).syncUser(updated);
    state = newBalance;
    return true;
  }

  Future<void> addPoints(int amount) async {
    final user = ref.read(userProvider);
    if (user == null) return;
    final newBalance = user.pawPoints + amount;
    final updated = user.copyWith(pawPoints: newBalance);
    await HiveService.saveUser(updated);
    ref.read(userProvider.notifier).syncUser(updated);
    state = newBalance;
  }
}

final pawPointsProvider = StateNotifierProvider<PawPointsNotifier, int>((ref) {
  return PawPointsNotifier(ref);
});

final currentStreakProvider = Provider<int>((ref) {
  final user = ref.watch(userProvider);
  return user?.currentStreak ?? 0;
});
