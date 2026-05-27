import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'report_detail_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bambang Sugiantoro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              'TBC-2026-038291',
              style: TextStyle(fontSize: 12, color: Color(0xCCFFFFFF)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Bukti Hari Ini'),
            Tab(text: 'Riwayat 7 Hari'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TodayEvidenceTab(context: context),
          const _WeekHistoryTab(),
        ],
      ),
    );
  }
}

class _TodayEvidenceTab extends StatelessWidget {
  final BuildContext context;
  const _TodayEvidenceTab({required this.context});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Patient Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: AppColors.warning, width: 4)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceContainer,
                child: const Text(
                  'BS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bambang Sugiantoro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                    Text(
                      'Terdaftar sejak 12 Jan 2024',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'INTENSIF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Verifikasi Obat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
            Text(
              '3 Jenis Obat',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Obat 1 - Verified
        _MedicineVerificationCard(
          medicineName: 'Isoniazid',
          status: MedicineStatus.verified,
          time: '07:15 WIB',
          imageUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportDetailScreen()),
          ),
        ),
        const SizedBox(height: 12),

        // Obat 2 - Needs Verification
        _MedicineVerificationCard(
          medicineName: 'Rifampisin',
          status: MedicineStatus.needsVerification,
          time: '10:45 WIB',
          imageUrl:
              'https://images.unsplash.com/photo-1550572017-edd951b55104?w=400',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportDetailScreen()),
          ),
        ),
        const SizedBox(height: 12),

        // Obat 3 - Missed
        _MedicineVerificationCard(
          medicineName: 'Pirazinamid',
          status: MedicineStatus.missed,
          time: null,
          imageUrl: null,
          onTap: null,
        ),
      ],
    );
  }
}

class _WeekHistoryTab extends StatelessWidget {
  const _WeekHistoryTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Riwayat 7 Hari'));
  }
}

enum MedicineStatus { verified, needsVerification, missed }

class _MedicineVerificationCard extends StatelessWidget {
  final String medicineName;
  final MedicineStatus status;
  final String? time;
  final String? imageUrl;
  final VoidCallback? onTap;

  const _MedicineVerificationCard({
    required this.medicineName,
    required this.status,
    required this.time,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    Color statusBg;

    switch (status) {
      case MedicineStatus.verified:
        statusColor = AppColors.success;
        statusLabel = 'Tepat Waktu';
        statusIcon = Icons.check_circle_outline;
        statusBg = AppColors.success.withOpacity(0.1);
        break;
      case MedicineStatus.needsVerification:
        statusColor = AppColors.warning;
        statusLabel = 'Butuh Verifikasi';
        statusIcon = Icons.warning_outlined;
        statusBg = AppColors.warning.withOpacity(0.1);
        break;
      case MedicineStatus.missed:
        statusColor = AppColors.danger;
        statusLabel = 'Terlewat';
        statusIcon = Icons.cancel_outlined;
        statusBg = AppColors.danger.withOpacity(0.1);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicineName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                    if (time != null)
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: status == MedicineStatus.verified
                                  ? AppColors.success.withOpacity(0.15)
                                  : AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status == MedicineStatus.verified ? 'SUDAH DIMINUM' : 'TERLAMBAT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: status == MedicineStatus.verified
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                          ),
                          Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Text(
                            time!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: const [
                          Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'Belum lapor',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (imageUrl != null)
            GestureDetector(
              onTap: onTap,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      imageUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (status == MedicineStatus.verified)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: AppColors.success, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Sudah Diverifikasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                    fontFamily: 'PlusJakartaSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_photography_outlined, color: AppColors.outline, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada foto bukti diunggah',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.outline,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ),

          if (status == MedicineStatus.needsVerification)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
                        backgroundColor: AppColors.danger.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text(
                        'Laporkan',
                        style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Konfirmasi',
                        style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (status == MedicineStatus.missed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tandai Terlewat',
                    style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}