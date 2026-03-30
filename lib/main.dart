import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_trimestral_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frequência Koinonia',
      theme: ThemeData(
        primaryColor: const Color(0xFF7e3285),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7e3285),
          secondary: const Color(0xFF9f5ea5),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF47034e),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black26,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          shadowColor: Colors.black12,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7e3285),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF5d0565), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFF5d0565)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardTrimestralScreen(),
      },
    );
  }
}
