import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tbeats/features/nurse/screens/patient_detail_screen.dart';
import 'package:tbeats/models/models.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  testWidgets('edit patient sheet opens when patient phase is empty',
      (tester) async {
    final patient = Patient(
      id: 'patient-1',
      name: 'Budi Santoso',
      registrationNo: 'TB-2026-001',
      patientId: 'TB-2026-001',
      phone: '08123456789',
      email: 'budi@example.com',
      startDate: DateTime(2026),
      durationMonths: 6,
      phase: '',
      nurseName: 'Ns. Dewi',
      dokterName: 'Dr. Ahmad',
      clinicName: 'Puskesmas Kecamatan',
      clinicAddress: 'Jl. Kesehatan No. 123',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PatientDetailScreen(patient: patient),
      ),
    );

    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Data Pasien'), findsOneWidget);
    expect(find.text('Intensif'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
