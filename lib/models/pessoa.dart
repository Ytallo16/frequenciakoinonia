enum ClassificacaoVocal { soprano, contralto, tenor, baixo, na }

enum TipoPessoa { coralista, membro, regente }

class Pessoa {
  final String id;
  final String nome;
  final DateTime dataNascimento;
  final String telefone;
  final ClassificacaoVocal classificacaoVocal;
  final TipoPessoa tipoPadrao;
  final String? fotoUrl;

  Pessoa({
    required this.id,
    required this.nome,
    required this.dataNascimento,
    required this.telefone,
    required this.classificacaoVocal,
    required this.tipoPadrao,
    this.fotoUrl,
  });
}