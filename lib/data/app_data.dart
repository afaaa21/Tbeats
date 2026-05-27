import 'package:flutter/material.dart';
import '../models/models.dart';

class AppData {
  static final Patient patient = Patient(
    name: 'Budi Santoso',
    registrationNo: 'TBC-2026-038291',
    patientId: 'TB-2023-0891',
    phone: '+62 812 3456 7890',
    email: 'budi.santoso@email.com',
    startDate: DateTime(2023, 10, 12),
    durationMonths: 6,
    phase: 'Intensif',
    nurseName: 'Dewi Lestari',
    clinicName: 'Puskesmas Kecamatan',
    clinicAddress: 'Jl. Kesehatan No. 123, Jakarta Selatan',
  );

  static List<Medication> todayMedications = [
    Medication(
      id: '1',
      name: 'Isoniazid',
      dose: '300mg',
      schedule: 'Pagi',
      time: const TimeOfDay(hour: 7, minute: 0),
      status: MedicationStatus.sudahDiminum,
    ),
    Medication(
      id: '2',
      name: 'Rifampisin',
      dose: '450mg',
      schedule: 'Pagi',
      time: const TimeOfDay(hour: 8, minute: 0),
      status: MedicationStatus.terlambat,
    ),
    Medication(
      id: '3',
      name: 'Pirazinamid',
      dose: '1000mg',
      schedule: 'Pagi',
      time: const TimeOfDay(hour: 9, minute: 0),
      status: MedicationStatus.terlewat,
    ),
    Medication(
      id: '4',
      name: 'Etambutol',
      dose: '750mg',
      schedule: 'Malam',
      time: const TimeOfDay(hour: 20, minute: 0),
      status: MedicationStatus.belumWaktunya,
    ),
  ];

  static final List<MedicationHistory> historyList = [
    MedicationHistory(
      medicationName: 'Rifampisin',
      dose: '150mg',
      scheduledAt: DateTime(2024, 6, 16, 8, 0),
      status: MedicationStatus.sudahDiminum,
      reportedAt: DateTime(2024, 6, 16, 8, 5),
      photoPath: null,
    ),
    MedicationHistory(
      medicationName: 'Isoniazid',
      dose: '300mg',
      scheduledAt: DateTime(2024, 6, 15, 8, 0),
      status: MedicationStatus.terlambat,
      reportedAt: DateTime(2024, 6, 15, 10, 30),
      photoPath: null,
    ),
    MedicationHistory(
      medicationName: 'Pirazinamid',
      dose: '400mg',
      scheduledAt: DateTime(2024, 6, 14, 8, 0),
      status: MedicationStatus.terlewat,
      reportedAt: null,
      photoPath: null,
    ),
    MedicationHistory(
      medicationName: 'Etambutol',
      dose: '750mg',
      scheduledAt: DateTime(2024, 6, 13, 8, 0),
      status: MedicationStatus.sudahDiminum,
      reportedAt: DateTime(2024, 6, 13, 8, 10),
      photoPath: null,
    ),
    MedicationHistory(
      medicationName: 'Rifampisin',
      dose: '450mg',
      scheduledAt: DateTime(2024, 6, 12, 8, 0),
      status: MedicationStatus.sudahDiminum,
      reportedAt: DateTime(2024, 6, 12, 8, 2),
      photoPath: null,
    ),
  ];

  // Weekly checklist data per medication [SEN, SEL, RAB, KAM, JUM, SAB, MIN]
  static Map<String, List<MedicationStatus?>> weeklyChecklist = {
    'Isoniazid (300mg)': [
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      MedicationStatus.terlambat,
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      null,
    ],
    'Rifampisin (450mg)': [
      MedicationStatus.sudahDiminum,
      MedicationStatus.terlewat,
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      null,
    ],
    'Pirazinamid (1000mg)': [
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      MedicationStatus.terlambat,
      MedicationStatus.terlewat,
      MedicationStatus.sudahDiminum,
      MedicationStatus.terlambat,
      null,
    ],
    'Etambutol (750mg)': [
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      MedicationStatus.sudahDiminum,
      MedicationStatus.terlewat,
      null,
    ],
  };
}
