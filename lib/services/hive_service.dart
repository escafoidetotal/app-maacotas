import 'package:hive_flutter/hive_flutter.dart';
import '../models/pet_model.dart';
import '../models/vaccine_model.dart';
import '../models/weight_record_model.dart';
import '../models/deworming_model.dart';
import '../models/medication_model.dart';
import '../models/walk_model.dart';
import '../models/vet_appointment_model.dart';
import '../models/user_model.dart';

class HiveService {
  static const String petsBox = 'pets';
  static const String vaccinesBox = 'vaccines';
  static const String weightRecordsBox = 'weight_records';
  static const String dewormingBox = 'deworming';
  static const String medicationsBox = 'medications';
  static const String walksBox = 'walks';
  static const String vetAppointmentsBox = 'vet_appointments';
  static const String userBox = 'user';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PetModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(VaccineModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(WeightRecordModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(DewormingModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(MedicationModelAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(WalkModelAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(VetAppointmentModelAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(UserModelAdapter());

    // Open boxes
    await Hive.openBox<PetModel>(petsBox);
    await Hive.openBox<VaccineModel>(vaccinesBox);
    await Hive.openBox<WeightRecordModel>(weightRecordsBox);
    await Hive.openBox<DewormingModel>(dewormingBox);
    await Hive.openBox<MedicationModel>(medicationsBox);
    await Hive.openBox<WalkModel>(walksBox);
    await Hive.openBox<VetAppointmentModel>(vetAppointmentsBox);
    await Hive.openBox<UserModel>(userBox);
  }

  static Box<PetModel> get pets => Hive.box<PetModel>(petsBox);
  static Box<VaccineModel> get vaccines => Hive.box<VaccineModel>(vaccinesBox);
  static Box<WeightRecordModel> get weightRecords => Hive.box<WeightRecordModel>(weightRecordsBox);
  static Box<DewormingModel> get deworming => Hive.box<DewormingModel>(dewormingBox);
  static Box<MedicationModel> get medications => Hive.box<MedicationModel>(medicationsBox);
  static Box<WalkModel> get walks => Hive.box<WalkModel>(walksBox);
  static Box<VetAppointmentModel> get vetAppointments => Hive.box<VetAppointmentModel>(vetAppointmentsBox);
  static Box<UserModel> get user => Hive.box<UserModel>(userBox);

  // Pet operations
  static Future<void> savePet(PetModel pet) async {
    await pets.put(pet.id, pet);
  }

  static Future<void> deletePet(String petId) async {
    await pets.delete(petId);
    // Also delete associated records
    final vaccineKeys = vaccines.keys.where((k) {
      final v = vaccines.get(k);
      return v?.petId == petId;
    }).toList();
    for (final key in vaccineKeys) {
      await vaccines.delete(key);
    }

    final weightKeys = weightRecords.keys.where((k) {
      final w = weightRecords.get(k);
      return w?.petId == petId;
    }).toList();
    for (final key in weightKeys) {
      await weightRecords.delete(key);
    }

    final dewormKeys = deworming.keys.where((k) {
      final d = deworming.get(k);
      return d?.petId == petId;
    }).toList();
    for (final key in dewormKeys) {
      await deworming.delete(key);
    }

    final medKeys = medications.keys.where((k) {
      final m = medications.get(k);
      return m?.petId == petId;
    }).toList();
    for (final key in medKeys) {
      await medications.delete(key);
    }

    final walkKeys = walks.keys.where((k) {
      final w = walks.get(k);
      return w?.petId == petId;
    }).toList();
    for (final key in walkKeys) {
      await walks.delete(key);
    }

    final apptKeys = vetAppointments.keys.where((k) {
      final a = vetAppointments.get(k);
      return a?.petId == petId;
    }).toList();
    for (final key in apptKeys) {
      await vetAppointments.delete(key);
    }
  }

  static List<PetModel> getAllPets() {
    return pets.values.toList();
  }

  // Vaccine operations
  static Future<void> saveVaccine(VaccineModel vaccine) async {
    await vaccines.put(vaccine.id, vaccine);
  }

  static Future<void> deleteVaccine(String vaccineId) async {
    await vaccines.delete(vaccineId);
  }

  static List<VaccineModel> getVaccinesForPet(String petId) {
    return vaccines.values.where((v) => v.petId == petId).toList()
      ..sort((a, b) => b.vaccineDate.compareTo(a.vaccineDate));
  }

  // Weight record operations
  static Future<void> saveWeightRecord(WeightRecordModel record) async {
    await weightRecords.put(record.id, record);
  }

  static Future<void> deleteWeightRecord(String recordId) async {
    await weightRecords.delete(recordId);
  }

  static List<WeightRecordModel> getWeightRecordsForPet(String petId) {
    return weightRecords.values.where((w) => w.petId == petId).toList()
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));
  }

  // Deworming operations
  static Future<void> saveDeworming(DewormingModel d) async {
    await deworming.put(d.id, d);
  }

  static Future<void> deleteDeworming(String dewormingId) async {
    await deworming.delete(dewormingId);
  }

  static List<DewormingModel> getDewormingForPet(String petId) {
    return deworming.values.where((d) => d.petId == petId).toList()
      ..sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
  }

  // Medication operations
  static Future<void> saveMedication(MedicationModel medication) async {
    await medications.put(medication.id, medication);
  }

  static Future<void> deleteMedication(String medicationId) async {
    await medications.delete(medicationId);
  }

  static List<MedicationModel> getMedicationsForPet(String petId) {
    return medications.values.where((m) => m.petId == petId).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  // Walk operations
  static Future<void> saveWalk(WalkModel walk) async {
    await walks.put(walk.id, walk);
  }

  static Future<void> deleteWalk(String walkId) async {
    await walks.delete(walkId);
  }

  static List<WalkModel> getWalksForPet(String petId) {
    return walks.values.where((w) => w.petId == petId).toList()
      ..sort((a, b) => b.walkDate.compareTo(a.walkDate));
  }

  // Vet appointment operations
  static Future<void> saveVetAppointment(VetAppointmentModel appointment) async {
    await vetAppointments.put(appointment.id, appointment);
  }

  static Future<void> deleteVetAppointment(String appointmentId) async {
    await vetAppointments.delete(appointmentId);
  }

  static List<VetAppointmentModel> getVetAppointmentsForPet(String petId) {
    return vetAppointments.values.where((a) => a.petId == petId).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  static List<VetAppointmentModel> getAllUpcomingAppointments() {
    final now = DateTime.now();
    return vetAppointments.values
        .where((a) => a.appointmentDate.isAfter(now) && !a.isCompleted)
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  // User operations
  static Future<UserModel> getOrCreateUser() async {
    if (user.isEmpty) {
      final newUser = UserModel(
        id: 'user_1',
        name: 'Tutor',
        createdAt: DateTime.now(),
      );
      await user.put(newUser.id, newUser);
      return newUser;
    }
    return user.values.first;
  }

  static Future<void> saveUser(UserModel u) async {
    await user.put(u.id, u);
  }
}
