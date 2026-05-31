import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../service/api_service.dart';
import '../../../../models/models.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final ApiService _apiService = ApiService();
  Patient? _patient;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final profileData = await _apiService.getProfileInfo();

      String perawatName = '';
      if (profileData['perawat_id'] != null) {
        try {
          final nurseProfile = await _apiService.getPasienDetail(profileData['perawat_id']);
          perawatName = nurseProfile['name'] ?? '';
        } catch (_) {}
      }

      profileData['perawat_name'] = perawatName;
      final loaded = Patient.fromSupabase(profileData);

      if (!mounted) return;
      setState(() {
        _patient = loaded;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryContainer)),
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
              const Text('Gagal Memuat Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _loadProfile, child: const Text('Coba Lagi')),
              ),
            ],
          ),
        ),
      );
    }

    final patient = _patient!;
    final initials = patient.name.split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    // Calculate treatment progress
    final now = DateTime.now();
    final daysPassed = now.difference(patient.startDate).inDays.clamp(0, patient.durationMonths * 30);
    final totalDays = patient.durationMonths * 30;
    final progressPct = totalDays == 0 ? 0.0 : daysPassed / totalDays;

    // Format dates
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final startStr = '${patient.startDate.day} ${months[patient.startDate.month - 1]} ${patient.startDate.year}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        title: const Text('TBeats'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppColors.primaryContainer,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Avatar
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primaryContainer,
                child: Text(initials,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Text(patient.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('ID Pasien: ${patient.patientId}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),

              // Kemajuan Pengobatan card
              _card(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kemajuan Pengobatan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('${(progressPct * 100).round()}%',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryContainer)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Hari ke-$daysPassed dari $totalDays',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPct.toDouble(),
                    minHeight: 10,
                    backgroundColor: AppColors.neutralLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // Informasi Akun
              _sectionTitle('Informasi Akun'),
              _card(children: [
                _infoRow(Icons.email_outlined, 'Email', patient.email),
                const SizedBox(height: 12),
                _infoRow(Icons.phone_outlined, 'No. Handphone', patient.phone.isEmpty ? '-' : patient.phone),
              ]),
              const SizedBox(height: 14),

              // Detail Pengobatan
              _sectionTitle('Detail Pengobatan'),
              _card(children: [
                _infoRow(Icons.calendar_today_outlined, 'Mulai Pengobatan', startStr),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _miniCard('Durasi', '${patient.durationMonths} Bulan'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _miniCard('Fase Aktif', patient.phase, highlight: true),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 14),

              // Perawat Pendamping
              if (patient.nurseName.isNotEmpty) ...[
                _card(children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.teal.shade50,
                        child: Icon(Icons.person_rounded, color: Colors.teal.shade400, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(patient.nurseName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                          const Text('Perawat Pendamping',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ]),
                      ),
                      GestureDetector(
                        onTap: () => _showCallDialog(patient.nurseName),
                        child: Container(
                          width: 42, height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 14),
              ],

              // Keluar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmLogout(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Keluar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger.withOpacity(0.1),
                    foregroundColor: AppColors.danger,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: AppColors.primaryContainer, size: 20),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
      ]),
    ]);
  }

  Widget _miniCard(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primaryContainer.withOpacity(0.08) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
          style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 16,
            color: highlight ? AppColors.primaryContainer : AppColors.textPrimary)),
      ]),
    );
  }

  void _showCallDialog(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hubungi Perawat'),
        content: Text('Menghubungi $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Telepon', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              try { await ApiService().logout(); } catch (e) { debugPrint('Gagal logout: $e'); }
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
