import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../mock_data.dart';
import '../models/evento.dart';
import '../models/pessoa.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  List<DateTime> _proximosSeteDias(DateTime hoje) {
    return List.generate(
      7,
      (index) => DateTime(hoje.year, hoje.month, hoje.day + index),
    );
  }

  List<Evento> _eventosOrdenados() {
    final eventos = [...mockEventos]
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
    return eventos;
  }

  String _rotuloDiaSemana(DateTime data) {
    switch (data.weekday) {
      case DateTime.monday:
        return 'SEG';
      case DateTime.tuesday:
        return 'TER';
      case DateTime.wednesday:
        return 'QUA';
      case DateTime.thursday:
        return 'QUI';
      case DateTime.friday:
        return 'SEX';
      case DateTime.saturday:
        return 'SAB';
      case DateTime.sunday:
        return 'DOM';
      default:
        return '';
    }
  }

  int _eventosNoDia(DateTime dia) {
    return mockEventos.where((evento) {
      final data = evento.dataHora;
      return data.year == dia.year &&
          data.month == dia.month &&
          data.day == dia.day;
    }).length;
  }

  List<Evento> _listaEventosNoDia(DateTime dia) {
    final eventosDoDia =
        mockEventos.where((evento) {
            final data = evento.dataHora;
            return data.year == dia.year &&
                data.month == dia.month &&
                data.day == dia.day;
          }).toList()
          ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    return eventosDoDia;
  }

  Future<void> _abrirEventosDoDia(
    BuildContext context,
    DateTime dia,
  ) async {
    final eventosDoDia = _listaEventosNoDia(dia);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eventos de ${DateFormat('dd/MM/yyyy').format(dia)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3C2A53),
                  ),
                ),
                const SizedBox(height: 10),
                if (eventosDoDia.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Nenhum evento neste dia.',
                      style: TextStyle(color: Color(0xFF7E6D95)),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: eventosDoDia.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final evento = eventosDoDia[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.event_note,
                            size: 20,
                            color: Color(0xFF6E3C98),
                          ),
                          title: Text(
                            evento.nome,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3D2A56),
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('HH:mm').format(evento.dataHora),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7E6D95),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _eventosNaSemana(DateTime hoje) {
    final fimSemana = hoje.add(const Duration(days: 7));
    return mockEventos
        .where(
          (evento) =>
              !evento.dataHora.isBefore(hoje) &&
              evento.dataHora.isBefore(fimSemana),
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final eventosOrdenados = _eventosOrdenados();
    final proximosEventos = eventosOrdenados
        .where((evento) => !evento.dataHora.isBefore(hoje))
        .toList();
    final proximoEvento = proximosEventos.isNotEmpty
        ? proximosEventos.first
        : null;

    final totalCoralistas = mockPessoas
        .where((pessoa) => pessoa.tipoPadrao == TipoPessoa.coralista)
        .length;
    final totalMusicas = mockEventos.fold<int>(
      0,
      (total, evento) => total + evento.musicas.length,
    );
    final eventosMes = mockEventos
        .where(
          (evento) =>
              evento.dataHora.year == hoje.year &&
              evento.dataHora.month == hoje.month,
        )
        .length;

    final cicloAtivo = mockCiclos.where((ciclo) => ciclo.ativo).toList();
    final anoAtivoLabel = cicloAtivo.isNotEmpty
        ? cicloAtivo.first.ano.toString()
        : 'Sem ano ativo';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequência Koinonia'),
        actions: [
          IconButton(
            tooltip: 'Ver eventos por trimestre',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.pushNamed(context, '/eventos'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F6FB), Color(0xFFF1ECF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6E3C98), Color(0xFF8C57B1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Painel Inicial',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    proximoEvento != null
                        ? 'Próximo evento: ${proximoEvento.nome}'
                        : 'Sem próximos eventos cadastrados',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  if (proximoEvento != null)
                    Text(
                      DateFormat(
                        'dd/MM/yyyy • HH:mm',
                      ).format(proximoEvento.dataHora),
                      style: const TextStyle(
                        color: Color(0xFFEDE2F8),
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(label: 'Ano: $anoAtivoLabel'),
                      _InfoPill(label: 'Eventos: ${mockEventos.length}'),
                      _InfoPill(label: 'Coralistas: $totalCoralistas'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.groups_2_outlined,
                    label: 'Coralistas',
                    value: '$totalCoralistas',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available_outlined,
                    label: 'No mês',
                    value: '$eventosMes',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.library_music_outlined,
                    label: 'Músicas',
                    value: '$totalMusicas',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.today_outlined,
                    label: 'Na semana',
                    value: '${_eventosNaSemana(hoje)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Agenda dos próximos dias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3C2A53),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _proximosSeteDias(hoje).length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final dia = _proximosSeteDias(hoje)[index];
                  final qtdEventos = _eventosNoDia(dia);
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _abrirEventosDoDia(context, dia),
                      child: Container(
                        width: 78,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE7DFF2)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _rotuloDiaSemana(dia),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B6AA9),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              DateFormat('dd').format(dia),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A2F68),
                              ),
                            ),
                            Text(
                              qtdEventos == 0 ? '-' : '$qtdEventos',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: qtdEventos == 0
                                    ? Colors.grey
                                    : const Color(0xFF5E3A84),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Ações rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3C2A53),
              ),
            ),
            const SizedBox(height: 10),
            _QuickActionButton(
              icon: Icons.person_add_alt_1,
              title: 'Cadastrar novo coralista',
              subtitle: 'Adicionar e editar pessoas do grupo',
              onTap: () => Navigator.pushNamed(context, '/coralistas'),
            ),
            const SizedBox(height: 8),
            _QuickActionButton(
              icon: Icons.event_note,
              title: 'Ver eventos por trimestre',
              subtitle: 'Abrir a tela de ano e trimestre',
              onTap: () => Navigator.pushNamed(context, '/eventos'),
            ),
            const SizedBox(height: 8),
            _QuickActionButton(
              icon: Icons.insights,
              title: 'Ver estatísticas',
              subtitle: 'Painel com frequência e indicadores',
              onTap: () => Navigator.pushNamed(context, '/estatisticas'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;

  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6DDF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6E3C98)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF3D2A56),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7E6D95), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6DDF1)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEE7F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF6E3C98)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D2A56),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7E6D95),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF7E6D95),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
