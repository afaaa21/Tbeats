import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NurseProfileScreen extends StatelessWidget {
  const NurseProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TBeats'),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            child: const Text(
              'DL',
              style: TextStyle(
                color: AppColors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          // Profile Header
          Column(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Text(
                      'DL',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Dewi Lestari',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans'),
              ),
              const Text(
                'dewi.lestari@tbeats.health',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontFamily: 'PlusJakartaSans'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                  ),
                  child: const Column(
                    children: [
                      Text('5', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primaryContainer, fontFamily: 'PlusJakartaSans')),
                      Text('Pasien Aktif', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'PlusJakartaSans')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: AppColors.secondaryContainer, width: 4)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                  ),
                  child: Column(
                    children: const [
                      Text('42', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.secondary, fontFamily: 'PlusJakartaSans')),
                      Text('Verifikasi Bulan Ini', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'PlusJakartaSans'), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Info Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text('Informasi Personal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans')),
                ),
                Divider(height: 1, color: AppColors.surfaceContainer),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(icon: Icons.call_outlined, iconColor: AppColors.primaryContainer, label: 'Nomor Handphone', value: '+62 812 3456 7890'),
                      SizedBox(height: 16),
                      _InfoRow(icon: Icons.calendar_today_outlined, iconColor: AppColors.primaryContainer, label: 'Bergabung Sejak', value: '12 Januari 2023'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Monitor Pasien
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monitor Pasien', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans')),
              Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'PlusJakartaSans')),
            ],
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PatientChip(name: 'Budi S.', isAlert: false),
              _PatientChip(name: 'Siti Aminah', isAlert: false),
              _PatientChip(name: 'Andi Wijaya', isAlert: true),
              _PatientChip(name: 'Rina K.', isAlert: false),
              _PatientChip(name: 'Eko P.', isAlert: false),
            ],
          ),
          const SizedBox(height: 32),

          // Logout
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              shadowColor: AppColors.danger.withOpacity(0.3),
              elevation: 4,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar', style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'PlusJakartaSans')),
            Text(value, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans')),
          ],
        ),
      ],
    );
  }
}

class _PatientChip extends StatelessWidget {
  final String name;
  final bool isAlert;

  const _PatientChip({required this.name, required this.isAlert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAlert ? AppColors.danger.withOpacity(0.1) : AppColors.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isAlert ? AppColors.danger.withOpacity(0.2) : AppColors.primaryContainer.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: isAlert ? AppColors.danger : AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              color: isAlert ? AppColors.danger : AppColors.primaryContainer,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      ),
    );
  }
}