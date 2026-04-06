class Musica {
  final String? id;
  final String? catalogoMusicaId;
  final String nome;
  final String? autor;
  final Map<String, String>
  naipes; // key: 'Soprano','Contralto','Tenor','Baixo', value: nome do coralista
  final String? link;
  final String descricao;

  Musica({
    this.id,
    this.catalogoMusicaId,
    required this.nome,
    this.autor,
    required this.naipes,
    this.link,
    this.descricao = '',
  });

  Musica copyWith({
    String? id,
    String? catalogoMusicaId,
    String? nome,
    String? autor,
    Map<String, String>? naipes,
    String? link,
    String? descricao,
  }) {
    return Musica(
      id: id ?? this.id,
      catalogoMusicaId: catalogoMusicaId ?? this.catalogoMusicaId,
      nome: nome ?? this.nome,
      autor: autor ?? this.autor,
      naipes: naipes ?? this.naipes,
      link: link ?? this.link,
      descricao: descricao ?? this.descricao,
    );
  }

  static const List<String> todosNaipes = [
    'Soprano',
    'Contralto',
    'Tenor',
    'Baixo',
  ];

  /// Retorna mapa de naipes vazios
  static Map<String, String> naipesVazios() {
    return {'Soprano': '', 'Contralto': '', 'Tenor': '', 'Baixo': ''};
  }
}
