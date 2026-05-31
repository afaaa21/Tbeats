import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/models.dart';
import '../../../../widgets/medication_icon.dart';
import '../../../../service/api_service.dart';
import 'lapor_page.dart';

class BerandaPage extends StatefulWidget {
  final VoidCallback onGoToJadwal;
  const BerandaPage({super.key, required this.onGoToJadwal});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final ApiService _apiService = ApiService();
  Patient? _patient;
  List<Medication> _meds = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profileData = await _apiService.getProfileInfo();
      
      String perawatName = "Ns. Dewi Lestari";
      if (profileData['perawat_id'] != null) {
        try {
          final nurseProfile = await _apiService.getPasienDetail(profileData['perawat_id']);
          perawatName = nurseProfile['name'] ?? perawatName;
        } catch (_) {}
      }
      
      profileData['perawat_name'] = perawatName;
      final loadedPatient = Patient.fromSupabase(profileData);

      final medsData = await _apiService.getJadwalObatKu();
      final loadedMeds = medsData.map((m) => Medication.fromSupabase(m)).toList();

      if (!mounted) return;
      setState(() {
        _patient = loadedPatient;
        _meds = loadedMeds;
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
              const Text('Gagal Memuat Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final patient = _patient!;
    final meds = _meds;
    final tepat = meds.where((m) => m.status == MedicationStatus.sudahDiminum).length;
    final telat = meds.where((m) => m.status == MedicationStatus.terlambat).length;
    final lewat = meds.where((m) => m.status == MedicationStatus.terlewat).length;
    final hasMissed = lewat > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('TBeats'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => _showNotifications(context),
              ),
              if (hasMissed)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(
                        color: AppColors.danger, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryContainer,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat, ${patient.name.split(' ').first} 👋',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text('ID Pasien: ${patient.patientId}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('Tetap semangat menjalani pengobatan hari ini!',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),

              // Alert banner jika ada yang terlewat
              if (hasMissed) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Anda telah melewatkan obat $lewat kali. Segera hubungi perawat Anda.',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Progress card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kemajuan Pengobatan',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          width: 80, height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: tepat / (meds.isEmpty ? 1 : meds.length),
                                backgroundColor: AppColors.neutralLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.success),
                                strokeWidth: 7,
                              ),
                              Text(
                                '${meds.isEmpty ? 0 : (tepat * 100 ~/ meds.length)}%',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700,
                                    color: AppColors.primaryContainer),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Anda berada di jalur yang benar!',
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              SizedBox(height: 4),
                              Text('Selesaikan sisa dosis bulan ini.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.neutralLight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statChip(Icons.check_circle_rounded,
                            '$tepat Tepat Waktu', AppColors.success),
                        _statChip(Icons.access_time_rounded,
                            '$telat Terlambat', AppColors.warning),
                        _statChip(Icons.cancel_rounded,
                            '$lewat Terlewat', AppColors.danger),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jadwal Hari Ini',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  GestureDetector(
                    onTap: widget.onGoToJadwal,
                    child: const Text('Lihat Semua',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.primaryContainer)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (meds.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text('Belum ada jadwal obat hari ini.', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              else
                ...meds.map((m) => _MedCard(
                      med: m,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LaporPage(medication: m)),
                      ).then((_) => _loadData()),
                    )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _notifTile(Icons.medication_rounded,
                'Rifampisin belum dilaporkan', 'Jadwal 08:00', AppColors.warning),
            _notifTile(Icons.cancel_rounded,
                'Pirazinamid terlewat', 'Jadwal 09:00', AppColors.danger),
          ],
        ),
      ),
    );
  }

  Widget _notifTile(IconData icon, String title, String sub, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color)),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(sub,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    );
  }
}

class _MedCard extends StatelessWidget {
  final Medication med;
  final VoidCallback onTap;
  const _MedCard({required this.med, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hour = med.time.hour.toString().padLeft(2, '0');
    final min = med.time.minute.toString().padLeft(2, '0');
    final borderColor = _borderColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: MedicationIcon(medicationName: med.name),
            title: Text(med.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15,
                    color: AppColors.textPrimary)),
            subtitle: Text('$hour:$min • ${med.dose}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            trailing: _statusWidget(),
          ),
          if (med.status == MedicationStatus.terlambat ||
              med.status == MedicationStatus.belumDilaporkan)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.camera_alt_rounded, size: 16),
                  label: const Text('Lapor'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero),
                ),
              ),
            ),
          if (med.status == MedicationStatus.terlewat)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Lapor Susulan'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _borderColor() {
    switch (med.status) {
      case MedicationStatus.sudahDiminum:
        return AppColors.success;
      case MedicationStatus.terlambat:
      case MedicationStatus.belumDilaporkan:
        return AppColors.warning;
      case MedicationStatus.terlewat:
        return AppColors.danger;
      case MedicationStatus.belumWaktunya:
        return AppColors.neutralLight;
    }
  }

  Widget _statusWidget() {
    switch (med.status) {
      case MedicationStatus.sudahDiminum:
        return _chip('Sudah Diminum', AppColors.success, AppColors.successLight);
      case MedicationStatus.terlambat:
        return _chip('Terlambat', AppColors.warning, AppColors.warningLight);
      case MedicationStatus.terlewat:
        return _chip('Terlewat', AppColors.danger, AppColors.dangerLight);
      case MedicationStatus.belumWaktunya:
      case MedicationStatus.belumDilaporkan:
        return _chip('Belum Waktunya', AppColors.textSecondary,
            AppColors.neutralLight);
    }
  }

  Widget _chip(String label, Color text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: text, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}