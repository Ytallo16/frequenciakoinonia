import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models/trimestre.dart';
import 'calendario_ensaios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<int> _anosDisponiveis = [];
  int? _anoSelecionado;
  bool _carregando = true;

  List<int> _gerarAnosDisponiveis() {
    final anoAtual = DateTime.now().year;
    final anos = <int>{...mockCiclos.map((c) => c.ano), anoAtual};
    final ordenados = anos.toList()..sort((a, b) => b.compareTo(a));
    return ordenados;
  }

  List<Trimestre> _trimestresDoAno(int? ano) {
    if (ano == null) return [];

    final cadastrados = mockTrimestres.where((t) => t.anoId == ano).toList()
      ..sort((a, b) => a.numero.compareTo(b.numero));

    if (cadastrados.isNotEmpty) return cadastrados;

    return List.generate(
      4,
      (index) =>
          Trimestre(id: 't$ano-${index + 1}', anoId: ano, numero: index + 1),
    );
  }

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      await ensureBackendDataLoaded();
      await garantirCicloAnoAtual();
      _anosDisponiveis = _gerarAnosDisponiveis();

      final cicloAtivo = mockCiclos.where((c) => c.ativo).toList();
      if (cicloAtivo.isNotEmpty) {
        _anoSelecionado = cicloAtivo.first.ano;
      } else if (_anosDisponiveis.isNotEmpty) {
        _anoSelecionado = _anosDisponiveis.first;
      }
    } catch (_) {
      _anosDisponiveis = _gerarAnosDisponiveis();
      if (_anosDisponiveis.isNotEmpty) {
        _anoSelecionado = _anosDisponiveis.first;
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final trimestresDoAno = _trimestresDoAno(_anoSelecionado);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos por Trimestre'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Voltar ao início',
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/inicio',
                (route) => false,
              );
            },
          ),
        ],
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
                    'Acesso Rápido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_add, color: Color(0xFF9f5ea5)),
                title: const Text(
                  'Cadastrar Coralista',
                  style: TextStyle(color: Color(0xFF5d0565)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/coralistas');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Color(0xFF9f5ea5)),
                title: const Text(
                  'Estatísticas',
                  style: TextStyle(color: Color(0xFF5d0565)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/estatisticas');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.library_music,
                  color: Color(0xFF9f5ea5),
                ),
                title: const Text(
                  'Catálogo de Músicas',
                  style: TextStyle(color: Color(0xFF5d0565)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/catalogo-musicas');
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 32,
                                color: Color(0xFF7e3285),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Selecione o ano e o trimestre',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: const Color(0xFF5d0565),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<int>(
                            initialValue: _anoSelecionado,
                            decoration: const InputDecoration(
                              labelText: 'Ano',
                              border: OutlineInputBorder(),
                            ),
                            items: _anosDisponiveis
                                .map(
                                  (ano) => DropdownMenuItem<int>(
                                    value: ano,
                                    child: Text(ano.toString()),
                                  ),
                                )
                                .toList(),
                            onChanged: (novoAno) {
                              setState(() {
                                _anoSelecionado = novoAno;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (trimestresDoAno.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Não há trimestres cadastrados para o ano selecionado.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: trimestresDoAno.length,
                      itemBuilder: (context, index) {
                        final trimestre = trimestresDoAno[index];
                        return Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalendarioEnsaiosScreen(
                                    trimestre: trimestre,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7e3285),
                                    Color(0xFF9f5ea5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.calendar_view_month,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Trimestre ${trimestre.numero}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
