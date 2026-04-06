import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/ciclo.dart';
import 'models/catalogo_musica.dart';
import 'models/evento.dart';
import 'models/frequencia.dart';
import 'models/matricula.dart';
import 'models/musica.dart';
import 'models/pessoa.dart';
import 'models/trimestre.dart';

final List<Pessoa> mockPessoas = [];
final List<Ciclo> mockCiclos = [];
final List<CatalogoMusica> mockCatalogoMusicas = [];
final List<Trimestre> mockTrimestres = [];
final List<Matricula> mockMatriculas = [];
final List<Evento> mockEventos = [];
final List<Frequencia> mockFrequencias = [];

final Map<int, String> _cicloIdByAno = {};

bool _backendLoaded = false;
Future<void>? _loadingFuture;

class BackendException implements Exception {
  final String message;

  BackendException(this.message);

  @override
  String toString() => message;
}

String _baseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (fromEnv.isNotEmpty) {
    return fromEnv;
  }
  if (kIsWeb) {
    return 'http://localhost:8000';
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000';
  }
  return 'http://localhost:8000';
}

Uri _uri(String path, {Map<String, String>? query}) {
  final sanitizedPath = path.startsWith('/') ? path : '/$path';
  return Uri.parse(
    '${_baseUrl()}$sanitizedPath',
  ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);
}

String _errorMessage(http.Response response) {
  if (response.body.trim().isEmpty) {
    return 'HTTP ${response.statusCode}';
  }
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map && decoded['detail'] != null) {
      return decoded['detail'].toString();
    }
    return decoded.toString();
  } catch (_) {
    return response.body;
  }
}

