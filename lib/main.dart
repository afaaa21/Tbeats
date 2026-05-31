import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/patient/presentation/pages/patient_main_wrapper.dart';
import 'features/nurse/screens/nurse_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Muat Environment Variables dari file .env
  await dotenv.load(fileName: ".env");
  
  // 2. Inisialisasi Supabase Backend
  await SupabaseConfig.initialize();

  // 3. Cek Sesi Aktif Supabase untuk auto-login
  Widget initialScreen = const OnboardingPage();
  final currentUser = SupabaseConfig.client.auth.currentUser;
  if (currentUser != null) {
    try {
      final profile = await SupabaseConfig.client
          .from('profiles')
          .select('role')
          .eq('id', currentUser.id)
          .single();
      
      final role = profile['role'];
      if (role == 'pasien') {
        initialScreen = const PatientMainWrapper();
      } else if (role == 'perawat') {
        initialScreen = const NurseDashboardScreen();
      }
    } catch (e) {
      debugPrint("Sesi aktif terdeteksi tetapi gagal memuat profil: $e");
    }
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(TBeatsApp(homeScreen: initialScreen));
}

class TBeatsApp extends StatelessWidget {
  final Widget homeScreen;
  const TBeatsApp({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBeats',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: homeScreen,
    );
  }
}
