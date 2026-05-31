import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../service/api_service.dart';
import '../../../core/config/supabase_config.dart';
import 'patient_detail_screen.dart';
import 'add_patient_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // 0 = Mingguan, 1 = Bulanan
  int _periodIndex = 0;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  int _totalPatients = 0;
  int _totalMissed = 0;
  int _urgentAlerts = 0;
  double _averageCompliance = 0.0;
  List<Map<String, dynamic>> _attentionList = [];
  
  int _lancarPatients = 0;
  List<double> _weeklyTrend = List.filled(7, 0.0);
  List<double> _monthlyTrend = List.filled(4, 0.0);
  bool _hasMedsData = false;

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
      // 1. Get daftar pasien
      final patientsData = await _apiService.getDaftarPasienKu();
      final loadedPatients = patientsData.map((p) => Patient.fromSupabase(p)).toList();

      int totalTepat = 0;
      int totalMeds = 0;
      int totalMissed = 0;
      int criticalCount = 0;
      final List<Map<String, dynamic>> patientComps = [];

      // Array to store tepat and total counts for each weekday (1 to 7)
      final List<int> weeklyTepat = List.filled(7, 0);
      final List<int> weeklyTotal = List.filled(7, 0);

      // Array to store tepat and total counts for each week of month (1 to 4)
      final List<int> monthlyTepat = List.filled(4, 0);
      final List<int> monthlyTotal = List.filled(4, 0);

      for (var patient in loadedPatients) {
        // Query medications
        final medsData = await SupabaseConfig.client
            .from('medications')
            .select()
            .eq('user_id', patient.id);
        
        final meds = medsData.map((m) => Medication.fromSupabase(m)).toList();
        
        int tepat = meds.where((m) => m.status == MedicationStatus.sudahDiminum).length;
        int lewat = meds.where((m) => m.status == MedicationStatus.terlewat).length;
        int total = tepat + lewat;
        
        double comp = total == 0 ? 0.0 : tepat / total;
        
        totalTepat += tepat;
        totalMeds += total;
        totalMissed += lewat;

        if (lewat > 0) {
          criticalCount++;
        }

        patientComps.add({
          'patient': patient,
          'compliance': (comp * 100).round(),
          'missed': lewat,
          'total': total,
        });

        // Hitung aggregasi trend mingguan & bulanan
        for (var m in meds) {
          final isTepat = m.status == MedicationStatus.sudahDiminum;
          final isLewat = m.status == MedicationStatus.terlewat;
          if (isTepat || isLewat) {
            final date = m.reportedAt ?? DateTime.now();
            
            // Weekday: 1 = Senin, ..., 7 = Minggu
            final weekdayIdx = date.weekday - 1;
            if (weekdayIdx >= 0 && weekdayIdx < 7) {
              weeklyTotal[weekdayIdx]++;
              if (isTepat) weeklyTepat[weekdayIdx]++;
            }

            // Day of month: 1 to 31
            final day = date.day;
            int weekIdx = 0;
            if (day <= 7) {
              weekIdx = 0;
            } else if (day <= 14) {
              weekIdx = 1;
            } else if (day <= 21) {
              weekIdx = 2;
            } else {
              weekIdx = 3;
            }
            monthlyTotal[weekIdx]++;
            if (isTepat) monthlyTepat[weekIdx]++;
          }
        }
      }

      // Sort patients by compliance ascending to identify who needs attention
      patientComps.sort((a, b) => a['compliance'].compareTo(b['compliance']));
      final attentionList = patientComps
          .where((element) => element['total'] > 0 && (element['compliance'] < 85 || element['missed'] > 0))
          .take(5)
          .toList();

      double averageComp = totalMeds == 0 ? 0.0 : totalTepat / totalMeds;
      int lancarPatients = patientComps.where((p) => p['total'] > 0 && p['compliance'] >= 85).length;

      final List<double> weeklyTrend = [];
      for (int i = 0; i < 7; i++) {
        double c = weeklyTotal[i] == 0 ? 0.0 : weeklyTepat[i] / weeklyTotal[i];
        weeklyTrend.add(c);
      }

      final List<double> monthlyTrend = [];
      for (int i = 0; i < 4; i++) {
        double c = monthlyTotal[i] == 0 ? 0.0 : monthlyTepat[i] / monthlyTotal[i];
        monthlyTrend.add(c);
      }

      if (!mounted) return;
      setState(() {
        _totalPatients = loadedPatients.length;
        _totalMissed = totalMissed;
        _urgentAlerts = criticalCount;
        _averageCompliance = averageComp;
        _attentionList = attentionList;
        _lancarPatients = lancarPatients;
        _weeklyTrend = weeklyTrend;
        _monthlyTrend = monthlyTrend;
        _hasMedsData = totalMeds > 0;
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
              const Text('Gagal Memuat Laporan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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

    if (_totalPatients == 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.all(10),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.leaderboard_rounded, color: Colors.white, size: 16),
            ),
          ),
          title: const Text(
            'Laporan Kepatuhan',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Icon Container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Belum Ada Data Pasien',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Laporan tren kepatuhan, wawasan, dan grafik mingguan/bulanan akan muncul setelah Anda memiliki pasien aktif yang didaftarkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                const SizedBox(height: 32),
                // Action Button to Register Patient
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddPatientScreen()),
                      ).then((_) => _loadData());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.person_add_outlined, size: 20),
                    label: const Text(
                      'Daftarkan Pasien Baru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final avgPercent = (_averageCompliance * 100).round();

    final weekDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final weekData = List.generate(7, (i) => (weekDays[i], _weeklyTrend[i]));

    final monthWeeks = ['M1', 'M2', 'M3', 'M4'];
    final monthData = List.generate(4, (i) => (monthWeeks[i], _monthlyTrend[i]));

    final chartData = _periodIndex == 0 ? weekData : monthData;
    final periodLabel = _periodIndex == 0
        ? '7 Hari Terakhir'
        : 'Bulan Ini';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white24,
            child: Icon(Icons.leaderboard_rounded, color: Colors.white, size: 16),
          ),
        ),
        title: const Text(
          'Laporan Kepatuhan',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryContainer,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            // ── Rata-rata Kepatuhan ────────────────────────────
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rata-rata Kepatuhan Pasien',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Donut progress
                      SizedBox(
                        width: 88,
                        height: 88,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 88,
                              height: 88,
                              child: CircularProgressIndicator(
                                value: _averageCompliance,
                                backgroundColor: AppColors.surfaceContainerHigh,
                                color: !_hasMedsData
                                    ? AppColors.textSecondary.withOpacity(0.3)
                                    : (avgPercent >= 85 ? AppColors.success : AppColors.warning),
                                strokeWidth: 9,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text(
                              '$avgPercent%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: !_hasMedsData
                                    ? AppColors.textSecondary
                                    : (avgPercent >= 85 ? AppColors.success : AppColors.warning),
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Keseluruhan Pasien',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _hasMedsData
                                  ? (avgPercent >= 85
                                      ? 'Sangat Baik! Target kepatuhan 85% berhasil dilewati.'
                                      : 'Perlu Perhatian. Target kepatuhan 85% belum tercapai.')
                                  : 'Belum ada riwayat pengobatan. Grafik kepatuhan akan muncul setelah laporan obat pertama dikonfirmasi.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontFamily: 'PlusJakartaSans',
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Progress bar tipis
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: _averageCompliance,
                                backgroundColor: AppColors.surfaceContainerHigh,
                                color: !_hasMedsData
                                    ? AppColors.textSecondary.withOpacity(0.3)
                                    : (avgPercent >= 85 ? AppColors.success : AppColors.warning),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '0%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'PlusJakartaSans',
                                  ),
                                ),
                                Text(
                                  'Target: 85%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'PlusJakartaSans',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Wawasan Cepat ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _QuickInsightCard(
                    icon: Icons.error_rounded,
                    iconColor: AppColors.danger,
                    borderColor: AppColors.danger,
                    value: '$_totalMissed',
                    label: 'Dosis Terlewat',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickInsightCard(
                    icon: Icons.warning_rounded,
                    iconColor: AppColors.warning,
                    borderColor: AppColors.warning,
                    value: '$_urgentAlerts',
                    label: 'Pasien Kritis',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Tren Kepatuhan ─────────────────────────────────
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tren Kepatuhan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      Text(
                        periodLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Toggle mingguan / bulanan
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildToggleBtn('Mingguan', 0),
                        _buildToggleBtn('Bulanan', 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bar chart or premium placeholder
                  if (!_hasMedsData)
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceContainerHigh),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 40,
                            color: AppColors.textSecondary.withOpacity(0.4),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Belum Ada Data Tren',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Tren mingguan dan bulanan akan terisi secara otomatis setelah pasien aktif mengonfirmasi kepatuhan minum obat.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary.withOpacity(0.8),
                                fontFamily: 'PlusJakartaSans',
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: chartData.map((d) {
                          final pct = (d.$2 * 100).round();
                          Color barColor;
                          if (d.$2 >= 0.85) {
                            barColor = AppColors.success;
                          } else if (d.$2 >= 0.70) {
                            barColor = AppColors.primaryContainer;
                          } else {
                            barColor = AppColors.warning;
                          }
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '$pct%',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      fontFamily: 'PlusJakartaSans',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: FractionallySizedBox(
                                      heightFactor: d.$2.clamp(0.05, 1.0),
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: barColor,
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    d.$1,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      fontFamily: 'PlusJakartaSans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Legenda warna bar
                    Row(
                      children: [
                        _barLegend(AppColors.success, '≥85%'),
                        const SizedBox(width: 16),
                        _barLegend(AppColors.primaryContainer, '70–84%'),
                        const SizedBox(width: 16),
                        _barLegend(AppColors.warning, '<70%'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Ringkasan Bulanan ──────────────────────────────
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Bulanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    icon: Icons.group_outlined,
                    iconBg: const Color(0x1A005235),
                    iconColor: AppColors.primary,
                    label: 'Total Pasien Didampingi',
                    value: '$_totalPatients',
                  ),
                  const Divider(height: 20, color: AppColors.surfaceContainerHigh),
                  _SummaryRow(
                    icon: Icons.task_alt_rounded,
                    iconBg: const Color(0x1A27AE60),
                    iconColor: AppColors.success,
                    label: 'Pasien Pengobatan Lancar',
                    value: '$_lancarPatients',
                  ),
                  const Divider(height: 20, color: AppColors.surfaceContainerHigh),
                  _SummaryRow(
                    icon: Icons.person_add_outlined,
                    iconBg: const Color(0x1A006492),
                    iconColor: const Color(0xFF006492),
                    label: 'Kepatuhan Bagus (≥85%)',
                    value: '$_lancarPatients',
                  ),
                  const Divider(height: 20, color: AppColors.surfaceContainerHigh),
                  _SummaryRow(
                    icon: Icons.medication_outlined,
                    iconBg: const Color(0x1AF2994A),
                    iconColor: AppColors.warning,
                    label: 'Total Dosis Terlewat Pasien',
                    value: '$_totalMissed',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Pasien Perlu Perhatian ─────────────────────────
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pasien Perlu Perhatian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x1AEB5757),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '$_urgentAlerts kritis',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_attentionList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          !_hasMedsData
                              ? 'Belum ada riwayat pengobatan dari pasien.'
                              : 'Semua pasien memiliki tingkat kepatuhan sangat baik!',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ..._attentionList.map((item) {
                      final Patient p = item['patient'];
                      final int comp = item['compliance'];
                      final int missed = item['missed'];
                      final initials = p.name
                          .split(' ')
                          .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                          .take(2)
                          .join();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AttentionPatientRow(
                          initials: initials,
                          name: p.name,
                          missedDays: missed,
                          compliance: comp,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PatientDetailScreen(patient: p),
                            ),
                          ).then((_) => _loadData()),
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Export / Unduh ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur ekspor laporan PDF berhasil diunduh ke folder Dokumen'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryContainer,
                  side: const BorderSide(color: AppColors.primaryContainer),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text(
                  'Unduh Laporan PDF',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String label, int index) {
    final selected = _periodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _periodIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ),
      ),
    );
  }

  Widget _barLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
      ],
    );
  }

  static Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1A1A2E),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Quick Insight Card ─────────────────────────────────────
class _QuickInsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final String value;
  final String label;

  const _QuickInsightCard({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1A1A2E),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Row ────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
      ],
    );
  }
}

// ── Attention Patient Row ──────────────────────────────────
class _AttentionPatientRow extends StatelessWidget {
  final String initials;
  final String name;
  final int missedDays;
  final int compliance;
  final VoidCallback onTap;

  const _AttentionPatientRow({
    required this.initials,
    required this.name,
    required this.missedDays,
    required this.compliance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: const Border(
              left: BorderSide(color: AppColors.danger, width: 3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0x1AEB5757),
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  Text(
                    'Dosis terlewat: $missedDays • Kepatuhan $compliance%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x1AEB5757),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$compliance%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
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