import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';
import 'report_screen.dart';
import 'nurse_profile_screen.dart';
import '../../../service/api_service.dart';
import '../../../models/models.dart';
import '../../../core/config/supabase_config.dart';

class NurseDashboardScreen extends StatefulWidget {
  const NurseDashboardScreen({super.key});

  @override
  State<NurseDashboardScreen> createState() => _NurseDashboardScreenState();
}

class _NurseDashboardScreenState extends State<NurseDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardContent(),
    _PatientsContent(),
    _ReportContent(),
    NurseProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPatientScreen()),
                );
                // Trigger refresh by rebuild
                setState(() {});
              },
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Pasien',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.onPrimaryContainer),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group, color: AppColors.onPrimaryContainer),
            label: 'Pasien',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard, color: Colors.white),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.onPrimaryContainer),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  final ApiService _apiService = ApiService();
  String _nurseName = "Perawat";
  List<Patient> _patients = [];
  List<Patient> _criticalPatients = [];
  Map<String, List<Medication>> _patientMedications = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Ambil data profil perawat
      final nurseProfile = await _apiService.getProfileInfo();
      _nurseName = nurseProfile['name'] ?? 'Ns. Dewi Lestari';

      // 2. Ambil daftar pasien pendamping
      final patientsData = await _apiService.getDaftarPasienKu();
      final loadedPatients = patientsData.map((p) => Patient.fromSupabase(p)).toList();

      // 3. Ambil status obat hari ini untuk tiap pasien untuk mencari status kritis & kepatuhan
      final List<Patient> criticals = [];
      final Map<String, List<Medication>> medMap = {};

      for (var patient in loadedPatients) {
        // Query medications untuk patient.id
        final medsData = await SupabaseConfig.client
            .from('medications')
            .select()
            .eq('user_id', patient.id);
        
        final List<Medication> loadedMeds = medsData.map((m) => Medication.fromSupabase(m)).toList();
        medMap[patient.id] = loadedMeds;

        // Pasien dianggap kritis jika ada obat yang terlewat (missed) atau terlambat belum dilaporkan
        final hasMissed = loadedMeds.any((m) => m.status == MedicationStatus.terlewat);
        if (hasMissed) {
          criticals.add(patient);
        }
      }

      if (!mounted) return;
      setState(() {
        _patients = loadedPatients;
        _criticalPatients = criticals;
        _patientMedications = medMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryContainer),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              const Text('Gagal Memuat Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadDashboardData,
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TBeats'),
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryContainer,
            child: Icon(Icons.medical_services_rounded, color: Colors.white, size: 16),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppColors.primaryContainer,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          children: [
            // Greeting Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, $_nurseName 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Anda mendampingi ${_patients.length} pasien aktif',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xCCFFFFFF),
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Alert Banner jika ada pasien kritis
            if (_criticalPatients.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(left: BorderSide(color: AppColors.danger, width: 4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_outlined, color: AppColors.danger, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onErrorContainer,
                            fontFamily: 'PlusJakartaSans',
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: '${_criticalPatients.length} pasien terdeteksi kritis! ',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const TextSpan(
                              text: 'Terdapat obat yang terlewatkan. Hubungi pasien untuk memastikan pengobatan tetap berlanjut.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Pasien Kritis List
            if (_criticalPatients.isNotEmpty) ...[
              const Text(
                'Pasien Kritis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _criticalPatients.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (ctx, i) {
                    final patient = _criticalPatients[i];
                    final initials = patient.name.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();
                    return _CriticalPatientCard(
                      initials: initials,
                      patient: patient,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: patient)),
                      ).then((_) => _loadDashboardData()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Semua Pasien
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Semua Pasien',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_patients.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Belum ada pasien yang didaftarkan.', style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ..._patients.map((patient) {
                final initials = patient.name.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();
                
                // Hitung status pasien hari ini
                final meds = _patientMedications[patient.id] ?? [];
                PatientStatus overallStatus = PatientStatus.notReported;

                if (meds.isNotEmpty) {
                  final allDone = meds.every((m) => m.status == MedicationStatus.sudahDiminum);
                  final hasLate = meds.any((m) => m.status == MedicationStatus.terlambat || m.status == MedicationStatus.belumDilaporkan);
                  
                  if (allDone) {
                    overallStatus = PatientStatus.taken;
                  } else if (hasLate) {
                    overallStatus = PatientStatus.late;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PatientRowItem(
                    initials: initials,
                    name: patient.name,
                    id: patient.registrationNo,
                    schedule: patient.phase,
                    status: overallStatus,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: patient)),
                    ).then((_) => _loadDashboardData()),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _PatientsContent extends StatefulWidget {
  const _PatientsContent();

  @override
  State<_PatientsContent> createState() => _PatientsContentState();
}

class _PatientsContentState extends State<_PatientsContent> {
  final ApiService _apiService = ApiService();
  List<Patient> _patients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final patientsData = await _apiService.getDaftarPasienKu();
      final loadedPatients = patientsData.map((p) => Patient.fromSupabase(p)).toList();

      if (!mounted) return;
      setState(() {
        _patients = loadedPatients;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryContainer),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pasien')),
      body: RefreshIndicator(
        onRefresh: _loadPatients,
        color: AppColors.primaryContainer,
        child: _patients.isEmpty
            ? const Center(
                child: Text('Belum ada pasien terdaftar.', style: TextStyle(color: AppColors.textSecondary)),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _patients.length,
                itemBuilder: (ctx, i) {
                  final patient = _patients[i];
                  final initials = patient.name.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryContainer.withOpacity(0.1),
                        child: Text(initials, style: const TextStyle(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text('ID: ${patient.registrationNo}\nFase: ${patient.phase}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: patient)),
                      ).then((_) => _loadPatients()),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  const _ReportContent();

  @override
  Widget build(BuildContext context) {
    return const ReportScreen();
  }
}

enum PatientStatus { taken, late, notReported }

class _CriticalPatientCard extends StatelessWidget {
  final String initials;
  final Patient patient;
  final VoidCallback onTap;

  const _CriticalPatientCard({
    required this.initials,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: AppColors.danger, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.errorContainer,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      Text(
                        'ID: ${patient.registrationNo}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠️ Ada Dosis Obat Terlewat!',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.danger,
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'KRITIS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                      letterSpacing: 0.02,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientRowItem extends StatelessWidget {
  final String initials;
  final String name;
  final String id;
  final String schedule;
  final PatientStatus status;
  final VoidCallback onTap;

  const _PatientRowItem({
    required this.initials,
    required this.name,
    required this.id,
    required this.schedule,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusColor;
    String statusLabel;

    switch (status) {
      case PatientStatus.taken:
        statusBg = AppColors.success.withOpacity(0.15);
        statusColor = AppColors.success;
        statusLabel = 'SUDAH DIMINUM';
        break;
      case PatientStatus.late:
        statusBg = AppColors.warning.withOpacity(0.15);
        statusColor = AppColors.warning;
        statusLabel = 'BUTUH VERIFIKASI';
        break;
      case PatientStatus.notReported:
        statusBg = AppColors.statusNeutral.withOpacity(0.15);
        statusColor = AppColors.statusNeutral;
        statusLabel = 'BELUM MELAPOR';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceContainer,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  Text(
                    'ID: $id • Fase: $schedule',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  letterSpacing: 0.02,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}