import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/app_data.dart';
import '../models/models.dart';
import '../widgets/medication_icon.dart';
import 'lapor_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  @override
  Widget build(BuildContext context) {
    final meds = AppData.todayMedications;
    final belumDilaporkan =
        meds.where((m) => m.status == MedicationStatus.terlambat || m.status == MedicationStatus.belumDilaporkan).toList();
    final terlewat =
        meds.where((m) => m.status == MedicationStatus.terlewat).toList();
    final sudahDilaporkan =
        meds.where((m) => m.status == MedicationStatus.sudahDiminum).toList();
    final belumWaktu =
        meds.where((m) => m.status == MedicationStatus.belumWaktunya).toList();

    final now = DateTime.now();
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
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
      backgroundColor: AppTheme.bgGray,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jadwal Minum Obat',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}',
              style:
                  const TextStyle(color: AppTheme.textGray, fontSize: 14),
            ),
            const SizedBox(height: 20),

            if (belumDilaporkan.isNotEmpty) ...[
              _buildSectionHeader(
                  '● Belum Dilaporkan', AppTheme.warningOrange, belumDilaporkan.length),
              ...belumDilaporkan.map((m) => _buildJadwalCard(context, m, false)),
              const SizedBox(height: 16),
            ],

            if (belumWaktu.isNotEmpty) ...[
              _buildSectionHeader('● Belum Waktunya', Colors.grey, belumWaktu.length),
              ...belumWaktu.map((m) => _buildJadwalCard(context, m, false)),
              const SizedBox(height: 16),
            ],

            if (terlewat.isNotEmpty) ...[
              _buildSectionHeader(
                  '● Terlewat', AppTheme.errorRed, terlewat.length),
              ...terlewat.map((m) => _buildJadwalCard(context, m, true)),
              const SizedBox(height: 16),
            ],

            if (sudahDilaporkan.isNotEmpty) ...[
              _buildSectionHeader(
                  '● Sudah Dilaporkan', AppTheme.successGreen, sudahDilaporkan.length),
              ...sudahDilaporkan.map((m) => _buildDoneMedCard(m)),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(BuildContext context, Medication med, bool isSusulan) {
    final hour = med.time.hour.toString().padLeft(2, '0');
    final minute = med.time.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute ${med.schedule == 'Pagi' ? 'Pagi' : 'WIB'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MedicationIcon(medicationName: med.name, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textDark)),
                    Text('${med.dose} • $timeStr',
                        style: const TextStyle(
                            color: AppTheme.textGray, fontSize: 13)),
                  ],
                ),
              ),
              if (med.status == MedicationStatus.terlambat ||
                  med.status == MedicationStatus.belumDilaporkan)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '15 Menit Lagi',
                    style: TextStyle(
                        color: AppTheme.warningOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LaporScreen(medication: med)),
              ).then((_) => setState(() {})),
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
              label: Text(isSusulan ? 'Lapor Susulan' : 'Lapor Minum'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneMedCard(Medication med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.successGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textDark)),
                    Text(
                        '${med.dose} • ${med.time.hour.toString().padLeft(2, '0')}:${med.time.minute.toString().padLeft(2, '0')} Pagi',
                        style: const TextStyle(
                            color: AppTheme.textGray, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Selesai',
                    style: TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.image_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Tepat Waktu',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Dilaporkan 05:58',
                        style:
                            TextStyle(color: AppTheme.textGray, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
