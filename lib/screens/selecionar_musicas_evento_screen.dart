import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../models/catalogo_musica.dart';

class SelecionarMusicasEventoScreen extends StatefulWidget {
  final String eventoId;

  const SelecionarMusicasEventoScreen({super.key, required this.eventoId});

  @override
  State<SelecionarMusicasEventoScreen> createState() =>
      _SelecionarMusicasEventoScreenState();
}

class _SelecionarMusicasEventoScreenState
    extends State<SelecionarMusicasEventoScreen> {
  bool _carregando = true;
  bool _salvando = false;
  final Set<String> _selecionadas = {};
  final TextEditingController _buscaController = TextEditingController();
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      await ensureBackendDataLoaded();
      await listarCatalogoMusicas(apenasAtivas: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar catálogo: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _confirmarSelecao() async {
    if (_selecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma música.')),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      await selecionarCatalogoMusicasNoEvento(
        eventoId: widget.eventoId,
        catalogoMusicaIds: _selecionadas.toList(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao adicionar músicas: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  void _aplicarBusca() {
    setState(() {
      _termoBusca = _buscaController.text.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final todasMusicas = [...mockCatalogoMusicas]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    final musicas = todasMusicas.where((musica) {
      if (_termoBusca.isEmpty) return true;
      return musica.nome.toLowerCase().contains(_termoBusca);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Músicas')),
      body: todasMusicas.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma música ativa no catálogo.\nCadastre no módulo de catálogo.',
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _buscaController,
                          onSubmitted: (_) => _aplicarBusca(),
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'Buscar música por nome',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _aplicarBusca,
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: musicas.isEmpty
                        ? const Center(
                            child: Text('Nenhuma música encontrada na busca.'),
                          )
                        : ListView.builder(
                            itemCount: musicas.length,
                            itemBuilder: (context, index) {
                              final musica = musicas[index];
                              final marcada = _selecionadas.contains(musica.id);
                              return Card(
                                child: CheckboxListTile(
                                  value: marcada,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selecionadas.add(musica.id);
                                      } else {
                                        _selecionadas.remove(musica.id);
                                      }
                                    });
                                  },
                                  title: Text(musica.nome),
                                  subtitle: _subtitulo(musica),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _salvando ? null : _confirmarSelecao,
        tooltip: 'OK',
        child: _salvando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check),
      ),
    );
  }

  Widget _subtitulo(CatalogoMusica musica) {
    final linhas = <String>[];
    if ((musica.autor ?? '').trim().isNotEmpty) {
      linhas.add('Autor: ${musica.autor}');
    }
    if ((musica.link ?? '').trim().isNotEmpty) {
      linhas.add('Link disponível');
    }
    if (musica.descricao.trim().isNotEmpty) {
      linhas.add(musica.descricao.trim());
    }

    if (linhas.isEmpty) {
      return const Text('Sem detalhes');
    }

    return Text(linhas.join(' • '));
  }
}
