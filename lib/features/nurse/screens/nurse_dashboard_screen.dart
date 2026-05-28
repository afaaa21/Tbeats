import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';
import 'report_screen.dart';
import 'nurse_profile_screen.dart';

class NurseDashboardScreen extends StatefulWidget {
  const NurseDashboardScreen({super.key});

  @override
  State<NurseDashboardScreen> createState() => _NurseDashboardScreenState();
}

class _NurseDashboardScreenState extends State<NurseDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    const _DashboardContent(),
    const _PatientsContent(),
    const _ReportContent(),
    const NurseProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPatientScreen()),
              ),
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              icon: const Icon(Icons.add),
              label: const Text(
                'Tambah Pasien',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.onPrimaryContainer),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group, color: AppColors.onPrimaryContainer),
            label: 'Pasien',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard, color: Colors.white),
            label: 'Laporan',               // ← tab baru
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.onPrimaryContainer),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TBeats'),
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDWzKJ3RpI6FWh1tLVr8S4E64b1fDVDmJxGLf1aRlpb1RcILptu_lUfDGQUBv9fzlNinqj9y1b_gVIRJdwu7Fyem6WW-7CJbgL-hhrDr9V20IJMHrn93sgXU7KbVL-X8pUbfDbIWLLVnmJNipfYXyp3Xq_KqKhKSoAB9D9aSjld7wMfk9LEBx5Tefhw8JU1HqTUsLQr2GOZNM81KDH4H1PGhudBd6pFEwSWSlKJUwNlKICT484B9r8_bGnXcGVYquL86fuWlzfH31QI',
            ),
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
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          // Greeting Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat pagi, Ns. Dewi 👋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Anda memiliki 5 pasien aktif',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xCCFFFFFF),
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Alert Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: AppColors.danger, width: 4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_outlined, color: AppColors.danger, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onErrorContainer,
                        fontFamily: 'PlusJakartaSans',
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '2 pasien belum melapor 2+ hari. ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: 'Segera tindak lanjuti untuk memastikan kepatuhan pengobatan.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pasien Kritis
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pasien Kritis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CriticalPatientCard(
                  initials: 'BS',
                  name: 'Budi Santoso',
                  id: '00412',
                  daysLate: 3,
                ),
                SizedBox(width: 16),
                _CriticalPatientCard(
                  initials: 'AH',
                  name: 'Ani Haryati',
                  id: '00455',
                  daysLate: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Semua Pasien
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semua Pasien',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
              Row(
                children: [
                  Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                  SizedBox(width: 8),
                  Icon(Icons.filter_list, color: AppColors.textSecondary, size: 22),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PatientRowItem(
            initials: 'MS',
            name: 'M. Saputra',
            id: '00501',
            schedule: 'Pagi',
            status: PatientStatus.taken,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientDetailScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _PatientRowItem(
            initials: 'RP',
            name: 'Rina Putri',
            id: '00508',
            schedule: 'Sore',
            status: PatientStatus.late,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientDetailScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _PatientRowItem(
            initials: 'DF',
            name: 'Dedi Faisal',
            id: '00512',
            schedule: 'Pagi',
            status: PatientStatus.notReported,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _PatientsContent extends StatelessWidget {
  const _PatientsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pasien')),
      body: const Center(child: Text('Daftar Pasien')),
    );
  }
}

class _ReportContent extends StatelessWidget {
  const _ReportContent();

  @override
  Widget build(BuildContext context) {
    return const ReportScreen();
  }
}

enum PatientStatus { taken, late, notReported }

class _CriticalPatientCard extends StatelessWidget {
  final String initials;
  final String name;
  final String id;
  final int daysLate;

  const _CriticalPatientCard({
    required this.initials,
    required this.name,
    required this.id,
    required this.daysLate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.danger, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.errorContainer,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  Text(
                    'ID: $id',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '⚠️ Terlambat: $daysLate Hari',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.danger,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'TERLEWAT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                    letterSpacing: 0.02,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatientRowItem extends StatelessWidget {
  final String initials;
  final String name;
  final String id;
  final String schedule;
  final PatientStatus status;
  final VoidCallback onTap;

  const _PatientRowItem({
    required this.initials,
    required this.name,
    required this.id,
    required this.schedule,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusColor;
    String statusLabel;

    switch (status) {
      case PatientStatus.taken:
        statusBg = AppColors.success.withOpacity(0.15);
        statusColor = AppColors.success;
        statusLabel = 'SUDAH DIMINUM';
        break;
      case PatientStatus.late:
        statusBg = AppColors.warning.withOpacity(0.15);
        statusColor = AppColors.warning;
        statusLabel = 'TERLAMBAT';
        break;
      case PatientStatus.notReported:
        statusBg = AppColors.statusNeutral.withOpacity(0.15);
        statusColor = AppColors.statusNeutral;
        statusLabel = 'BELUM MELAPOR';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceContainer,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  Text(
                    'ID: $id • $schedule',
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  letterSpacing: 0.02,
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