import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  StreamSubscription<AuthState>? _authSub;

  UserNotifier() : super(null) {
    _load();
    _listenAuth();
  }

  Future<void> _load() async {
    final user = await HiveService.getOrCreateUser();
    // If logged in via Supabase, use the auth user's id and email
    final supaUser = SupabaseService.currentUser;
    if (supaUser != null) {
      final synced = user.copyWith(
        id: supaUser.id,
        email: supaUser.email,
        name: user.name == 'Tutor'
            ? (supaUser.userMetadata?['name'] as String? ?? user.name)
            : user.name,
      );
      await HiveService.saveUser(synced);
      state = synced;
    } else {
      state = user;
    }
  }

  void _listenAuth() {
    _authSub =
        SupabaseService.authStateChanges.listen((authState) async {
      if (authState.event == AuthChangeEvent.signedIn) {
        await _load();
        // Background sync profile to Supabase
        if (state != null) {
          SupabaseService.syncProfile(state!);
        }
      } else if (authState.event == AuthChangeEvent.signedOut) {
        state = null;
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    state = null;
  }

  Future<void> updateName(String name) async {
    if (state == null) return;
    final updated = state!.copyWith(name: name);
    await HiveService.saveUser(updated);
    state = updated;
    SupabaseService.syncProfile(updated);
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
    SupabaseService.syncProfile(updated);
  }

  Future<void> updateTheme(String theme) async {
    if (state == null) return;
    final updated = state!.copyWith(selectedTheme: theme);
    await HiveService.saveUser(updated);
    state = updated;
    SupabaseService.syncProfile(updated);
  }

  Future<void> addOwnedItem(String itemId) async {
    if (state == null) return;
    final items = [...state!.ownedItems, itemId];
    final updated = state!.copyWith(ownedItems: items);
    await HiveService.saveUser(updated);
    state = updated;
    SupabaseService.syncProfile(updated);
  }

  bool ownsItem(String itemId) {
    return state?.ownedItems.contains(itemId) ?? false;
  }

  /// Used by PawPointsNotifier to sync state after external Hive updates
  void syncUser(UserModel user) {
    state = user;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
