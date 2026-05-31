import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/models.dart';
import '../../../../widgets/medication_icon.dart';
import '../../../../service/api_service.dart';
import '../../../../core/config/supabase_config.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});
  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final ApiService _apiService = ApiService();
  List<MedicationHistory> _historyList = [];
  Map<String, List<MedicationStatus?>> _weeklyChecklist = {};
  int _selectedMonthIndex = DateTime.now().month - 1;
  bool _isLoading = true;
  String? _error;
  int _tepatCount = 0;
  int _telatCount = 0;
  int _lewatCount = 0;
  double _complianceRate = 0.0;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  final List<String> _dayLabels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

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
      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser == null) throw 'Sesi tidak ditemukan.';

      final historyData = await _apiService.getHistoryMedication(currentUser.id);
      final loadedHistory = historyData.map((h) => MedicationHistory.fromSupabase(h)).toList();

      final weekData = await _apiService.getMedicationsThisWeek(currentUser.id);
      final weekMeds = weekData.map((m) => Medication.fromSupabase(m)).toList();

      int tepat = 0;
      int telat = 0;
      int lewat = 0;

      for (var h in loadedHistory) {
        if (h.status == MedicationStatus.sudahDiminum) {
          tepat++;
        } else if (h.status == MedicationStatus.terlambat) {
          telat++;
        } else if (h.status == MedicationStatus.terlewat) {
          lewat++;
        }
      }

      final total = tepat + telat + lewat;
      final compliance = total == 0 ? 1.0 : (tepat + telat) / total;

      final now = DateTime.now();
      final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));

      final Map<String, Map<int, MedicationStatus>> medDayMap = {};
      for (var m in weekMeds) {
        if (m.createdAt == null) continue;
        final dayIndex = m.createdAt!.toLocal().difference(monday).inDays;
        if (dayIndex < 0 || dayIndex > 6) continue;
        final key = "${m.name} (${m.dose})";
        medDayMap.putIfAbsent(key, () => {});
        medDayMap[key]![dayIndex] = m.status;
      }

      final Map<String, List<MedicationStatus?>> checklist = {};
      for (var entry in medDayMap.entries) {
        checklist[entry.key] = List.generate(7, (i) => entry.value[i]);
      }

      if (!mounted) return;
      setState(() {
        _historyList = loadedHistory;
        _weeklyChecklist = checklist;
        _tepatCount = tepat;
        _telatCount = telat;
        _lewatCount = lewat;
        _complianceRate = compliance;
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
              const Text('Gagal Memuat Riwayat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
        onRefresh: _loadData,
        color: AppColors.primaryContainer,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Riwayat Pengobatan',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text('Pantau tingkat kepatuhan Anda.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
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
                              ? AppColors.primaryContainer
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          _months[i],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
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
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              if (_historyList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Belum ada riwayat pelaporan minum obat.', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              else
                ..._historyList.map((h) => _buildHistoryItem(h)),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceCard() {
    final pctString = '${(_complianceRate * 100).round()}%';

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
                    value: _complianceRate,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.success),
                    strokeWidth: 8,
                  ),
                ),
                Text(
                  pctString,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendRow(AppColors.success, '$_tepatCount Tepat Waktu'),
              const SizedBox(height: 8),
              _buildLegendRow(AppColors.warning, '$_telatCount Terlambat'),
              const SizedBox(height: 8),
              _buildLegendRow(AppColors.danger, '$_lewatCount Terlewat'),
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
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildWeeklyChecklist() {
    final now = DateTime.now();
    final days = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final dateLabel = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

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
                    color: AppColors.textPrimary),
              ),
              Text(dateLabel,
                  style:
                      const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          if (_weeklyChecklist.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text('Belum ada checklist obat.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          else
            ..._weeklyChecklist.entries.map((entry) {
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return Column(
                children: [
                  Text(_dayLabels[i],
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
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
              color: AppColors.success, shape: BoxShape.circle),
          child:
              const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        );
      case MedicationStatus.terlambat:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              color: AppColors.warning, shape: BoxShape.circle),
          child: const Icon(Icons.remove_rounded,
              color: Colors.white, size: 16),
        );
      case MedicationStatus.terlewat:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              color: AppColors.danger, shape: BoxShape.circle),
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
        statusColor = AppColors.success;
        statusLabel = 'SUDAH DIMINUM';
        statusBg = AppColors.successLight;
        break;
      case MedicationStatus.terlambat:
        statusColor = AppColors.warning;
        statusLabel = 'TERLAMBAT';
        statusBg = AppColors.warningLight;
        break;
      case MedicationStatus.terlewat:
        statusColor = AppColors.danger;
        statusLabel = 'TERLEWAT';
        statusBg = AppColors.dangerLight;
        break;
      default:
        statusColor = AppColors.textSecondary;
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
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                Text('${h.medicationName} ${h.dose}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(reportStr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
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
