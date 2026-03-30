import 'musica.dart';

enum TipoEvento { ensaioGeral, ensaioNaipe, reuniao }

class Evento {
  final String id;
  final String trimestreId;
  final DateTime dataHora;
  final TipoEvento tipo;
  final String? nome;
  final List<Musica> musicas;

  Evento({
    required this.id,
    required this.trimestreId,
    required this.dataHora,
    required this.tipo,
    this.nome,
    this.musicas = const [],
  });
}