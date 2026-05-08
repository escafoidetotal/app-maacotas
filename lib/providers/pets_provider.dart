import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/pet_model.dart';
import '../models/vaccine_model.dart';
import '../models/weight_record_model.dart';
import '../models/deworming_model.dart';
import '../models/medication_model.dart';
import '../models/walk_model.dart';
import '../models/vet_appointment_model.dart';
import '../services/hive_service.dart';

const _uuid = Uuid();

// ─── Selected Pet ───────────────────────────────────────────────────────────

final selectedPetIdProvider = StateProvider<String?>((ref) => null);

final selectedPetProvider = Provider<PetModel?>((ref) {
  final id = ref.watch(selectedPetIdProvider);
  if (id == null) return null;
  final pets = ref.watch(petsProvider);
  return pets.firstWhere((p) => p.id == id, orElse: () => pets.first);
});

// ─── Pets ────────────────────────────────────────────────────────────────────

class PetsNotifier extends StateNotifier<List<PetModel>> {
  PetsNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.getAllPets();
    if (state.isNotEmpty) {
      // Sort by created date
      state = [...state]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
  }

  Future<PetModel> addPet({
    required String name,
    required String breed,
    required DateTime birthdate,
    required double weight,
    required String gender,
    String? photoPath,
    String? microchipNumber,
    String? insuranceInfo,
  }) async {
    final pet = PetModel(
      id: _uuid.v4(),
      name: name,
      breed: breed,
      birthdate: birthdate,
      weight: weight,
      gender: gender,
      photoPath: photoPath,
      microchipNumber: microchipNumber,
      insuranceInfo: insuranceInfo,
      createdAt: DateTime.now(),
      selectedSkin: breed.toLowerCase().replaceAll(' ', '_'),
    );
    await HiveService.savePet(pet);
    state = [...state, pet];
    return pet;
  }

  Future<void> updatePet(PetModel pet) async {
    await HiveService.savePet(pet);
    state = state.map((p) => p.id == pet.id ? pet : p).toList();
  }

  Future<void> deletePet(String petId) async {
    await HiveService.deletePet(petId);
    state = state.where((p) => p.id != petId).toList();
  }

  Future<void> equipAccessory(String petId, String accessoryId, String category) async {
    final pet = state.firstWhere((p) => p.id == petId);
    PetModel updated;
    switch (category) {
      case 'hat':
        updated = pet.copyWith(equippedHat: accessoryId);
        break;
      case 'collar':
        updated = pet.copyWith(equippedCollar: accessoryId);
        break;
      case 'outfit':
        updated = pet.copyWith(equippedOutfit: accessoryId);
        break;
      default:
        return;
    }
    await updatePet(updated);
  }
}

final petsProvider = StateNotifierProvider<PetsNotifier, List<PetModel>>((ref) {
  return PetsNotifier();
});

// ─── Vaccines ────────────────────────────────────────────────────────────────

class VaccinesNotifier extends StateNotifier<List<VaccineModel>> {
  final String petId;

  VaccinesNotifier(this.petId) : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.getVaccinesForPet(petId);
  }

  Future<void> addVaccine({
    required String name,
    required DateTime vaccineDate,
    DateTime? nextDoseDate,
    String? notes,
    String? veterinarian,
  }) async {
    final vaccine = VaccineModel(
      id: _uuid.v4(),
      petId: petId,
      name: name,
      vaccineDate: vaccineDate,
      nextDoseDate: nextDoseDate,
      notes: notes,
      veterinarian: veterinarian,
    );
    await HiveService.saveVaccine(vaccine);
    state = [vaccine, ...state];
  }

  Future<void> deleteVaccine(String vaccineId) async {
    await HiveService.deleteVaccine(vaccineId);
    state = state.where((v) => v.id != vaccineId).toList();
  }
}

final vaccinesProvider = StateNotifierProvider.family<VaccinesNotifier, List<VaccineModel>, String>(
  (ref, petId) => VaccinesNotifier(petId),
);

// ─── Weight Records ───────────────────────────────────────────────────────────

class WeightRecordsNotifier extends StateNotifier<List<WeightRecordModel>> {
  final String petId;
  final Ref ref;

  WeightRecordsNotifier(this.petId, this.ref) : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.getWeightRecordsForPet(petId);
  }

  Future<void> addWeightRecord({
    required double weight,
    DateTime? recordDate,
    String? notes,
  }) async {
    final record = WeightRecordModel(
      id: _uuid.v4(),
      petId: petId,
      weight: weight,
      recordDate: recordDate ?? DateTime.now(),
      notes: notes,
    );
    await HiveService.saveWeightRecord(record);
    // Update pet's current weight
    final pets = ref.read(petsProvider.notifier);
    final pet = ref.read(petsProvider).firstWhere((p) => p.id == petId);
    await pets.updatePet(pet.copyWith(weight: weight));
    state = [...state, record]..sort((a, b) => a.recordDate.compareTo(b.recordDate));
  }

  Future<void> deleteWeightRecord(String recordId) async {
    await HiveService.deleteWeightRecord(recordId);
    state = state.where((w) => w.id != recordId).toList();
  }
}

final weightRecordsProvider = StateNotifierProvider.family<WeightRecordsNotifier, List<WeightRecordModel>, String>(
  (ref, petId) => WeightRecordsNotifier(petId, ref),
);

// ─── Deworming ────────────────────────────────────────────────────────────────

class DewormingNotifier extends StateNotifier<List<DewormingModel>> {
  final String petId;

