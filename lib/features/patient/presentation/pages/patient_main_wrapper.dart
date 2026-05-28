import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'beranda_page.dart';
import 'jadwal_page.dart';
import 'riwayat_page.dart';
import 'profil_page.dart';

class PatientMainWrapper extends StatefulWidget {
  const PatientMainWrapper({super.key});
  @override
  State<PatientMainWrapper> createState() => _PatientMainWrapperState();
}

class _PatientMainWrapperState extends State<PatientMainWrapper> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _idx,
        children: [
          BerandaPage(onGoToJadwal: () => setState(() => _idx = 1)),
          const JadwalPage(),
          const RiwayatPage(),
          const ProfilPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          )],
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryContainer,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Jadwal'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'Riwayat'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil'),
          ],
        ),
      ),
    );
  }
}