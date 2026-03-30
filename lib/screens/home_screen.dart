import 'package:flutter/material.dart';
import '../mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cicloAtivo = mockCiclos.firstWhere((c) => c.ativo);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequência Koinonia'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF47034e), Color(0xFF7e3285)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_add, color: Color(0xFF9f5ea5)),
                title: const Text('Cadastrar Pessoa', style: TextStyle(color: Color(0xFF5d0565))),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cadastrar Pessoa - Mock')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Color(0xFF9f5ea5)),
                title: const Text('Relatório Geral Anual', style: TextStyle(color: Color(0xFF5d0565))),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Relatório Geral Anual - Mock')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock, color: Color(0xFF9f5ea5)),
                title: const Text('Trocar Senha de Acesso', style: TextStyle(color: Color(0xFF5d0565))),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trocar Senha - Mock')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFe0b6e4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 80,
                          color: Color(0xFF7e3285),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ano Vigente: ${cicloAtivo.ano}',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/dashboard');
                  },
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Entrar no Dashboard'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}