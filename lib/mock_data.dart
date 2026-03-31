import 'models/pessoa.dart';
import 'models/ciclo.dart';
import 'models/trimestre.dart';
import 'models/matricula.dart';
import 'models/evento.dart';
import 'models/frequencia.dart';
import 'models/musica.dart';

// Mock data
final List<Pessoa> mockPessoas = [
  Pessoa(
    id: '1',
    nome: 'João Silva',
    dataNascimento: DateTime(1990, 1, 1),
    telefone: '(11) 99999-0001',
    classificacaoVocal: ClassificacaoVocal.tenor,
    tipoPadrao: TipoPessoa.coralista,
  ),
  Pessoa(
    id: '2',
    nome: 'Maria Santos',
    dataNascimento: DateTime(1985, 5, 10),
    telefone: '(11) 99999-0002',
    classificacaoVocal: ClassificacaoVocal.soprano,
    tipoPadrao: TipoPessoa.coralista,
  ),
  Pessoa(
    id: '3',
    nome: 'Pedro Oliveira',
    dataNascimento: DateTime(1975, 12, 15),
    telefone: '(11) 99999-0003',
    classificacaoVocal: ClassificacaoVocal.baixo,
    tipoPadrao: TipoPessoa.regente,
  ),
  Pessoa(
    id: '4',
    nome: 'Ana Costa',
    dataNascimento: DateTime(1992, 3, 22),
    telefone: '(11) 99999-0004',
    classificacaoVocal: ClassificacaoVocal.contralto,
    tipoPadrao: TipoPessoa.coralista,
  ),
  Pessoa(
    id: '5',
    nome: 'Lucas Ferreira',
    dataNascimento: DateTime(1988, 7, 8),
    telefone: '(11) 99999-0005',
    classificacaoVocal: ClassificacaoVocal.tenor,
    tipoPadrao: TipoPessoa.coralista,
  ),
  Pessoa(
    id: '6',
    nome: 'Fernanda Lima',
    dataNascimento: DateTime(1995, 11, 30),
    telefone: '(11) 99999-0006',
    classificacaoVocal: ClassificacaoVocal.soprano,
    tipoPadrao: TipoPessoa.coralista,
  ),
  Pessoa(
    id: '7',
    nome: 'Carla Mendes',
    dataNascimento: DateTime(1993, 9, 14),
    telefone: '(11) 99999-0007',
    classificacaoVocal: ClassificacaoVocal.contralto,
    tipoPadrao: TipoPessoa.coralista,
  ),
  Pessoa(
    id: '8',
    nome: 'Ricardo Alves',
    dataNascimento: DateTime(1987, 4, 20),
    telefone: '(11) 99999-0008',
    classificacaoVocal: ClassificacaoVocal.baixo,
    tipoPadrao: TipoPessoa.coralista,
  ),
];

final List<Ciclo> mockCiclos = [
  Ciclo(ano: 2025, ativo: false),
  Ciclo(ano: 2026, ativo: true),
];

final List<Trimestre> mockTrimestres = [
  Trimestre(id: 't1', anoId: 2026, numero: 1),
  Trimestre(id: 't2', anoId: 2026, numero: 2),
  Trimestre(id: 't3', anoId: 2026, numero: 3),
  Trimestre(id: 't4', anoId: 2026, numero: 4),
];

final List<Matricula> mockMatriculas = [
  Matricula(
    trimestreId: 't1',
    pessoaId: '1',
    funcaoNoTrimestre: FuncaoTrimestre.coralista,
  ),
  Matricula(
    trimestreId: 't1',
    pessoaId: '2',
    funcaoNoTrimestre: FuncaoTrimestre.coralista,
  ),
  Matricula(
    trimestreId: 't1',
    pessoaId: '3',
    funcaoNoTrimestre: FuncaoTrimestre.regente,
  ),
  Matricula(
    trimestreId: 't1',
    pessoaId: '4',
    funcaoNoTrimestre: FuncaoTrimestre.coralista,
  ),
  Matricula(
    trimestreId: 't1',
    pessoaId: '5',
    funcaoNoTrimestre: FuncaoTrimestre.coralista,
  ),
  Matricula(
    trimestreId: 't1',
    pessoaId: '6',
    funcaoNoTrimestre: FuncaoTrimestre.coralista,
  ),
  Matricula(
    trimestreId: 't1',
    pessoaId: '7',
    funcaoNoTrimestre: FuncaoTrimestre.coralista,
  ),
  Matricula(
    trimestreId: 't1',
    pessoaId: '8',
    funcaoNoTrimestre: FuncaoTrimestre.coralista,
  ),
];

final List<Evento> mockEventos = [
  Evento(
    id: 'e1',
    trimestreId: 't1',
    dataHora: DateTime(2026, 2, 20, 19, 0),
    nome: 'Ensaio Geral - Fevereiro',
    descricao: 'Ensaio geral com foco no repertório de fevereiro.',
    musicas: [
      Musica(
        nome: 'Grande é o Senhor',
        naipes: {
          'Soprano': 'Maria Santos',
          'Contralto': 'Ana Costa',
          'Tenor': 'João Silva',
          'Baixo': 'Ricardo Alves',
        },
        link: 'https://example.com/grande-e-o-senhor',
      ),
      Musica(
        nome: 'Aleluia',
        naipes: {
          'Soprano': 'Fernanda Lima',
          'Contralto': 'Carla Mendes',
          'Tenor': 'Lucas Ferreira',
          'Baixo': '',
        },
        link: 'https://example.com/aleluia',
      ),
    ],
  ),
  Evento(
    id: 'e2',
    trimestreId: 't1',
    dataHora: DateTime(2026, 2, 27, 19, 0),
    nome: 'Ensaio de Naipe - Soprano',
    descricao: 'Ajustes de afinação e dinâmica para o naipe soprano.',
    musicas: [
      Musica(
        nome: 'Magnificent',
        naipes: {
          'Soprano': 'Maria Santos',
          'Contralto': 'Ana Costa',
          'Tenor': '',
          'Baixo': '',
        },
        link: 'https://example.com/magnificent',
      ),
    ],
  ),
  Evento(
    id: 'e3',
    trimestreId: 't1',
    dataHora: DateTime(2026, 2, 15, 19, 0),
    nome: 'Ensaio Geral - Meio de Fev',
    descricao: 'Revisão intermediária do repertório do trimestre.',
  ),
];

final List<Frequencia> mockFrequencias = [
  Frequencia(eventoId: 'e1', pessoaId: '1', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e1', pessoaId: '2', status: StatusFrequencia.falta),
  Frequencia(eventoId: 'e1', pessoaId: '4', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e1', pessoaId: '5', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e1', pessoaId: '6', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e1', pessoaId: '7', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e1', pessoaId: '8', status: StatusFrequencia.falta),
  Frequencia(eventoId: 'e2', pessoaId: '1', status: StatusFrequencia.presenca),
  Frequencia(
    eventoId: 'e2',
    pessoaId: '2',
    status: StatusFrequencia.faltaJustificada,
    justificativa: 'Consulta médica',
  ),
  Frequencia(eventoId: 'e2', pessoaId: '4', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e2', pessoaId: '5', status: StatusFrequencia.falta),
  Frequencia(eventoId: 'e3', pessoaId: '1', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e3', pessoaId: '2', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e3', pessoaId: '4', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e3', pessoaId: '5', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e3', pessoaId: '6', status: StatusFrequencia.falta),
  Frequencia(eventoId: 'e3', pessoaId: '7', status: StatusFrequencia.presenca),
  Frequencia(eventoId: 'e3', pessoaId: '8', status: StatusFrequencia.presenca),
];
