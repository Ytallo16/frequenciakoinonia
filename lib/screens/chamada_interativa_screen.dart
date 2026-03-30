import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models/evento.dart';
import '../models/matricula.dart';
import 'detalhes_pessoa_screen.dart';

class ChamadaInterativaScreen extends StatefulWidget {
  final Evento evento;

  const ChamadaInterativaScreen({super.key, required this.evento});

  @override
  _ChamadaInterativaScreenState createState() => _ChamadaInterativaScreenState();
}

class _ChamadaInterativaScreenState extends State<ChamadaInterativaScreen> {
  Map<String, String> frequencias = {};

  @override
  void initState() {
    super.initState();
    for (var freq in mockFrequencias.where((f) => f.eventoId == widget.evento.id)) {
      frequencias[freq.pessoaId] = freq.status.toString().split('.').last;
    }
  }

  @override
  Widget build(BuildContext context) {
    final matriculas = mockMatriculas.where((m) => m.trimestreId == widget.evento.trimestreId).toList();
    final pessoasMatriculadas = matriculas.map((m) => mockPessoas.firstWhere((p) => p.id == m.pessoaId)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamada Interativa'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFe0b6e4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pessoasMatriculadas.length,
          itemBuilder: (context, index) {
            final pessoa = pessoasMatriculadas[index];
            final matricula = matriculas.firstWhere((m) => m.pessoaId == pessoa.id);
            final status = frequencias[pessoa.id] ?? 'não marcado';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: matricula.funcaoNoTrimestre == FuncaoTrimestre.coralista
                      ? const Color(0xFF9f5ea5)
                      : const Color(0xFF7e3285),
                  child: Icon(
                    matricula.funcaoNoTrimestre == FuncaoTrimestre.coralista
                        ? Icons.music_note
                        : Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  pessoa.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5d0565),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Função: ${matricula.funcaoNoTrimestre.toString().split('.').last}',
                      style: const TextStyle(color: Color(0xFF9f5ea5)),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(
                        status == 'presenca' ? 'Presente' : status == 'falta' ? 'Faltou' : status == 'justificativa' ? 'Justificado' : status == 'atraso' ? 'Atrasado' : 'Não Marcado',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: status == 'presenca'
                          ? Colors.green
                          : status == 'falta'
                              ? Colors.red
                              : status == 'justificativa'
                                  ? Colors.orange
                                  : status == 'atraso'
                                      ? Colors.yellow[700]
                                      : Colors.grey,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesPessoaScreen(pessoa: pessoa),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          frequencias[pessoa.id] = 'presenca';
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          frequencias[pessoa.id] = 'falta';
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gerenciar Pessoas - Mock')),
          );
        },
        backgroundColor: const Color(0xFF9f5ea5),
        child: const Icon(Icons.settings),
      ),
    );
  }
}