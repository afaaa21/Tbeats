import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/app_data.dart';
import '../models/models.dart';
import '../widgets/medication_icon.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  int _selectedMonthIndex = 5; // Jun = index 5

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  final List<String> _dayLabels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

  @override
  Widget build(BuildContext context) {
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
              'Riwayat Pengobatan',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 4),
            const Text('Pantau tingkat kepatuhan Anda.',
                style: TextStyle(color: AppTheme.textGray, fontSize: 14)),
            const SizedBox(height: 16),

            // Month selector
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _months.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final isSelected = i == _selectedMonthIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMonthIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGreen
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        _months[i],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textGray,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Compliance card
            _buildComplianceCard(),
            const SizedBox(height: 16),

            // Weekly checklist
            _buildWeeklyChecklist(),
            const SizedBox(height: 16),

            // History list
            const Text(
              'Daftar Riwayat',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),
            ...AppData.historyList.map((h) => _buildHistoryItem(h)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Fixed: centered donut with alignment fix
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.successGreen),
                    strokeWidth: 8,
                  ),
                ),
                const Text(
                  '85%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendRow(AppTheme.successGreen, '24 Tepat Waktu'),
              const SizedBox(height: 8),
              _buildLegendRow(AppTheme.warningOrange, '3 Terlambat'),
              const SizedBox(height: 8),
              _buildLegendRow(AppTheme.errorRed, '1 Terlewat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildWeeklyChecklist() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Checklist Obat Hari Ini',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.textDark),
              ),
              const Text('Sabtu, 17 Jun',
                  style:
                      TextStyle(color: AppTheme.textGray, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          ...AppData.weeklyChecklist.entries.map((entry) {
            return _buildMedChecklist(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildMedChecklist(String medName, List<MedicationStatus?> statuses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.textDark)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return Column(
                children: [
                  Text(_dayLabels[i],
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textGray)),
                  const SizedBox(height: 4),
                  _buildDayDot(statuses[i]),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDot(MedicationStatus? status) {
    if (status == null) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
      );
    }
    switch (status) {
      case MedicationStatus.sudahDiminum:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              color: AppTheme.successGreen, shape: BoxShape.circle),
          child:
              const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        );
      case MedicationStatus.terlambat:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              color: AppTheme.warningOrange, shape: BoxShape.circle),
          child: const Icon(Icons.remove_rounded,
              color: Colors.white, size: 16),
        );
      case MedicationStatus.terlewat:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              color: AppTheme.errorRed, shape: BoxShape.circle),
          child:
              const Icon(Icons.close_rounded, color: Colors.white, size: 16),
        );
      default:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              color: Colors.grey.shade200, shape: BoxShape.circle),
        );
    }
  }

  Widget _buildHistoryItem(MedicationHistory h) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    Color statusColor;
    String statusLabel;
    Color statusBg;

    switch (h.status) {
      case MedicationStatus.sudahDiminum:
        statusColor = AppTheme.successGreen;
        statusLabel = 'SUDAH DIMINUM';
        statusBg = AppTheme.lightGreenBg;
        break;
      case MedicationStatus.terlambat:
        statusColor = AppTheme.warningOrange;
        statusLabel = 'TERLAMBAT';
        statusBg = AppTheme.lightOrange;
        break;
      case MedicationStatus.terlewat:
        statusColor = AppTheme.errorRed;
        statusLabel = 'TERLEWAT';
        statusBg = AppTheme.lightRed;
        break;
      default:
        statusColor = AppTheme.textGray;
        statusLabel = '-';
        statusBg = Colors.grey.shade100;
    }

    final dateStr =
        '${h.scheduledAt.day} ${months[h.scheduledAt.month - 1]} ${h.scheduledAt.year} • '
        '${h.scheduledAt.hour.toString().padLeft(2, '0')}:${h.scheduledAt.minute.toString().padLeft(2, '0')}';

    final reportStr = h.reportedAt != null
        ? 'Dilaporkan pada ${h.reportedAt!.hour.toString().padLeft(2, '0')}:${h.reportedAt!.minute.toString().padLeft(2, '0')}'
        : 'Tidak ada laporan';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          // Use medication icon instead of photo
          MedicationIcon(medicationName: h.medicationName, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: const TextStyle(
                        color: AppTheme.textGray, fontSize: 11)),
                const SizedBox(height: 4),
                Text('${h.medicationName} ${h.dose}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(reportStr,
                    style: const TextStyle(
                        color: AppTheme.textGray, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
