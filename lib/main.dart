import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const HastaneApp());

class HastaneApp extends StatelessWidget {
  const HastaneApp({super.key});

  @override
  Widget build(BuildContext context) {
    const hospitalBlue = Color(0xFF1565C0);
    const hospitalTurquoise = Color(0xFF00BFA5);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Isparta Şehir Hastanesi',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: hospitalBlue,
          primary: hospitalBlue,
          secondary: hospitalTurquoise,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}