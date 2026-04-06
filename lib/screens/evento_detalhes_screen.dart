import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../models/evento.dart';
import '../models/musica.dart';
import '../models/pessoa.dart';
import 'selecionar_musicas_evento_screen.dart';

class EventoDetalhesScreen extends StatefulWidget {
  final String eventoId;

  const EventoDetalhesScreen({super.key, required this.eventoId});

  @override
  State<EventoDetalhesScreen> createState() => _EventoDetalhesScreenState();
}

class _EventoDetalhesScreenState extends State<EventoDetalhesScreen> {
  late Evento _evento;
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  Set<String> _musicaIdsOriginais = {};
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _evento = mockEventos.firstWhere((evento) => evento.id == widget.eventoId);
    _musicaIdsOriginais = _evento.musicas
        .where((musica) => musica.id != null && musica.id!.isNotEmpty)
        .map((musica) => musica.id!)
        .toSet();
    _nomeController = TextEditingController(text: _evento.nome);
    _descricaoController = TextEditingController(text: _evento.descricao);
    _nomeController.addListener(_onNomeChanged);
    _descricaoController.addListener(_onDescricaoChanged);
  }

  @override
  void dispose() {
    _nomeController.removeListener(_onNomeChanged);
    _descricaoController.removeListener(_onDescricaoChanged);
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final ano = dataHora.year.toString();
    return '$dia/$mes/$ano';
  }

  String _formatarHora(DateTime dataHora) {
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  void _onNomeChanged() {
    final nomeAtual = _nomeController.text;
    if (nomeAtual == _evento.nome) return;
    _atualizarEvento(_evento.copyWith(nome: nomeAtual));
  }

  void _onDescricaoChanged() {
    final descricaoAtual = _descricaoController.text;
    if (descricaoAtual == _evento.descricao) return;
    _atualizarEvento(_evento.copyWith(descricao: descricaoAtual));
  }

  void _atualizarEvento(Evento novoEvento) {
    final index = mockEventos.indexWhere((evento) => evento.id == _evento.id);
    if (index == -1) return;
    setState(() {
      _evento = novoEvento;
      mockEventos[index] = novoEvento;
    });
  }

  Future<void> _selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _evento.dataHora,
      firstDate: DateTime(_evento.dataHora.year - 1, 1, 1),
      lastDate: DateTime(_evento.dataHora.year + 1, 12, 31),
    );
    if (dataSelecionada == null) return;

    final novaDataHora = DateTime(
      dataSelecionada.year,
      dataSelecionada.month,
      dataSelecionada.day,
      _evento.dataHora.hour,
      _evento.dataHora.minute,
    );
    _atualizarEvento(_evento.copyWith(dataHora: novaDataHora));
  }

  Future<void> _selecionarHora() async {
    final horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_evento.dataHora),
    );
    if (horaSelecionada == null) return;

    final novaDataHora = DateTime(
      _evento.dataHora.year,
      _evento.dataHora.month,
      _evento.dataHora.day,
      horaSelecionada.hour,
      horaSelecionada.minute,
    );
    _atualizarEvento(_evento.copyWith(dataHora: novaDataHora));
  }

  Future<void> _selecionarAnexo() async {
    final resultado = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (resultado == null || resultado.files.isEmpty) return;

    final arquivo = resultado.files.first;
    if (arquivo.path == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível obter o caminho do arquivo.'),
        ),
      );
      return;
    }

    try {
      final atualizado = await uploadAnexoEvento(
        eventoId: _evento.id,
        filePath: arquivo.path!,
      );
      if (!mounted) return;
      setState(() {
        _evento = atualizado.copyWith(musicas: _evento.musicas);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anexo enviado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar anexo: $e')));
    }
  }

  Future<void> _removerAnexo() async {
    try {
      final atualizado = await removerAnexoEvento(_evento.id);
      if (!mounted) return;
      setState(() {
        _evento = atualizado.copyWith(musicas: _evento.musicas);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Anexo removido.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao remover anexo: $e')));
    }
  }

  Future<void> _abrirSelecaoMusicas() async {
    final adicionou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelecionarMusicasEventoScreen(eventoId: _evento.id),
      ),
    );
    if (adicionou != true) return;

    final atualizado = await buscarEvento(_evento.id);
    if (!mounted) return;
    setState(() {
      _evento = atualizado;
      _musicaIdsOriginais = _evento.musicas
          .where((musica) => musica.id != null && musica.id!.isNotEmpty)
          .map((musica) => musica.id!)
          .toSet();
    });
  }

  void _removerMusica(int index) {
    final musicas = List<Musica>.from(_evento.musicas);
    if (index < 0 || index >= musicas.length) return;
    musicas.removeAt(index);
    _atualizarEvento(_evento.copyWith(musicas: musicas));
  }

  void _atualizarMusica(int index, Musica novaMusica) {
    final musicas = List<Musica>.from(_evento.musicas);
    if (index < 0 || index >= musicas.length) return;
    musicas[index] = novaMusica;
    _atualizarEvento(_evento.copyWith(musicas: musicas));
  }

  void _atualizarNaipe(int musicaIndex, String naipe, String novoNome) {
    final musica = _evento.musicas[musicaIndex];
    final novosNaipes = Map<String, String>.from(musica.naipes);
    novosNaipes[naipe] = novoNome;
    _atualizarMusica(musicaIndex, musica.copyWith(naipes: novosNaipes));
  }

  String _nomeMusicaOuFallback(String nome, int index) {
    final trimmed = nome.trim();
    if (trimmed.isEmpty) {
      return 'Música ${index + 1}';
    }
    return trimmed;
  }

  Future<void> _salvarAlteracoes() async {
    setState(() {
      _salvando = true;
    });

    try {
      final atualizadoBasico = await atualizarEventoBasico(
        _evento.copyWith(
          nome: _nomeController.text.trim(),
          descricao: _descricaoController.text.trim(),
        ),
      );

      final idsAtuais = _evento.musicas
          .where((musica) => musica.id != null && musica.id!.isNotEmpty)
          .map((musica) => musica.id!)
          .toSet();
      final idsRemovidos = _musicaIdsOriginais.difference(idsAtuais);
      for (final musicaId in idsRemovidos) {
        await excluirMusicaEvento(eventoId: _evento.id, musicaId: musicaId);
      }

      final musicasPersistidas = <Musica>[];
      for (var i = 0; i < _evento.musicas.length; i++) {
        final musicaLocal = _evento.musicas[i];
        final musicaComNome = musicaLocal.copyWith(
          nome: _nomeMusicaOuFallback(musicaLocal.nome, i),
        );

        Musica persistida;
        if (musicaComNome.id == null || musicaComNome.id!.isEmpty) {
          persistida = await criarMusicaEvento(
            eventoId: _evento.id,
            musica: musicaComNome,
            ordem: i,
          );
        } else {
          persistida = await atualizarMusicaEvento(
            eventoId: _evento.id,
            musica: musicaComNome,
            ordem: i,
          );
        }

        final musicaComEscalas = persistida.copyWith(
          naipes: musicaComNome.naipes,
        );
        final escalasAtualizadas = await substituirEscalasMusica(
          eventoId: _evento.id,
          musica: musicaComEscalas,
        );
        musicasPersistidas.add(escalasAtualizadas);
      }

      if (!mounted) return;
      setState(() {
        _evento = atualizadoBasico.copyWith(musicas: musicasPersistidas);
        _musicaIdsOriginais = musicasPersistidas
            .where((musica) => musica.id != null && musica.id!.isNotEmpty)
            .map((musica) => musica.id!)
            .toSet();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento atualizado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar evento: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  ClassificacaoVocal? _classificacaoPorNaipe(String naipe) {
    switch (naipe) {
      case 'Soprano':
        return ClassificacaoVocal.soprano;
      case 'Contralto':
        return ClassificacaoVocal.contralto;
      case 'Tenor':
        return ClassificacaoVocal.tenor;
      case 'Baixo':
        return ClassificacaoVocal.baixo;
      default:
        return null;
    }
  }

  List<String> _nomesPorNaipe(String naipe) {
    final classificacao = _classificacaoPorNaipe(naipe);
    if (classificacao == null) return const [];

    final nomes =
        mockPessoas
            .where((pessoa) => pessoa.classificacaoVocal == classificacao)
            .map((pessoa) => pessoa.nome)
            .toSet()
            .toList()
          ..sort();
    return nomes;
  }

  Widget _buildNaipeDropdown({
    required int musicaIndex,
    required String naipe,
    required String valorSelecionado,
  }) {
    final nomesDisponiveis = _nomesPorNaipe(naipe);
    final opcoes = <String>{'', ...nomesDisponiveis};
    if (valorSelecionado.isNotEmpty) {
      opcoes.add(valorSelecionado);
    }
    final opcoesOrdenadas = opcoes.toList()
      ..sort((a, b) {
        if (a.isEmpty) return -1;
        if (b.isEmpty) return 1;
        return a.compareTo(b);
      });

    final valorValido = opcoesOrdenadas.contains(valorSelecionado)
        ? valorSelecionado
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('m$musicaIndex-$naipe-$valorValido'),
          initialValue: valorValido,
          decoration: InputDecoration(
            labelText: naipe,
            border: const OutlineInputBorder(),
          ),
          items: opcoesOrdenadas
              .map(
                (nome) => DropdownMenuItem<String>(
                  value: nome,
                  child: Text(nome.isEmpty ? 'Não escalado' : nome),
                ),
              )
              .toList(),
          onChanged: (novoNome) {
            if (novoNome == null) return;
            _atualizarNaipe(musicaIndex, naipe, novoNome);
          },
        ),
        if (nomesDisponiveis.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Sem pessoas cadastradas para $naipe.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Evento'),
        actions: [
          IconButton(
            onPressed: _salvando ? null : _salvarAlteracoes,
            icon: _salvando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            tooltip: 'Salvar alterações',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFe0b6e4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dados Básicos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5d0565),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do evento',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF7e3285),
                      ),
                      title: Text('Data: ${_formatarData(_evento.dataHora)}'),
                      trailing: const Icon(Icons.edit),
                      onTap: _selecionarData,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.access_time,
                        color: Color(0xFF7e3285),
                      ),
                      title: Text('Hora: ${_formatarHora(_evento.dataHora)}'),
                      trailing: const Icon(Icons.edit),
                      onTap: _selecionarHora,
                    ),
                    TextField(
                      controller: _descricaoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Anexo (Foto ou Arquivo)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5d0565),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_evento.anexoPath == null)
                      const Text(
                        'Nenhum anexo selecionado.',
                        style: TextStyle(color: Color(0xFF5d0565)),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _evento.anexoNome ?? 'Arquivo selecionado',
                            style: const TextStyle(
                              color: Color(0xFF5d0565),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _evento.anexoPath ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _selecionarAnexo,
                          icon: const Icon(Icons.attach_file),
                          label: Text(
                            _evento.anexoPath == null
                                ? 'Selecionar'
                                : 'Substituir',
                          ),
                        ),
                        if (_evento.anexoPath != null)
                          OutlinedButton.icon(
                            onPressed: _removerAnexo,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remover'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Músicas e Escala de Naipes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5d0565),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _abrirSelecaoMusicas,
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xFF7e3285),
                          ),
                          tooltip: 'Selecionar músicas do catálogo',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_evento.musicas.isEmpty)
                      const Text(
                        'Nenhuma música adicionada. Toque no + para selecionar do catálogo.',
                        style: TextStyle(color: Color(0xFF5d0565)),
                      ),
                    ..._evento.musicas.asMap().entries.map((entry) {
                      final musicaIndex = entry.key;
                      final musica = entry.value;
                      final titulo = musica.nome.trim().isEmpty
                          ? 'Música ${musicaIndex + 1}'
                          : musica.nome;

                      return Card(
                        margin: const EdgeInsets.only(top: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      titulo,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5d0565),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _removerMusica(musicaIndex),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    tooltip: 'Remover música',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: musica.nome,
                                decoration: const InputDecoration(
                                  labelText: 'Nome da música',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (valor) {
                                  _atualizarMusica(
                                    musicaIndex,
                                    musica.copyWith(nome: valor),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: musica.autor ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Autor',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (valor) {
                                  _atualizarMusica(
                                    musicaIndex,
                                    musica.copyWith(
                                      autor: valor.trim().isEmpty
                                          ? null
                                          : valor.trim(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: musica.link ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Link (Spotify, YouTube, etc)',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (valor) {
                                  _atualizarMusica(
                                    musicaIndex,
                                    musica.copyWith(link: valor.trim()),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: musica.descricao,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Descrição da música',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (valor) {
                                  _atualizarMusica(
                                    musicaIndex,
                                    musica.copyWith(descricao: valor),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              ...Musica.todosNaipes.map((naipe) {
                                final valorSelecionado =
                                    musica.naipes[naipe] ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _buildNaipeDropdown(
                                    musicaIndex: musicaIndex,
                                    naipe: naipe,
                                    valorSelecionado: valorSelecionado,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
