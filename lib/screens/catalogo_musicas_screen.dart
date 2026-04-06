import 'dart:async';

import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../models/catalogo_musica.dart';

class CatalogoMusicasScreen extends StatefulWidget {
  const CatalogoMusicasScreen({super.key});

  @override
  State<CatalogoMusicasScreen> createState() => _CatalogoMusicasScreenState();
}

class _CatalogoMusicasScreenState extends State<CatalogoMusicasScreen> {
  bool _carregando = true;
  final TextEditingController _buscaController = TextEditingController();
  Timer? _buscaDebounce;
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(_onBuscaChanged);
    _carregar();
  }

  @override
  void dispose() {
    _buscaDebounce?.cancel();
    _buscaController
      ..removeListener(_onBuscaChanged)
      ..dispose();
    super.dispose();
  }

  void _onBuscaChanged() {
    _buscaDebounce?.cancel();
    _buscaDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final valor = _buscaController.text.trim().toLowerCase();
      if (valor == _termoBusca) return;
      setState(() {
        _termoBusca = valor;
      });
    });
  }

  Future<void> _carregar() async {
    try {
      await ensureBackendDataLoaded();
      await listarCatalogoMusicas();
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

  Future<void> _salvarMusica({CatalogoMusica? existente}) async {
    final nomeController = TextEditingController(text: existente?.nome ?? '');
    final autorController = TextEditingController(text: existente?.autor ?? '');
    final linkController = TextEditingController(text: existente?.link ?? '');
    final descricaoController = TextEditingController(
      text: existente?.descricao ?? '',
    );
    var ativo = existente?.ativo ?? true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      existente == null ? 'Nova música' : 'Editar música',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: autorController,
                      decoration: const InputDecoration(
                        labelText: 'Autor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descricaoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      value: ativo,
                      onChanged: (value) => setModalState(() => ativo = value),
                      title: const Text('Ativa'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final nome = nomeController.text.trim();
                          if (nome.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Informe o nome.')),
                            );
                            return;
                          }

                          try {
                            if (existente == null) {
                              await criarCatalogoMusica(
                                nome: nome,
                                autor: autorController.text.trim().isEmpty
                                    ? null
                                    : autorController.text.trim(),
                                link: linkController.text.trim().isEmpty
                                    ? null
                                    : linkController.text.trim(),
                                descricao: descricaoController.text.trim(),
                                ativo: ativo,
                              );
                            } else {
                              await atualizarCatalogoMusica(
                                CatalogoMusica(
                                  id: existente.id,
                                  nome: nome,
                                  autor: autorController.text.trim().isEmpty
                                      ? null
                                      : autorController.text.trim(),
                                  link: linkController.text.trim().isEmpty
                                      ? null
                                      : linkController.text.trim(),
                                  descricao: descricaoController.text.trim(),
                                  ativo: ativo,
                                ),
                              );
                            }
                            await listarCatalogoMusicas();
                            if (!context.mounted) return;
                            setState(() {});
                            Navigator.pop(context);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao salvar: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nomeController.dispose();
    autorController.dispose();
    linkController.dispose();
    descricaoController.dispose();
  }

  Future<void> _excluirMusica(CatalogoMusica musica) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir música'),
        content: Text('Deseja excluir "${musica.nome}" do catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await excluirCatalogoMusica(musica.id);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"${musica.nome}" excluída.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  List<CatalogoMusica> _filtrarMusicas(List<CatalogoMusica> musicas) {
    return musicas.where((musica) {
      if (_termoBusca.isEmpty) return true;
      return musica.nome.toLowerCase().contains(_termoBusca);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final todasMusicas = [...mockCatalogoMusicas]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    final musicas = _filtrarMusicas(todasMusicas);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Músicas'),
        actions: [
          IconButton(onPressed: _carregar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: todasMusicas.isEmpty
          ? const Center(child: Text('Nenhuma música cadastrada.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: 'Buscar música por nome',
                      border: const OutlineInputBorder(),
                      suffixIcon: _buscaController.text.trim().isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _buscaController.clear();
                                _buscaDebounce?.cancel();
                                setState(() {
                                  _termoBusca = '';
                                });
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: musicas.isEmpty
                      ? const Center(
                          child: Text('Nenhuma música encontrada com a busca.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          itemCount: musicas.length,
                          itemBuilder: (context, index) {
                            final musica = musicas[index];
                            return Card(
                              child: ListTile(
                                title: Text(musica.nome),
                                subtitle: Text(
                                  [
                                    if ((musica.autor ?? '').trim().isNotEmpty)
                                      'Autor: ${musica.autor}',
                                    if ((musica.link ?? '').trim().isNotEmpty)
                                      'Link: ${musica.link}',
                                    if (!musica.ativo) 'Inativa',
                                  ].join(' • '),
                                ),
                                isThreeLine: (musica.descricao)
                                    .trim()
                                    .isNotEmpty,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _salvarMusica(existente: musica),
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () => _excluirMusica(musica),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _salvarMusica,
        child: const Icon(Icons.add),
      ),
    );
  }
}
