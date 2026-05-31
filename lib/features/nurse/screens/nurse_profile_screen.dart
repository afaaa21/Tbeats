import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../service/api_service.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../../models/models.dart';

class NurseProfileScreen extends StatefulWidget {
  const NurseProfileScreen({super.key});

  @override
  State<NurseProfileScreen> createState() => _NurseProfileScreenState();
}

class _NurseProfileScreenState extends State<NurseProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  String _nurseName = "Dewi Lestari";
  String _nurseEmail = "dewi.lestari@tbeats.health";
  String _nursePhone = "+62 812 3456 7890";
  List<Patient> _patients = [];
  int _verifikasiCount = 0;
  String _bergabungSejak = '';
  String _clinicName = 'Puskesmas Kecamatan';
  String _clinicAddress = 'Jl. Kesehatan No. 123';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _apiService.getProfileInfo();
      final patientsData = await _apiService.getDaftarPasienKu();
      final loadedPatients = patientsData
          .map((p) => Patient.fromSupabase(p))
          .toList();
      final verif = await _apiService.getVerifikasiCountBulanIni();

      // Parse created_at for bergabung sejak
      String bergabung = '';
      if (profile['created_at'] != null) {
        final dt = DateTime.parse(profile['created_at']);
        const months = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];
        bergabung = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }

      if (!mounted) return;
      setState(() {
        _nurseName = profile['name'] ?? 'Dewi Lestari';
        _nurseEmail = profile['email'] ?? '';
        _nursePhone = profile['phone'] ?? '';
        _patients = loadedPatients;
        _verifikasiCount = verif;
        _bergabungSejak = bergabung;
        _clinicName = profile['clinic_name'] ?? 'Puskesmas Kecamatan';
        _clinicAddress = profile['clinic_address'] ?? 'Jl. Kesehatan No. 123';
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
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadProfile,
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final initials = _nurseName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TBeats'),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          // Profile Header
          Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _nurseName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
              Text(
                _nurseEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: AppColors.primary, width: 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_patients.length}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryContainer,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      const Text(
                        'Pasien Aktif',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(
                        color: AppColors.secondaryContainer,
                        width: 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_verifikasiCount',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      const Text(
                        'Verifikasi Bulan Ini',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Info Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(
                    'Informasi Personal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.surfaceContainer),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.call_outlined,
                        iconColor: AppColors.primaryContainer,
                        label: 'Nomor Handphone',
                        value: _nursePhone,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        iconColor: AppColors.primaryContainer,
                        label: 'Bergabung Sejak',
                        value: _bergabungSejak.isNotEmpty
                            ? _bergabungSejak
                            : '-',
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.local_hospital_outlined,
                        iconColor: AppColors.primaryContainer,
                        label: 'Nama Faskes',
                        value: _clinicName,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        iconColor: AppColors.primaryContainer,
                        label: 'Alamat Faskes',
                        value: _clinicAddress,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Monitor Pasien
          if (_patients.isNotEmpty) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monitor Pasien',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _patients.map<Widget>((p) {
                return _PatientChip(name: p.name, isAlert: false);
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // Logout
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await _apiService.logout();
              } catch (e) {
                debugPrint("Gagal logout perawat: $e");
              }
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: AppColors.danger.withOpacity(0.3),
              elevation: 4,
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatientChip extends StatelessWidget {
  final String name;
  final bool isAlert;

  const _PatientChip({required this.name, required this.isAlert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAlert
            ? AppColors.danger.withOpacity(0.1)
            : AppColors.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isAlert
              ? AppColors.danger.withOpacity(0.2)
              : AppColors.primaryContainer.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isAlert ? AppColors.danger : AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              color: isAlert ? AppColors.danger : AppColors.primaryContainer,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      ),
    );
  }
}
