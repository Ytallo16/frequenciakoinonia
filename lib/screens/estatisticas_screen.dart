import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../mock_data.dart';
import '../models/pessoa.dart';
import '../models/frequencia.dart';

class EstatisticasScreen extends StatefulWidget {
  const EstatisticasScreen({super.key});

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _filtroNaipe; // null = Todos

  static const _naipeColors = {
    'Soprano': Color(0xFFEC4899),
    'Contralto': Color(0xFF8B5CF6),
    'Tenor': Color(0xFF3B82F6),
    'Baixo': Color(0xFF10B981),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _classifLabel(ClassificacaoVocal c) {
    switch (c) {
      case ClassificacaoVocal.soprano:
        return 'Soprano';
      case ClassificacaoVocal.contralto:
        return 'Contralto';
      case ClassificacaoVocal.tenor:
        return 'Tenor';
      case ClassificacaoVocal.baixo:
        return 'Baixo';
      case ClassificacaoVocal.na:
        return 'N/A';
    }
  }

  Color _classifColor(ClassificacaoVocal c) {
    return _naipeColors[_classifLabel(c)] ?? AppColors.textSecondary;
  }

  List<Pessoa> get _coralistas {
    var list = mockPessoas.where((p) => p.tipoPadrao == TipoPessoa.coralista).toList();
    if (_filtroNaipe != null) {
      list = list.where((p) => _classifLabel(p.classificacaoVocal) == _filtroNaipe).toList();
    }
    return list;
  }

  // Get frequency stats for a person
  Map<String, int> _getFreqStats(String pessoaId) {
    final f = mockFrequencias.where((f) => f.pessoaId == pessoaId);
    int presenca = 0, falta = 0, fj = 0;
    for (var freq in f) {
      switch (freq.status) {
        case StatusFrequencia.presenca:
          presenca++;
          break;
        case StatusFrequencia.falta:
          falta++;
          break;
        case StatusFrequencia.faltaJustificada:
          fj++;
          break;
        case StatusFrequencia.atraso:
          presenca++;
          break;
      }
    }
    final total = presenca + falta + fj;
    return {
      'presenca': presenca,
      'falta': falta,
      'fj': fj,
      'total': total,
      'pct': total > 0 ? ((presenca / total) * 100).round() : 0,
    };
  }

  // Get frequency stats per naipe
  Map<String, Map<String, int>> get _naipeStats {
    final result = <String, Map<String, int>>{};
    for (final naipe in ['Soprano', 'Contralto', 'Tenor', 'Baixo']) {
      final pessoas = mockPessoas.where(
        (p) => p.tipoPadrao == TipoPessoa.coralista && _classifLabel(p.classificacaoVocal) == naipe,
      );
      int totalPresenca = 0, totalFalta = 0, totalFJ = 0, totalAll = 0;
      for (var p in pessoas) {
        final stats = _getFreqStats(p.id);
        totalPresenca += stats['presenca']!;
        totalFalta += stats['falta']!;
        totalFJ += stats['fj']!;
        totalAll += stats['total']!;
      }
      result[naipe] = {
        'presenca': totalPresenca,
        'falta': totalFalta,
        'fj': totalFJ,
        'total': totalAll,
        'pct': totalAll > 0 ? ((totalPresenca / totalAll) * 100).round() : 0,
        'membros': pessoas.length,
      };
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Dashboard',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Visão Geral'),
            Tab(text: 'Coralistas'),
            Tab(text: 'Naipes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeralTab(),
          _buildCoralistasTab(),
          _buildNaipesTab(),
        ],
      ),
    );
  }

  // ============================
  //  TAB 1: Visão Geral
  // ============================
  Widget _buildGeralTab() {
    final totalFreqs = mockFrequencias.length;
    final presentes = mockFrequencias.where((f) => f.status == StatusFrequencia.presenca || f.status == StatusFrequencia.atraso).length;
    final faltas = mockFrequencias.where((f) => f.status == StatusFrequencia.falta).length;
    final fjs = mockFrequencias.where((f) => f.status == StatusFrequencia.faltaJustificada).length;

    final pctPresenca = totalFreqs > 0 ? (presentes / totalFreqs * 100) : 0.0;
    final pctFalta = totalFreqs > 0 ? (faltas / totalFreqs * 100) : 0.0;
    final pctFJ = totalFreqs > 0 ? (fjs / totalFreqs * 100) : 0.0;

    final coralistas = mockPessoas.where((p) => p.tipoPadrao == TipoPessoa.coralista).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Coralistas', value: '$coralistas', icon: Icons.people_outline, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Eventos', value: '${mockEventos.length}', icon: Icons.event_outlined, color: AppColors.info)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Presenças', value: '$presentes', icon: Icons.check_circle_outline, color: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Faltas', value: '$faltas', icon: Icons.cancel_outlined, color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 24),

          // Distribuição
          Text(
            'Distribuição de Frequência',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildDistribuicaoChart(pctPresenca, pctFalta, pctFJ),
          const SizedBox(height: 16),
          _buildLegendRow('Presença', pctPresenca, AppColors.success),
          _buildLegendRow('Faltas', pctFalta, AppColors.error),
          _buildLegendRow('Faltas Justif.', pctFJ, AppColors.warning),
          const SizedBox(height: 28),

          // Comparativo por naipe
          Text(
            'Presença por Naipe',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildNaipeBarChart(),
        ],
      ),
    );
  }

  Widget _buildDistribuicaoChart(double presenca, double falta, double fj) {
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              color: AppColors.success,
              value: presenca,
              title: '${presenca.round()}%',
              radius: 40,
              titleStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: AppColors.error,
              value: falta,
              title: '${falta.round()}%',
              radius: 40,
              titleStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: AppColors.warning,
              value: fj,
              title: '${fj.round()}%',
              radius: 40,
              titleStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          Text(
            '${pct.round()}%',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildNaipeBarChart() {
    final stats = _naipeStats;
    final naipes = ['Soprano', 'Contralto', 'Tenor', 'Baixo'];

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()}%',
                  GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < naipes.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        naipes[i],
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}%', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.cardBorder, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: naipes.asMap().entries.map((e) {
            final idx = e.key;
            final naipe = e.value;
            final pct = (stats[naipe]?['pct'] ?? 0).toDouble();
            final color = _naipeColors[naipe] ?? AppColors.primary;
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: pct,
                  color: color,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: AppColors.cardBorder.withAlpha(50),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================
  //  TAB 2: Coralistas
  // ============================
  Widget _buildCoralistasTab() {
    final coralistas = _coralistas;
    // Sort by presença
    coralistas.sort((a, b) {
      final sa = _getFreqStats(a.id)['pct']!;
      final sb = _getFreqStats(b.id)['pct']!;
      return sb.compareTo(sa);
    });

    return Column(
      children: [
        // Filtro por naipe
        _buildNaipeFilter(),

        // Lista
        Expanded(
          child: coralistas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_outlined, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum coralista encontrado',
                        style: GoogleFonts.inter(fontSize: 15, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: coralistas.length,
                  itemBuilder: (context, index) {
                    final p = coralistas[index];
                    return _buildCoralistaCard(p);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNaipeFilter() {
    final naipes = ['Todos', 'Soprano', 'Contralto', 'Tenor', 'Baixo'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: naipes.map((naipe) {
            final isAll = naipe == 'Todos';
            final isSelected = isAll ? _filtroNaipe == null : _filtroNaipe == naipe;
            final color = isAll ? AppColors.primary : (_naipeColors[naipe] ?? AppColors.primary);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _filtroNaipe = isAll ? null : naipe;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(20) : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : AppColors.cardBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    naipe,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCoralistaCard(Pessoa pessoa) {
    final stats = _getFreqStats(pessoa.id);
    final pct = stats['pct']!;
    final presenca = stats['presenca']!;
    final falta = stats['falta']!;
    final fj = stats['fj']!;
    final total = stats['total']!;
    final naipeLabel = _classifLabel(pessoa.classificacaoVocal);
    final naipeColor = _classifColor(pessoa.classificacaoVocal);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: naipeColor.withAlpha(20),
                child: Text(
                  pessoa.nome[0],
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: naipeColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pessoa.nome,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: naipeColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        naipeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: naipeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Porcentagem
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _pctColor(pct).withAlpha(15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pct%',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _pctColor(pct),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? presenca / total : 0,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(_pctColor(pct)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),

          // Detalhes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Presença', '$presenca', AppColors.success),
              _buildMiniStat('Faltas', '$falta', AppColors.error),
              _buildMiniStat('FJ', '$fj', AppColors.warning),
              _buildMiniStat('Total', '$total', AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Color _pctColor(int pct) {
    if (pct >= 80) return AppColors.success;
    if (pct >= 60) return AppColors.warning;
    return AppColors.error;
  }

  // ============================
  //  TAB 3: Naipes
  // ============================
  Widget _buildNaipesTab() {
    final stats = _naipeStats;
    final naipes = ['Soprano', 'Contralto', 'Tenor', 'Baixo'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparativo por Naipe',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),

          ...naipes.map((naipe) {
            final s = stats[naipe]!;
            final color = _naipeColors[naipe]!;
            final pct = s['pct']!;
            final membros = s['membros']!;
            final presenca = s['presenca']!;
            final falta = s['falta']!;
            final fj = s['fj']!;
            final total = s['total']!;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.group_outlined, color: color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              naipe,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            Text(
                              '$membros membro${membros > 1 ? 's' : ''}',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _pctColor(pct).withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$pct%',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _pctColor(pct),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? presenca / total : 0,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('Presenças', '$presenca', AppColors.success),
                      _buildMiniStat('Faltas', '$falta', AppColors.error),
                      _buildMiniStat('FJ', '$fj', AppColors.warning),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: AppColors.cardBorder,
                  ),
                  const SizedBox(height: 12),

                  // Members list
                  Text(
                    'Membros',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  ...mockPessoas
                      .where((p) =>
                          p.tipoPadrao == TipoPessoa.coralista &&
                          _classifLabel(p.classificacaoVocal) == naipe)
                      .map((p) {
                    final ps = _getFreqStats(p.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color.withAlpha(12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                p.nome[0],
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              p.nome,
                              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                            ),
                          ),
                          Text(
                            '${ps['pct']}%',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _pctColor(ps['pct']!),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
