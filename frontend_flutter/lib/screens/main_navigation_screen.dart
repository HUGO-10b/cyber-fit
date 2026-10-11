import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'dashboard_screen.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';
import 'cardio_qr_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    NutritionScreen(),
    WorkoutScreen(),
    CardioQrScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: CyberpunkTheme.cardSurface,
          border: Border(
            top: BorderSide(
              color: CyberpunkTheme.neonGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: CyberpunkTheme.cardSurface,
          selectedItemColor: CyberpunkTheme.neonGreen,
          unselectedItemColor: CyberpunkTheme.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard, color: CyberpunkTheme.neonGreen),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant, color: CyberpunkTheme.neonGreen),
              label: 'Nutrición AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center, color: CyberpunkTheme.neonGreen),
              label: 'Gym Rutina',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_outlined),
              activeIcon: Icon(Icons.qr_code_scanner, color: CyberpunkTheme.neonGreen),
              label: 'Cardio QR',
            ),
          ],
        ),
      ),
    );
  }
}
