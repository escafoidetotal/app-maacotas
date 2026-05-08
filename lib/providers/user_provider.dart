import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final user = await HiveService.getOrCreateUser();
    state = user;
  }

  Future<void> updateName(String name) async {
    if (state == null) return;
    final updated = state!.copyWith(name: name);
    await HiveService.saveUser(updated);
    state = updated;
  }

  Future<void> updateEmail(String email) async {
    if (state == null) return;
    final updated = state!.copyWith(email: email);
    await HiveService.saveUser(updated);
    state = updated;
  }

  Future<void> updatePhoto(String photoPath) async {
    if (state == null) return;
    final updated = state!.copyWith(photoPath: photoPath);
    await HiveService.saveUser(updated);
    state = updated;
  }

  Future<void> updateTheme(String theme) async {
    if (state == null) return;
    final updated = state!.copyWith(selectedTheme: theme);
    await HiveService.saveUser(updated);
    state = updated;
  }

  Future<void> addOwnedItem(String itemId) async {
    if (state == null) return;
    final items = [...state!.ownedItems, itemId];
    final updated = state!.copyWith(ownedItems: items);
    await HiveService.saveUser(updated);
    state = updated;
  }

  bool ownsItem(String itemId) {
    return state?.ownedItems.contains(itemId) ?? false;
  }

  /// Internal method used by other providers to sync state after external Hive updates
  void syncUser(UserModel user) {
    state = user;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
