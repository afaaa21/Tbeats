import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/app_data.dart';
import '../models/models.dart';
import '../widgets/medication_icon.dart';
import 'jadwal_screen.dart';
import 'riwayat_screen.dart';
import 'profil_screen.dart';
import 'lapor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _BerandaTab(onNavigateToJadwal: () => setState(() => _selectedIndex = 1)),
      const JadwalScreen(),
      const RiwayatScreen(),
      const ProfilScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: AppTheme.textGray,
          selectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _BerandaTab extends StatefulWidget {
  final VoidCallback onNavigateToJadwal;
  const _BerandaTab({required this.onNavigateToJadwal});

  @override
  State<_BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<_BerandaTab> {
  @override
  Widget build(BuildContext context) {
    final patient = AppData.patient;
    final meds = AppData.todayMedications;
    final tepat = meds.where((m) => m.status == MedicationStatus.sudahDiminum).length;
    final telat = meds.where((m) => m.status == MedicationStatus.terlambat).length;
    final lewat = meds.where((m) => m.status == MedicationStatus.terlewat).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text('TBeats',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => _showNotifications(context),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppTheme.bgGray,
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Selamat pagi, ${patient.name.split(' ').first} 👋',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. Registrasi: ${patient.registrationNo}',
                      style: const TextStyle(
                          color: AppTheme.textGray, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Compliance card
              _buildCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: 0.85,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.successGreen),
                                strokeWidth: 7,
                              ),
                              const Center(
                                child: Text(
                                  '85%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
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
                                'Kepatuhan Minum Obat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('Bulan ini',
                                  style: TextStyle(
                                      color: AppTheme.textGray, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatChip(Icons.check_circle, '17 Tepat',
                            AppTheme.successGreen),
                        _buildStatChip(
                            Icons.warning_amber_rounded, '2 Telat', AppTheme.warningOrange),
                        _buildStatChip(
                            Icons.cancel_rounded, '1 Lewat', AppTheme.errorRed),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jadwal Hari Ini',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...meds.map((m) => _MedicationCard(
                    medication: m,
                    onTap: () => _onMedicationTap(context, m),
                  )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _onMedicationTap(BuildContext context, Medication med) {
    if (med.status == MedicationStatus.belumWaktunya) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LaporScreen(medication: med),
        ),
      ).then((_) => setState(() {}));
    } else if (med.status == MedicationStatus.terlambat ||
        med.status == MedicationStatus.belumDilaporkan) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LaporScreen(medication: med),
        ),
      ).then((_) => setState(() {}));
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _notifTile(Icons.medication_rounded, 'Rifampisin belum dilaporkan',
                'Jadwal 08:00 Pagi', AppTheme.warningOrange),
            _notifTile(Icons.cancel_rounded, 'Pirazinamid terlewat',
                'Jadwal 09:00 Pagi', AppTheme.errorRed),
          ],
        ),
      ),
    );
  }

  Widget _notifTile(IconData icon, String title, String sub, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: AppTheme.textGray)),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTap;

  const _MedicationCard({required this.medication, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: MedicationIcon(medicationName: medication.name),
        title: Text(
          medication.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
        ),
        subtitle: Text(
          '${medication.dose} • ${medication.schedule}',
          style: const TextStyle(color: AppTheme.textGray, fontSize: 13),
        ),
        trailing: _buildStatusWidget(context),
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context) {
    switch (medication.status) {
      case MedicationStatus.sudahDiminum:
        return _StatusChip('Sudah Diminum', AppTheme.successGreen,
            AppTheme.successGreen.withOpacity(0.12));
      case MedicationStatus.terlambat:
        return _StatusChip('Terlambat', AppTheme.warningOrange,
            AppTheme.warningOrange.withOpacity(0.12));
      case MedicationStatus.terlewat:
        return _StatusChip('Terlewat', AppTheme.errorRed,
            AppTheme.errorRed.withOpacity(0.12));
      case MedicationStatus.belumWaktunya:
      case MedicationStatus.belumDilaporkan:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Belum Waktunya',
                style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text('Lapor', style: TextStyle(fontSize: 13)),
            ),
          ],
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;

  const _StatusChip(this.label, this.textColor, this.bgColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
