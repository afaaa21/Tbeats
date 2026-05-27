import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.medication_rounded,
      iconColor: const Color(0xFF4CAF7D),
      title: 'Selamat Datang di TBeats',
      subtitle: 'Pendamping setia perjalanan pengobatan TBC Anda',
      description:
          'TBeats hadir untuk memastikan tidak ada satu pun dosis obat yang terlewat. Bersama, kita wujudkan pengobatan TBC yang tuntas.',
      isLast: false,
    ),
    _OnboardingPage(
      icon: Icons.camera_alt_rounded,
      iconColor: const Color(0xFF1B5E37),
      title: 'Pantau Setiap Langkah Pengobatan',
      subtitle: 'Laporan harian yang mudah dan terpercaya',
      description:
          'Cukup foto obat sebelum diminum, dan laporan Anda langsung sampai ke perawat dan klinik. Jadwal obat tercatat rapi, riwayat kepatuhan selalu bisa dilihat kapan saja.',
      isLast: false,
    ),
    _OnboardingPage(
      icon: Icons.group_rounded,
      iconColor: const Color(0xFF1B5E37),
      title: 'Sembuh Itu Perjalanan Bersama',
      subtitle: 'Kamu tidak sendirian dalam proses ini',
      description:
          'Perawat dan klinik Anda selalu memantau perkembangan di setiap langkah. TBC bisa disembuhkan — dan TBeats ada untuk menemanimu hingga tuntas.',
      isLast: true,
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
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgGray,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _OnboardingPageWidget(page: _pages[i]),
          ),
          // Skip button
          Positioned(
            top: 52,
            right: 24,
            child: TextButton(
              onPressed: _goToLogin,
              child: Text(
                'Lewati',
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots
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
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Mulai Sekarang'
                            : 'Lanjut',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
  final bool isLast;

  _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isLast,
  });
}

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          // Icon circle
          Container(
            width: 180,
            height: 180,
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
            child: Icon(
              page.icon,
              size: 90,
              color: page.iconColor,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textGray,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 160),
        ],
      ),
    );
  }
}
