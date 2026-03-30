class Musica {
  final String nome;
  final Map<String, String> naipes; // key: 'Soprano','Contralto','Tenor','Baixo', value: nome do coralista
  final String? link;

  Musica({
    required this.nome,
    required this.naipes,
    this.link,
  });

  static const List<String> todosNaipes = ['Soprano', 'Contralto', 'Tenor', 'Baixo'];

  /// Retorna mapa de naipes vazios
  static Map<String, String> naipesVazios() {
    return {
      'Soprano': '',
      'Contralto': '',
      'Tenor': '',
      'Baixo': '',
    };
  }
}
