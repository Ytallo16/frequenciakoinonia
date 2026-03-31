import 'package:flutter/material.dart';
import 'screens/coralistas_screen.dart';
import 'screens/estatisticas_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inicio_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frequência Koinonia',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const InicioScreen(),
        '/eventos': (context) => const HomeScreen(),
        '/coralistas': (context) => const CoralistasScreen(),
        '/estatisticas': (context) => const EstatisticasScreen(),
      },
    );
  }
}
