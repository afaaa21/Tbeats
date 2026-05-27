import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('Laporan'),
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.onPrimaryContainer), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month, color: AppColors.onPrimaryContainer), label: 'Jadwal'),
          NavigationDestination(icon: Icon(Icons.leaderboard_outlined), selectedIcon: Icon(Icons.leaderboard, color: AppColors.onPrimaryContainer), label: 'Laporan'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.onPrimaryContainer), label: 'Profil'),
        ],
        onDestinationSelected: (_) {},
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Rata-rata Kepatuhan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rata-rata Kepatuhan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 80, height: 80,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 0.82,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            color: AppColors.success,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ),
                          const Center(
                            child: Text(
                              '82%',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.success, fontFamily: 'PlusJakartaSans'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bulan ini', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'PlusJakartaSans')),
                          SizedBox(height: 4),
                          Text(
                            'Status Kepatuhan Baik. Target 85% sedikit lagi tercapai.',
                            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Wawasan Cepat
          Row(
            children: [
              Expanded(
                child: _QuickInsightCard(
                  icon: Icons.error,
                  iconColor: AppColors.danger,
                  borderColor: AppColors.danger,
                  value: '45',
                  label: 'Dosis Terlewat',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickInsightCard(
                  icon: Icons.warning,
                  iconColor: AppColors.warning,
                  borderColor: AppColors.warning,
                  value: '3',
                  label: 'Peringatan Mendesak',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tren Kepatuhan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tren Kepatuhan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans')),
                    Text('18 Okt - 24 Okt 2023', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'PlusJakartaSans')),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final d in [
                        ('Sen', 0.80), ('Sel', 0.65), ('Rab', 0.90),
                        ('Kam', 0.75), ('Jum', 0.85), ('Sab', 0.70), ('Min', 0.95)
                      ])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: FractionallySizedBox(
                                    heightFactor: d.$2,
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(d.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, fontFamily: 'PlusJakartaSans')),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ringkasan Bulanan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ringkasan Bulanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans')),
                const SizedBox(height: 16),
                _SummaryRow(icon: Icons.group_outlined, iconBg: AppColors.primary.withOpacity(0.1), iconColor: AppColors.primary, label: 'Total Pasien', value: '124'),
                const Divider(height: 24, color: AppColors.surfaceContainerHigh),
                _SummaryRow(icon: Icons.task_alt, iconBg: AppColors.success.withOpacity(0.1), iconColor: AppColors.success, label: 'Selesai Pengobatan', value: '12'),
                const Divider(height: 24, color: AppColors.surfaceContainerHigh),
                _SummaryRow(icon: Icons.person_add_outlined, iconBg: AppColors.secondaryContainer.withOpacity(0.2), iconColor: AppColors.secondary, label: 'Pasien Baru', value: '5'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: iconColor, fontFamily: 'PlusJakartaSans')),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'PlusJakartaSans')),
        ],
      ),
    );
  }
}

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
              width: 32, height: 32,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(99)),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans')),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans')),
      ],
    );
  }
}