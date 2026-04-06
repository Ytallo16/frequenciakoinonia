enum StatusFrequencia { presenca, falta, atraso, faltaJustificada }

class Frequencia {
  final String? id;
  final String eventoId;
  final String pessoaId;
  final StatusFrequencia status;
  final String? imagemPath;
  final String? justificativa;

  Frequencia({
    this.id,
    required this.eventoId,
    required this.pessoaId,
    required this.status,
    this.imagemPath,
    this.justificativa,
  });
}
