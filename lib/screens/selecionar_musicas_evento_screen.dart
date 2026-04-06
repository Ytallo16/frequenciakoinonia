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

  @override
  void initState() {
    super.initState();
    _carregar();
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

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final musicas = [...mockCatalogoMusicas]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Músicas')),
      body: musicas.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma música ativa no catálogo.\nCadastre no módulo de catálogo.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _salvando ? null : _confirmarSelecao,
        icon: _salvando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.playlist_add_check),
        label: Text(_salvando ? 'Salvando...' : 'Adicionar selecionadas'),
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
