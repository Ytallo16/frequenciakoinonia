import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'screens/coralistas_screen.dart';
import 'screens/catalogo_musicas_screen.dart';
import 'screens/estatisticas_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inicio_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = ensureBackendDataLoaded();
  }

  void _retryBootstrap() {
    setState(() {
      _bootstrapFuture = recarregarDadosBackend();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'Koinonia',
          theme: AppTheme.lightTheme,
          home: snapshot.connectionState != ConnectionState.done
              ? const _BootstrapLoadingScreen()
              : snapshot.hasError
              ? _BootstrapErrorScreen(
                  onRetry: _retryBootstrap,
                  errorMessage: '${snapshot.error}',
                )
              : const InicioScreen(),
          routes: {
            '/inicio': (context) => const InicioScreen(),
            '/eventos': (context) => const HomeScreen(),
            '/coralistas': (context) => const CoralistasScreen(),
            '/catalogo-musicas': (context) => const CatalogoMusicasScreen(),
            '/estatisticas': (context) => const EstatisticasScreen(),
          },
        );
      },
    );
  }
}

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final String errorMessage;

  const _BootstrapErrorScreen({
    required this.onRetry,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Não foi possível conectar ao backend.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
