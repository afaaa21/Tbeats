import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'beranda_page.dart';
import 'jadwal_page.dart';
import 'riwayat_page.dart';
import 'profil_page.dart';
import 'lapor_page.dart';
import '../../../../service/api_service.dart';
import '../../../../models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class PatientMainWrapper extends StatefulWidget {
  const PatientMainWrapper({super.key});
  @override
  State<PatientMainWrapper> createState() => _PatientMainWrapperState();
}

class _PatientMainWrapperState extends State<PatientMainWrapper> {
  int _idx = 0;
  final ApiService _apiService = ApiService();
  List<Medication> _meds = [];
  Timer? _medFetchTimer;
  Timer? _alarmTimer;
  int _reminderInterval = 30;
  final Set<String> _alertedKeys = {};

  @override
  void initState() {
    super.initState();
    _loadReminderInterval();
    _loadMeds();
    
    // Fetch medications every 30 seconds to keep synced in real-time
    _medFetchTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadMeds();
      _loadReminderInterval();
    });

    // Check system time matches medication jam_minum every 10 seconds
    _alarmTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkAlarm();
    });
  }

  @override
  void dispose() {
    _medFetchTimer?.cancel();
    _alarmTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadReminderInterval() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderInterval = prefs.getInt('reminder_interval_minutes') ?? 30;
  }

  Future<void> _loadMeds() async {
    try {
      final medsData = await _apiService.getJadwalObatKu();
      final loadedMeds = medsData.map((m) => Medication.fromSupabase(m)).toList();
      _meds = loadedMeds;
    } catch (_) {}
  }

  void _checkAlarm() {
    if (_meds.isEmpty) return;

    final now = DateTime.now();

    for (var m in _meds) {
      if (m.status == MedicationStatus.sudahDiminum) continue;

      // Pengingat susulan tidak perlu mengingatkan jika pasien sudah kirim foto tapi belum diverifikasi oleh perawat
      if (m.photoPath != null && m.photoPath!.isNotEmpty) continue;

      final medHour = m.time.hour;
      final medMin = m.time.minute;

      final scheduledTime = DateTime(now.year, now.month, now.day, medHour, medMin);
      final diffMins = now.difference(scheduledTime).inMinutes;

      if (diffMins < 0) continue;

      if (diffMins == 0 || (diffMins > 0 && diffMins % _reminderInterval == 0)) {
        final alertKey = "${m.id}_${now.hour}_${now.minute}";
        
        if (!_alertedKeys.contains(alertKey)) {
          _alertedKeys.add(alertKey);
          _showAlarmOverlay(m, diffMins);
        }
      }
    }
  }

  void _showAlarmOverlay(Medication med, int diffMins) {
    final bool isLate = diffMins > 0;
    final timeStr = "${med.time.hour.toString().padLeft(2, '0')}:${med.time.minute.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isLate ? AppColors.danger : AppColors.primaryContainer).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: (isLate ? AppColors.danger : AppColors.primaryContainer).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.8, end: 1.2),
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isLate ? AppColors.danger : AppColors.primaryContainer).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLate ? Icons.warning_rounded : Icons.notifications_active_rounded,
                            color: isLate ? AppColors.danger : AppColors.primary,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isLate ? 'PENGINGAT SUSULAN!' : 'WAKTUNYA MINUM OBAT!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: isLate ? AppColors.danger : AppColors.primary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    med.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosis: ${med.dose} • Jadwal: $timeStr WIB',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: (isLate ? AppColors.danger : AppColors.primaryContainer).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isLate
                          ? '⚠️ Anda terlambat selama $diffMins menit! Harap segera minum obat Anda.'
                          : '🔔 Waktunya telah tiba. Tetap disiplin demi kesembuhan Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLate ? AppColors.danger : AppColors.primaryContainer,
                        fontFamily: 'PlusJakartaSans',
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.outline.withOpacity(0.3)),
                            minimumSize: const Size(0, 48),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Tunda',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LaporPage(medication: med),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Lapor Sekarang',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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