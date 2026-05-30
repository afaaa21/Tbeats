import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Muat Environment Variables dari file .env
  await dotenv.load(fileName: ".env");
  
  // 2. Inisialisasi Supabase Backend
  await SupabaseConfig.initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const TBeatsApp());
}

class TBeatsApp extends StatelessWidget {
  const TBeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBeats',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const OnboardingPage(),
    );
  }
}
