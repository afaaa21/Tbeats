import 'package:flutter/material.dart';

enum MedicationStatus { sudahDiminum, terlambat, terlewat, belumWaktunya, belumDilaporkan }

// Extension untuk mempermudah konversi Enum ke String dan sebaliknya
extension MedicationStatusExtension on MedicationStatus {
  String toJsonString() => name;

  static MedicationStatus fromJsonString(String json) {
    return MedicationStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MedicationStatus.belumDilaporkan, 
    );
  }
}

class Medication {
  final String id;
  final String name;
  final String dose;
  final String schedule; // Pagi / Malam
  final TimeOfDay time;
  final String? notes; // catatan dari pasien / dokter
  MedicationStatus status;
  String? photoPath;
  DateTime? reportedAt;
  DateTime? createdAt;

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.schedule,
    required this.time,
    this.notes,
    this.status = MedicationStatus.belumWaktunya,
    this.photoPath,
    this.reportedAt,
    this.createdAt,
  });

  // Factory untuk membaca JSON dari API
  factory Medication.fromJson(Map<String, dynamic> json) {
    // API biasanya mengirim waktu dalam format string "HH:mm"
    final timeParts = json['time'].toString().split(':');
    final timeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]), 
      minute: int.parse(timeParts[1])
    );

    return Medication(
      id: json['id'].toString(),
      name: json['name'],
      dose: json['dose'],
      schedule: json['schedule'],
      time: timeOfDay,
      notes: json['notes'],
      status: MedicationStatusExtension.fromJsonString(json['status'] ?? 'belumWaktunya'),
      photoPath: json['photoPath'],
      reportedAt: json['reportedAt'] != null ? DateTime.parse(json['reportedAt']) : null,
    );
  }

  // Factory untuk membaca data dari Supabase (Indonesian snake_case columns)
  factory Medication.fromSupabase(Map<String, dynamic> json) {
    final String jamMinum = json['jam_minum'] ?? '08:00';
    final timeParts = jamMinum.split(':');
    final timeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]), 
      minute: int.parse(timeParts[1])
    );

    return Medication(
      id: json['id'].toString(),
      name: json['nama_obat'] ?? '',
      dose: json['takaran'] ?? '',
      schedule: (timeOfDay.hour < 12) ? 'Pagi' : 'Malam',
      time: timeOfDay,
      notes: json['aturan_makan'] ?? json['notes'] ?? '',
      status: MedicationStatusExtension.fromJsonString(json['status'] ?? 'belumWaktunya'),
      photoPath: json['photo_path'],
      reportedAt: json['reported_at'] != null ? DateTime.parse(json['reported_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  // Method untuk mengirim data ke API (misal saat lapor minum obat)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'schedule': schedule,
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'status': status.toJsonString(),
      'photoPath': photoPath,
      'reportedAt': reportedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  // Method untuk update Supabase
  Map<String, dynamic> toSupabase() {
    return {
      'nama_obat': name,
      'takaran': dose,
      'jam_minum': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'aturan_makan': notes,
      'status': status.toJsonString(),
      'photo_path': photoPath,
      'reported_at': reportedAt?.toIso8601String(),
    };
  }
}

class MedicationHistory {
  final String medicationName;
  final String dose;
  final DateTime scheduledAt;
  final MedicationStatus status;
  final String? photoPath;
  final DateTime? reportedAt;

  MedicationHistory({
    required this.medicationName,
    required this.dose,
    required this.scheduledAt,
    required this.status,
    this.photoPath,
    this.reportedAt,
  });

  factory MedicationHistory.fromJson(Map<String, dynamic> json) {
    return MedicationHistory(
      medicationName: json['medicationName'],
      dose: json['dose'],
      scheduledAt: DateTime.parse(json['scheduledAt']),
      status: MedicationStatusExtension.fromJsonString(json['status']),
      photoPath: json['photoPath'],
      reportedAt: json['reportedAt'] != null ? DateTime.parse(json['reportedAt']) : null,
    );
  }

  factory MedicationHistory.fromSupabase(Map<String, dynamic> json) {
    return MedicationHistory(
      medicationName: json['nama_obat'] ?? '',
      dose: json['takaran'] ?? '',
      scheduledAt: json['reported_at'] != null ? DateTime.parse(json['reported_at']) : DateTime.now(),
      status: MedicationStatusExtension.fromJsonString(json['status'] ?? 'belumWaktunya'),
      photoPath: json['photo_path'],
      reportedAt: json['reported_at'] != null ? DateTime.parse(json['reported_at']) : null,
    );
  }
}

class Patient {
  final String id; // Kita butuh ID UUID riil dari database
  final String name;
  final String registrationNo;
  final String patientId;
  final String phone;
  final String email;
  final DateTime startDate;
  final int durationMonths;
  final String phase;
  final String nurseName;
  final String nurseId; // Simpan juga nurse ID
  final String dokterName;
  final String clinicName;
  final String clinicAddress;

  Patient({
    required this.id,
    required this.name,
    required this.registrationNo,
    required this.patientId,
    required this.phone,
    required this.email,
    required this.startDate,
    required this.durationMonths,
    required this.phase,
    required this.nurseName,
    this.nurseId = '',
    this.dokterName = '',
    required this.clinicName,
    required this.clinicAddress,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      name: json['name'],
      registrationNo: json['registrationNo'] ?? '',
      patientId: json['patientId'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      durationMonths: json['durationMonths'] ?? 6,
      phase: json['phase'] ?? 'Intensif',
      nurseName: json['nurseName'] ?? '',
      dokterName: json['dokterName'] ?? '',
      clinicName: json['clinicName'] ?? '',
      clinicAddress: json['clinicAddress'] ?? '',
    );
  }

  factory Patient.fromSupabase(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      registrationNo: json['registration_no'] ?? 'TBC-2026-038291',
      patientId: json['registration_no'] ?? 'TB-2026-001',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : DateTime.now(),
      durationMonths: json['duration_months'] != null ? int.parse(json['duration_months'].toString()) : 6,
      phase: json['phase'] ?? 'Intensif',
      nurseName: json['perawat_name'] ?? 'Ns. Dewi Lestari',
      nurseId: json['perawat_id'] ?? '',
      dokterName: json['dokter_name'] ?? '',
      clinicName: json['clinic_name'] ?? 'Puskesmas Kecamatan',
      clinicAddress: json['clinic_address'] ?? 'Jl. Kesehatan No. 123, Jakarta',
    );
  }
}