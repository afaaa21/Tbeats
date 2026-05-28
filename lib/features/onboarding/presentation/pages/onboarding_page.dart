import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.medication_rounded,
      iconColor: const Color(0xFF4CAF7D),
      title: 'Selamat Datang di TBeats',
      subtitle: 'Pendamping setia perjalanan pengobatan TBC Anda',
      description:
          'TBeats hadir untuk memastikan tidak ada satu pun dosis obat yang terlewat. Bersama, kita wujudkan pengobatan TBC yang tuntas.',
    ),
    _OnboardingData(
      icon: Icons.camera_alt_rounded,
      iconColor: AppColors.primaryContainer,
      title: 'Pantau Setiap Langkah Pengobatan',
      subtitle: 'Laporan harian yang mudah dan terpercaya',
      description:
          'Cukup foto obat sebelum diminum, dan laporan Anda langsung sampai ke perawat dan klinik. Jadwal obat tercatat rapi, riwayat kepatuhan selalu bisa dilihat kapan saja.',
    ),
    _OnboardingData(
      icon: Icons.group_rounded,
      iconColor: AppColors.primaryContainer,
      title: 'Sembuh Itu Perjalanan Bersama',
      subtitle: 'Kamu tidak sendirian dalam proses ini',
      description:
          'Perawat dan klinik Anda selalu memantau perkembangan di setiap langkah. TBC bisa disembuhkan — dan TBeats ada untuk menemanimu hingga tuntas.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _OnboardingPageWidget(data: _pages[i]),
          ),
          Positioned(
            top: 52,
            right: 24,
            child: TextButton(
              onPressed: _goToLogin,
              child: const Text('Lewati',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 16)),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primaryContainer
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Mulai Sekarang'
                            : 'Lanjut',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;

  _OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPageWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(data.icon, size: 90, color: data.iconColor),
          ),
          const SizedBox(height: 48),
          Text(data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Text(data.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: AppColors.primaryContainer)),
          const SizedBox(height: 16),
          Text(data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 160),
        ],
      ),
    );
  }
}