Future<dynamic> _request(
  String method,
  String path, {
  Object? body,
  Map<String, String>? query,
}) async {
  final headers = <String, String>{};
  if (body != null) {
    headers['Content-Type'] = 'application/json';
  }

  late final http.Response response;
  final targetUri = _uri(path, query: query);

  switch (method) {
    case 'GET':
      response = await http.get(targetUri, headers: headers);
      break;
    case 'POST':
      response = await http.post(
        targetUri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
      break;
    case 'PUT':
      response = await http.put(
        targetUri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
      break;
    case 'PATCH':
      response = await http.patch(
        targetUri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
      break;
    case 'DELETE':
      response = await http.delete(
        targetUri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
      break;
    default:
      throw BackendException('Método HTTP não suportado: $method');
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw BackendException('Erro ao chamar $path: ${_errorMessage(response)}');
  }

  if (response.body.trim().isEmpty) {
    return null;
  }
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> _uploadFile(String path, String filePath) async {
  final request = http.MultipartRequest('POST', _uri(path));
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  final streamedResponse = await request.send();
  final responseBody = await streamedResponse.stream.bytesToString();

  if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
    throw BackendException(
      'Erro ao enviar anexo: ${streamedResponse.statusCode} $responseBody',
    );
  }

  final decoded = jsonDecode(responseBody);
  if (decoded is! Map<String, dynamic>) {
    throw BackendException('Resposta inesperada no upload de anexo.');
  }
  return decoded;
}

List<dynamic> _asList(dynamic raw, String endpoint) {
  if (raw is List<dynamic>) return raw;
  throw BackendException('Resposta inesperada em $endpoint.');
}

Map<String, dynamic> _asMap(dynamic raw, String endpoint) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return raw.cast<String, dynamic>();
  throw BackendException('Resposta inesperada em $endpoint.');
}

ClassificacaoVocal _classificacaoFromApi(String value) {
  switch (value) {
    case 'soprano':
      return ClassificacaoVocal.soprano;
    case 'contralto':
      return ClassificacaoVocal.contralto;
    case 'tenor':
      return ClassificacaoVocal.tenor;
    case 'baixo':
      return ClassificacaoVocal.baixo;
    default:
      return ClassificacaoVocal.na;
  }
}

String _classificacaoToApi(ClassificacaoVocal value) {
  switch (value) {
    case ClassificacaoVocal.soprano:
      return 'soprano';
    case ClassificacaoVocal.contralto:
      return 'contralto';
    case ClassificacaoVocal.tenor:
      return 'tenor';
    case ClassificacaoVocal.baixo:
      return 'baixo';
    case ClassificacaoVocal.na:
      return 'na';
  }
}

TipoPessoa _tipoPessoaFromApi(String value) {
  switch (value) {
    case 'membro':
      return TipoPessoa.membro;
    case 'regente':
      return TipoPessoa.regente;
    default:
      return TipoPessoa.coralista;
  }
}

String _tipoPessoaToApi(TipoPessoa value) {
  switch (value) {
    case TipoPessoa.coralista:
      return 'coralista';
    case TipoPessoa.membro:
      return 'membro';
    case TipoPessoa.regente:
      return 'regente';
  }
}

FuncaoTrimestre _funcaoFromApi(String value) {
  switch (value) {
    case 'membro':
      return FuncaoTrimestre.membro;
    case 'regente':
      return FuncaoTrimestre.regente;
    default:
      return FuncaoTrimestre.coralista;
  }
}

StatusFrequencia _statusFromApi(String value) {
  switch (value) {
    case 'falta':
      return StatusFrequencia.falta;
    case 'atraso':
      return StatusFrequencia.atraso;
    case 'falta_justificada':
      return StatusFrequencia.faltaJustificada;
    default:
      return StatusFrequencia.presenca;
  }
}

String _statusFromUi(String value) {
  switch (value) {
    case 'faltaJustificada':
    case 'falta_justificada':
      return 'falta_justificada';
    case 'falta':
      return 'falta';
    case 'atraso':
      return 'atraso';
    default:
      return 'presenca';
  }
}

String _naipeLabelFromApi(String value) {
  switch (value) {
    case 'soprano':
      return 'Soprano';
    case 'contralto':
      return 'Contralto';
    case 'tenor':
      return 'Tenor';
    case 'baixo':
      return 'Baixo';
    default:
      return value;
  }
}

String _naipeToApi(String value) {
  switch (value.toLowerCase()) {
    case 'soprano':
      return 'soprano';
    case 'contralto':
      return 'contralto';
    case 'tenor':
      return 'tenor';
    case 'baixo':
      return 'baixo';
    default:
      return value.toLowerCase();
  }
}

String _yyyyMmDd(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _yyyyMmDdThhMmSs(DateTime dateTime) {
  final y = dateTime.year.toString().padLeft(4, '0');
  final m = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  final hh = dateTime.hour.toString().padLeft(2, '0');
  final mm = dateTime.minute.toString().padLeft(2, '0');
  final ss = dateTime.second.toString().padLeft(2, '0');
  return '$y-$m-${d}T$hh:$mm:$ss';
}

Map<String, String> _pessoaNomeById() {
  return {for (final p in mockPessoas) p.id: p.nome};
}

Map<String, String> _pessoaIdByNome() {
  return {for (final p in mockPessoas) p.nome: p.id};
}

CatalogoMusica _catalogoMusicaFromJson(Map<String, dynamic> json) {
  return CatalogoMusica(
    id: json['id'].toString(),
    nome: (json['nome'] ?? '').toString(),
    autor: json['autor']?.toString(),
    link: json['link']?.toString(),
    descricao: (json['descricao'] ?? '').toString(),
    ativo: json['ativo'] == true,
  );
}

Pessoa _pessoaFromJson(Map<String, dynamic> json) {
  return Pessoa(
    id: json['id'].toString(),
    nome: (json['nome'] ?? '').toString(),
    dataNascimento: DateTime.parse(json['data_nascimento'].toString()),
    telefone: (json['telefone'] ?? '').toString(),
    classificacaoVocal: _classificacaoFromApi(
      (json['classificacao_vocal'] ?? '').toString(),
    ),
    tipoPadrao: _tipoPessoaFromApi((json['tipo_padrao'] ?? '').toString()),
    fotoUrl: json['foto_url']?.toString(),
  );
}

Evento _eventoFromJson(
  Map<String, dynamic> json, {
  List<Musica> musicas = const [],
}) {
  return Evento(
    id: json['id'].toString(),
    trimestreId: json['trimestre_id'].toString(),
    dataHora: DateTime.parse(json['data_hora'].toString()).toLocal(),
    nome: (json['nome'] ?? '').toString(),
    descricao: (json['descricao'] ?? '').toString(),
    anexoPath: json['anexo_storage_path']?.toString(),
    anexoNome: json['anexo_nome']?.toString(),
    anexoMimeType: json['anexo_mime_type']?.toString(),
    musicas: musicas,
  );
}

Matricula _matriculaFromJson(Map<String, dynamic> json) {
  return Matricula(
    trimestreId: json['trimestre_id'].toString(),
    pessoaId: json['pessoa_id'].toString(),
    funcaoNoTrimestre: _funcaoFromApi(
      (json['funcao_no_trimestre'] ?? '').toString(),
    ),
  );
}

Frequencia _frequenciaFromJson(Map<String, dynamic> json) {
  return Frequencia(
    id: json['id']?.toString(),
    eventoId: json['evento_id'].toString(),
    pessoaId: json['pessoa_id'].toString(),
    status: _statusFromApi((json['status'] ?? '').toString()),
    justificativa: json['justificativa']?.toString(),
    imagemPath: json['imagem_path']?.toString(),
  );
}

Musica _musicaFromJson(
  Map<String, dynamic> json,
  Map<String, String> pessoaNomePorId,
) {
  final naipes = Musica.naipesVazios();
  final escalas = _asList(json['escalas'] ?? [], 'musica.escalas');

  for (final rawEscala in escalas) {
    final escala = _asMap(rawEscala, 'musica.escalas.item');
    final naipe = _naipeLabelFromApi((escala['naipe'] ?? '').toString());
    final pessoaMap = escala['pessoa'];
    final pessoaNome =
        (pessoaMap is Map ? pessoaMap['nome'] : null)?.toString() ??
        pessoaNomePorId[(escala['pessoa_id'] ?? '').toString()] ??
        '';
    if (naipes.containsKey(naipe)) {
      naipes[naipe] = pessoaNome;
    }
  }

  return Musica(
    id: json['id']?.toString(),
    catalogoMusicaId: json['catalogo_musica_id']?.toString(),
    nome: (json['nome'] ?? '').toString(),
    autor: json['autor']?.toString(),
    link: json['link']?.toString(),
    descricao: (json['descricao'] ?? '').toString(),
    naipes: naipes,
  );
}

Evento? obterEventoLocalPorId(String eventoId) {
  for (final evento in mockEventos) {
    if (evento.id == eventoId) {
      return evento;
    }
  }
  return null;
}

void _upsertPessoa(Pessoa pessoa) {
  final index = mockPessoas.indexWhere((item) => item.id == pessoa.id);
  if (index == -1) {
    mockPessoas.add(pessoa);
  } else {
    mockPessoas[index] = pessoa;
  }
}

void _upsertCatalogoMusica(CatalogoMusica musica) {
  final index = mockCatalogoMusicas.indexWhere((item) => item.id == musica.id);
  if (index == -1) {
    mockCatalogoMusicas.add(musica);
  } else {
    mockCatalogoMusicas[index] = musica;
  }
}

void _upsertEvento(Evento evento) {
  final index = mockEventos.indexWhere((item) => item.id == evento.id);
  if (index == -1) {
    mockEventos.add(evento);
  } else {
    mockEventos[index] = evento;
  }
}

void _setMusicasEvento(String eventoId, List<Musica> musicas) {
  final index = mockEventos.indexWhere((evento) => evento.id == eventoId);
  if (index == -1) return;
  mockEventos[index] = mockEventos[index].copyWith(musicas: musicas);
}

void _replaceFrequenciasEvento(String eventoId, List<Frequencia> frequencias) {
  mockFrequencias.removeWhere((item) => item.eventoId == eventoId);
  mockFrequencias.addAll(frequencias);
}

Future<void> ensureBackendDataLoaded({bool force = false}) async {
  if (!force && _backendLoaded) {
    return;
  }

  if (_loadingFuture != null) {
    await _loadingFuture;
    if (!force || _backendLoaded) {
      return;
    }
  }

  _loadingFuture = _loadAllFromBackend();
  try {
    await _loadingFuture;
  } finally {
    _loadingFuture = null;
  }
}

Future<void> recarregarDadosBackend() async {
  await ensureBackendDataLoaded(force: true);
}

Future<void> _loadAllFromBackend() async {
  final pessoasRaw = _asList(await _request('GET', '/pessoas'), '/pessoas');

  mockPessoas
    ..clear()
    ..addAll(
      pessoasRaw.map((raw) => _pessoaFromJson(_asMap(raw, '/pessoas.item'))),
    );

  final catalogoRaw = _asList(
    await _request('GET', '/catalogo-musicas'),
    '/catalogo-musicas',
  );
  mockCatalogoMusicas
    ..clear()
    ..addAll(
      catalogoRaw.map(
        (raw) => _catalogoMusicaFromJson(_asMap(raw, '/catalogo-musicas.item')),
      ),
    );

  final ciclosRaw = _asList(await _request('GET', '/ciclos'), '/ciclos');

  mockCiclos.clear();
  _cicloIdByAno.clear();

  for (final raw in ciclosRaw) {
    final cicloMap = _asMap(raw, '/ciclos.item');
    final ano = (cicloMap['ano'] as num).toInt();
    final cicloId = cicloMap['id'].toString();

    mockCiclos.add(
      Ciclo(id: cicloId, ano: ano, ativo: cicloMap['ativo'] == true),
    );
    _cicloIdByAno[ano] = cicloId;
  }

  mockTrimestres.clear();
  for (final ciclo in mockCiclos) {
    if (ciclo.id == null) continue;
    final trimestresRaw = _asList(
      await _request('GET', '/ciclos/${ciclo.id}/trimestres'),
      '/ciclos/${ciclo.id}/trimestres',
    );

    for (final raw in trimestresRaw) {
      final trimestreMap = _asMap(raw, '/trimestres.item');
      mockTrimestres.add(
        Trimestre(
          id: trimestreMap['id'].toString(),
          anoId: ciclo.ano,
          numero: (trimestreMap['numero'] as num).toInt(),
        ),
      );
    }
  }

  mockMatriculas.clear();
  mockEventos.clear();

  for (final trimestre in mockTrimestres) {
    final matriculasRaw = _asList(
      await _request('GET', '/trimestres/${trimestre.id}/matriculas'),
      '/trimestres/${trimestre.id}/matriculas',
    );
    mockMatriculas.addAll(
      matriculasRaw.map(
        (raw) => _matriculaFromJson(_asMap(raw, '/matriculas.item')),
      ),
    );

    final eventosRaw = _asList(
      await _request('GET', '/trimestres/${trimestre.id}/eventos'),
      '/trimestres/${trimestre.id}/eventos',
    );
    for (final raw in eventosRaw) {
      final evento = _eventoFromJson(_asMap(raw, '/eventos.item'));
      _upsertEvento(evento);
    }
  }

  final pessoaNomePorId = _pessoaNomeById();

  mockFrequencias.clear();
  for (final evento in mockEventos) {
    final frequenciasRaw = _asList(
      await _request('GET', '/eventos/${evento.id}/frequencias'),
      '/eventos/${evento.id}/frequencias',
    );
    mockFrequencias.addAll(
      frequenciasRaw.map(
        (raw) => _frequenciaFromJson(
          _asMap(raw, '/eventos/${evento.id}/frequencias.item'),
        ),
      ),
    );

    final musicasRaw = _asList(
      await _request('GET', '/eventos/${evento.id}/musicas'),
      '/eventos/${evento.id}/musicas',
    );

    final musicas = musicasRaw
        .map(
          (raw) => _musicaFromJson(
            _asMap(raw, '/eventos/${evento.id}/musicas.item'),
            pessoaNomePorId,
          ),
        )
        .toList();

    _setMusicasEvento(evento.id, musicas);
  }

  _backendLoaded = true;
}

Future<Pessoa> criarPessoa({
  required String nome,
  required DateTime dataNascimento,
  required String telefone,
  required ClassificacaoVocal classificacaoVocal,
  required TipoPessoa tipoPadrao,
}) async {
  final payload = {
    'nome': nome,
    'data_nascimento': _yyyyMmDd(dataNascimento),
    'telefone': telefone,
    'classificacao_vocal': _classificacaoToApi(classificacaoVocal),
    'tipo_padrao': _tipoPessoaToApi(tipoPadrao),
  };

  final created = _pessoaFromJson(
    _asMap(await _request('POST', '/pessoas', body: payload), '/pessoas.post'),
  );
  _upsertPessoa(created);
  return created;
}

Future<Pessoa> atualizarPessoa(Pessoa pessoa) async {
  final payload = {
    'nome': pessoa.nome,
    'data_nascimento': _yyyyMmDd(pessoa.dataNascimento),
    'telefone': pessoa.telefone,
    'classificacao_vocal': _classificacaoToApi(pessoa.classificacaoVocal),
    'tipo_padrao': _tipoPessoaToApi(pessoa.tipoPadrao),
    'foto_url': pessoa.fotoUrl,
  };

  final updated = _pessoaFromJson(
    _asMap(
      await _request('PUT', '/pessoas/${pessoa.id}', body: payload),
      '/pessoas.put',
    ),
  );
  _upsertPessoa(updated);
  return updated;
}

Future<void> excluirPessoa(String pessoaId) async {
  await _request('DELETE', '/pessoas/$pessoaId');
  mockPessoas.removeWhere((pessoa) => pessoa.id == pessoaId);
  mockMatriculas.removeWhere((matricula) => matricula.pessoaId == pessoaId);
  mockFrequencias.removeWhere((freq) => freq.pessoaId == pessoaId);
}

Future<List<CatalogoMusica>> listarCatalogoMusicas({
  bool apenasAtivas = false,
}) async {
  final raw = _asList(
    await _request(
      'GET',
      '/catalogo-musicas',
      query: {'apenas_ativas': apenasAtivas ? 'true' : 'false'},
    ),
    '/catalogo-musicas',
  );
  final musicas = raw
      .map(
        (item) =>
            _catalogoMusicaFromJson(_asMap(item, '/catalogo-musicas.item')),
      )
      .toList();
  mockCatalogoMusicas
    ..clear()
    ..addAll(musicas);
  return musicas;
}

Future<CatalogoMusica> criarCatalogoMusica({
  required String nome,
  String? autor,
  String? link,
  String descricao = '',
  bool ativo = true,
}) async {
  final payload = {
    'nome': nome,
    'autor': autor,
    'link': link,
    'descricao': descricao,
    'ativo': ativo,
  };
  final created = _catalogoMusicaFromJson(
    _asMap(
      await _request('POST', '/catalogo-musicas', body: payload),
      '/catalogo-musicas.post',
    ),
  );
  _upsertCatalogoMusica(created);
  return created;
}

Future<CatalogoMusica> atualizarCatalogoMusica(CatalogoMusica musica) async {
  final payload = {
    'nome': musica.nome,
    'autor': musica.autor,
    'link': musica.link,
    'descricao': musica.descricao,
    'ativo': musica.ativo,
  };
  final updated = _catalogoMusicaFromJson(
    _asMap(
      await _request('PUT', '/catalogo-musicas/${musica.id}', body: payload),
      '/catalogo-musicas.put',
    ),
  );
  _upsertCatalogoMusica(updated);
  return updated;
}

Future<void> excluirCatalogoMusica(String musicaId) async {
  await _request('DELETE', '/catalogo-musicas/$musicaId');
  mockCatalogoMusicas.removeWhere((musica) => musica.id == musicaId);
}

Future<Evento> criarEvento({
  required String trimestreId,
  required String nome,
  required String descricao,
  required DateTime dataHora,
}) async {
  final payload = {
    'trimestre_id': trimestreId,
    'nome': nome,
    'descricao': descricao,
    'data_hora': _yyyyMmDdThhMmSs(dataHora),
  };

  final created = _eventoFromJson(
    _asMap(await _request('POST', '/eventos', body: payload), '/eventos.post'),
  );
  _upsertEvento(created);
  return created;
}

Future<Evento> buscarEvento(String eventoId) async {
  final eventoMap = _asMap(
    await _request('GET', '/eventos/$eventoId'),
    '/eventos/{id}',
  );
  final pessoaNomePorId = _pessoaNomeById();
  final musicasRaw = _asList(
    await _request('GET', '/eventos/$eventoId/musicas'),
    '/eventos/{id}/musicas',
  );

  final musicas = musicasRaw
      .map(
        (raw) => _musicaFromJson(
          _asMap(raw, '/eventos/{id}/musicas.item'),
          pessoaNomePorId,
        ),
      )
      .toList();

  final evento = _eventoFromJson(eventoMap, musicas: musicas);
  _upsertEvento(evento);
  return evento;
}

Future<Evento> atualizarEventoBasico(Evento evento) async {
  final payload = {
    'nome': evento.nome,
    'descricao': evento.descricao,
    'data_hora': _yyyyMmDdThhMmSs(evento.dataHora),
  };

  final existing = obterEventoLocalPorId(evento.id);
  final updatedMap = _asMap(
    await _request('PUT', '/eventos/${evento.id}', body: payload),
    '/eventos/{id}.put',
  );
  final updated = _eventoFromJson(
    updatedMap,
    musicas: existing?.musicas ?? evento.musicas,
  );
  _upsertEvento(updated);
  return updated;
}

Future<void> excluirEvento(String eventoId) async {
  await _request('DELETE', '/eventos/$eventoId');
  mockEventos.removeWhere((evento) => evento.id == eventoId);
  mockFrequencias.removeWhere((freq) => freq.eventoId == eventoId);
}

List<Map<String, dynamic>> _escalasPayloadFromMusica(Musica musica) {
  final pessoaIdPorNome = _pessoaIdByNome();
  final payload = <Map<String, dynamic>>[];

  for (final entry in musica.naipes.entries) {
    final nomeEscalado = entry.value.trim();
    payload.add({
      'naipe': _naipeToApi(entry.key),
      'pessoa_id': nomeEscalado.isEmpty ? null : pessoaIdPorNome[nomeEscalado],
    });
  }

  return payload;
}

Future<Musica> criarMusicaEvento({
  required String eventoId,
  required Musica musica,
  required int ordem,
}) async {
  final payload = {
    'catalogo_musica_id': musica.catalogoMusicaId,
    'nome': musica.nome.trim().isEmpty ? 'Nova música' : musica.nome.trim(),
    'autor': (musica.autor ?? '').trim().isEmpty ? null : musica.autor!.trim(),
    'link': (musica.link ?? '').trim().isEmpty ? null : musica.link!.trim(),
    'descricao': musica.descricao,
    'ordem': ordem,
    'escalas': _escalasPayloadFromMusica(musica),
  };

  final createdMap = _asMap(
    await _request('POST', '/eventos/$eventoId/musicas', body: payload),
    '/eventos/{id}/musicas.post',
  );
  final created = _musicaFromJson(createdMap, _pessoaNomeById());

  final evento = obterEventoLocalPorId(eventoId);
  final musicas = [...?evento?.musicas, created];
  _setMusicasEvento(eventoId, musicas);
  return created;
}

Future<List<Musica>> selecionarCatalogoMusicasNoEvento({
  required String eventoId,
  required List<String> catalogoMusicaIds,
}) async {
  final raw = _asList(
    await _request(
      'POST',
      '/eventos/$eventoId/musicas/selecionar',
      body: {'catalogo_musica_ids': catalogoMusicaIds},
    ),
    '/eventos/{id}/musicas/selecionar',
  );
  final musicas = raw
      .map(
        (item) => _musicaFromJson(
          _asMap(item, '/eventos/{id}/musicas/selecionar.item'),
          _pessoaNomeById(),
        ),
      )
      .toList();
  _setMusicasEvento(eventoId, musicas);
  return musicas;
}

Future<Musica> atualizarMusicaEvento({
  required String eventoId,
  required Musica musica,
  required int ordem,
}) async {
  if (musica.id == null || musica.id!.isEmpty) {
    throw BackendException('Música sem ID para atualizar.');
  }

  final payload = {
    'nome': musica.nome.trim().isEmpty ? 'Nova música' : musica.nome.trim(),
    'autor': (musica.autor ?? '').trim().isEmpty ? null : musica.autor!.trim(),
    'link': (musica.link ?? '').trim().isEmpty ? null : musica.link!.trim(),
    'descricao': musica.descricao,
    'ordem': ordem,
  };

  final updatedMap = _asMap(
    await _request(
      'PUT',
      '/eventos/$eventoId/musicas/${musica.id}',
      body: payload,
    ),
    '/eventos/{id}/musicas/{id}.put',
  );

  final updated = _musicaFromJson(updatedMap, _pessoaNomeById());
  final evento = obterEventoLocalPorId(eventoId);
  if (evento == null) return updated;

  final musicas = [...evento.musicas];
  final index = musicas.indexWhere((item) => item.id == updated.id);
  if (index == -1) {
    musicas.add(updated);
  } else {
    musicas[index] = updated;
  }
  _setMusicasEvento(eventoId, musicas);
  return updated;
}

Future<Musica> substituirEscalasMusica({
  required String eventoId,
  required Musica musica,
}) async {
  if (musica.id == null || musica.id!.isEmpty) {
    throw BackendException('Música sem ID para salvar escalas.');
  }

  final payload = {'escalas': _escalasPayloadFromMusica(musica)};

  final updatedMap = _asMap(
    await _request('PUT', '/musicas/${musica.id}/escalas', body: payload),
    '/musicas/{id}/escalas.put',
  );

  final updated = _musicaFromJson(updatedMap, _pessoaNomeById());
  final evento = obterEventoLocalPorId(eventoId);
  if (evento == null) return updated;

  final musicas = [...evento.musicas];
  final index = musicas.indexWhere((item) => item.id == updated.id);
  if (index != -1) {
    musicas[index] = updated;
    _setMusicasEvento(eventoId, musicas);
  }
  return updated;
}

Future<void> excluirMusicaEvento({
  required String eventoId,
  required String musicaId,
}) async {
  await _request('DELETE', '/eventos/$eventoId/musicas/$musicaId');
  final evento = obterEventoLocalPorId(eventoId);
  if (evento == null) return;
  _setMusicasEvento(
    eventoId,
    evento.musicas.where((musica) => musica.id != musicaId).toList(),
  );
}

Future<Evento> uploadAnexoEvento({
  required String eventoId,
  required String filePath,
}) async {
  final updatedMap = await _uploadFile('/eventos/$eventoId/anexo', filePath);
  final existing = obterEventoLocalPorId(eventoId);
  final updated = _eventoFromJson(
    updatedMap,
    musicas: existing?.musicas ?? const [],
  );
  _upsertEvento(updated);
  return updated;
}

Future<Evento> removerAnexoEvento(String eventoId) async {
  final updatedMap = _asMap(
    await _request('DELETE', '/eventos/$eventoId/anexo'),
    '/eventos/{id}/anexo.delete',
  );
  final existing = obterEventoLocalPorId(eventoId);
  final updated = _eventoFromJson(
    updatedMap,
    musicas: existing?.musicas ?? const [],
  );
  _upsertEvento(updated);
  return updated;
}

Future<void> salvarFrequenciasEvento(
  String eventoId,
  Map<String, String> frequenciasPorPessoa,
) async {
  final payload = {
    'frequencias': frequenciasPorPessoa.entries
        .map(
          (entry) => {
            'pessoa_id': entry.key,
            'status': _statusFromUi(entry.value),
          },
        )
        .toList(),
  };

  final raw = _asList(
    await _request('PUT', '/eventos/$eventoId/frequencias', body: payload),
    '/eventos/{id}/frequencias.put',
  );

  final mapped = raw
      .map((item) => _frequenciaFromJson(_asMap(item, '/frequencias.item')))
      .toList();
  _replaceFrequenciasEvento(eventoId, mapped);
}

Future<void> garantirCicloAnoAtual() async {
  final anoAtual = DateTime.now().year;
  final jaExiste = mockCiclos.any((ciclo) => ciclo.ano == anoAtual);
  if (jaExiste) return;

  final created = _asMap(
    await _request(
      'POST',
      '/ciclos',
      body: {'ano': anoAtual, 'ativo': true, 'criar_trimestres': true},
    ),
    '/ciclos.post',
  );

  final cicloId = created['id'].toString();
  mockCiclos.add(
    Ciclo(id: cicloId, ano: anoAtual, ativo: created['ativo'] == true),
  );
  _cicloIdByAno[anoAtual] = cicloId;

  final trimestresRaw = _asList(
    await _request('GET', '/ciclos/$cicloId/trimestres'),
    '/ciclos/{id}/trimestres',
  );

  for (final raw in trimestresRaw) {
    final trimestreMap = _asMap(raw, '/trimestres.item');
    mockTrimestres.add(
      Trimestre(
        id: trimestreMap['id'].toString(),
        anoId: anoAtual,
        numero: (trimestreMap['numero'] as num).toInt(),
      ),
    );
  }
}
