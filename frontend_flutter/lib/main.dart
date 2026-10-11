import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: CyberpunkTheme.cardSurface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CyberFitApp());
}

class CyberFitApp extends StatelessWidget {
  const CyberFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberFit // OS',
      debugShowCheckedModeBanner: false,
      theme: CyberpunkTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
