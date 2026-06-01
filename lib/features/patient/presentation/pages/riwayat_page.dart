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
  int _selectedYear = DateTime.now().year;
  late final List<int> _years;
  bool _isLoading = true;
  String? _error;
  bool _isWeekView = true;
  DateTime? _selectedCalendarDate;
  DateTime? _registrationDate;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  final List<String> _dayLabels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

  @override
  void initState() {
    super.initState();
    _years = [
      DateTime.now().year - 2,
      DateTime.now().year - 1,
      DateTime.now().year,
      DateTime.now().year + 1,
    ];
    _selectedCalendarDate = DateTime.now();
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

      final profileData = await _apiService.getProfileInfo();
      final patient = Patient.fromSupabase(profileData);
      final regDate = patient.startDate;

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
        _registrationDate = regDate;
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

  bool _isBeforeRegistration() {
    if (_registrationDate == null) return false;
    final year = _selectedYear;
    final month = _selectedMonthIndex + 1;

    if (year < _registrationDate!.year) return true;
    if (year == _registrationDate!.year && month < _registrationDate!.month) return true;
    return false;
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

    final year = _selectedYear;
    final selectedMonthHistory = _historyList.where((h) => h.scheduledAt.year == year && h.scheduledAt.month == _selectedMonthIndex + 1).toList();

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

              // View toggle: Minggu Ini vs Bulan Ini
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isWeekView = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isWeekView ? AppColors.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isWeekView
                                ? [BoxShadow(color: AppColors.primaryContainer.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Minggu Ini',
                              style: TextStyle(
                                color: _isWeekView ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _isWeekView = false;
                          // Inisialisasi tanggal terpilih di bulan ini
                          final now = DateTime.now();
                          if (_selectedMonthIndex + 1 == now.month && _selectedYear == now.year) {
                            _selectedCalendarDate = now;
                          } else {
                            _selectedCalendarDate = DateTime(_selectedYear, _selectedMonthIndex + 1, 1);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isWeekView ? AppColors.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isWeekView
                                ? [BoxShadow(color: AppColors.primaryContainer.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Bulan Ini',
                              style: TextStyle(
                                color: !_isWeekView ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (!_isWeekView) ...[
                // Year selector (Pop-up Card)
                const Text(
                  'Tahun',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showYearPickerDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tahun: $_selectedYear',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Month selector
                const Text(
                  'Bulan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _months.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final isSelected = i == _selectedMonthIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMonthIndex = i;
                            final now = DateTime.now();
                            if (i + 1 == now.month && _selectedYear == now.year) {
                              _selectedCalendarDate = now;
                            } else {
                              _selectedCalendarDate = DateTime(_selectedYear, i + 1, 1);
                            }
                          });
                        },
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

                if (_isBeforeRegistration()) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum terdaftar pada bulan ini',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Data pengobatan hanya tersedia setelah pembuatan akun.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!selectedMonthHistory.any((h) =>
                    h.status == MedicationStatus.sudahDiminum ||
                    h.status == MedicationStatus.terlambat ||
                    h.status == MedicationStatus.terlewat)) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada laporan pada bulan ini',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tidak ada data laporan minum obat pada bulan ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Compliance card (spesifik untuk bulan terpilih)
                  _buildComplianceCard(selectedMonthHistory),
                  const SizedBox(height: 16),

                  // Kalender Bulanan Kepatuhan
                  _buildCalendarViewCard(selectedMonthHistory),
                  const SizedBox(height: 20),

                  // List obat harian untuk tanggal terpilih
                  _buildSelectedDateMedsSection(),
                ],
              ] else ...[
                // Compliance card (akumulasi total)
                _buildComplianceCard(_historyList),
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
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceCard(List<MedicationHistory> history) {
    int tepat = 0;
    int telat = 0;
    int lewat = 0;

    for (var h in history) {
      if (h.status == MedicationStatus.sudahDiminum) {
        tepat++;
      } else if (h.status == MedicationStatus.terlambat) {
        telat++;
      } else if (h.status == MedicationStatus.terlewat) {
        lewat++;
      }
    }

    final total = tepat + telat + lewat;

    // Jika tidak ada data laporan sama sekali
    if (total == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belum Ada Riwayat Kepatuhan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tidak ada data laporan minum obat pada bulan ini.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'PlusJakartaSans',
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final compliance = (tepat + telat) / total;
    final pctString = '${(compliance * 100).round()}%';

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
                    value: compliance,
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
              _buildLegendRow(AppColors.success, '$tepat Tepat Waktu'),
              const SizedBox(height: 8),
              _buildLegendRow(AppColors.warning, '$telat Terlambat'),
              const SizedBox(height: 8),
              _buildLegendRow(AppColors.danger, '$lewat Terlewat'),
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

  Widget _buildCalendarViewCard(List<MedicationHistory> monthHistory) {
    final year = _selectedYear;
    final month = _selectedMonthIndex + 1;
    final totalDays = DateTime(year, month + 1, 0).day;
    final startWeekday = DateTime(year, month, 1).weekday; // 1 = Senin, 7 = Minggu
    final prefixEmptyCells = startWeekday - 1;
    final totalGridCells = prefixEmptyCells + totalDays;

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
              Expanded(
                child: Text(
                  'Kepatuhan - ${_months[_selectedMonthIndex]} $year',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Bulan Ini',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    _dayLabels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalGridCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < prefixEmptyCells) {
                return const SizedBox.shrink();
              }

              final day = index - prefixEmptyCells + 1;
              final cellDate = DateTime(year, month, day);

              final dayMeds = monthHistory.where((h) => 
                h.scheduledAt.year == year && 
                h.scheduledAt.month == month && 
                h.scheduledAt.day == day
              ).toList();

              final totalOnDay = dayMeds.length;
              final takenOnDay = dayMeds.where((h) => 
                h.status == MedicationStatus.sudahDiminum || 
                h.status == MedicationStatus.terlambat
              ).length;
              final dayPct = totalOnDay == 0 ? 0.0 : (takenOnDay / totalOnDay);

              final isSelected = _selectedCalendarDate != null &&
                  _selectedCalendarDate!.day == day &&
                  _selectedCalendarDate!.month == month &&
                  _selectedCalendarDate!.year == year;

              final isToday = cellDate.day == DateTime.now().day &&
                  cellDate.month == DateTime.now().month &&
                  cellDate.year == DateTime.now().year;

              Color bgColor;
              Color borderCol;
              Color textColor;

              if (totalOnDay == 0) {
                bgColor = Colors.grey.shade50;
                borderCol = Colors.grey.shade200;
                textColor = AppColors.textSecondary.withOpacity(0.6);
              } else if (dayPct == 1.0) {
                bgColor = AppColors.success.withOpacity(0.12);
                borderCol = AppColors.success.withOpacity(0.35);
                textColor = AppColors.success;
              } else if (dayPct >= 0.5) {
                bgColor = AppColors.warning.withOpacity(0.12);
                borderCol = AppColors.warning.withOpacity(0.35);
                textColor = AppColors.warning;
              } else {
                bgColor = AppColors.danger.withOpacity(0.12);
                borderCol = AppColors.danger.withOpacity(0.35);
                textColor = AppColors.danger;
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCalendarDate = cellDate;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: AppColors.primaryContainer, width: 2.2)
                        : Border.all(color: borderCol, width: 1.0),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryContainer.withOpacity(0.25),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ]
                        : (isToday
                            ? [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                )
                              ]
                            : []),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: (isSelected || isToday) ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.primaryContainer : textColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateMedsSection() {
    if (_selectedCalendarDate == null) {
      return const SizedBox.shrink();
    }

    final year = _selectedCalendarDate!.year;
    final month = _selectedCalendarDate!.month;
    final day = _selectedCalendarDate!.day;

    final selectedDayMeds = _historyList.where((h) =>
        h.scheduledAt.year == year &&
        h.scheduledAt.month == month &&
        h.scheduledAt.day == day).toList();

    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final indMonths = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateLabel = '${days[_selectedCalendarDate!.weekday - 1]}, $day ${indMonths[month - 1]} $year';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Laporan Obat Harian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              dateLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (selectedDayMeds.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.healing_outlined,
                  size: 40,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tidak ada jadwal atau riwayat obat pada tanggal ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...selectedDayMeds.map((h) => _buildHistoryItem(h)),
      ],
    );
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

  void _showYearPickerDialog(BuildContext context) {
    final textCtrl = TextEditingController(text: _selectedYear.toString());
    int tempSelectedYear = _selectedYear;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Pilih Tahun',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih dari daftar:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _years.map((y) {
                        final isSel = y == tempSelectedYear;
                        return ChoiceChip(
                          label: Text(
                            y.toString(),
                            style: TextStyle(
                              color: isSel ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: AppColors.primaryContainer,
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide(
                            color: isSel ? AppColors.primaryContainer : Colors.grey.shade200,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                tempSelectedYear = y;
                                textCtrl.text = y.toString();
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Atau input kustom:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: textCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 2026',
                        prefixIcon: Icon(Icons.edit_calendar_rounded, size: 20),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val.trim());
                        if (parsed != null && parsed >= 1900 && parsed <= 2100) {
                          setModalState(() {
                            tempSelectedYear = parsed;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final finalYear = int.tryParse(textCtrl.text.trim());
                    if (finalYear == null || finalYear < 1900 || finalYear > 2100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tahun tidak valid. Harap input tahun antara 1900 - 2100.'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedYear = finalYear;
                      final now = DateTime.now();
                      if (_selectedMonthIndex + 1 == now.month && finalYear == now.year) {
                        _selectedCalendarDate = now;
                      } else {
                        _selectedCalendarDate = DateTime(finalYear, _selectedMonthIndex + 1, 1);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
