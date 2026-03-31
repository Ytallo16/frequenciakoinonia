import 'musica.dart';

class Evento {
  final String id;
  final String trimestreId;
  final DateTime dataHora;
  final String nome;
  final String descricao;
  final String? anexoPath;
  final String? anexoNome;
  final String? anexoMimeType;
  final List<Musica> musicas;

  Evento({
    required this.id,
    required this.trimestreId,
    required this.dataHora,
    required this.nome,
    this.descricao = '',
    this.anexoPath,
    this.anexoNome,
    this.anexoMimeType,
    this.musicas = const [],
  });

  Evento copyWith({
    String? id,
    String? trimestreId,
    DateTime? dataHora,
    String? nome,
    String? descricao,
    String? anexoPath,
    String? anexoNome,
    String? anexoMimeType,
    List<Musica>? musicas,
    bool limparAnexo = false,
  }) {
    return Evento(
      id: id ?? this.id,
      trimestreId: trimestreId ?? this.trimestreId,
      dataHora: dataHora ?? this.dataHora,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      anexoPath: limparAnexo ? null : (anexoPath ?? this.anexoPath),
      anexoNome: limparAnexo ? null : (anexoNome ?? this.anexoNome),
      anexoMimeType: limparAnexo ? null : (anexoMimeType ?? this.anexoMimeType),
      musicas: musicas ?? this.musicas,
    );
  }
}
