import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const OnboardingScreen(),
    );
  }
}
