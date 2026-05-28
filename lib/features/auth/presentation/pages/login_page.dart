import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../patient/presentation/pages/patient_main_wrapper.dart';
import 'register_page.dart';
import '../../../nurse/screens/nurse_dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  void _login() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 800));

    // Demo: pasien@email.com / 12345678 → pasien
    // Demo: perawat@email.com / 12345678 → nurse dashboard (TODO)
    if (_emailCtrl.text.trim() == 'pasien@email.com' &&
        _passCtrl.text == '12345678') {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PatientMainWrapper()),
      );

      // Demo perawat ← tambahkan blok ini
    } else if (_emailCtrl.text.trim() == 'perawat@email.com' && 
    _passCtrl.text == '12345678') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NurseDashboardScreen()),
      );

    } else {
      setState(() { _loading = false; _error = 'Email atau kata sandi salah.'; });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: Column(
        children: [
          // ── Hero ──────────────────────────────────────
          SizedBox(
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // dekoratif lingkaran
                Positioned(top: -50, left: -50,
                  child: _circle(220, Colors.white.withOpacity(0.07))),
                Positioned(bottom: -60, right: -40,
                  child: _circle(260, Colors.white.withOpacity(0.07))),
                // konten brand
                const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('TBeats',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(width: 48, child: Divider(color: Colors.white30, thickness: 3)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Card bawah ────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selamat Datang',
                      style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Masuk ke akun Anda',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 28),

                    // Email
                    const Text('Email',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    _field(controller: _emailCtrl, hint: 'nama@email.com',
                      icon: Icons.mail_outlined,
                      keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 18),

                    // Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kata Sandi',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('Lupa kata sandi?',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                color: AppColors.primaryContainer)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary, letterSpacing: 2),
                        filled: true,
                        fillColor: AppColors.background,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.outline, size: 22),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined
                                     : Icons.visibility_off_outlined,
                            color: AppColors.outline, size: 22),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primaryContainer, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol masuk
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Masuk',
                                style: TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                      ),
                    ),

                    // Error
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.danger, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_error!,
                            style: const TextStyle(
                                color: AppColors.danger, fontSize: 13))),
                        ]),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Link register perawat
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RegisterPage())),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontFamily: 'PlusJakartaSans',
                                fontSize: 14, color: AppColors.textPrimary),
                            children: [
                              TextSpan(text: 'Belum punya akun?  '),
                              TextSpan(text: 'Daftar sebagai Perawat',
                                style: TextStyle(fontWeight: FontWeight.w700,
                                    color: AppColors.primaryContainer)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info box pasien
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Akun pasien dibuat oleh perawat Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        prefixIcon: Icon(icon, color: AppColors.outline, size: 22),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: AppColors.primaryContainer, width: 1.5)),
      ),
    );
  }
}