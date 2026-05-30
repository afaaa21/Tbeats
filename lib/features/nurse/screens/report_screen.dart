import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // 0 = Mingguan, 1 = Bulanan
  int _periodIndex = 0;

  static const _weekData = [
    ('Sen', 0.80),
    ('Sel', 0.65),
    ('Rab', 0.90),
    ('Kam', 0.75),
    ('Jum', 0.85),
    ('Sab', 0.70),
    ('Min', 0.95),
  ];

  static const _monthData = [
    ('M1', 0.72),
    ('M2', 0.78),
    ('M3', 0.82),
    ('M4', 0.88),
  ];

  @override
  Widget build(BuildContext context) {
    final chartData = _periodIndex == 0 ? _weekData : _monthData;
    final periodLabel = _periodIndex == 0
        ? '18 Okt – 24 Okt 2025'
        : 'Oktober 2025';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {},
        ),
        title: const Text(
          'Laporan',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryContainer, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // ── Rata-rata Kepatuhan ────────────────────────────
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rata-rata Kepatuhan',
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
                    const SizedBox(
                      width: 88,
                      height: 88,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: CircularProgressIndicator(
                              value: 0.82,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              color: AppColors.success,
                              strokeWidth: 9,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text(
                            '82%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
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
                            'Bulan ini',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Status Kepatuhan Baik. Target 85% sedikit lagi tercapai.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontFamily: 'PlusJakartaSans',
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Progress bar tipis
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: const LinearProgressIndicator(
                              value: 0.82,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              color: AppColors.success,
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
          const Row(
            children: [
              Expanded(
                child: _QuickInsightCard(
                  icon: Icons.error_rounded,
                  iconColor: AppColors.danger,
                  borderColor: AppColors.danger,
                  value: '45',
                  label: 'Dosis Terlewat',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickInsightCard(
                  icon: Icons.warning_rounded,
                  iconColor: AppColors.warning,
                  borderColor: AppColors.warning,
                  value: '3',
                  label: 'Peringatan Mendesak',
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

                // Bar chart
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
                                  heightFactor: d.$2,
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
            ),
          ),
          const SizedBox(height: 12),

          // ── Ringkasan Bulanan ──────────────────────────────
          _buildCard(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Bulanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                SizedBox(height: 16),
                _SummaryRow(
                  icon: Icons.group_outlined,
                  iconBg: Color(0x1A005235),
                  iconColor: AppColors.primary,
                  label: 'Total Pasien',
                  value: '124',
                ),
                Divider(height: 20, color: AppColors.surfaceContainerHigh),
                _SummaryRow(
                  icon: Icons.task_alt_rounded,
                  iconBg: Color(0x1A27AE60),
                  iconColor: AppColors.success,
                  label: 'Selesai Pengobatan',
                  value: '12',
                ),
                Divider(height: 20, color: AppColors.surfaceContainerHigh),
                _SummaryRow(
                  icon: Icons.person_add_outlined,
                  iconBg: Color(0x1A006492),
                  iconColor: Color(0xFF006492),
                  label: 'Pasien Baru',
                  value: '5',
                ),
                Divider(height: 20, color: AppColors.surfaceContainerHigh),
                _SummaryRow(
                  icon: Icons.medication_outlined,
                  iconBg: Color(0x1AF2994A),
                  iconColor: AppColors.warning,
                  label: 'Total Dosis Terlewat',
                  value: '45',
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
                      child: const Text(
                        '3 kritis',
                        style: TextStyle(
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
                const _AttentionPatientRow(
                    initials: 'BS',
                    name: 'Budi Santoso',
                    missedDays: 3,
                    compliance: 42),
                const SizedBox(height: 10),
                const _AttentionPatientRow(
                    initials: 'AH',
                    name: 'Ani Haryati',
                    missedDays: 2,
                    compliance: 55),
                const SizedBox(height: 10),
                const _AttentionPatientRow(
                    initials: 'DK',
                    name: 'Dedi Kurniawan',
                    missedDays: 2,
                    compliance: 61),
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
                    content: Text('Fitur ekspor laporan segera hadir'),
                    behavior: SnackBarBehavior.floating,
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

  const _AttentionPatientRow({
    required this.initials,
    required this.name,
    required this.missedDays,
    required this.compliance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'Terlambat $missedDays hari • Kepatuhan $compliance%',
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
    );
  }
}