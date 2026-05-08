import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';
import '../models/vaccine_model.dart';
import '../models/weight_record_model.dart';
import '../models/deworming_model.dart';
import '../models/medication_model.dart';
import '../models/walk_model.dart';
import '../models/vet_appointment_model.dart';
import '../models/user_model.dart';

class SupabaseService {
  // Replace these with your real Supabase project values from supabase.com
  static const String _supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static String? get userId => currentUser?.id;
  static Session? get session => client.auth.currentSession;
  static bool get isLoggedIn => session != null;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  // ─── Auth ────────────────────────────────────────────────────────────────────

  static Future<AuthResponse> signUp(
      String email, String password, String name) async {
    return client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // ─── Profile sync ────────────────────────────────────────────────────────────

  static Future<void> syncProfile(UserModel user) async {
    if (userId == null) return;
    await client.from('profiles').upsert({
      'id': userId,
      'name': user.name,
      'photo_url': user.photoPath,
      'paw_points': user.pawPoints,
      'owned_items': user.ownedItems,
      'points_log': user.pointsLog,
      'current_streak': user.currentStreak,
      'last_walk_date': user.lastWalkDate?.toIso8601String(),
      'selected_theme': user.selectedTheme,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ─── Pets ─────────────────────────────────────────────────────────────────────

  static Future<void> syncPet(PetModel pet) async {
    if (userId == null) return;
    await client.from('pets').upsert({
      'id': pet.id,
      'user_id': userId,
      'name': pet.name,
      'breed': pet.breed,
      'birthdate': pet.birthdate.toIso8601String(),
      'weight': pet.weight,
      'gender': pet.gender,
      'photo_url': pet.photoPath,
      'microchip_number': pet.microchipNumber,
      'insurance_info': pet.insuranceInfo,
      'selected_skin': pet.selectedSkin,
      'owned_accessories': pet.ownedAccessories,
      'equipped_hat': pet.equippedHat,
      'equipped_collar': pet.equippedCollar,
      'equipped_outfit': pet.equippedOutfit,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deletePet(String petId) async {
    if (userId == null) return;
    await client.from('pets').delete().eq('id', petId).eq('user_id', userId!);
  }

  static Future<List<Map<String, dynamic>>> fetchPets() async {
    if (userId == null) return [];
    final response =
        await client.from('pets').select().eq('user_id', userId!);
    return List<Map<String, dynamic>>.from(response);
  }

  // ─── Vaccines ────────────────────────────────────────────────────────────────

  static Future<void> syncVaccine(VaccineModel v) async {
    if (userId == null) return;
    await client.from('vaccines').upsert({
      'id': v.id,
      'pet_id': v.petId,
      'user_id': userId,
      'name': v.name,
      'vaccine_date': v.vaccineDate.toIso8601String(),
      'next_date': v.nextDate?.toIso8601String(),
      'notes': v.notes,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteVaccine(String id) async {
    if (userId == null) return;
    await client.from('vaccines').delete().eq('id', id);
  }

  static Future<List<Map<String, dynamic>>> fetchVaccinesForPet(
      String petId) async {
    if (userId == null) return [];
    final response = await client
        .from('vaccines')
        .select()
        .eq('pet_id', petId)
        .eq('user_id', userId!);
    return List<Map<String, dynamic>>.from(response);
  }

  // ─── Weight records ──────────────────────────────────────────────────────────

  static Future<void> syncWeightRecord(WeightRecordModel w) async {
    if (userId == null) return;
    await client.from('weight_records').upsert({
      'id': w.id,
      'pet_id': w.petId,
      'user_id': userId,
      'weight': w.weight,
      'record_date': w.recordDate.toIso8601String(),
      'notes': w.notes,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteWeightRecord(String id) async {
    if (userId == null) return;
    await client.from('weight_records').delete().eq('id', id);
  }

  // ─── Deworming ───────────────────────────────────────────────────────────────

  static Future<void> syncDeworming(DewormingModel d) async {
    if (userId == null) return;
    await client.from('deworming').upsert({
      'id': d.id,
      'pet_id': d.petId,
      'user_id': userId,
      'type': d.type,
      'product': d.product,
      'application_date': d.applicationDate.toIso8601String(),
      'next_date': d.nextDate?.toIso8601String(),
      'notes': d.notes,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteDeworming(String id) async {
    if (userId == null) return;
    await client.from('deworming').delete().eq('id', id);
  }

  // ─── Medications ─────────────────────────────────────────────────────────────

  static Future<void> syncMedication(MedicationModel m) async {
    if (userId == null) return;
    await client.from('medications').upsert({
      'id': m.id,
      'pet_id': m.petId,
      'user_id': userId,
      'name': m.name,
      'dose': m.dose,
      'frequency': m.frequency,
      'start_date': m.startDate.toIso8601String(),
      'end_date': m.endDate?.toIso8601String(),
      'is_active': m.isActive,
      'notes': m.notes,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteMedication(String id) async {
    if (userId == null) return;
    await client.from('medications').delete().eq('id', id);
  }

  // ─── Walks ───────────────────────────────────────────────────────────────────

  static Future<void> syncWalk(WalkModel w) async {
    if (userId == null) return;
    await client.from('walks').upsert({
      'id': w.id,
      'pet_id': w.petId,
      'user_id': userId,
      'walk_date': w.walkDate.toIso8601String(),
      'duration_minutes': w.durationMinutes,
      'distance_km': w.distanceKm,
      'notes': w.notes,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteWalk(String id) async {
    if (userId == null) return;
    await client.from('walks').delete().eq('id', id);
  }

  // ─── Vet appointments ─────────────────────────────────────────────────────────

  static Future<void> syncVetAppointment(VetAppointmentModel a) async {
    if (userId == null) return;
    await client.from('vet_appointments').upsert({
      'id': a.id,
      'pet_id': a.petId,
      'user_id': userId,
      'title': a.title,
      'appointment_date': a.appointmentDate.toIso8601String(),
      'vet_name': a.vetName,
      'clinic': a.clinic,
      'notes': a.notes,
      'is_completed': a.isCompleted,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteVetAppointment(String id) async {
    if (userId == null) return;
    await client.from('vet_appointments').delete().eq('id', id);
  }
}
