enum FuncaoTrimestre { coralista, membro, regente }

class Matricula {
  final String trimestreId;
  final String pessoaId;
  final FuncaoTrimestre funcaoNoTrimestre;

  Matricula({
    required this.trimestreId,
    required this.pessoaId,
    required this.funcaoNoTrimestre,
  });
}