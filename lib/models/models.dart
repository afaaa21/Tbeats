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
}

class Patient {
  final String name;
  final String registrationNo;
  final String patientId;
  final String phone;
  final String email;
  final DateTime startDate;
  final int durationMonths;
  final String phase;
  final String nurseName;
  final String clinicName;
  final String clinicAddress;

  Patient({
    required this.name,
    required this.registrationNo,
    required this.patientId,
    required this.phone,
    required this.email,
    required this.startDate,
    required this.durationMonths,
    required this.phase,
    required this.nurseName,
    required this.clinicName,
    required this.clinicAddress,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['name'],
      registrationNo: json['registrationNo'],
      patientId: json['patientId'],
      phone: json['phone'],
      email: json['email'],
      startDate: DateTime.parse(json['startDate']),
      durationMonths: json['durationMonths'],
      phase: json['phase'],
      nurseName: json['nurseName'],
      clinicName: json['clinicName'],
      clinicAddress: json['clinicAddress'],
    );
  }
}