import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../models/evento.dart';
import '../models/frequencia.dart';
import '../models/matricula.dart';
import '../models/pessoa.dart';
import 'detalhes_pessoa_screen.dart';

class ChamadaInterativaScreen extends StatefulWidget {
  final Evento evento;

  const ChamadaInterativaScreen({super.key, required this.evento});

  @override
  State<ChamadaInterativaScreen> createState() =>
      _ChamadaInterativaScreenState();
}

class _ChamadaInterativaScreenState extends State<ChamadaInterativaScreen> {
  final Map<String, String> frequencias = {};

  bool _carregando = true;
  bool _salvando = false;
  List<Matricula> _matriculas = const [];
  List<Pessoa> _pessoasMatriculadas = const [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      await ensureBackendDataLoaded();
      final matriculas = mockMatriculas
          .where((m) => m.trimestreId == widget.evento.trimestreId)
          .toList();
      final pessoasById = {for (final pessoa in mockPessoas) pessoa.id: pessoa};

      final pessoasMatriculadas = <Pessoa>[];
      for (final matricula in matriculas) {
        final pessoa = pessoasById[matricula.pessoaId];
        if (pessoa != null) {
          pessoasMatriculadas.add(pessoa);
        }
      }

      frequencias.clear();
      for (final freq in mockFrequencias.where(
        (f) => f.eventoId == widget.evento.id,
      )) {
        switch (freq.status) {
          case StatusFrequencia.presenca:
            frequencias[freq.pessoaId] = 'presenca';
            break;
          case StatusFrequencia.falta:
            frequencias[freq.pessoaId] = 'falta';
            break;
          case StatusFrequencia.atraso:
            frequencias[freq.pessoaId] = 'atraso';
            break;
          case StatusFrequencia.faltaJustificada:
            frequencias[freq.pessoaId] = 'falta_justificada';
            break;
        }
      }

      if (!mounted) return;
      setState(() {
        _matriculas = matriculas;
        _pessoasMatriculadas = pessoasMatriculadas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar chamada: $e')));
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'presenca':
        return 'Presente';
      case 'falta':
        return 'Faltou';
      case 'falta_justificada':
        return 'Justificado';
      case 'atraso':
        return 'Atrasado';
      default:
        return 'Não marcado';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'presenca':
        return Colors.green;
      case 'falta':
        return Colors.red;
      case 'falta_justificada':
        return Colors.orange;
      case 'atraso':
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }

  Future<void> _salvarChamada() async {
    setState(() {
      _salvando = true;
    });

    try {
      await salvarFrequenciasEvento(widget.evento.id, frequencias);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chamada salva com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar chamada: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          itemCount: _pessoasMatriculadas.length,
          itemBuilder: (context, index) {
            final pessoa = _pessoasMatriculadas[index];
            final matricula = _matriculas.firstWhere(
              (m) => m.pessoaId == pessoa.id,
            );
            final status = frequencias[pessoa.id] ?? 'nao_marcado';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      matricula.funcaoNoTrimestre == FuncaoTrimestre.coralista
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
                        _statusLabel(status),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _statusColor(status),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetalhesPessoaScreen(pessoa: pessoa),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _salvando ? null : _salvarChamada,
        backgroundColor: const Color(0xFF9f5ea5),
        icon: _salvando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save),
        label: Text(_salvando ? 'Salvando...' : 'Salvar chamada'),
      ),
    );
  }
}