  DewormingNotifier(this.petId) : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.getDewormingForPet(petId);
  }

  Future<void> addDeworming({
    required String type,
    required String productName,
    required DateTime applicationDate,
    DateTime? nextApplicationDate,
    String? notes,
  }) async {
    final d = DewormingModel(
      id: _uuid.v4(),
      petId: petId,
      type: type,
      productName: productName,
      applicationDate: applicationDate,
      nextApplicationDate: nextApplicationDate,
      notes: notes,
    );
    await HiveService.saveDeworming(d);
    state = [d, ...state];
  }

  Future<void> deleteDeworming(String dewormingId) async {
    await HiveService.deleteDeworming(dewormingId);
    state = state.where((d) => d.id != dewormingId).toList();
  }
}

final dewormingProvider = StateNotifierProvider.family<DewormingNotifier, List<DewormingModel>, String>(
  (ref, petId) => DewormingNotifier(petId),
);

// ─── Medications ──────────────────────────────────────────────────────────────

class MedicationsNotifier extends StateNotifier<List<MedicationModel>> {
  final String petId;

  MedicationsNotifier(this.petId) : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.getMedicationsForPet(petId);
  }

  Future<void> addMedication({
    required String name,
    required String dose,
    required String frequency,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    final medication = MedicationModel(
      id: _uuid.v4(),
      petId: petId,
      name: name,
      dose: dose,
      frequency: frequency,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
    );
    await HiveService.saveMedication(medication);
    state = [medication, ...state];
  }

  Future<void> deleteMedication(String medicationId) async {
    await HiveService.deleteMedication(medicationId);
    state = state.where((m) => m.id != medicationId).toList();
  }

  Future<void> toggleActive(String medicationId) async {
    state = state.map((m) {
      if (m.id == medicationId) {
        final updated = m.copyWith(isActive: !m.isActive);
        HiveService.saveMedication(updated);
        return updated;
      }
      return m;
    }).toList();
  }
}

final medicationsProvider = StateNotifierProvider.family<MedicationsNotifier, List<MedicationModel>, String>(
  (ref, petId) => MedicationsNotifier(petId),
);

// ─── Walks ────────────────────────────────────────────────────────────────────

class WalksNotifier extends StateNotifier<List<WalkModel>> {
  final String petId;

  WalksNotifier(this.petId) : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.getWalksForPet(petId);
  }

  Future<WalkModel> logWalk({
    required int durationMinutes,
    double? distanceKm,
    DateTime? walkDate,
    String? notes,
  }) async {
    final walk = WalkModel(
      id: _uuid.v4(),
      petId: petId,
      walkDate: walkDate ?? DateTime.now(),
      durationMinutes: durationMinutes,
      distanceKm: distanceKm,
      notes: notes,
      isCompleted: true,
    );
    await HiveService.saveWalk(walk);
    state = [walk, ...state];
    return walk;
  }

  Future<void> scheduleWalk({
    required DateTime walkDate,
    required int durationMinutes,
  }) async {
    final walk = WalkModel(
      id: _uuid.v4(),
      petId: petId,
      walkDate: walkDate,
      durationMinutes: durationMinutes,
      isScheduled: true,
      isCompleted: false,
    );
    await HiveService.saveWalk(walk);
    state = [walk, ...state];
  }

  Future<void> completeWalk(String walkId) async {
    state = state.map((w) {
      if (w.id == walkId) {
        final updated = w.copyWith(isCompleted: true);
        HiveService.saveWalk(updated);
        return updated;
      }
      return w;
    }).toList();
  }

  Future<void> deleteWalk(String walkId) async {
    await HiveService.deleteWalk(walkId);
    state = state.where((w) => w.id != walkId).toList();
  }
}

final walksProvider = StateNotifierProvider.family<WalksNotifier, List<WalkModel>, String>(
  (ref, petId) => WalksNotifier(petId),
);

// ─── Vet Appointments ─────────────────────────────────────────────────────────

class VetAppointmentsNotifier extends StateNotifier<List<VetAppointmentModel>> {
  final String petId;

  VetAppointmentsNotifier(this.petId) : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.getVetAppointmentsForPet(petId);
  }

  Future<void> addAppointment({
    required String vetName,
    String? clinic,
    required DateTime appointmentDate,
    String? reason,
    String? notes,
  }) async {
    final appointment = VetAppointmentModel(
      id: _uuid.v4(),
      petId: petId,
      vetName: vetName,
      clinic: clinic,
      appointmentDate: appointmentDate,
      reason: reason,
      notes: notes,
    );
    await HiveService.saveVetAppointment(appointment);
    state = [...state, appointment]..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await HiveService.deleteVetAppointment(appointmentId);
    state = state.where((a) => a.id != appointmentId).toList();
  }

  Future<void> markCompleted(String appointmentId) async {
    state = state.map((a) {
      if (a.id == appointmentId) {
        final updated = a.copyWith(isCompleted: true);
        HiveService.saveVetAppointment(updated);
        return updated;
      }
      return a;
    }).toList();
  }
}

final vetAppointmentsProvider = StateNotifierProvider.family<VetAppointmentsNotifier, List<VetAppointmentModel>, String>(
  (ref, petId) => VetAppointmentsNotifier(petId),
);

// All upcoming appointments across all pets
final allUpcomingAppointmentsProvider = Provider<List<VetAppointmentModel>>((ref) {
  return HiveService.getAllUpcomingAppointments();
});
