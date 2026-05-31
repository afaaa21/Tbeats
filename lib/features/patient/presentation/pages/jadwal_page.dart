import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/models.dart';
import '../../../../widgets/medication_icon.dart';
import '../../../../service/api_service.dart';
import 'tambah_obat_page.dart';
import 'lapor_page.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final ApiService _apiService = ApiService();
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
      final medsData = await _apiService.getJadwalObatKu();
      final loadedMeds = medsData.map((m) => Medication.fromSupabase(m)).toList();

      if (!mounted) return;
      setState(() {
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
              const Text('Gagal Memuat Jadwal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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

    final meds = _meds;
    final belumDilaporkan = meds
        .where((m) =>
            m.status == MedicationStatus.terlambat ||
            m.status == MedicationStatus.belumDilaporkan)
        .toList();
    final terlewat =
        meds.where((m) => m.status == MedicationStatus.terlewat).toList();
    final sudah =
        meds.where((m) => m.status == MedicationStatus.sudahDiminum).toList();
    final belumWaktu =
        meds.where((m) => m.status == MedicationStatus.belumWaktunya).toList();

    final now = DateTime.now();
    final days = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    final months = ['Januari','Februari','Maret','April','Mei','Juni',
        'Juli','Agustus','September','Oktober','November','Desember'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TambahObatPage()));
          if (result == true) _loadData();
        },
        backgroundColor: AppColors.primaryContainer,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
              const Text('Jadwal Minum Obat',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 20),

              if (meds.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text('Belum ada jadwal obat ditambahkan.', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),

              if (belumDilaporkan.isNotEmpty) ...[
                _sectionHeader('Belum Dilaporkan',
                    AppColors.warning, belumDilaporkan.length),
                ...belumDilaporkan
                    .map((m) => _jadwalCard(context, m, false)),
                const SizedBox(height: 16),
              ],

              if (belumWaktu.isNotEmpty) ...[
                _sectionHeader('Belum Waktunya',
                    AppColors.textSecondary, belumWaktu.length),
                ...belumWaktu.map((m) => _jadwalCard(context, m, false)),
                const SizedBox(height: 16),
              ],

              if (terlewat.isNotEmpty) ...[
                _sectionHeader('Terlewat', AppColors.danger, terlewat.length),
                ...terlewat.map((m) => _jadwalCard(context, m, true)),
                const SizedBox(height: 16),
              ],

              if (sudah.isNotEmpty) ...[
                _sectionHeader('Sudah Dilaporkan',
                    AppColors.success, sudah.length),
                ...sudah.map((m) => _doneCard(m)),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _jadwalCard(BuildContext context, Medication med, bool isSusulan) {
    final hour = med.time.hour.toString().padLeft(2, '0');
    final min = med.time.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MedicationIcon(medicationName: med.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${med.name} ${med.dose}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      '${med.schedule} • ${med.schedule == 'Pagi' ? 'Sebelum Makan' : 'Sebelum Tidur'}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isSusulan
                              ? AppColors.danger
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 3),
                        Text('$hour:$min WIB',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSusulan
                                  ? AppColors.danger
                                  : AppColors.warning,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: isSusulan
                ? OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => LaporPage(medication: med)),
                    ).then((_) => setState(() {})),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Lapor Susulan',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  )
                : ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => LaporPage(medication: med)),
                    ).then((_) => setState(() {})),
                    icon: const Icon(Icons.camera_alt_rounded, size: 16),
                    label: const Text('Lapor Minum',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _doneCard(Medication med) {
    final hour = med.time.hour.toString().padLeft(2, '0');
    final min = med.time.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${med.name} ${med.dose}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14,
                        color: AppColors.textPrimary,
                        decoration: TextDecoration.lineThrough)),
                Text('Selesai dilaporkan jam $hour:$min',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Selesai',
                style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}