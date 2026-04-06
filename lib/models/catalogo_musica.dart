class CatalogoMusica {
  final String id;
  final String nome;
  final String? autor;
  final String? link;
  final String descricao;
  final bool ativo;

  CatalogoMusica({
    required this.id,
    required this.nome,
    this.autor,
    this.link,
    this.descricao = '',
    this.ativo = true,
  });
}
